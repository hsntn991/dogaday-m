begin;

-- Existing places receive photos through a separate queue: approving a photo
-- must never create a duplicate place record.
create table if not exists public.place_photo_submissions (
  id uuid primary key default gen_random_uuid(),
  place_key text not null check (char_length(btrim(place_key)) between 2 and 160),
  place_name text not null check (char_length(btrim(place_name)) between 2 and 160),
  place_location text,
  photo_path text,
  submitted_by uuid not null references auth.users(id) on delete cascade,
  submitter_name text,
  submitter_email text,
  status public.place_submission_status not null default 'pending',
  moderator_note text,
  moderated_by uuid references auth.users(id) on delete set null,
  moderated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists place_photo_submissions_status_created_idx
  on public.place_photo_submissions (status, created_at desc);
create index if not exists place_photo_submissions_place_key_status_idx
  on public.place_photo_submissions (place_key, status);

create or replace function public.guard_place_photo_submission()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_email text;
  v_name text;
begin
  if auth.uid() is null then
    raise exception 'authenticated user required';
  end if;
  new.submitted_by := auth.uid();
  select email,
         coalesce(
           nullif(trim(raw_user_meta_data ->> 'full_name'), ''),
           nullif(trim(raw_user_meta_data ->> 'name'), ''),
           nullif(split_part(email, '@', 1), ''),
           'Doğadayım kullanıcısı'
         )
    into v_email, v_name
    from auth.users
   where id = auth.uid();
  new.submitter_email := v_email;
  new.submitter_name := v_name;
  new.status := 'pending';
  new.photo_path := null;
  new.moderator_note := null;
  new.moderated_by := null;
  new.moderated_at := null;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists guard_place_photo_submission_trigger
  on public.place_photo_submissions;
create trigger guard_place_photo_submission_trigger
before insert on public.place_photo_submissions
for each row execute function public.guard_place_photo_submission();

alter table public.place_photo_submissions enable row level security;

drop policy if exists "Public reads approved community photos" on public.place_photo_submissions;
create policy "Public reads approved community photos"
on public.place_photo_submissions for select
to anon, authenticated
using (
  status = 'approved'
  or submitted_by = (select auth.uid())
  or public.is_place_moderator()
);

drop policy if exists "Authenticated users submit community photos" on public.place_photo_submissions;
create policy "Authenticated users submit community photos"
on public.place_photo_submissions for insert
to authenticated
with check (submitted_by = (select auth.uid()) and status = 'pending');

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'community-photos',
  'community-photos',
  false,
  8388608,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users upload own community photos" on storage.objects;
create policy "Users upload own community photos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'community-photos'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce((storage.foldername(name))[2], '') ~ '^[0-9a-fA-F-]{36}$'
  and exists (
    select 1
    from public.place_photo_submissions submission
    where submission.id::text = (storage.foldername(name))[2]
      and submission.submitted_by = (select auth.uid())
      and submission.status in ('pending', 'changes_requested')
  )
);

drop policy if exists "Approved community photos are readable" on storage.objects;
create policy "Approved community photos are readable"
on storage.objects for select
to anon, authenticated
using (
  bucket_id = 'community-photos'
  and exists (
    select 1
    from public.place_photo_submissions submission
    where submission.id::text = (storage.foldername(name))[2]
      and (
        submission.status = 'approved'
        or submission.submitted_by = (select auth.uid())
        or public.is_place_moderator()
      )
  )
);

create or replace function public.attach_community_photo(
  p_submission_id uuid,
  p_path text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.place_photo_submissions
     set photo_path = p_path,
         updated_at = now()
   where id = p_submission_id
     and submitted_by = auth.uid()
     and status in ('pending', 'changes_requested')
     and p_path like (auth.uid()::text || '/' || p_submission_id::text || '/%');
  if not found then
    raise exception 'photo submission owner required';
  end if;
end;
$$;

create or replace function public.approve_community_photo_submission(
  p_submission_id uuid,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.place_photo_submissions;
begin
  if not public.is_place_moderator() then
    raise exception 'moderator permission required';
  end if;
  select * into v_submission
    from public.place_photo_submissions
   where id = p_submission_id
   for update;
  if not found or v_submission.status not in ('pending', 'changes_requested')
     or v_submission.photo_path is null then
    raise exception 'photo submission is not ready for approval';
  end if;
  update public.place_photo_submissions
     set status = 'approved', moderator_note = nullif(btrim(p_note), ''),
         moderated_by = auth.uid(), moderated_at = now(), updated_at = now()
   where id = p_submission_id;
  insert into public.user_notifications (user_id, type, title, body)
  values (
    v_submission.submitted_by,
    'photo_approved',
    'Fotoğraf katkın onaylandı',
    v_submission.place_name || ' için gönderdiğin fotoğraf yayınlandı.'
  );
end;
$$;

create or replace function public.review_community_photo_submission(
  p_submission_id uuid,
  p_decision public.place_submission_status,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.place_photo_submissions;
  v_title text;
begin
  if not public.is_place_moderator() then
    raise exception 'moderator permission required';
  end if;
  if p_decision not in ('changes_requested', 'rejected') then
    raise exception 'invalid photo decision';
  end if;
  select * into v_submission
    from public.place_photo_submissions
   where id = p_submission_id
   for update;
  if not found or v_submission.status not in ('pending', 'changes_requested') then
    raise exception 'photo submission is already finalized';
  end if;
  update public.place_photo_submissions
     set status = p_decision, moderator_note = nullif(btrim(p_note), ''),
         moderated_by = auth.uid(), moderated_at = now(), updated_at = now()
   where id = p_submission_id;
  v_title := case when p_decision = 'changes_requested'
    then 'Fotoğraf katkın için düzeltme istendi'
    else 'Fotoğraf katkın yayınlanamadı' end;
  insert into public.user_notifications (user_id, type, title, body)
  values (
    v_submission.submitted_by,
    case when p_decision = 'changes_requested' then 'photo_changes_requested' else 'photo_rejected' end,
    v_title,
    coalesce(nullif(btrim(p_note), ''), v_submission.place_name || ' için gönderdiğin fotoğraf incelenemedi.')
  );
end;
$$;

revoke all on function public.attach_community_photo(uuid, text) from public, anon;
revoke all on function public.approve_community_photo_submission(uuid, text) from public, anon;
revoke all on function public.review_community_photo_submission(uuid, public.place_submission_status, text) from public, anon;
grant execute on function public.attach_community_photo(uuid, text) to authenticated;
grant execute on function public.approve_community_photo_submission(uuid, text) to authenticated;
grant execute on function public.review_community_photo_submission(uuid, public.place_submission_status, text) to authenticated;

commit;
