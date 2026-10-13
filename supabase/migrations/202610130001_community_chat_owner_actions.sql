-- Kullanıcı kendi sohbet mesajını düzenleyebilir veya geri alabilir. Her iki
-- işlem de istemcinin doğrudan tablo yazmasına izin vermeden, sahipliği
-- sunucuda denetleyen RPC'ler üzerinden yürür.

create or replace function public.update_community_chat_message(
  p_message_id uuid,
  p_body text
)
returns public.community_chat_messages
language plpgsql security definer set search_path = public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_body text := btrim(coalesce(p_body, ''));
  v_result public.community_chat_messages;
begin
  if v_user_id is null then raise exception 'authentication required'; end if;
  if char_length(v_body) not between 1 and 500 then
    raise exception 'invalid message length';
  end if;
  if v_body ~* '(https?://|www\\.|t\\.me/|discord\\.gg|bit\\.ly)' then
    raise exception 'links are not allowed';
  end if;
  if v_body ~* '(amk|aq|orospu|siktir|fuck|shit|malware|payload|ransomware)' then
    raise exception 'message violates community rules';
  end if;

  update public.community_chat_messages
  set body = v_body
  where id = p_message_id
    and author_id = v_user_id
    and deleted_at is null
  returning * into v_result;
  if not found then raise exception 'message not found or not owned'; end if;
  return v_result;
end;
$$;

create or replace function public.delete_community_chat_message(
  p_message_id uuid
)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then raise exception 'authentication required'; end if;
  update public.community_chat_messages
  set deleted_at = now(), deleted_by = v_user_id
  where id = p_message_id
    and author_id = v_user_id
    and deleted_at is null;
  if not found then raise exception 'message not found or not owned'; end if;
end;
$$;

grant execute on function public.update_community_chat_message(uuid, text)
  to authenticated;
grant execute on function public.delete_community_chat_message(uuid)
  to authenticated;

-- Yönetim panelindeki şikâyet listesi doğrudan tablo sorgusu kullandığından
-- moderatör politikasının çalışabilmesi için yalnızca select yetkisi gerekir.
grant select on public.community_chat_reports, public.community_chat_restrictions
  to authenticated;
