begin;

-- İl keşif ekranı yalnız seçilen ilin yayınlanmış noktalarını döndürür.
-- Genel harita fonksiyonundan ayrı tutulur; mevcut harita davranışını değiştirmez.
create or replace function public.province_explorer_points(
  p_city text,
  p_limit integer default 500
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
declare
  v_city text := nullif(btrim(p_city), '');
  v_limit integer := least(greatest(coalesce(p_limit, 500), 1), 750);
begin
  if v_city is null or char_length(v_city) > 80 then
    raise exception 'invalid province request';
  end if;

  return query
  select * from (
    select
      'place'::text,
      place.id,
      coalesce(nullif(place.name_tr, ''), place.name),
      place.latitude,
      place.longitude,
      place.city,
      place.district,
      place.clean_type,
      place.clean_type,
      false as is_amenity
    from public.places as place
    where lower(btrim(place.city)) = lower(v_city)
      and place.is_active = true
      and place.is_verified = true
      and place.publish_status = 'publish'
      and place.clean_type is not null

    union all

    select
      'amenity'::text,
      amenity.id,
      amenity.name,
      amenity.latitude,
      amenity.longitude,
      amenity.city,
      amenity.district,
      null::text,
      amenity.subtype,
      true as is_amenity
    from public.amenities as amenity
    where lower(btrim(amenity.city)) = lower(v_city)
  ) as points
  where points.latitude is not null and points.longitude is not null
  order by points.is_amenity, points.name, points.id
  limit v_limit;
end;
$$;

create or replace function public.province_explorer_summary(p_city text)
returns table (category_key text, point_count bigint, district_count bigint)
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_city text := nullif(btrim(p_city), '');
begin
  if v_city is null or char_length(v_city) > 80 then
    raise exception 'invalid province request';
  end if;

  return query
  with points as (
    select
      place.clean_type as category_key,
      place.district
    from public.places as place
    where lower(btrim(place.city)) = lower(v_city)
      and place.is_active = true
      and place.is_verified = true
      and place.publish_status = 'publish'
      and place.clean_type is not null
    union all
    select
      case
        when amenity.subtype in ('drinking_water', 'water_fountain')
          then 'water_amenities'
        else amenity.subtype
      end,
      amenity.district
    from public.amenities as amenity
    where lower(btrim(amenity.city)) = lower(v_city)
  )
  select
    points.category_key,
    count(*)::bigint,
    count(distinct nullif(btrim(points.district), ''))::bigint
  from points
  where points.category_key is not null
  group by points.category_key
  order by points.category_key;
end;
$$;

revoke all on function public.province_explorer_points(text, integer) from public;
revoke all on function public.province_explorer_summary(text) from public;
grant execute on function public.province_explorer_points(text, integer) to anon, authenticated;
grant execute on function public.province_explorer_summary(text) to anon, authenticated;

commit;
