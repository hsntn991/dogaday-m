begin;

alter table public.place_submissions
  add column if not exists client_reference text,
  add column if not exists main_category text,
  add column if not exists subtype text,
  add column if not exists facilities jsonb not null default '{}'::jsonb;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_client_reference_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_client_reference_check
      check (
        client_reference is null
        or char_length(client_reference) between 3 and 120
      );
  end if;
end $$;

create unique index if not exists place_submissions_owner_reference_idx
  on public.place_submissions (submitted_by, client_reference)
  where client_reference is not null;

alter table public.categories enable row level security;
alter table public.places enable row level security;
alter table public.place_facilities enable row level security;
alter table public.app_user_roles enable row level security;
alter table public.place_submissions enable row level security;
alter table public.moderation_audit_logs enable row level security;

drop policy if exists "Categories are publicly readable" on public.categories;
create policy "Categories are publicly readable"
on public.categories for select
to anon, authenticated
using (true);

revoke insert, update, delete on public.categories from anon, authenticated;
revoke insert, update, delete on public.places from anon, authenticated;
revoke insert, update, delete on public.place_facilities
  from anon, authenticated;
grant select on public.categories, public.places, public.place_facilities
  to anon, authenticated;
grant select, insert on public.place_submissions to authenticated;

create or replace function public.guard_place_submission()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_content text;
  v_recent_hour integer;
  v_recent_day integer;
begin
  if auth.uid() is null or new.submitted_by <> auth.uid() then
    raise exception 'authenticated submission owner required';
  end if;

  select count(*) into v_recent_hour
  from public.place_submissions
  where submitted_by = auth.uid()
    and created_at >= now() - interval '1 hour';
  select count(*) into v_recent_day
  from public.place_submissions
  where submitted_by = auth.uid()
    and created_at >= now() - interval '1 day';

  if v_recent_hour >= 10 or v_recent_day >= 30 then
    raise exception 'submission rate limit exceeded';
  end if;

  v_content := lower(
    translate(
      coalesce(new.name, '') || ' ' || coalesce(new.description, ''),
      'çğıöşüÇĞİÖŞÜ',
      'cgiosuCGIOSU'
    )
  );
  if v_content ~ '(orospu|siktir|sikik|yarrak|amk|aq\y)' then
    raise exception 'submission contains blocked language';
  end if;

  new.content_flags := '[]'::jsonb;
  if v_content ~ '(cumhurbaskani|basbakan|milletvekili|siyasi parti|parti lideri|genel baskan)' then
    new.content_flags := new.content_flags || '["political_reference"]'::jsonb;
  end if;
  return new;
end;
$$;

drop trigger if exists guard_place_submission_trigger
  on public.place_submissions;
create trigger guard_place_submission_trigger
before insert on public.place_submissions
for each row execute function public.guard_place_submission();

revoke all on function public.guard_place_submission() from public;
revoke all on function public.guard_place_submission() from anon, authenticated;

drop policy if exists "Users delete their own submission photos"
  on storage.objects;
create policy "Users delete their own submission photos"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'place-submissions'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users upload their own submission photos"
  on storage.objects;
create policy "Users upload their own submission photos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'place-submissions'
  and (storage.foldername(name))[1] = auth.uid()::text
  and coalesce((storage.foldername(name))[2], '')
    ~ '^[0-9a-fA-F-]{36}$'
  and exists (
    select 1
    from public.place_submissions submission
    where submission.id::text = (storage.foldername(name))[2]
      and submission.submitted_by = auth.uid()
      and submission.status in ('pending', 'changes_requested')
  )
);

drop policy if exists "Users update their own submission photos"
  on storage.objects;
create policy "Users update their own submission photos"
on storage.objects for update
to authenticated
using (
  bucket_id = 'place-submissions'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'place-submissions'
  and (storage.foldername(name))[1] = auth.uid()::text
);

update storage.buckets
set allowed_mime_types = array[
  'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'
]
where id = 'place-submissions';

