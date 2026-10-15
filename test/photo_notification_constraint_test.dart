import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('photo moderation notifications are allowed by the database constraint',
      () {
    final migration = File(
      'supabase/migrations/202610150001_allow_photo_notification_types.sql',
    ).readAsStringSync();

    expect(migration, contains('user_notifications_type_check'));
    expect(migration, contains("'photo_approved'"));
    expect(migration, contains("'photo_changes_requested'"));
    expect(migration, contains("'photo_rejected'"));
  });
}
