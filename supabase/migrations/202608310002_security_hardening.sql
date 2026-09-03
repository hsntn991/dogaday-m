begin;

-- Bu bakım fonksiyonu istemci API'sinden çağrılmamalıdır.
revoke all on function public.rls_auto_enable() from public;
revoke all on function public.rls_auto_enable() from anon;
revoke all on function public.rls_auto_enable() from authenticated;

commit;
