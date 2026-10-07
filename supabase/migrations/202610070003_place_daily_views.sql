-- Migration: 202610070003_place_daily_views.sql
-- Görüntülenme ve 24 saat trend takip tablosu ile güvenli RPC fonksiyonları

create table if not exists public.place_daily_views (
  place_id text not null,
  view_date date not null default current_date,
  view_count integer not null default 1 check (view_count > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (place_id, view_date)
);

create index if not exists idx_place_daily_views_place_date
  on public.place_daily_views (place_id, view_date desc);

alter table public.place_daily_views enable row level security;

-- Read policy for client queries
drop policy if exists place_daily_views_select on public.place_daily_views;
create policy place_daily_views_select on public.place_daily_views
  for select to anon, authenticated using (true);

-- Disallow client direct inserts/updates/deletes
revoke insert, update, delete on public.place_daily_views from anon, authenticated, public;

-- RPC: record_place_view
create or replace function public.record_place_view(p_place_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := current_date;
  v_today_views integer := 0;
  v_24h_views integer := 0;
  v_7d_views integer := 0;
  v_total_views bigint := 0;
begin
  if p_place_id is null or trim(p_place_id) = '' then
    return jsonb_build_object(
      'success', false,
      'error', 'invalid_place_id'
    );
  end if;

  insert into public.place_daily_views (place_id, view_date, view_count, updated_at)
  values (p_place_id, v_today, 1, now())
  on conflict (place_id, view_date)
  do update set
    view_count = public.place_daily_views.view_count + 1,
    updated_at = now();

  select coalesce(view_count, 0)
    into v_today_views
    from public.place_daily_views
   where place_id = p_place_id and view_date = v_today;

  select coalesce(sum(view_count), 0)
    into v_24h_views
    from public.place_daily_views
   where place_id = p_place_id and view_date >= (v_today - interval '1 day');

  select coalesce(sum(view_count), 0)
    into v_7d_views
    from public.place_daily_views
   where place_id = p_place_id and view_date >= (v_today - interval '6 day');

  select coalesce(sum(view_count), 0)
    into v_total_views
    from public.place_daily_views
   where place_id = p_place_id;

  return jsonb_build_object(
    'place_id', p_place_id,
    'views_today', v_today_views,
    'views_24h', v_24h_views,
    'views_7d', v_7d_views,
    'views_total', v_total_views
  );
end;
$$;

-- RPC: get_place_views
create or replace function public.get_place_views(p_place_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_today date := current_date;
  v_today_views integer := 0;
  v_24h_views integer := 0;
  v_7d_views integer := 0;
  v_total_views bigint := 0;
begin
  if p_place_id is null or trim(p_place_id) = '' then
    return jsonb_build_object(
      'place_id', coalesce(p_place_id, ''),
      'views_today', 0,
      'views_24h', 0,
      'views_7d', 0,
      'views_total', 0
    );
  end if;

  select coalesce(view_count, 0)
    into v_today_views
    from public.place_daily_views
   where place_id = p_place_id and view_date = v_today;

  select coalesce(sum(view_count), 0)
    into v_24h_views
    from public.place_daily_views
   where place_id = p_place_id and view_date >= (v_today - interval '1 day');

  select coalesce(sum(view_count), 0)
    into v_7d_views
    from public.place_daily_views
   where place_id = p_place_id and view_date >= (v_today - interval '6 day');

  select coalesce(sum(view_count), 0)
    into v_total_views
    from public.place_daily_views
   where place_id = p_place_id;

  return jsonb_build_object(
    'place_id', p_place_id,
    'views_today', v_today_views,
    'views_24h', v_24h_views,
    'views_7d', v_7d_views,
    'views_total', v_total_views
  );
end;
$$;

revoke all on function public.record_place_view(text) from public;
grant execute on function public.record_place_view(text) to anon, authenticated;

revoke all on function public.get_place_views(text) from public;
grant execute on function public.get_place_views(text) to anon, authenticated;
