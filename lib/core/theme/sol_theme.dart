import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sol_colors.dart';

abstract final class SolTheme {
  static ThemeData buildLightTheme() {
    final TextTheme baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SolColors.dawn,
      colorScheme: const ColorScheme.light(
        primary: SolColors.cocoa,
        onPrimary: SolColors.cream,
        secondary: SolColors.gold,
        surface: SolColors.cream,
        onSurface: SolColors.cocoa,
        error: SolColors.destructive,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w700,
          fontSize: 30,
          letterSpacing: -0.6,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: SolColors.cocoa,
          fontSize: 15.5,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: SolColors.clayDeep,
          fontSize: 14,
          height: 1.45,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: SolColors.clayDeep,
          fontSize: 12.5,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: SolColors.cocoa,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: SolColors.clayDeep,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.7,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SolColors.dawn,
        foregroundColor: SolColors.cocoa,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: SolColors.hair,
    );
  }
}
