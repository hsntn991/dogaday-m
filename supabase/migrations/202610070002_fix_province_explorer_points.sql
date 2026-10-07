begin;

-- 202610070001 ilk çalıştırmada UNION alt sorgusunun son alanına ad
-- vermediği için points.is_amenity çözümlenemiyordu. Şema değiştirmeden
-- fonksiyonu düzeltiyoruz.
create or replace function public.province_explorer_points(
  p_city text,
  p_limit integer default 500
)
returns table (
  source_kind text, id bigint, name text, latitude double precision,
  longitude double precision, city text, district text, main_category text,
  subtype text, is_amenity boolean
)
language plpgsql stable security definer
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
      'place'::text as source_kind, place.id,
      coalesce(nullif(place.name_tr, ''), place.name) as name,
      place.latitude, place.longitude, place.city, place.district,
      place.clean_type as main_category, place.clean_type as subtype,
      false as is_amenity
    from public.places as place
    where lower(btrim(place.city)) = lower(v_city)
      and place.is_active = true and place.is_verified = true
      and place.publish_status = 'publish' and place.clean_type is not null
    union all
    select
      'amenity'::text as source_kind, amenity.id, amenity.name,
      amenity.latitude, amenity.longitude, amenity.city, amenity.district,
      null::text as main_category, amenity.subtype, true as is_amenity
    from public.amenities as amenity
    where lower(btrim(amenity.city)) = lower(v_city)
  ) as points
  where points.latitude is not null and points.longitude is not null
  order by points.is_amenity, points.name, points.id
  limit v_limit;
end;
$$;

commit;
