begin;

-- Keep the exact ownership rule, but allow PostgreSQL to evaluate auth.uid()
-- once for the query instead of once for every candidate row.
drop policy if exists "Authenticated users can submit reports"
  on public.help_request_reports;
create policy "Authenticated users can submit reports"
on public.help_request_reports for insert
to authenticated
with check (reporter_id = (select auth.uid()));

commit;
