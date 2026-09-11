-- Çeşme kayıtlarını, doğa destinasyonu değil haritada ayrı gösterilen utility
-- türü olarak sınıflandırır. Yayın/aktif/doğrulama durumunu değiştirmez.
begin;

update public.places p
set
  main_category = null,
  subtype = 'water_fountain'
from public.categories c
where c.id = p.category_id
  and lower(c.name) in ('çeşme', 'cesme', 'fountain')
  and p.subtype is distinct from 'water_fountain';

commit;
