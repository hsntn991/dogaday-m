begin;

revoke insert, update, delete
on public.app_user_roles
from anon, authenticated;

revoke insert, update, delete
on public.moderation_audit_logs
from anon, authenticated;

commit;
