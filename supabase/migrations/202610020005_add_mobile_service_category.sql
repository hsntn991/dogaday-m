-- Add Mobil Servis & İşletme category to categories table
insert into public.categories (name, slug, description, icon_key, sort_order, is_active)
values (
  'Mobil Servis & İşletme',
  'mobil-servis-isletme',
  'Oto kurtarma, mobil tamir, lastikçi ve karavan teknik servisleri',
  'handyman',
  17,
  true
)
on conflict (slug) do nothing;
