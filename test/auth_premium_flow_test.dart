import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'authentication starts with a clear welcome screen and opens email sign-in',
      () {
    final source = File('lib/src/app/app.dart').readAsStringSync();

    expect(source, contains('enum AuthStage { welcome, email }'));
    expect(source, contains('AuthStage _stage = AuthStage.welcome'));
    expect(source, contains('Doğadayım’a hoş geldin'));
    expect(source, contains('E-posta ile devam et'));
    expect(source, contains('E-posta ile giriş'));
    expect(source, contains('AuthStage.email'));
  });

  test('authentication keeps account and guest paths accessible on phones', () {
    final source = File('lib/src/app/app.dart').readAsStringSync();

    expect(source, contains('SafeArea('));
    expect(source, contains('SingleChildScrollView('));
    expect(source, contains('Misafir olarak devam et'));
    expect(source, contains('_buildLanguageChooser('));
  });

  test('welcome screen is compact, has no back action, and states the brand',
      () {
    final source = File('lib/src/app/app.dart').readAsStringSync();
    final welcomeStart = source.indexOf('Widget _buildWelcomeStage');
    final emailStart = source.indexOf('Widget _buildEmailStage');
    final welcome = source.substring(welcomeStart, emailStart);

    expect(welcome, contains('Türkiye’nin Toplum Destekli Doğa Haritası'));
    expect(welcome, isNot(contains('Navigator.maybePop(context)')));
    expect(welcome, isNot(contains('IconButton(')));
  });
}
