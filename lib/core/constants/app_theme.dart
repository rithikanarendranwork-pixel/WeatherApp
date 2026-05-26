import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Tokens ────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const Color nightBase    = Color(0xFF0C1220);
  static const Color nightDeep    = Color(0xFF060D18);
  static const Color skyDay       = Color(0xFF2979FF);
  static const Color skyMid       = Color(0xFF1565C0);
  static const Color glass        = Color(0x1AFFFFFF);
  static const Color glassBorder  = Color(0x26FFFFFF);
  static const Color glassDark    = Color(0x0DFFFFFF);
  static const Color white        = Colors.white;
  static const Color white70      = Color(0xB3FFFFFF);
  static const Color white40      = Color(0x66FFFFFF);
  static const Color white20      = Color(0x33FFFFFF);
  static const Color accent       = Color(0xFF64B5F6);
  static const Color accentWarm   = Color(0xFFFFB74D);
  static const Color success      = Color(0xFF81C784);
  static const Color error        = Color(0xFFEF9A9A);

  // Dynamic weather gradients keyed by OWM condition group
  static const Map<String, List<Color>> conditionGradients = {
    'Clear':       [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF90CAF9)],
    'Clouds':      [Color(0xFF37474F), Color(0xFF546E7A), Color(0xFF78909C)],
    'Rain':        [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
    'Drizzle':     [Color(0xFF263238), Color(0xFF37474F), Color(0xFF546E7A)],
    'Thunderstorm':[Color(0xFF0D0D0D), Color(0xFF1A237E), Color(0xFF311B92)],
    'Snow':        [Color(0xFF78909C), Color(0xFFB0BEC5), Color(0xFFECEFF1)],
    'Mist':        [Color(0xFF455A64), Color(0xFF607D8B), Color(0xFF90A4AE)],
    'Fog':         [Color(0xFF455A64), Color(0xFF607D8B), Color(0xFF90A4AE)],
    'Haze':        [Color(0xFF4E342E), Color(0xFF6D4C41), Color(0xFF8D6E63)],
    'Smoke':       [Color(0xFF212121), Color(0xFF424242), Color(0xFF616161)],
    'Dust':        [Color(0xFF5D4037), Color(0xFF795548), Color(0xFFA1887F)],
    'Sand':        [Color(0xFF5D4037), Color(0xFF795548), Color(0xFFA1887F)],
    'Ash':         [Color(0xFF212121), Color(0xFF424242), Color(0xFF616161)],
    'Squall':      [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
    'Tornado':     [Color(0xFF212121), Color(0xFF37474F), Color(0xFF546E7A)],
  };

  static List<Color> gradientForCondition(String condition) =>
      conditionGradients[condition] ??
      [nightDeep, nightBase, const Color(0xFF1C2840)];
}

// ─── Text Styles ─────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle tempHero(double fontSize) => GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w100,
        color: AppColors.white,
        letterSpacing: -3,
        height: 1.0,
      );

  static TextStyle cityName = GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle condition = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.white70,
    letterSpacing: 2.5,
  );

  static TextStyle sectionLabel = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.white40,
    letterSpacing: 2.0,
  );

  static TextStyle cardValue = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle cardLabel = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.white70,
  );

  static TextStyle body = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white70,
  );

  static TextStyle bodyBold = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle searchHint = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.white40,
  );
}

// ─── Material Theme ───────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.nightBase,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.skyDay,
          secondary: AppColors.accent,
          surface: AppColors.nightBase,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      );
}
