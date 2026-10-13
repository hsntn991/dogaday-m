import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File('supabase/migrations/202610100001_community_chat_safety.sql')
      .readAsStringSync();

  test('community chat accepts writes only through a guarded RPC', () {
    expect(sql, contains('send_community_chat_message'));
    expect(sql, contains('links are not allowed'));
    expect(sql, contains('message violates community rules'));
    expect(sql, contains('chat_restricted:'));
    expect(sql, contains('revoke all on public.community_chat_messages'));
  });

  test('chat reports and restrictions are moderated by staff', () {
    expect(sql, contains('community_chat_reports'));
    expect(sql, contains('apply_community_chat_restriction'));
    expect(sql, contains("p_duration_days not in (7, -1)"));
    expect(sql, contains('public.is_place_moderator()'));
  });

  test('profile lets a signed-in user choose the name shown in chat', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(profile, contains('_showDisplayNameEditor'));
    expect(profile, contains("'display_name'"));
    expect(profile, contains("AppStrings.get('profile_display_name_title')"));
  });

  test('chat reporting and profile name editing use app translations', () {
    final chat =
        File('lib/src/features/community_chat.dart').readAsStringSync();
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();
    final locale = File('lib/src/core/app_locale.dart').readAsStringSync();

    expect(chat, contains("AppStrings.get('chat_report_message')"));
    expect(locale, contains("'chat_report_sent':"));
    expect(profile, contains("AppStrings.get('profile_display_name_title')"));
    expect(locale, contains("'profile_display_name_title':"));
    expect(profile, contains("AppStrings.get('profile_feedback_acknowledge')"));
    expect(chat, contains("AppStrings.get('community_chat_retry')"));
  });

  test('the app loads chat messages and reports through guarded RPCs', () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    expect(core, contains('class CommunityChatService'));
    expect(core, contains('get_community_chat_messages'));
    expect(core, contains('report_community_chat_message'));
    final admin = File('lib/src/app/admin_panel.dart').readAsStringSync();
    expect(admin, contains('AdminChatModerationScreen'));
    expect(admin, contains('apply_community_chat_restriction'));
  });

  test('community chat receives newly published messages without reopening',
      () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final room =
        File('lib/src/features/community_chat.dart').readAsStringSync();

    expect(core, contains('watchMessages'));
    expect(core, contains('onPostgresChanges'));
    expect(room, contains('_subscribeToLiveMessages'));
    expect(room, contains('_realtimeChannel'));
  });

  test('message owners can edit or delete only their own messages', () {
    final migration = File(
      'supabase/migrations/202610130001_community_chat_owner_actions.sql',
    ).readAsStringSync();
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final room =
        File('lib/src/features/community_chat.dart').readAsStringSync();

    expect(migration, contains('update_community_chat_message'));
    expect(migration, contains('delete_community_chat_message'));
    expect(migration, contains('author_id = v_user_id'));
    expect(core, contains('updateMessage'));
    expect(core, contains('deleteMessage'));
    expect(room, contains('_showOwnMessageActions'));
    expect(room, contains('Mesaj seçeneklerini aç:'));
    expect(room, contains('onPressed: message.id.isEmpty'));
  });

  test('a restricted user cannot use message editing to bypass chat limits', () {
    final migration = File(
      'supabase/migrations/202610130002_block_restricted_chat_edits.sql',
    ).readAsStringSync();

    expect(migration, contains('community_chat_restrictions'));
    expect(migration, contains("raise exception 'chat_restricted:%'"));
  });
}
