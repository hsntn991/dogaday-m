begin;

create table if not exists public.help_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  request_type text not null check (request_type in (
    'lost', 'vehicle_stuck', 'vehicle_not_working', 'injured'
  )),
  contact_preference text not null check (contact_preference in (
    'location_only', 'contact_details'
  )),
  contact_value text,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  status text not null default 'active' check (status in ('active', 'resolved')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '48 hours'),
  resolved_at timestamptz,
  constraint help_requests_contact_choice_check check (
    (contact_preference = 'location_only' and contact_value is null)
    or (contact_preference = 'contact_details' and char_length(btrim(coalesce(contact_value, ''))) between 3 and 80)
  )
);

create index if not exists help_requests_active_map_idx
  on public.help_requests (status, expires_at, created_at desc);
create index if not exists help_requests_owner_idx
  on public.help_requests (requester_id, created_at desc);
create unique index if not exists help_requests_one_active_per_user_idx
  on public.help_requests (requester_id)
  where status = 'active';

create or replace function public.enforce_help_request_lifecycle()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' then
    if new.requester_id <> old.requester_id then
      raise exception 'requester cannot be changed';
    end if;
    if old.status = 'resolved' and new.status <> 'resolved' then
      raise exception 'resolved help request cannot be reactivated';
    end if;
  end if;

  if new.status = 'active' and (
    new.expires_at < now() + interval '47 hours'
    or new.expires_at > now() + interval '49 hours'
  ) then
    raise exception 'active help request expiry must be approximately 48 hours';
  end if;

  if new.status = 'resolved' and new.resolved_at is null then
    new.resolved_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists enforce_help_request_lifecycle on public.help_requests;
create trigger enforce_help_request_lifecycle
before insert or update on public.help_requests
for each row execute function public.enforce_help_request_lifecycle();

alter table public.help_requests enable row level security;

drop policy if exists "Authenticated users can view active help requests" on public.help_requests;
create policy "Authenticated users can view active help requests"
on public.help_requests for select
to authenticated
using (
  requester_id = auth.uid()
  or (status = 'active' and expires_at > now())
);

drop policy if exists "Users can create their own help request" on public.help_requests;
create policy "Users can create their own help request"
on public.help_requests for insert
to authenticated
with check (
  requester_id = auth.uid()
  and status = 'active'
  and expires_at between now() + interval '47 hours' and now() + interval '49 hours'
  and resolved_at is null
);

drop policy if exists "Users can manage their own help request" on public.help_requests;
create policy "Users can manage their own help request"
on public.help_requests for update
to authenticated
using (requester_id = auth.uid())
with check (requester_id = auth.uid());

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'help_requests'
  ) then
    alter publication supabase_realtime add table public.help_requests;
  end if;
end $$;

commit;
