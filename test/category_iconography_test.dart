import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category chips use distinct nature pictograms for waterfall and cave',
      () {
    final widgets =
        File('lib/src/widgets/design_system_widgets.dart').readAsStringSync();
    final home = File('lib/src/features/home.dart').readAsStringSync();
    final map = File('lib/src/features/search_map.dart').readAsStringSync();

    expect(widgets, contains('class AppCategoryPictogram'));
    expect(widgets, contains("'assets/icons/categories/waterfall.svg'"));
    expect(widgets, contains("'assets/icons/categories/cave.svg'"));
    expect(home, contains('AppCategoryPictogram('));
    expect(home, contains('category.key,'));
    expect(map, contains('AppCategoryPictogram('));
    expect(map, contains("category ?? 'all'"));
  });
}
