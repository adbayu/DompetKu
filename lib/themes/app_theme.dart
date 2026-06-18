import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFF2F7BFF);

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF050B18)
          : const Color(0xFFF5F8FF),
    );
    return base.copyWith(
      textTheme: GoogleFonts.quicksandTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.quicksandTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: GoogleFonts.quicksand(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        color: brightness == Brightness.dark
            ? const Color(0xFF101A2E)
            : Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primaryContainer.withValues(alpha: .42),
        side: BorderSide(color: scheme.primary.withValues(alpha: .18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xEE071223)
            : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: .14),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? const Color(0xFF101A2E)
            : const Color(0xFFEAF0F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
