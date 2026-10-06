begin;

-- Kullanıcılar bildirim satırlarını doğrudan değiştiremez. Okundu durumu,
-- sahiplik kontrolü yapan mark_notification_as_read RPC'si üzerinden güncellenir.
drop policy if exists "Users can update their own notifications"
  on public.user_notifications;
drop policy if exists "Users mark their own notifications read"
  on public.user_notifications;
revoke update on public.user_notifications from anon, authenticated;

commit;
