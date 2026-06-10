import 'package:flutter/material.dart';

class AppTheme {
  // Colors - Professional color palette
  static const Color primaryColor = Color(0xFF1976D2); // Professional blue
  static const Color primaryDark = Color(0xFF0D47A1); // Darker blue
  static const Color accentColor = Color(0xFF00BCD4); // Cyan accent
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color correctColor = Color(0xFF4CAF50); // Green - 3.3:1 contrast on white
  static const Color incorrectColor = Color(0xFFF44336); // Red - 4.0:1 contrast on white
  static const Color lockedColor = Color(0xFF9E9E9E); // Gray - 2.8:1 contrast on white
  static const Color masteredColor = Color(0xFFFFB300); // Amber gold - 2.4:1 contrast on white
  static const Color warningColor = Color(0xFFFF9800); // Orange - 2.9:1 contrast on white
  // Note: Colors with lower contrast ratios are always paired with icons and text labels
  // to ensure accessibility compliance (WCAG 2.1 Level AA)
  static const Color infoColor = Color(0xFF2196F3); // Blue - 3.1:1 contrast on white
  static const Color surfaceColor = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textDisabled = Colors.grey;

  // Font fallback so Tamil script (தமிழ்) renders correctly alongside the
  // primary Latin font. Bilingual UI strings (see AppStrings) rely on this.
  static const List<String> tamilFontFallback = ['Noto Sans Tamil'];

  // Text styles - Large, readable fonts suitable for school-age students
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 18,
    color: textPrimary,
    height: 1.5,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 16,
    color: textPrimary,
    height: 1.5,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
    fontFamilyFallback: tamilFontFallback,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.4,
    fontFamilyFallback: tamilFontFallback,
  );

  // Spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Animation durations (in milliseconds)
  static const int animationFast = 100;
  static const int animationNormal = 200;
  static const int animationMedium = 300;
  static const int animationSlow = 500;

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: 'Roboto',
      // Ensures Tamil script falls back to a font with full Tamil coverage.
      fontFamilyFallback: tamilFontFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        error: incorrectColor,
      ),
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        displaySmall: headline3,
        bodyLarge: bodyText1,
        bodyMedium: bodyText2,
        bodySmall: caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          minimumSize: const Size(48, 48),
          elevation: 3,
          shadowColor: Colors.black26,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          minimumSize: const Size(48, 48),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(48, 48),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        margin: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white, // Selected tab text color - WHITE for visibility
        unselectedLabelColor: Colors.white70, // Unselected tab text - semi-transparent white
        indicatorColor: accentColor, // Cyan indicator for better contrast
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.3,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXS),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: accentColor,
            width: 3,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        size: 24,
        color: textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: spacingM,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: bodyText2.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        elevation: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Colors.grey,
        circularTrackColor: Colors.grey,
      ),
      // Page transitions with animations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Helper method to create a box shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // Helper method for input decoration
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon),
              onPressed: onSuffixIconTap,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: incorrectColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    );
  }
}
