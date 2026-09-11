-- KOSKI's Konya fountain inventory is a verified, coordinate-complete
-- utility dataset. Keep it out of discovery destinations while making it
-- available through the dedicated water-fountain map layer.
begin;

update public.places
set
  main_category = null,
  subtype = 'water_fountain',
  verification_level = 'verified',
  is_verified = true,
  publish_status = 'publish'
where lower(coalesce(city, '')) = 'konya'
  and is_active = true
  and subtype = 'spring'
  and coalesce(short_description, '') ilike 'KOSKI%'
  and latitude is not null
  and longitude is not null;

commit;
