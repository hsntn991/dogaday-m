-- Sıkılaştırma: Misafir (anon) rolünün yönetim ve başvuru tablolarında hiçbir yetkisinin bulunmamasını garantiye al.
begin;

revoke all on public.place_submissions from anon;
revoke all on public.moderation_audit_logs from anon;
revoke all on public.app_user_roles from anon;

commit;
