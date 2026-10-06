begin;

-- Mobile service submissions are first-class moderation submissions. The
-- earlier taxonomy allowlists predate this category, so valid business
-- registrations were rejected before they could reach the admin queue.
alter table public.place_submissions
  drop constraint if exists place_submissions_main_category_check;
alter table public.place_submissions
  add constraint place_submissions_main_category_check
  check (
    main_category is null or main_category in (
      'water', 'mountain_terrain', 'natural_formation', 'nature_area',
      'camp_caravan', 'route_activity', 'discovery_point', 'wildlife',
      'local_service'
    )
  );

-- The approved place must retain the same taxonomy as the reviewed
-- submission. This also allows the map to identify a published business as
-- a mobile service.
alter table public.places
  drop constraint if exists places_main_category_check;
alter table public.places
  add constraint places_main_category_check
  check (
    main_category is null or main_category in (
      'water', 'mountain_terrain', 'natural_formation', 'nature_area',
      'camp_caravan', 'route_activity', 'discovery_point', 'wildlife',
      'local_service'
    )
  );

-- Author identity is never accepted from a client payload. It is derived
-- from the authenticated request and recorded for the moderation screen.
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
  if auth.uid() is null then
    raise exception 'authenticated submission owner required';
  end if;

  new.submitted_by := auth.uid();

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
  new.author_name := coalesce(
    nullif(trim(coalesce(new.author_name, '')), ''),
    v_name,
    'Doğadayım kullanıcısı'
  );
  return new;
end;
$$;

-- Repair all historic records that can be tied to their authenticated owner.
update public.place_submissions as submission
set
  submitter_name = coalesce(
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'full_name', '')), ''),
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'name', '')), ''),
    nullif(split_part(users.email, '@', 1), ''),
    'Doğadayım kullanıcısı'
  ),
  submitter_email = users.email,
  author_name = coalesce(
    nullif(trim(coalesce(submission.author_name, '')), ''),
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'full_name', '')), ''),
    nullif(trim(coalesce(users.raw_user_meta_data ->> 'name', '')), ''),
    nullif(split_part(users.email, '@', 1), ''),
    'Doğadayım kullanıcısı'
  )
from auth.users as users
where users.id = submission.submitted_by;

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
    main_category, subtype, verification_level, publish_status,
    author_name
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
    'publish',
    coalesce(v_submission.author_name, v_submission.submitter_name, 'Doğadayım kullanıcısı')
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

commit;
