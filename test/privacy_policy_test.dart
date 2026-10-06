import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('terms acceptance metadata records the policy version and UTC time', () {
    final acceptedAt = DateTime.utc(2026, 10, 2, 12, 30);

    expect(
      AppLegalLinks.termsAcceptanceMetadata(acceptedAt),
      equals(<String, dynamic>{
        'terms_accepted_at': '2026-10-02T12:30:00.000Z',
        'terms_version': AppLegalLinks.termsVersion,
      }),
    );
  });

  testWidgets('privacy opens inside app and returns to caller', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => AppLegalLinks.openPrivacyPolicy(context),
        child: const Text('Politikayı aç'),
      ),
    ))));
    await tester.tap(find.text('Politikayı aç'));
    await tester.pumpAndSettle();
    expect(find.text('Gizlilik Politikası'), findsOneWidget);
    expect(find.text('Doğadayım'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Politikayı aç'), findsOneWidget);
  });

  testWidgets('terms opens in the same in-app document flow as privacy',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppLegalLinks.openTermsOfService(context),
            child: const Text('Koşulları aç'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Koşulları aç'));
    await tester.pumpAndSettle();

    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(find.text('Doğadayım'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Koşulları aç'), findsOneWidget);
  });
  testWidgets('privacy remains readable at phone widths and large text',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [
      const Size(320, 800),
      const Size(375, 800),
      const Size(430, 800),
      const Size(800, 375),
    ]) {
      for (final brightness in Brightness.values) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: const PrivacyPolicyScreen(),
        ));
        expect(tester.takeException(), isNull, reason: '$size / $brightness');
        expect(find.text('10. İletişim'), findsOneWidget);
        await tester.ensureVisible(find.text('10. İletişim'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
