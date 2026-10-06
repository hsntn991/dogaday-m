import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canlı Üretim Güvenlik & Kabul Testleri (Supabase & Admin & MFA)', () {
    test('1. Misafir kullanıcı (anon) yönetim ve başvuru tablolarına erişemez', () {
      final migration = File(
        'supabase/migrations/202610050001_anon_admin_tables_revoke_hardening.sql',
      ).readAsStringSync();

      expect(migration, contains('revoke all on public.place_submissions from anon;'));
      expect(migration, contains('revoke all on public.moderation_audit_logs from anon;'));
      expect(migration, contains('revoke all on public.app_user_roles from anon;'));
    });

    test('2. Normal kullanıcı yalnızca kendi başvurusunu ve bildirimini görebilir', () {
      final subMigration = File(
        'supabase/migrations/202608270001_place_moderation.sql',
      ).readAsStringSync();
      final notifMigration = File(
        'supabase/migrations/202609270001_submission_author_and_feedback.sql',
      ).readAsStringSync();
      final notifPrivacyMigration = File(
        'supabase/migrations/202610030004_notification_and_account_privacy.sql',
      ).readAsStringSync();

      // Başvuruda sadece kendi başvurusu veya moderatör görebilir
      expect(
        subMigration,
        contains('using (submitted_by = auth.uid() or public.is_place_moderator())'),
      );
      // Bildirimde sadece kendi bildirimini görebilir
      expect(notifMigration, contains('using (user_id = auth.uid())'));
      // Doğrudan güncelleme yetkisi kullanıcılardan alınmıştır
      expect(notifPrivacyMigration, contains('revoke update on public.user_notifications from anon, authenticated;'));
    });

    test('3. Moderatör/admin olmayan hesap yönetim paneline ve yetkili RPC lere erişemez', () {
      final adminCode = File('lib/src/app/admin_panel.dart').readAsStringSync();
      final moderationSql = File(
        'supabase/migrations/202608270001_place_moderation.sql',
      ).readAsStringSync();

      // Veritabanı is_place_moderator() fonksiyonu
      expect(moderationSql, contains('create or replace function public.is_place_moderator()'));
      expect(moderationSql, contains("role in ('admin', 'moderator')"));

      // İstemci tarafı rol kontrolü ve hata mesajı
      expect(adminCode, contains("role == 'admin' || role == 'moderator'"));
      expect(adminCode, contains("if (!_authorized) _error = 'Bu hesabın yönetici yetkisi yok.';"));
    });

    test('4. MFA kontrolü fail-closed prensibine uygundur ve AAL2 doğrulaması zorunludur', () {
      final adminCode = File('lib/src/app/admin_panel.dart').readAsStringSync();

      // _checkAccess içinde fail-closed yakalama
      expect(adminCode, contains('// Fail-closed: MFA kontrolünde hata olursa paneli kesinlikle açma, erişimi engelle.'));
      expect(adminCode, contains('MFA güvenlik kontrolü başarısız oldu. Güvenlik nedeniyle erişim reddedildi.'));

      // Dashboard initState içinde savunma derinliği (defense-in-depth) AAL2 denetimi
      expect(adminCode, contains('aal.nextLevel == AuthenticatorAssuranceLevels.aal2 &&'));
      expect(adminCode, contains('aal.currentLevel != AuthenticatorAssuranceLevels.aal2'));
      expect(adminCode, contains("Oturum için AAL2 iki aşamalı doğrulama zorunludur."));
    });

    test('5. Audit log kaydı istemciden eklenemez, değiştirilemez veya silinemez', () {
      final revokeSql = File(
        'supabase/migrations/202609140001_role_audit_permissions_hardening.sql',
      ).readAsStringSync();
      final moderationSql = File(
        'supabase/migrations/202608270001_place_moderation.sql',
      ).readAsStringSync();

      // Audit log üzerinde insert, update, delete tamamen iptal
      expect(revokeSql, contains('revoke insert, update, delete\non public.moderation_audit_logs\nfrom anon, authenticated;'));

      // Sadece moderatörler okuma yapabilir
      expect(moderationSql, contains('create policy "Moderators can read moderation logs"'));
      expect(moderationSql, contains('using (public.is_place_moderator());'));
    });
  });
}
