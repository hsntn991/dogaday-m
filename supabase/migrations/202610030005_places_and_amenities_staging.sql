begin;

-- This migration is additive. It does not delete, overwrite or publish any
-- current place. CSV rows are first imported into the two staging tables
-- below, then reviewed before a separate, explicit promotion operation.

create extension if not exists postgis with schema extensions;

alter table public.places
  add column if not exists clean_type text,
  add column if not exists parent_id bigint,
  add column if not exists source_dataset_id bigint;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'places_clean_type_check'
  ) then
    alter table public.places add constraint places_clean_type_check check (
      clean_type is null or clean_type in (
        'camp', 'caravan', 'lake', 'waterfall', 'canyon_valley', 'cave',
        'national_park'
      )
    ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint where conname = 'places_parent_id_fkey'
  ) then
    alter table public.places add constraint places_parent_id_fkey
      foreign key (parent_id) references public.places(id) on delete set null
      not valid;
  end if;
end;
$$;

create unique index if not exists places_source_dataset_id_unique
  on public.places (source_dataset_id)
  where source_dataset_id is not null;
create index if not exists places_parent_id_idx
  on public.places (parent_id)
  where parent_id is not null;

create table if not exists public.amenities (
  id bigint primary key,
  name text not null,
  subtype text not null check (subtype in (
    'drinking_water', 'water_fountain', 'toilet'
  )),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  city text,
  district text,
  location extensions.geography(Point, 4326) generated always as (
    extensions.st_setsrid(
      extensions.st_makepoint(longitude, latitude), 4326
    )::extensions.geography
  ) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists amenities_location_gix
  on public.amenities using gist (location);
create index if not exists amenities_city_subtype_idx
  on public.amenities (city, subtype);

-- Amenities do not have a public table-read policy. The mobile app receives
-- only nearby, non-coordinate details through the restricted function below.
alter table public.amenities enable row level security;

create or replace function public.nearby_amenities(
  p_latitude double precision,
  p_longitude double precision,
  p_radius_m integer default 2000
)
returns table (
  id bigint,
  name text,
  subtype text,
  distance_m integer
)
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_origin extensions.geography;
begin
  if p_latitude not between -90 and 90
    or p_longitude not between -180 and 180
    or p_radius_m not between 1 and 2000 then
    raise exception 'invalid nearby amenities request';
  end if;

  v_origin := extensions.st_setsrid(
    extensions.st_makepoint(p_longitude, p_latitude), 4326
  )::extensions.geography;

  return query
  select
    amenity.id,
    amenity.name,
    amenity.subtype,
    round(extensions.st_distance(amenity.location, v_origin))::integer
  from public.amenities as amenity
  where extensions.st_dwithin(amenity.location, v_origin, p_radius_m)
  order by extensions.st_distance(amenity.location, v_origin), amenity.id
  limit 50;
end;
$$;

revoke all on function public.nearby_amenities(double precision, double precision, integer)
  from public;
grant execute on function public.nearby_amenities(double precision, double precision, integer)
  to anon, authenticated;

-- Dashboard-only review area. Import the generated CSV previews here first.
create table if not exists public.places_import_staging (
  id bigint primary key,
  name text not null,
  clean_type text not null check (clean_type in (
    'camp', 'caravan', 'lake', 'waterfall', 'canyon_valley', 'cave',
    'national_park'
  )),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  city text,
  district text,
  parent_id bigint,
  imported_at timestamptz not null default now()
);

create table if not exists public.amenities_import_staging (
  id bigint primary key,
  name text not null,
  subtype text not null check (subtype in (
    'drinking_water', 'water_fountain', 'toilet'
  )),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  city text,
  district text,
  imported_at timestamptz not null default now()
);

alter table public.places_import_staging enable row level security;
alter table public.amenities_import_staging enable row level security;

commit;
