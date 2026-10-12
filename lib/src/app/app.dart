part of '../../main.dart';

class DogaApp extends StatelessWidget {
  const DogaApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.current,
          builder: (context, locale, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Doğada',
                locale: locale,
                supportedLocales: AppLocaleController.supported,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.onPrimary,
                    secondary: AppColors.primary,
                    onSecondary: AppColors.onPrimary,
                    surface: AppColors.surface,
                    onSurface: AppColors.textPrimary,
                    error: AppColors.error,
                    onError: AppColors.onPrimary,
                  ),
                  scaffoldBackgroundColor: AppColors.background,
                  canvasColor: AppColors.surface,
                  fontFamily: 'Outfit',
                  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.6,
                    ),
                    displayMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                    headlineLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.4,
                    ),
                    headlineMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.3,
                    ),
                    headlineSmall: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.2,
                    ),
                    titleLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                    titleMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                    bodyLarge: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                    bodyMedium: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                    bodySmall: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.large,
                      vertical: AppSpacing.medium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: green, width: 1.8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.8),
                    ),
                  ),
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(AppControlSizes.button),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                    ),
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ink,
                      side: const BorderSide(color: AppColors.border, width: 1),
                      minimumSize: const Size.fromHeight(AppControlSizes.button),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                      ),
                    ),
                  ),
                  dividerTheme: const DividerThemeData(
                    color: AppColors.border,
                    thickness: 1,
                    space: 1,
                  ),
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.large),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: AppColors.surface,
                    surfaceTintColor: Colors.transparent,
                    modalBackgroundColor: AppColors.surface,
                    modalBarrierColor: AppColors.shadow33,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadii.large),
                      ),
                    ),
                  ),
                  snackBarTheme: SnackBarThemeData(
                    behavior: SnackBarBehavior.floating,
                    elevation: 0,
                    backgroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                  ),
                  chipTheme: ChipThemeData(
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    secondarySelectedColor: AppColors.primary,
                    labelStyle: AppTypography.labelOf(context),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  checkboxTheme: CheckboxThemeData(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return AppColors.surface;
                    }),
                  ),
                ),
                darkTheme: _buildDarkTheme(),
                themeMode: themeMode,
                home: const SplashScreen(),
                builder: (context, child) => Directionality(
                  textDirection: locale.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              )));
}

ThemeData _buildDarkTheme() {
  const background = AppColors.darkBackground;
  const surface = AppColors.darkSurface;
  const border = AppColors.darkBorder;
  const text = AppColors.darkTextPrimary;
  const secondaryText = AppColors.darkTextSecondary;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: green,
    brightness: Brightness.dark,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    fontFamily: 'Outfit',
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Outfit',
      bodyColor: text,
      displayColor: text,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: AppColors.darkPrimaryLight, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: text,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
        side: const BorderSide(color: border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: surface,
      modalBarrierColor: AppColors.shadow80,
      elevation: 0,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: text,
      iconColor: secondaryText,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : secondaryText,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.darkPrimary
            : border,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: AppColors.darkPrimarySoft,
      contentTextStyle: const TextStyle(color: text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
    ),
  );
}
