begin;

-- Moderation needs an accountable sender, but the client must never be able to
-- impersonate another account. These fields are always stamped from auth.users.
alter table public.place_submissions
  add column if not exists submitter_name text,
  add column if not exists submitter_email text;

create or replace function public.stamp_place_submission_author()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_name text;
  v_email text;
begin
  select
    coalesce(
      nullif(trim(coalesce(raw_user_meta_data ->> 'full_name', '')), ''),
      nullif(trim(coalesce(raw_user_meta_data ->> 'name', '')), ''),
      nullif(split_part(email, '@', 1), ''),
      'Doğadayım kullanıcısı'
    ),
    email
  into v_name, v_email
  from auth.users
  where id = new.submitted_by;

  new.submitter_name := coalesce(v_name, 'Doğadayım kullanıcısı');
  new.submitter_email := v_email;
  return new;
end;
$$;

drop trigger if exists stamp_place_submission_author_trigger
  on public.place_submissions;
create trigger stamp_place_submission_author_trigger
before insert on public.place_submissions
for each row execute function public.stamp_place_submission_author();

-- Existing submissions get the same safe, server-derived identity.
update public.place_submissions as submission
set
  submitter_name = coalesce(
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'full_name', '')), ''),
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'name', '')), ''),
    nullif(split_part(users.email, '@', 1), ''),
    'Doğadayım kullanıcısı'
  ),
  submitter_email = users.email
from auth.users as users
where users.id = submission.submitted_by
  and (submission.submitter_name is null or submission.submitter_email is null);

create table if not exists public.user_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  submission_id uuid references public.place_submissions(id) on delete cascade,
  type text not null check (type in (
    'submission_approved',
    'submission_changes_requested',
    'submission_rejected'
  )),
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists user_notifications_owner_created_idx
  on public.user_notifications (user_id, created_at desc);

alter table public.user_notifications enable row level security;

drop policy if exists "Users read their own notifications"
  on public.user_notifications;
create policy "Users read their own notifications"
on public.user_notifications for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users mark their own notifications read"
  on public.user_notifications;
create policy "Users mark their own notifications read"
on public.user_notifications for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create or replace function public.create_submission_status_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_title text;
  v_body text;
  v_type text;
begin
  if new.status is not distinct from old.status
      or new.status not in ('approved', 'changes_requested', 'rejected') then
    return new;
  end if;

  if new.status = 'approved' then
    v_type := 'submission_approved';
    v_title := 'Katkın onaylandı';
    v_body := coalesce(new.name, 'Gönderdiğin yer') || ' artık Doğadayım’da yayınlandı.';
  elsif new.status = 'changes_requested' then
    v_type := 'submission_changes_requested';
    v_title := 'Katkın için düzeltme istendi';
    v_body := coalesce(new.moderator_note, 'Gönderdiğin yer için yönetici notunu incele.');
  else
    v_type := 'submission_rejected';
    v_title := 'Katkın yayınlanamadı';
    v_body := coalesce(new.moderator_note, 'Gönderdiğin yer yayın kriterlerini karşılamadı.');
  end if;

  insert into public.user_notifications (
    user_id, submission_id, type, title, body
  ) values (
    new.submitted_by, new.id, v_type, v_title, v_body
  );
  return new;
end;
$$;

drop trigger if exists place_submission_status_notification_trigger
  on public.place_submissions;
create trigger place_submission_status_notification_trigger
after update of status on public.place_submissions
for each row execute function public.create_submission_status_notification();

revoke all on public.user_notifications from anon;
grant select, update on public.user_notifications to authenticated;

commit;
