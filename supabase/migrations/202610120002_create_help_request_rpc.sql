-- Yardım çağrısı oluşturma işlemini tek, sahiplik doğrulamalı sunucu
-- işlemine taşır. Süresi dolmuş aktif satırların benzersizlik indeksini
-- kilitlemesini önler.

create or replace function public.create_help_request(
  p_request_type text,
  p_contact_preference text,
  p_contact_value text,
  p_latitude double precision,
  p_longitude double precision
)
returns public.help_requests
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_request public.help_requests;
  v_contact text := nullif(btrim(coalesce(p_contact_value, '')), '');
begin
  if v_user_id is null then
    raise exception 'Yardım çağrısı için giriş yapmalısın.';
  end if;
  if p_request_type not in ('lost', 'vehicle_stuck', 'vehicle_not_working', 'injured') then
    raise exception 'Geçersiz yardım türü.';
  end if;
  if p_contact_preference not in ('location_only', 'contact_details') then
    raise exception 'Geçersiz iletişim tercihi.';
  end if;
  if p_latitude not between -90 and 90 or p_longitude not between -180 and 180 then
    raise exception 'Geçersiz konum.';
  end if;
  if p_contact_preference = 'contact_details'
     and (v_contact is null or char_length(v_contact) not between 3 and 80) then
    raise exception 'Telefon numarası veya iletişim bilgisi gir.';
  end if;

  -- Eski çağrılar görünmez hâle gelir ve yeni çağrıyı engellemez.
  update public.help_requests
  set status = 'resolved', resolved_at = coalesce(resolved_at, now())
  where requester_id = v_user_id
    and status = 'active'
    and expires_at <= now();

  insert into public.help_requests (
    requester_id,
    request_type,
    contact_preference,
    contact_value,
    latitude,
    longitude,
    status,
    expires_at
  ) values (
    v_user_id,
    p_request_type,
    p_contact_preference,
    case when p_contact_preference = 'contact_details' then v_contact else null end,
    p_latitude,
    p_longitude,
    'active',
    now() + interval '48 hours'
  ) returning * into v_request;

  return v_request;
end;
$$;

revoke all on function public.create_help_request(text, text, text, double precision, double precision)
  from public, anon;
grant execute on function public.create_help_request(text, text, text, double precision, double precision)
  to authenticated;
