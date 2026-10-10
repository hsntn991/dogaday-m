begin;

-- Public chat is intentionally write-only through RPCs. This prevents a
-- modified client from bypassing the content, link, rate, or restriction rules.
create table if not exists public.community_chat_messages (
  id uuid primary key default gen_random_uuid(),
  category_key text not null check (char_length(category_key) between 1 and 64),
  author_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null check (char_length(author_name) between 2 and 48),
  body text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid references auth.users(id) on delete set null
);

create index if not exists community_chat_messages_category_created_idx
  on public.community_chat_messages (category_key, created_at desc);

create table if not exists public.community_chat_reports (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.community_chat_messages(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null check (reason in ('abuse', 'harassment', 'spam', 'unsafe', 'other')),
  note text check (char_length(coalesce(note, '')) <= 300),
  created_at timestamptz not null default now(),
  unique (message_id, reporter_id)
);

create table if not exists public.community_chat_restrictions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  ends_at timestamptz,
  reason text not null check (char_length(reason) between 1 and 300),
  imposed_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at > created_at)
);

alter table public.community_chat_messages enable row level security;
alter table public.community_chat_reports enable row level security;
alter table public.community_chat_restrictions enable row level security;

create policy "Authenticated users read visible chat messages"
on public.community_chat_messages for select to authenticated
using (deleted_at is null);

create policy "Users read their own chat restrictions"
on public.community_chat_restrictions for select to authenticated
using (user_id = (select auth.uid()));

create policy "Users submit one report per chat message"
on public.community_chat_reports for insert to authenticated
with check (reporter_id = (select auth.uid()));

create policy "Users read their own chat reports"
on public.community_chat_reports for select to authenticated
using (reporter_id = (select auth.uid()));

create policy "Staff reads chat moderation data"
on public.community_chat_reports for select to authenticated
using (public.is_place_moderator());

create policy "Staff reads chat restrictions"
on public.community_chat_restrictions for select to authenticated
using (public.is_place_moderator());

create or replace function public.send_community_chat_message(
  p_category_key text,
  p_body text
)
returns public.community_chat_messages
language plpgsql security definer set search_path = public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_body text := btrim(coalesce(p_body, ''));
  v_name text := btrim(coalesce(auth.jwt() -> 'user_metadata' ->> 'display_name', auth.jwt() -> 'user_metadata' ->> 'full_name', 'Doğa Kaşifi'));
  v_restriction public.community_chat_restrictions;
  v_result public.community_chat_messages;
begin
  if v_user_id is null then raise exception 'authentication required'; end if;
  if char_length(btrim(coalesce(p_category_key, ''))) not between 1 and 64 then raise exception 'invalid category'; end if;
  if char_length(v_body) not between 1 and 500 then raise exception 'invalid message length'; end if;
  if v_body ~* '(https?://|www\\.|t\\.me/|discord\\.gg|bit\\.ly)' then raise exception 'links are not allowed'; end if;
  if v_body ~* '(amk|aq|orospu|siktir|fuck|shit|malware|payload|ransomware)' then raise exception 'message violates community rules'; end if;
  select * into v_restriction from public.community_chat_restrictions where user_id = v_user_id and (ends_at is null or ends_at > now());
  if found then
    raise exception 'chat_restricted:%', coalesce(to_char(v_restriction.ends_at, 'YYYY-MM-DD HH24:MI'), 'permanent');
  end if;
  if exists (select 1 from public.community_chat_messages where author_id = v_user_id and created_at > now() - interval '10 seconds') then
    raise exception 'please wait before sending another message';
  end if;
  insert into public.community_chat_messages(category_key, author_id, author_name, body)
  values (btrim(p_category_key), v_user_id, left(v_name, 48), v_body)
  returning * into v_result;
  return v_result;
end;
$$;

create or replace function public.apply_community_chat_restriction(
  p_user_id uuid, p_duration_days integer, p_reason text
)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if not public.is_place_moderator() then raise exception 'not authorized'; end if;
  if p_duration_days not in (7, -1) then raise exception 'invalid restriction duration'; end if;
  insert into public.community_chat_restrictions(user_id, ends_at, reason, imposed_by)
  values (p_user_id, case when p_duration_days = -1 then null else now() + make_interval(days => p_duration_days) end, btrim(p_reason), auth.uid())
  on conflict (user_id) do update set ends_at = excluded.ends_at, reason = excluded.reason, imposed_by = excluded.imposed_by, created_at = now();
end;
$$;

create or replace function public.get_community_chat_messages(
  p_category_key text
)
returns table (
  id uuid,
  author_id uuid,
  author_name text,
  body text,
  created_at timestamptz,
  is_staff boolean
)
language sql security definer set search_path = public, extensions
as $$
  select
    message.id,
    message.author_id,
    message.author_name,
    message.body,
    message.created_at,
    exists (
      select 1 from public.app_user_roles role
      where role.user_id = message.author_id
        and role.role in ('admin', 'moderator')
    ) as is_staff
  from public.community_chat_messages message
  where message.category_key = btrim(p_category_key)
    and message.deleted_at is null
  order by message.created_at asc
  limit 150;
$$;

create or replace function public.report_community_chat_message(
  p_message_id uuid,
  p_reason text,
  p_note text default null
)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_reason not in ('abuse', 'harassment', 'spam', 'unsafe', 'other') then
    raise exception 'invalid report reason';
  end if;
  if char_length(coalesce(p_note, '')) > 300 then raise exception 'report note is too long'; end if;
  insert into public.community_chat_reports(message_id, reporter_id, reason, note)
  values (p_message_id, auth.uid(), p_reason, nullif(btrim(p_note), ''));
end;
$$;

revoke all on public.community_chat_messages, public.community_chat_reports, public.community_chat_restrictions from anon, authenticated;
grant select on public.community_chat_messages to authenticated;
grant select, insert on public.community_chat_reports to authenticated;
grant select on public.community_chat_restrictions to authenticated;
grant execute on function public.send_community_chat_message(text, text) to authenticated;
grant execute on function public.apply_community_chat_restriction(uuid, integer, text) to authenticated;
grant execute on function public.get_community_chat_messages(text) to authenticated;
grant execute on function public.report_community_chat_message(uuid, text, text) to authenticated;

commit;
