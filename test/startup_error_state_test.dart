import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup error never presents a retry action that does nothing', () {
    final source = File('lib/src/app/app.dart').readAsStringSync();

    expect(source, contains("label: const Text('Uygulamayı kapat')"));
    expect(source, contains('SystemNavigator.pop();'));
    expect(source, isNot(contains("label: const Text('Yeniden Dene')")));
    expect(source, contains('backgroundColor: AppColors.background'));
    expect(source, contains('backgroundColor: AppColors.primary'));
  });
}
