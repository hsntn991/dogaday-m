begin;

do $$
declare
  v_missing_rls text;
begin
  select string_agg(c.relname, ', ')
  into v_missing_rls
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relname in (
      'categories', 'places', 'place_facilities', 'app_user_roles',
      'place_submissions', 'moderation_audit_logs'
    )
    and not c.relrowsecurity;

  if v_missing_rls is not null then
    raise exception 'RLS is disabled for: %', v_missing_rls;
  end if;
  if has_function_privilege(
    'anon', 'public.approve_place_submission(uuid,text)', 'EXECUTE'
  ) then
    raise exception 'anon can execute approve_place_submission';
  end if;
  if has_function_privilege(
    'anon', 'public.attach_submission_photo(uuid,text)', 'EXECUTE'
  ) then
    raise exception 'anon can execute attach_submission_photo';
  end if;
  if has_function_privilege(
    'anon', 'public.rls_auto_enable()', 'EXECUTE'
  ) or has_function_privilege(
    'authenticated', 'public.rls_auto_enable()', 'EXECUTE'
  ) then
    raise exception 'client roles can execute rls_auto_enable';
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'places'
      and policyname = 'Verified active places are publicly readable'
  ) then
    raise exception 'public places read policy is missing';
  end if;
end;
$$;

rollback;
