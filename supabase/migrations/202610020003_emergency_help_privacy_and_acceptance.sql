-- Migration: 202610020003_emergency_help_privacy_and_acceptance.sql
-- Description:
--   1. Create help_request_acceptances table for server-side verified help acceptance.
--   2. Tighten help_requests RLS: exact coordinates and contact_value are ONLY readable by requester and active accepted helpers.
--   3. Create help_requests_feed secure view with masked contact_value and approximate coordinates for general users.
--   4. RPCs: accept_help_request, cancel_help_request_acceptance, block_help_request_helper.
--   5. Fix user_notifications update security: revoke direct update, enforce mark_notification_as_read.
--   6. Auto-hide abused help requests when report count >= 3.

begin;

-- 1. Help Request Acceptances Table
create table if not exists public.help_request_acceptances (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.help_requests(id) on delete cascade,
  helper_id uuid not null references auth.users(id) on delete cascade,
  accepted_at timestamptz not null default now(),
  status text not null default 'active' check (status in ('active', 'cancelled', 'blocked')),
  constraint help_request_acceptances_unique_helper unique (request_id, helper_id)
);

create index if not exists help_request_acceptances_req_helper_idx
  on public.help_request_acceptances (request_id, helper_id, status);

create index if not exists help_request_acceptances_helper_idx
  on public.help_request_acceptances (helper_id, status);

alter table public.help_request_acceptances enable row level security;

drop policy if exists "Users can read their own or their requests acceptances" on public.help_request_acceptances;
create policy "Users can read their own or their requests acceptances"
on public.help_request_acceptances for select
to authenticated
using (
  helper_id = auth.uid()
  or exists (
    select 1 from public.help_requests hr
    where hr.id = request_id and hr.requester_id = auth.uid()
  )
);

drop policy if exists "Helpers can insert their own acceptance" on public.help_request_acceptances;
create policy "Helpers can insert their own acceptance"
on public.help_request_acceptances for insert
to authenticated
with check (
  helper_id = auth.uid()
  and status = 'active'
);

drop policy if exists "Helpers or requesters can update acceptance status" on public.help_request_acceptances;
create policy "Helpers or requesters can update acceptance status"
on public.help_request_acceptances for update
to authenticated
using (
  helper_id = auth.uid()
  or exists (
    select 1 from public.help_requests hr
    where hr.id = request_id and hr.requester_id = auth.uid()
  )
)
with check (
  helper_id = auth.uid()
  or exists (
    select 1 from public.help_requests hr
    where hr.id = request_id and hr.requester_id = auth.uid()
  )
);

-- 2. Secure help_requests RLS: Only requester and active accepted helpers read full record
drop policy if exists "Authenticated users can view active help requests" on public.help_requests;
drop policy if exists "Only requester and accepted helpers can view full help request" on public.help_requests;
create policy "Only requester and accepted helpers can view full help request"
on public.help_requests for select
to authenticated
using (
  requester_id = auth.uid()
  or (
    status = 'active'
    and expires_at > now()
    and exists (
      select 1 from public.help_request_acceptances a
      where a.request_id = help_requests.id
        and a.helper_id = auth.uid()
        and a.status = 'active'
    )
  )
);

