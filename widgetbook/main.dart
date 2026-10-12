import 'package:dogada_gezi/main.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Geliştirme sırasında uygulamayı açmadan temel arayüz durumlarını denetlemek
/// için ayrı giriş noktası. Üretim uygulamasında çalıştırılmaz.
void main() => runApp(const DogaWidgetbook());

class DogaWidgetbook extends StatelessWidget {
  const DogaWidgetbook({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
        initialRoute: '?path=foundations/buttons/primary-and-secondary',
        lightTheme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const _DogaWidgetbookHome(),
        directories: [
          WidgetbookCategory(
            name: 'Foundations',
            children: [
              WidgetbookComponent(
                name: 'Buttons',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Primary and secondary',
                    builder: (context) => const _ButtonShowcase(),
                  ),
                  WidgetbookUseCase(
                    name: 'Disabled',
                    builder: (context) => const _DisabledButtonShowcase(),
                  ),
                ],
              ),
              WidgetbookComponent(
                name: 'Feedback',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Retry',
                    builder: (context) => AppFeedbackCard(
                      icon: Icons.location_off_outlined,
                      title: 'Yakındaki yerler alınamadı',
                      message: 'Bağlantını kontrol edip yeniden dene.',
                      actionLabel: 'Tekrar dene',
                      onAction: () {},
                    ),
                  ),
                  WidgetbookUseCase(
                    name: 'No results',
                    builder: (context) => const AppFeedbackCard(
                      icon: Icons.search_off_outlined,
                      title: 'Sonuç bulunamadı',
                      message: 'Arama ifadesini veya filtreleri değiştir.',
                    ),
                  ),
                ],
              ),
              WidgetbookComponent(
                name: 'Loading',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Content placeholder',
                    builder: (context) => const AppLoadingCard(height: 156),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}

class _DogaWidgetbookHome extends StatelessWidget {
  const _DogaWidgetbookHome();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: _ButtonShowcase(),
            ),
          ),
        ),
      );
}

class _ButtonShowcase extends StatelessWidget {
  const _ButtonShowcase();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(label: 'Keşfe başla'),
            SizedBox(height: AppSpacing.compact),
            AppSecondaryButton(label: 'Daha sonra'),
            SizedBox(height: AppSpacing.compact),
            Align(
              alignment: Alignment.centerLeft,
              child: AppTextButton(label: 'Yeniden dene'),
            ),
          ],
        ),
      );
}

class _DisabledButtonShowcase extends StatelessWidget {
  const _DisabledButtonShowcase();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(label: 'Kaydediliyor'),
            SizedBox(height: AppSpacing.compact),
            AppSecondaryButton(label: 'Devam et'),
          ],
        ),
      );
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final primary = dark ? AppColors.darkPrimary : AppColors.primary;
  final onSurface = dark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  final surface = dark ? AppColors.darkSurface : AppColors.surface;
  final border = dark ? AppColors.darkBorder : AppColors.border;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor:
        dark ? AppColors.darkBackground : AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      onSurface: onSurface,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
  );
}
