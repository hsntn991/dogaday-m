begin;

-- One-time, in-database recovery point. Existing rows remain recoverable if
-- this data product decision is later reversed.
create table if not exists public.places_pre_cleanup_backup_20261003
  as table public.places with no data;

insert into public.places_pre_cleanup_backup_20261003
select current_place.*
from public.places as current_place
where not exists (
  select 1
  from public.places_pre_cleanup_backup_20261003 as backup
  where backup.id = current_place.id
);

-- The raw import used the same stable IDs as the supplied CSV. Copy utility
-- points first, then leave them out of the map-facing place list.
insert into public.amenities (
  id, name, subtype, latitude, longitude, city, district
)
select
  backup.id,
  backup.name,
  backup.subtype,
  backup.latitude,
  backup.longitude,
  backup.city,
  backup.district
from public.places_pre_cleanup_backup_20261003 as backup
where backup.subtype in ('drinking_water', 'water_fountain', 'toilet')
on conflict (id) do update set
  name = excluded.name,
  subtype = excluded.subtype,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  city = excluded.city,
  district = excluded.district,
  updated_at = now();

update public.places as place
set clean_type = case place.subtype
  when 'camp_site' then 'camp'
  when 'caravan_site' then 'caravan'
  when 'lake' then 'lake'
  when 'waterfall' then 'waterfall'
  when 'canyon' then 'canyon_valley'
  when 'valley' then 'canyon_valley'
  when 'cave' then 'cave'
  when 'national_park' then 'national_park'
  when 'nature_park' then 'national_park'
  else null
end
where exists (
  select 1 from public.places_pre_cleanup_backup_20261003 as backup
  where backup.id = place.id
);

-- Recalculate parent relationships from coordinates. A place is linked only
-- to the closest park in its own city and within 15 km.
with parent_candidates as (
  select
    child.id,
    (
      select park.id
      from public.places as park
      where park.clean_type = 'national_park'
        and park.city is not null
        and lower(park.city) = lower(child.city)
        and extensions.st_dwithin(
          extensions.st_setsrid(
            extensions.st_makepoint(child.longitude, child.latitude), 4326
          )::extensions.geography,
          extensions.st_setsrid(
            extensions.st_makepoint(park.longitude, park.latitude), 4326
          )::extensions.geography,
          15000
        )
      order by extensions.st_distance(
        extensions.st_setsrid(
          extensions.st_makepoint(child.longitude, child.latitude), 4326
        )::extensions.geography,
        extensions.st_setsrid(
          extensions.st_makepoint(park.longitude, park.latitude), 4326
        )::extensions.geography
      )
      limit 1
    ) as parent_id
  from public.places as child
  where child.clean_type in (
    'camp', 'caravan', 'lake', 'waterfall', 'canyon_valley', 'cave'
  )
    and child.city is not null
    and exists (
      select 1 from public.places_pre_cleanup_backup_20261003 as backup
      where backup.id = child.id
    )
)
update public.places as child
set parent_id = candidate.parent_id
from parent_candidates as candidate
where candidate.id = child.id
  and candidate.parent_id is not null;

-- Do not delete rows. They are hidden from the map while staying in the
-- recovery snapshot and source table for a reversible rollout.
update public.places as place
set is_active = false,
    publish_status = 'hold'
where place.clean_type is null
  and exists (
    select 1 from public.places_pre_cleanup_backup_20261003 as backup
    where backup.id = place.id
  );

commit;

select
  (select count(*) from public.places where is_active = true) as active_places,
  (select count(*) from public.amenities) as amenities,
  (select count(*) from public.places where parent_id is not null) as linked_children;