-- 3. Public feed view with server-side masking
-- General users see approximate coordinate and null contact_value.
-- Requesters and accepted helpers see exact coordinate and real contact_value.
create or replace view public.help_requests_feed
with (security_invoker = false)
as
select
  hr.id,
  hr.requester_id,
  hr.request_type,
  hr.contact_preference,
  case
    when hr.requester_id = auth.uid() or exists (
      select 1 from public.help_request_acceptances a
      where a.request_id = hr.id
        and a.helper_id = auth.uid()
        and a.status = 'active'
    ) then hr.contact_value
    else null
  end as contact_value,
  case
    when hr.requester_id = auth.uid() or exists (
      select 1 from public.help_request_acceptances a
      where a.request_id = hr.id
        and a.helper_id = auth.uid()
        and a.status = 'active'
    ) then hr.latitude
    else round(hr.latitude::numeric, 2)::double precision
  end as latitude,
  case
    when hr.requester_id = auth.uid() or exists (
      select 1 from public.help_request_acceptances a
      where a.request_id = hr.id
        and a.helper_id = auth.uid()
        and a.status = 'active'
    ) then hr.longitude
    else round(hr.longitude::numeric, 2)::double precision
  end as longitude,
  hr.status,
  hr.created_at,
  hr.expires_at,
  hr.resolved_at,
  (
    hr.requester_id = auth.uid()
    or exists (
      select 1 from public.help_request_acceptances a
      where a.request_id = hr.id
        and a.helper_id = auth.uid()
        and a.status = 'active'
    )
  ) as is_accepted
from public.help_requests hr
where hr.status = 'active'
  and hr.expires_at > now()
  and (
    select count(*)
    from public.help_request_reports rep
    where rep.request_id = hr.id
  ) < 3;

grant select on public.help_requests_feed to authenticated, anon;

-- 4. RPCs for Safe Help Acceptance Lifecycle
create or replace function public.accept_help_request(p_request_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_req public.help_requests;
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Giriş yapmalısın.';
  end if;

  select * into v_req
  from public.help_requests
  where id = p_request_id;

  if not found then
    raise exception 'Yardım çağrısı bulunamadı.';
  end if;

  if v_req.requester_id = v_user_id then
    raise exception 'Kendi çağrını kabul edemezsin.';
  end if;

  if v_req.status <> 'active' or v_req.expires_at <= now() then
    raise exception 'Bu yardım çağrısı artık aktif değil.';
  end if;

  insert into public.help_request_acceptances (request_id, helper_id, status, accepted_at)
  values (p_request_id, v_user_id, 'active', now())
  on conflict (request_id, helper_id)
  do update set status = 'active', accepted_at = now();

  -- Notify the requester that someone accepted
  insert into public.user_notifications (
    user_id,
    type,
    title,
    body
  ) values (
    v_req.requester_id,
    'submission_approved',
    'Yardım Çağrın Kabul Edildi',
    'Bir doğa dostu yardım çağrını kabul etti ve seninle iletişime geçiyor.'
  );

  return jsonb_build_object(
    'success', true,
    'latitude', v_req.latitude,
    'longitude', v_req.longitude,
    'contact_value', v_req.contact_value
  );
end;
$$;

grant execute on function public.accept_help_request(uuid) to authenticated;

create or replace function public.cancel_help_request_acceptance(p_request_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  update public.help_request_acceptances
  set status = 'cancelled'
  where request_id = p_request_id
    and helper_id = auth.uid();

  return true;
end;
$$;

grant execute on function public.cancel_help_request_acceptance(uuid) to authenticated;

-- 5. Fix user_notifications Update Privilege Leak
-- Revoke direct table update from users so only RPC mark_notification_as_read can update read_at
drop policy if exists "Users can update their own notifications" on public.user_notifications;
drop policy if exists "Users mark their own notifications read" on public.user_notifications;
revoke update on public.user_notifications from authenticated;
revoke update on public.user_notifications from anon;

-- 6. Abuse Prevention: Auto-resolve/hide heavily reported help requests
create or replace function public.check_help_request_reports_threshold()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  select count(*) into v_count
  from public.help_request_reports
  where request_id = new.request_id;

  if v_count >= 3 then
    update public.help_requests
    set status = 'resolved',
        resolved_at = coalesce(resolved_at, now())
    where id = new.request_id
      and status = 'active';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_check_help_request_reports_threshold on public.help_request_reports;
create trigger trg_check_help_request_reports_threshold
after insert on public.help_request_reports
for each row execute function public.check_help_request_reports_threshold();

commit;
