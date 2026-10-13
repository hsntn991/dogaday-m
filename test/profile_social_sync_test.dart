import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('social accounts are restored from the signed-in Supabase profile', () {
    final core = File('lib/src/core/app_core.dart').readAsStringSync();
    final auth = File('lib/src/app/app.dart').readAsStringSync();
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(core, contains("['social_accounts']"));
    expect(core, contains("UserAttributes(data: {'social_accounts':"));
    expect(auth, contains('UserSocialAccountsController.load()'));
    expect(core, contains('static Future<void> clear() async'));
    expect(profile, contains('await UserSocialAccountsController.clear()'));
  });

  test('profile avatar offers camera and gallery instead of a URL field', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(profile, contains("label: 'Kamerayı aç'"));
    expect(profile, contains("label: 'Fotoğraflardan seç'"));
    expect(profile, contains('ImagePicker().pickImage'));
    expect(profile, contains('data:image/jpeg;base64'));
    expect(profile, isNot(contains('Özel Fotoğraf Bağlantısı')));
  });

  test('profile stores an explicit full or surname-initial display style', () {
    final profile =
        File('lib/src/features/favorites_profile.dart').readAsStringSync();

    expect(profile, contains('profileDisplayNameForStyle'));
    expect(profile, contains("'display_name_style'"));
    expect(profile, contains("'short' : 'full'"));
    expect(profile, contains('Soyadımı baş harf olarak göster'));
  });
}
