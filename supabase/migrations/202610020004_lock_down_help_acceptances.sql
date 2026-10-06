-- Only the security-definer acceptance RPC may create or change acceptances.
-- This prevents a client from bypassing the server-side checks by writing to
-- help_request_acceptances directly.

begin;

drop policy if exists "Helpers can insert their own acceptance" on public.help_request_acceptances;
drop policy if exists "Helpers or requesters can update acceptance status" on public.help_request_acceptances;

revoke insert, update on public.help_request_acceptances from authenticated;
revoke insert, update on public.help_request_acceptances from anon;

commit;
