begin;

-- Reversible, map-only viewport endpoint. It does not alter or delete any
-- existing place or amenity; removing this function returns the app to its
-- previous full-list behaviour.
create index if not exists places_viewport_active_idx
  on public.places (latitude, longitude)
  where is_active = true
    and is_verified = true
    and publish_status = 'publish'
    and clean_type is not null;

create index if not exists amenities_viewport_idx
  on public.amenities (latitude, longitude, subtype);

create or replace function public.map_points_in_bbox(
  p_min_lat double precision,
  p_max_lat double precision,
  p_min_lng double precision,
  p_max_lng double precision,
  p_zoom_level integer,
  p_filter_types text[] default null
)
returns table (
  source_kind text,
  id bigint,
  name text,
  latitude double precision,
  longitude double precision,
  city text,
  district text,
  main_category text,
  subtype text,
  is_amenity boolean
)
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
begin
  if p_min_lat is null or p_max_lat is null
    or p_min_lng is null or p_max_lng is null
    or p_min_lat < -90 or p_max_lat > 90
    or p_min_lng < -180 or p_max_lng > 180
    or p_min_lat >= p_max_lat or p_min_lng >= p_max_lng
    or p_zoom_level not between 4 and 18
    or p_max_lat - p_min_lat > 40
    or p_max_lng - p_min_lng > 60 then
    raise exception 'invalid map viewport request';
  end if;

  return query
  with primary_points as (
    select
      'place'::text as source_kind,
      place.id,
      coalesce(nullif(place.name_tr, ''), place.name) as name,
      place.latitude,
      place.longitude,
      place.city,
      place.district,
      place.clean_type as main_category,
      place.clean_type as subtype,
      false as is_amenity,
      0 as priority
    from public.places as place
    where place.is_active = true
      and place.is_verified = true
      and place.publish_status = 'publish'
      and place.clean_type is not null
      and place.latitude between p_min_lat and p_max_lat
      and place.longitude between p_min_lng and p_max_lng
      and (
        p_filter_types is null
        or place.clean_type = any(p_filter_types)
      )
    order by place.name, place.id
    limit 200
  ),

  auxiliary_points as (
    select
      'amenity'::text as source_kind,
      amenity.id,
      amenity.name,
      amenity.latitude,
      amenity.longitude,
      amenity.city,
      amenity.district,
      null::text as main_category,
      amenity.subtype,
      true as is_amenity,
      1 as priority
    from public.amenities as amenity
    where p_zoom_level >= 9
      and amenity.latitude between p_min_lat and p_max_lat
      and amenity.longitude between p_min_lng and p_max_lng
      and (
        p_filter_types is null
        or amenity.subtype = any(p_filter_types)
      )
    order by amenity.name, amenity.id
    limit 100
  )

  select
    points.source_kind,
    points.id,
    points.name,
    points.latitude,
    points.longitude,
    points.city,
    points.district,
    points.main_category,
    points.subtype,
    points.is_amenity
  from (
    select * from primary_points
    union all
    select * from auxiliary_points
  ) as points
  order by points.priority, points.name, points.id
  limit 300;
end;
$$;

revoke all on function public.map_points_in_bbox(
  double precision, double precision, double precision, double precision,
  integer, text[]
) from public;
grant execute on function public.map_points_in_bbox(
  double precision, double precision, double precision, double precision,
  integer, text[]
) to anon, authenticated;

commit;
