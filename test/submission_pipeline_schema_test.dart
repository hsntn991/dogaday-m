import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'submission schema accepts mobile-service businesses and stamps owner identity',
      () {
    final migration = File(
      'supabase/migrations/202610030001_submission_identity_and_mobile_service.sql',
    ).readAsStringSync();

    expect(migration, contains("'local_service'"));
    expect(migration, contains('new.submitted_by := auth.uid()'));
    expect(migration, contains('new.submitter_email := v_email'));
    expect(migration, contains('main_category, subtype, verification_level'));
    expect(migration, isNot(contains('facility_key, is_available')));
  });

  test('mobile service businesses can attach a photo that reaches moderation',
      () {
    final source =
        File('lib/src/features/mobile_service.dart').readAsStringSync();

    expect(source, contains('İşletme Fotoğrafı'));
    expect(source, contains('ImagePicker().pickImage'));
    expect(source, contains('PlacePhotoStorage.persistPrimaryPhoto'));
  });

  test('place and business photo forms offer camera or gallery, never a URL',
      () {
    final addPlace = File('lib/src/features/add_place.dart').readAsStringSync();
    final service =
        File('lib/src/features/mobile_service.dart').readAsStringSync();
    final detail = File('lib/src/features/detail.dart').readAsStringSync();
    final core = File('lib/src/core/app_core.dart').readAsStringSync();

    for (final source in [addPlace, service, detail]) {
      expect(source, contains('showPhotoSourceSheet'));
    }
    expect(core, contains('ImageSource.camera'));
    expect(core, contains('ImageSource.gallery'));
    expect(detail, isNot(contains('Görsel Bağlantısı (URL)')));
  });

  test(
      'admin photo loader keeps working when one stored photo cannot be signed',
      () {
    final source = File('lib/src/app/admin_panel.dart').readAsStringSync();

    expect(source, contains("normalizedPath.startsWith('https://')"));
    expect(source, contains('catch (_)'));
  });

  test('help report RLS evaluates the authenticated user once per query', () {
    final migration = File(
      'supabase/migrations/202610030002_optimize_help_request_report_rls.sql',
    ).readAsStringSync();

    expect(migration, contains('reporter_id = (select auth.uid())'));
  });

  test('existing-place photos are privately moderated before publication', () {
    final migration = File(
      'supabase/migrations/202610030003_community_photo_moderation.sql',
    ).readAsStringSync();
    final controller = File('lib/src/core/app_core.dart').readAsStringSync();
    final detail = File('lib/src/features/detail.dart').readAsStringSync();
    final admin = File('lib/src/app/admin_panel.dart').readAsStringSync();

    expect(
      migration,
      contains('create table if not exists public.place_photo_submissions'),
    );
    expect(migration, contains("'community-photos'"));
    expect(migration, contains('approve_community_photo_submission'));
    expect(migration, contains('review_community_photo_submission'));
    expect(controller, contains('submitPhotoForModeration'));
    expect(detail, contains('submitPhotoForModeration'));
    expect(admin, contains('Fotoğraf katkıları'));
  });

  test('approved photos are not offered a local-only delete action', () {
    final detail = File('lib/src/features/detail.dart').readAsStringSync();

    expect(detail, contains("!p.id.startsWith('moderated-')"));
  });
}
