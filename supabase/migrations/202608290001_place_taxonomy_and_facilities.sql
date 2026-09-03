begin;

alter table public.places
  add column if not exists main_category text,
  add column if not exists subtype text,
  add column if not exists name_tr text,
  add column if not exists alternate_names text[] not null default '{}',
  add column if not exists verification_level text not null default 'unverified',
  add column if not exists publish_status text not null default 'review',
  add column if not exists review_reasons text[] not null default '{}';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'places_main_category_check'
  ) then
    alter table public.places add constraint places_main_category_check
      check (
        main_category is null or main_category in (
          'water', 'mountain_terrain', 'natural_formation', 'nature_area',
          'camp_caravan', 'route_activity', 'discovery_point', 'wildlife'
        )
      ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'places_verification_level_check'
  ) then
    alter table public.places add constraint places_verification_level_check
      check (verification_level in ('verified', 'community', 'unverified'))
      not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'places_publish_status_check'
  ) then
    alter table public.places add constraint places_publish_status_check
      check (publish_status in ('publish', 'review', 'hold', 'exclude'))
      not valid;
  end if;
end $$;

create index if not exists places_taxonomy_idx
  on public.places (main_category, subtype)
  where is_active = true;
create index if not exists places_publish_status_idx
  on public.places (publish_status, updated_at desc);

update public.places p
set
  main_category = case c.name
    when 'Şelale' then 'water'
    when 'Mağara' then 'natural_formation'
    when 'Göl' then 'water'
    when 'Kanyon' then 'natural_formation'
    when 'Kamp Alanı' then 'camp_caravan'
    when 'Yürüyüş Rotası' then 'route_activity'
    when 'Milli Park' then 'nature_area'
    when 'Tabiat Parkı' then 'nature_area'
    when 'Yayla' then 'mountain_terrain'
    when 'Seyir Noktası' then 'discovery_point'
    when 'Koy ve Plaj' then null
    when 'Piknik Alanı' then 'nature_area'
    when 'Su Kaynağı' then 'water'
    when 'Karavan Alanı' then 'camp_caravan'
    when 'WC' then null
    when 'İçme Suyu' then null
    else p.main_category
  end,
  subtype = case c.name
    when 'Şelale' then 'waterfall'
    when 'Mağara' then 'cave'
    when 'Göl' then 'lake'
    when 'Kanyon' then 'canyon'
    when 'Kamp Alanı' then 'camp_site'
    when 'Yürüyüş Rotası' then 'hiking'
    when 'Milli Park' then 'national_park'
    when 'Tabiat Parkı' then 'nature_park'
    when 'Yayla' then 'plateau'
    when 'Seyir Noktası' then 'viewpoint'
    when 'Koy ve Plaj' then null
    when 'Piknik Alanı' then 'picnic_area'
    when 'Su Kaynağı' then 'spring'
    when 'Karavan Alanı' then 'caravan_site'
    when 'WC' then 'toilet'
    when 'İçme Suyu' then 'drinking_water'
    else p.subtype
  end,
  verification_level = case
    when p.is_verified then 'verified'
    else 'unverified'
  end,
  publish_status = case
    when p.is_active and p.is_verified then 'publish'
    when not p.is_active then 'hold'
    else 'review'
  end,
  name_tr = case
    when regexp_replace(
      p.name,
      '[[:space:][:digit:][:punct:]A-Za-zÀ-ɏ]',
      '',
      'g'
    ) = '' then p.name
    else p.name_tr
  end,
  review_reasons = case
    when regexp_replace(
      p.name,
      '[[:space:][:digit:][:punct:]A-Za-zÀ-ɏ]',
      '',
      'g'
    ) <> '' and not ('non_latin_name' = any(p.review_reasons))
      then array_append(p.review_reasons, 'non_latin_name')
    else p.review_reasons
  end
from public.categories c
where c.id = p.category_id;

update public.places
set publish_status = 'review'
where 'non_latin_name' = any(review_reasons)
  and publish_status = 'publish';

update public.places p
set
  review_reasons = case
    when not ('unmapped_legacy_category' = any(p.review_reasons))
      then array_append(p.review_reasons, 'unmapped_legacy_category')
    else p.review_reasons
  end
from public.categories c
where c.id = p.category_id
  and c.name = 'Koy ve Plaj';

drop policy if exists "Verified active places are publicly readable"
  on public.places;
create policy "Verified active places are publicly readable"
on public.places for select
to anon, authenticated
using (
  is_active = true
  and is_verified = true
  and publish_status = 'publish'
);

create table if not exists public.place_facilities (
  place_id bigint primary key references public.places(id) on delete cascade,
  toilets boolean,
  drinking_water boolean,
  parking boolean,
  shower boolean,
  electricity boolean,
  picnic_allowed boolean,
  picnic_facility boolean,
  picnic_table_nearby boolean,
  bbq_allowed boolean,
  bbq_facility boolean,
  open_fire_allowed boolean,
  firepit_facility boolean,
  tents boolean,
  caravans boolean,
  dump_station boolean,
  nearby_toilets boolean,
  nearby_toilets_distance_m integer check (nearby_toilets_distance_m >= 0),
  nearby_drinking_water boolean,
  nearby_drinking_water_distance_m integer
    check (nearby_drinking_water_distance_m >= 0),
  nearby_parking boolean,
  nearby_parking_distance_m integer check (nearby_parking_distance_m >= 0),
  nearby_shower boolean,
  nearby_shower_distance_m integer check (nearby_shower_distance_m >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.place_facilities enable row level security;

drop policy if exists "Published place facilities are publicly readable"
  on public.place_facilities;
create policy "Published place facilities are publicly readable"
on public.place_facilities for select
to anon, authenticated
using (
  exists (
    select 1 from public.places p
    where p.id = place_facilities.place_id
      and p.is_active = true
      and p.is_verified = true
      and p.publish_status = 'publish'
  )
);

alter table public.places validate constraint places_main_category_check;
alter table public.places validate constraint places_verification_level_check;
alter table public.places validate constraint places_publish_status_check;

commit;
