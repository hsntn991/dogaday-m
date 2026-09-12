begin;

-- ============================================================================
-- 1. Helper Function: Array Element Length Validation
-- ============================================================================
-- CHECK constraint'ler içinde alt sorgu (subquery) doğrudan kullanılamadığı için
-- dizi elemanlarının karakter uzunluğunu güvenle denetleyen IMMUTABLE fonksiyon.
create or replace function public.validate_array_element_lengths(
  p_items text[],
  p_max_length integer
)
returns boolean
language sql
immutable
parallel safe
set search_path = pg_catalog, public
as $$
  select not exists (
    select 1
    from unnest(p_items) as item
    where item is not null
      and char_length(item) > p_max_length
  );
$$;

comment on function public.validate_array_element_lengths(text[], integer) is
  'Dizi elemanlarının karakter uzunluğunun belirtilen sınırı aşmadığını doğrular.';

revoke all on function public.validate_array_element_lengths(text[], integer) from public;
revoke all on function public.validate_array_element_lengths(text[], integer) from anon;
grant execute on function public.validate_array_element_lengths(text[], integer) to authenticated;

-- ============================================================================
-- 2. P0: main_category Allowlist Constraint
-- ============================================================================
-- public.places.places_main_category_check ile birebir eşleşen allowlist.
-- NULL değerler geriye dönük uyumluluk için geçerli kabul edilir.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_main_category_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_main_category_check
      check (
        main_category is null or main_category in (
          'water', 'mountain_terrain', 'natural_formation', 'nature_area',
          'camp_caravan', 'route_activity', 'discovery_point', 'wildlife'
        )
      );
  end if;
end $$;

-- ============================================================================
-- 3. P0: facilities JSONB Validation Constraint
-- ============================================================================
-- facilities NULL veya JSON nesnesi olabilir.
-- Yalnızca approve_place_submission() tarafından okunan 15 geçerli tesis anahtarına izin verilir.
-- Değerler yalnızca boolean (true/false) veya null olabilir (string "true", "gecersiz" vb. reddedilir).
-- Helper function gerektirmeden yerel JSONB operatörleri ve SQL/JSON path ile doğrulanır.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_facilities_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_facilities_check
      check (
        facilities is null or (
          jsonb_typeof(facilities) = 'object'
          and (facilities - array[
            'toilets',
            'drinking_water',
            'parking',
            'shower',
            'electricity',
            'picnic_allowed',
            'picnic_facility',
            'picnic_table_nearby',
            'bbq_allowed',
            'bbq_facility',
            'open_fire_allowed',
            'firepit_facility',
            'tents',
            'caravans',
            'dump_station'
          ]) = '{}'::jsonb
          and not jsonb_path_exists(
            facilities,
            '$.* ? (@.type() != "boolean" && @.type() != "null")'
          )
        )
      );
  end if;
end $$;

-- ============================================================================
-- 4. P0: Payload Size Limits Constraints
-- ============================================================================
-- district: NULL veya trimlenmiş uzunluk <= 80
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_district_length_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_district_length_check
      check (
        district is null or char_length(btrim(district)) <= 80
      );
  end if;
end $$;

-- location_label: NULL veya trimlenmiş uzunluk <= 200
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_location_label_length_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_location_label_length_check
      check (
        location_label is null or char_length(btrim(location_label)) <= 200
      );
  end if;
end $$;

-- road_access: NULL veya trimlenmiş uzunluk <= 100
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_road_access_length_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_road_access_length_check
      check (
        road_access is null or char_length(btrim(road_access)) <= 100
      );
  end if;
end $$;

-- environment_tags: cardinality <= 20 ve her eleman <= 80 karakter
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_environment_tags_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_environment_tags_check
      check (
        cardinality(environment_tags) <= 20
        and public.validate_array_element_lengths(environment_tags, 80)
      );
  end if;
end $$;

-- features: cardinality <= 30 ve her eleman <= 120 karakter
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'place_submissions_features_check'
  ) then
    alter table public.place_submissions
      add constraint place_submissions_features_check
      check (
        cardinality(features) <= 30
        and public.validate_array_element_lengths(features, 120)
      );
  end if;
end $$;

commit;
