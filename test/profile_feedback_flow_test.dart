import 'dart:io';

import 'package:dogada_gezi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a rejected place notification is identifiable and carries its id', () {
    final feedback = SubmissionFeedback.fromNotification({
      'id': 'rejection-1',
      'type': 'submission_rejected',
      'title': 'Katkın yayınlanamadı',
      'body': 'Yer adı ve konumu uyuşmuyor.',
      'created_at': '2026-10-08T12:00:00Z',
      'read_at': null,
    });

    expect(feedback.id, 'rejection-1');
    expect(feedback.isRejected, isTrue);
    expect(feedback.body, 'Yer adı ve konumu uyuşmuyor.');
  });

  test('profile presents rejections once and no longer reserves a card', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(profile, contains('_showUnreadRejectionNotice'));
    expect(profile, contains('SubmissionFeedbackController.markRead'));
    expect(profile, contains('!item.isRejected'));
  });

  test('profile also acknowledges a requested correction once', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(profile, contains('item.isRejected || item.isActionRequired'));
    expect(profile, contains("AppStrings.get('profile_feedback_correction_title')"));
  });

  test('help request entry is not blocked when the feed cannot load', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    final start = profile.indexOf('Future<void> _openEmergencyHelp() async');
    final end = profile.indexOf('Future<void> _handleDeleteAccount()', start);
    final entryFlow = profile.substring(start, end);

    expect(entryFlow, isNot(contains('isAvailable.value')));
    expect(entryFlow, contains('EmergencyHelpRequestSheet.show(context)'));
  });

  test('account deletion confirmations use the active app language', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();
    final locale = File('lib/src/core/app_locale.dart').readAsStringSync();

    expect(profile, contains("AppStrings.get('profile_delete_confirm_title')"));
    expect(profile, contains("AppStrings.get('profile_delete_failed')"));
    expect(locale, contains("'profile_delete_confirm_title':"));
  });

  test('social account editor uses the active app language', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();
    final locale = File('lib/src/core/app_locale.dart').readAsStringSync();

    expect(profile, contains("AppStrings.get('profile_social_title')"));
    expect(profile, contains("AppStrings.get('profile_social_saved')"));
    expect(locale, contains("'profile_social_title':"));
  });
}
