-- Fotoğraf katkısı moderasyonunda kullanıcıya bildirim gönderilir.
-- Önceki tür kısıtı yalnız yer başvurularını kapsadığı için reddet/düzelt
-- akışındaki bildirim kaydı engelleniyordu.
begin;

alter table public.user_notifications
  drop constraint if exists user_notifications_type_check;

alter table public.user_notifications
  add constraint user_notifications_type_check
  check (type in (
    'submission_approved',
    'submission_changes_requested',
    'submission_rejected',
    'photo_approved',
    'photo_changes_requested',
    'photo_rejected'
  ));

commit;
