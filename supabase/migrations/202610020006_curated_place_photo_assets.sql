-- Editöryal olarak eşleştirilmiş yer fotoğrafları için sadece okunabilir alan.
-- Yazma erişimi uygulama kullanıcılarına verilmez; yükleme yönetim işlemiyle yapılır.
begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'place-assets',
  'place-assets',
  true,
  4194304,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public read curated place assets" on storage.objects;
create policy "Public read curated place assets"
on storage.objects for select
to public
using (bucket_id = 'place-assets');

commit;
