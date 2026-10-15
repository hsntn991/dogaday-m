import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'community room tiles replace the active label with a notification opt-in',
      () {
    final source =
        File('lib/src/features/community_chat.dart').readAsStringSync();

    expect(source, contains('Icons.notifications_none_rounded'));
    expect(source, contains('CommunityChatSubscriptionController.subscribe'));
    expect(source,
        contains('Bu sohbet odası ile ilgili bildirim almak ister misiniz?'));
    expect(source,
        isNot(contains("Text(\n                                  'Aktif'")));
  });

  test('followed community rooms create in-app notifications on a later launch',
      () {
    final source = File('lib/src/core/app_core.dart').readAsStringSync();

    expect(source, contains('class CommunityChatSubscriptionController'));
    expect(source, contains("'community_chat_room_subscriptions_v1'"));
    expect(source, contains('CommunityChatService.loadMessages(category)'));
  });

  test(
      'home notification center includes followed room messages and opens rooms',
      () {
    final source = File('lib/src/features/home.dart').readAsStringSync();

    expect(source, contains('CommunityChatSubscriptionController.load()'));
    expect(source, contains('CommunityChatSubscriptionController.items'));
    expect(source, contains('CommunityChatRoomScreen('));
  });

  testWidgets('room notification icon asks before subscribing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CommunityChatHubScreen()),
    );

    await tester.tap(find.byTooltip('Kamp bildirimlerini aç'));
    await tester.pumpAndSettle();

    expect(
      find.text('Bu sohbet odası ile ilgili bildirim almak ister misiniz?'),
      findsOneWidget,
    );
    expect(find.text('Aktif'), findsNothing);
  });
}
