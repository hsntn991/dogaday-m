-- Curated imports may include a public HTTPS hero image for a place card.
-- The statements remain safe when the dashboard migration has already run.
alter table public.places add column if not exists image_url text;

alter table public.places drop constraint if exists places_image_url_https_check;
alter table public.places add constraint places_image_url_https_check
  check (image_url is null or image_url ~ '^https://') not valid;
