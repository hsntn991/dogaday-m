begin;

-- moderation_audit_logs.actor_id foreign key kısıtını ON DELETE SET NULL olarak güncelle.
-- Bu sayede bir yetkili/moderatör hesabı silindiğinde geçmiş denetim kayıtları
-- RESTRICT hatası nedeniyle hesap silmeyi engellemez, anonimleştirilerek korunur.

alter table public.moderation_audit_logs
  alter column actor_id drop not null;

alter table public.moderation_audit_logs
  drop constraint if exists moderation_audit_logs_actor_id_fkey;

alter table public.moderation_audit_logs
  add constraint moderation_audit_logs_actor_id_fkey
  foreign key (actor_id) references auth.users(id) on delete set null;

commit;
