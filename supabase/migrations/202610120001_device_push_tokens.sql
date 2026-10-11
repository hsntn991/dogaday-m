-- Cihaz bildirim kayıtları.
--
-- Bu tablo yalnızca cihaz tokenını ve platform bilgisini tutar; bildirim
-- içeriği user_notifications tablosunda, gönderim ise servis rolü kullanan
-- güvenilir Edge Function'da kalır. Böylece bir kullanıcı başka bir hesabın
-- cihazına token yazamaz veya token listesini okuyamaz.

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null check (char_length(token) between 16 and 4096),
  platform text not null check (platform in ('android', 'ios', 'web')),
  device_label text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

create index if not exists device_push_tokens_user_last_seen_idx
  on public.device_push_tokens (user_id, last_seen_at desc);

alter table public.device_push_tokens enable row level security;

drop policy if exists "Users read their own device tokens"
  on public.device_push_tokens;
create policy "Users read their own device tokens"
  on public.device_push_tokens for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users delete their own device tokens"
  on public.device_push_tokens;
create policy "Users delete their own device tokens"
  on public.device_push_tokens for delete
  to authenticated
  using (auth.uid() = user_id);

-- Token yazımı RLS ile doğrudan açılmaz. RPC hem sahipliği hem de platformu
-- doğrular; istemci yalnızca kendi oturumuna ait tokenı güncelleyebilir.
create or replace function public.upsert_device_push_token(
  p_token text,
  p_platform text,
  p_device_label text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if char_length(trim(coalesce(p_token, ''))) < 16 then
    raise exception 'Invalid device token';
  end if;
  if p_platform not in ('android', 'ios', 'web') then
    raise exception 'Invalid push platform';
  end if;

  insert into public.device_push_tokens (
    user_id, token, platform, device_label, last_seen_at, updated_at
  ) values (
    v_user_id, trim(p_token), p_platform, nullif(trim(p_device_label), ''), now(), now()
  )
  on conflict (user_id, token) do update
    set platform = excluded.platform,
        device_label = excluded.device_label,
        last_seen_at = now(),
        updated_at = now();
end;
$$;

revoke all on public.device_push_tokens from anon;
revoke all on public.device_push_tokens from authenticated;
grant select, delete on public.device_push_tokens to authenticated;
grant execute on function public.upsert_device_push_token(text, text, text)
  to authenticated;

-- Uygulama açıkken bildirim merkezi Supabase Realtime üzerinden güncellenir.
-- Mevcut yayında tablo varsa güvenle eklenir; yoksa geçiş yine başarılı olur.
do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'user_notifications'
  ) and not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'user_notifications'
  ) then
    alter publication supabase_realtime add table public.user_notifications;
  end if;
end;
$$;