create or replace function public.attach_submission_photo(
  p_submission_id uuid,
  p_path text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.place_submissions;
begin
  select * into v_submission
  from public.place_submissions
  where id = p_submission_id
  for update;

  if not found or v_submission.submitted_by <> auth.uid() then
    raise exception 'submission owner required';
  end if;
  if v_submission.status not in ('pending', 'changes_requested') then
    raise exception 'submission is not editable';
  end if;
  if p_path not like (auth.uid()::text || '/%/%') then
    raise exception 'invalid photo path';
  end if;
  if cardinality(v_submission.photo_paths) >= 5 then
    raise exception 'photo limit exceeded';
  end if;

  update public.place_submissions
  set photo_paths = case
        when p_path = any(photo_paths) then photo_paths
        else array_append(photo_paths, p_path)
      end,
      updated_at = now()
  where id = p_submission_id;
end;
$$;

revoke all on function public.attach_submission_photo(uuid, text) from public;
revoke all on function public.attach_submission_photo(uuid, text) from anon;
grant execute on function public.attach_submission_photo(uuid, text)
  to authenticated;

create or replace function public.approve_place_submission(
  p_submission_id uuid,
  p_note text default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.place_submissions;
  v_place_id bigint;
  v_slug text;
begin
  if not public.is_place_moderator() then
    raise exception 'moderator permission required';
  end if;

  select * into v_submission
  from public.place_submissions
  where id = p_submission_id
  for update;

  if not found then raise exception 'submission not found'; end if;
  if v_submission.status not in ('pending', 'changes_requested') then
    raise exception 'submission is already finalized';
  end if;

  v_slug := 'community-' || replace(v_submission.id::text, '-', '');

  insert into public.places (
    category_id, name, slug, short_description, description,
    city, district, address, latitude, longitude,
    is_verified, last_verified_at, is_active,
    main_category, subtype, verification_level, publish_status
  ) values (
    v_submission.category_id,
    btrim(v_submission.name),
    v_slug,
    left(btrim(v_submission.description), 180),
    btrim(v_submission.description),
    btrim(v_submission.city),
    nullif(btrim(v_submission.district), ''),
    nullif(btrim(v_submission.location_label), ''),
    v_submission.latitude,
    v_submission.longitude,
    true,
    now(),
    true,
    v_submission.main_category,
    v_submission.subtype,
    'community',
    'publish'
  ) returning id into v_place_id;

  if v_submission.facilities <> '{}'::jsonb then
    insert into public.place_facilities (
      place_id, toilets, drinking_water, parking, shower, electricity,
      picnic_allowed, picnic_facility, picnic_table_nearby, bbq_allowed,
      bbq_facility, open_fire_allowed, firepit_facility, tents, caravans,
      dump_station
    ) values (
      v_place_id,
      (v_submission.facilities->>'toilets')::boolean,
      (v_submission.facilities->>'drinking_water')::boolean,
      (v_submission.facilities->>'parking')::boolean,
      (v_submission.facilities->>'shower')::boolean,
      (v_submission.facilities->>'electricity')::boolean,
      (v_submission.facilities->>'picnic_allowed')::boolean,
      (v_submission.facilities->>'picnic_facility')::boolean,
      (v_submission.facilities->>'picnic_table_nearby')::boolean,
      (v_submission.facilities->>'bbq_allowed')::boolean,
      (v_submission.facilities->>'bbq_facility')::boolean,
      (v_submission.facilities->>'open_fire_allowed')::boolean,
      (v_submission.facilities->>'firepit_facility')::boolean,
      (v_submission.facilities->>'tents')::boolean,
      (v_submission.facilities->>'caravans')::boolean,
      (v_submission.facilities->>'dump_station')::boolean
    );
  end if;

  update public.place_submissions
  set status = 'approved',
      published_place_id = v_place_id,
      moderator_note = nullif(btrim(p_note), ''),
      moderated_by = auth.uid(),
      moderated_at = now(),
      updated_at = now()
  where id = p_submission_id;

  insert into public.moderation_audit_logs (
    submission_id, actor_id, action, previous_status, new_status, note
  ) values (
    p_submission_id, auth.uid(), 'approve', v_submission.status, 'approved',
    nullif(btrim(p_note), '')
  );

  return v_place_id;
end;
$$;

revoke all on function public.approve_place_submission(uuid, text) from public;
revoke all on function public.approve_place_submission(uuid, text) from anon;
revoke all on function public.review_place_submission(
  uuid, public.place_submission_status, text
) from anon;
revoke all on function public.is_place_moderator() from anon;
grant execute on function public.approve_place_submission(uuid, text)
  to authenticated;

do $$
declare
  v_missing_rls text;
begin
  select string_agg(c.relname, ', ')
  into v_missing_rls
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relname in (
      'categories', 'places', 'place_facilities', 'app_user_roles',
      'place_submissions', 'moderation_audit_logs'
    )
    and not c.relrowsecurity;

  if v_missing_rls is not null then
    raise exception 'RLS is disabled for: %', v_missing_rls;
  end if;
  if has_function_privilege(
    'anon', 'public.approve_place_submission(uuid,text)', 'EXECUTE'
  ) then
    raise exception 'anon must not execute approve_place_submission';
  end if;
end;
$$;

commit;
