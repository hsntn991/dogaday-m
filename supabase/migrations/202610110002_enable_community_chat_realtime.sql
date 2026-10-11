begin;

-- Realtime is read-only here: all message writes continue to pass through the
-- guarded RPC that enforces authentication, rate limits and content rules.
do $$
begin
  if exists (
    select 1
    from pg_publication
    where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'community_chat_messages'
  ) then
    alter publication supabase_realtime
      add table public.community_chat_messages;
  end if;
end;
$$;

commit;
