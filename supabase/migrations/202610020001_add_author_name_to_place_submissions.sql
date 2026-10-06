begin;

alter table public.place_submissions
  add column if not exists author_name text;

create or replace function public.stamp_place_submission_author()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_name text;
  v_email text;
begin
  select
    coalesce(
      nullif(trim(coalesce(raw_user_meta_data ->> 'full_name', '')), ''),
      nullif(trim(coalesce(raw_user_meta_data ->> 'name', '')), ''),
      nullif(split_part(email, '@', 1), ''),
      'Doğadayım kullanıcısı'
    ),
    email
  into v_name, v_email
  from auth.users
  where id = new.submitted_by;

  new.submitter_name := coalesce(v_name, 'Doğadayım kullanıcısı');
  new.submitter_email := v_email;
  new.author_name := coalesce(nullif(trim(coalesce(new.author_name, '')), ''), v_name, 'Doğadayım kullanıcısı');
  return new;
end;
$$;

update public.place_submissions
set author_name = coalesce(author_name, submitter_name, 'Doğadayım kullanıcısı')
where author_name is null;

commit;
