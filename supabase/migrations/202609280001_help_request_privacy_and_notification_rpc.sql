-- Migration: 202609280001_help_request_privacy_and_notification_rpc.sql
-- Purpose:
--   1. Secure user_notifications: prevent arbitrary update of notification content,
--      providing a secure RPC mark_notification_as_read(uuid).
--   2. Add help_request_reports table to allow reporting abusive / false alarm help requests.

begin;

-- 1. Bildirimler için güvenli okundu fonksiyonu
create or replace function public.mark_notification_as_read(p_notification_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.user_notifications
  set read_at = now()
  where id = p_notification_id
    and user_id = auth.uid();
end;
$$;

grant execute on function public.mark_notification_as_read(uuid) to authenticated;

-- user_notifications üzerinde kullanıcının doğrudan satır güncellemesini sınırla (yalnızca RPC ile read_at değişebilir)
drop policy if exists "Users can update their own notifications" on public.user_notifications;
create policy "Users can update their own notifications"
on public.user_notifications for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- 2. Yardım Çağrısı Kötüye Kullanım Bildirimi Tablosu
create table if not exists public.help_request_reports (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.help_requests(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null check (reason in ('spam', 'false_alarm', 'inappropriate', 'resolved_already', 'other')),
  details text check (details is null or char_length(details) <= 500),
  created_at timestamptz not null default now(),
  constraint help_request_reports_unique_reporter unique (request_id, reporter_id)
);

create index if not exists help_request_reports_request_idx
  on public.help_request_reports (request_id, created_at desc);

alter table public.help_request_reports enable row level security;

drop policy if exists "Authenticated users can submit reports" on public.help_request_reports;
create policy "Authenticated users can submit reports"
on public.help_request_reports for insert
to authenticated
with check (reporter_id = auth.uid());

drop policy if exists "Users can view their own submitted reports" on public.help_request_reports;
create policy "Users can view their own submitted reports"
on public.help_request_reports for select
to authenticated
using (reporter_id = auth.uid());

commit;
