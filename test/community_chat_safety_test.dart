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
    expect(profile, contains('Görünecek adın'));
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
}
