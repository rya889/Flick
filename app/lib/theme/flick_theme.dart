import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Signal Coral design tokens from docs/03-ui-ux-spec.md
class FlickColors {
  static const bgLight = Color(0xFFF7F4F1);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF14151A);
  static const inkMutedLight = Color(0xFF5C5F6A);
  static const signalLight = Color(0xFFFF3B2E);
  static const signalSoftLight = Color(0x22FF3B2E);

  static const bgDark = Color(0xFF0E0F12);
  static const surfaceDark = Color(0xFF1A1C22);
  static const inkDark = Color(0xFFF2F0EC);
  static const inkMutedDark = Color(0xFF9A9DA8);
  static const signalDark = Color(0xFFFF5A4F);
  static const signalSoftDark = Color(0x33FF5A4F);

  static const successLight = Color(0xFF1F8A5B);
  static const successDark = Color(0xFF3DDC97);
}

ThemeData buildFlickTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final bg = dark ? FlickColors.bgDark : FlickColors.bgLight;
  final surface = dark ? FlickColors.surfaceDark : FlickColors.surfaceLight;
  final ink = dark ? FlickColors.inkDark : FlickColors.inkLight;
  final muted = dark ? FlickColors.inkMutedDark : FlickColors.inkMutedLight;
  final signal = dark ? FlickColors.signalDark : FlickColors.signalLight;

  final display = GoogleFonts.frauncesTextTheme().apply(
    bodyColor: ink,
    displayColor: ink,
  );
  final body = GoogleFonts.sourceSerif4TextTheme().apply(
    bodyColor: ink,
    displayColor: ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: signal,
      onPrimary: Colors.white,
      secondary: signal,
      onSecondary: Colors.white,
      error: dark ? const Color(0xFFFF8A80) : const Color(0xFFB00020),
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
    ),
    textTheme: body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.55, fontSize: 18),
      bodyMedium: body.bodyMedium?.copyWith(color: muted),
      labelLarge: GoogleFonts.syne(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: signal,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return ink;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return signal;
          return surface;
        }),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: ink),
    ),
  );
}
