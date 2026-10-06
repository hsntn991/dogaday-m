import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GoodnessMovementScreen renders properly in light theme', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const GoodnessMovementScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İyilik Harekâtı'), findsOneWidget);
    expect(find.text('İyilik yap, şehrini zirveye taşı.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MainShell renders Goodness tab in light mode', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    AppThemeController.mode.value = ThemeMode.light;
    await AppLocaleController.setLocale(const Locale('tr'));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const MainShell(),
      ),
    );
    await tester.pump();
    final notNow = find.text(AppStrings.get('location_dialog_not_now'));
    if (notNow.evaluate().isNotEmpty) {
      await tester.tap(notNow);
      await tester.pump();
    }

    // Tap on Goodness tab (İyilik)
    final goodnessTab = find.byIcon(Icons.volunteer_activism_outlined);
    expect(goodnessTab, findsOneWidget);
    await tester.tap(goodnessTab);
    await tester.pump();

    expect(find.text('İyilik Harekâtı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
