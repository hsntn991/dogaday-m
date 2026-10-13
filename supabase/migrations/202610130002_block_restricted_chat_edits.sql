-- Kısıtlanan bir kullanıcı, eski bir mesajı düzenleyerek sohbet kuralını
-- dolanamasın. İlk mesaj yazma RPC'sindeki denetimle aynı kural uygulanır.

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
  v_restriction public.community_chat_restrictions;
  v_result public.community_chat_messages;
begin
  if v_user_id is null then raise exception 'authentication required'; end if;

  select * into v_restriction
  from public.community_chat_restrictions
  where user_id = v_user_id
    and (ends_at is null or ends_at > now());
  if found then
    raise exception 'chat_restricted:%',
      coalesce(to_char(v_restriction.ends_at, 'YYYY-MM-DD HH24:MI'), 'permanent');
  end if;

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
