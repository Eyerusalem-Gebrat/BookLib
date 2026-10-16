import 'package:flutter/material.dart';

/// BookLib Mobile Design System Tokens
/// Perfectly mirroring the web app's editorial aesthetic:
/// Warm Cream/Peach Canvas, Pure White Cards, Terracotta Sienna Accents & Editorial Serif Typography
class AppTheme {
  // 1. Page Canvas & Headers
  static const Color pageBg = Color(0xFFFAF4ED);
  static const Color headerBg = Color(0xFFFAF0E6);
  static const Color headerBorder = Color(0xFFF0E2D3);
  static const Color headerLogo = Color(0xFF8D3B0D);

  // 2. Cards & Inset Surfaces
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF2E7DC);
  static const Color surfaceInset = Color(0xFFFCF3EC);
  static const Color inputBorder = Color(0xFFF4E6D8);
  static const Color inputPlaceholder = Color(0xFFA59284);

  // 3. Text Colors
  static const Color text = Color(0xFF1F160F);
  static const Color textMuted = Color(0xFF766355);
  static const Color textLight = Color(0xFF9E8C7F);

  // 4. Primary & Terracotta Accents
  static const Color primary = Color(0xFF8D3B0D);
  static const Color primaryHover = Color(0xFF783009);
  static const Color kicker = Color(0xFF9E4416);
  static const Color accentLight = Color(0xFFFBEBE1);
  static const Color statusWantBorder = Color(0xFFF5D8C6);

  // 5. Buttons
  static const Color btnCardBg = Color(0xFFFBECE3);
  static const Color btnCardBorder = Color(0xFFF3DFD1);
  static const Color btnCardText = Color(0xFF2B1911);

  // 6. Badges & Progress
  static const Color badgeIconBg = Color(0xFFFBECE2);
  static const Color badgeGreenBg = Color(0xFFE3EDE2);
  static const Color badgeGreenText = Color(0xFF234E38);
  static const Color progressTrack = Color(0xFFEEDDD0);

  // 7. Reading Salon Banner & Footer
  static const Color salonBannerBg = Color(0xFFFCF1E7);
  static const Color salonBannerBorder = Color(0xFFF3DFD1);
  static const Color footerBg = Color(0xFFFAF0E6);
  static const Color footerBorder = Color(0xFFF0E2D3);

  // 8. Typography
  static const String fontSerif = 'Georgia';

  // 9. Shadows
  static const BoxShadow shadowSm = BoxShadow(
    color: Color(0x0DA06E46),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14A06E46),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow authCardShadow = BoxShadow(
    color: Color(0x1EA06E46),
    blurRadius: 36,
    offset: Offset(0, 12),
  );

  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x388D3B0D),
    blurRadius: 14,
    offset: Offset(0, 4),
  );

  // 10. ThemeData definition
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardBg,
        onSurface: text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          fontFamily: fontSerif,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: headerLogo,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInset,
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: inputPlaceholder, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
