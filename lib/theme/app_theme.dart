import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF0D0D14);
  static const Color surface = Color(0xFF16161F);
  static const Color card = Color(0xFF1E1E2A);
  static const Color cardLight = Color(0xFF252535);
  static const Color primary = Color(0xFF00C6A0);   // Verde Groq
  static const Color primaryDark = Color(0xFF009E80);
  static const Color accent = Color(0xFF7C6BFF);
  static const Color userBubble = Color(0xFF1A2A40);
  static const Color aiBubble = Color(0xFF1A1E2E);
  static const Color error = Color(0xFFFF5F7E);
  static const Color textPrimary = Color(0xFFEEEEF5);
  static const Color textSecondary = Color(0xFF8A8AA8);
  static const Color divider = Color(0xFF252535);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary),
        hintStyle: GoogleFonts.inter(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerColor: divider,
    );
  }
}
