import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  GLOBAL COLOR PALETTE
//  Change any color here and the whole UI updates
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color scaffold = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceAlt = Color(0xFF1A1A24);

  // Accent – purple / violet core
  static const Color accent1 = Color(0xFF8B51F5); // vivid purple
  static const Color accent2 = Color(0xFFD673E8); // soft pink
  static const Color accent3 = Color(0xFF6E9DEB); // blue tint

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B5);
  static const Color textMuted = Color(0xFF606070);

  // Border / divider
  static const Color border = Color(0xFF252535);
}

// ─────────────────────────────────────────────
//  GRADIENT PALETTE
// ─────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  /// Purple → Pink (primary accent gradient used across the UI)
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accent1, AppColors.accent2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple → Pink → Blue (AI bubble background)
  static const LinearGradient aiBubble = LinearGradient(
    colors: [Color(0xFF7B3FE4), Color(0xFFCC66DB), Color(0xFF5B8EDB)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark subtle gradient for user bubble
  static const LinearGradient userBubble = LinearGradient(
    colors: [Color(0xFF1E1E2E), Color(0xFF252535)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// AppBar / top section glow gradient
  static const LinearGradient appBarGlow = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF13101E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Input area background
  static const LinearGradient inputArea = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF0F0F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Send button gradient
  static const LinearGradient sendButton = LinearGradient(
    colors: [AppColors.accent1, AppColors.accent2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
//  APP BAR THEME
// ─────────────────────────────────────────────
class AppBarThemeConfig {
  AppBarThemeConfig._();

  static const Color background = AppColors.scaffold;
  static const Color iconColor = AppColors.textPrimary;
  static const TextStyle titleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
}

// ─────────────────────────────────────────────
//  CHAT BUBBLE THEME
// ─────────────────────────────────────────────
class ChatBubbleTheme {
  ChatBubbleTheme._();

  // User bubble
  static const Gradient userGradient = AppGradients.userBubble;
  static const Color userText = AppColors.textPrimary;
  static const BorderRadius userRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(4),
  );

  // AI bubble
  static const Gradient aiGradient = AppGradients.aiBubble;
  static const Color aiText = AppColors.textPrimary;
  static const BorderRadius aiRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(20),
  );

  // Glow / shadow for AI bubble
  static List<BoxShadow> get aiGlow => [
    BoxShadow(
      color: AppColors.accent1.withAlpha(70),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get userShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(100),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static const double maxWidthFraction = 0.78;
  static const EdgeInsets padding = EdgeInsets.all(14);
  static const EdgeInsets verticalMargin = EdgeInsets.symmetric(vertical: 6);
}

// ─────────────────────────────────────────────
//  INPUT AREA THEME
// ─────────────────────────────────────────────
class InputAreaTheme {
  InputAreaTheme._();

  static const EdgeInsets padding = EdgeInsets.fromLTRB(12, 10, 12, 10);
  static const Gradient background = AppGradients.inputArea;
  static const Color textFieldBg = AppColors.surfaceAlt;
  static const Color textFieldBorder = AppColors.border;
  static const Color hintColor = AppColors.textMuted;
  static const Color textColor = AppColors.textPrimary;
  static const Color attachIcon = AppColors.accent2;
  static const Gradient sendButtonGradient = AppGradients.sendButton;
  static const Color sendButtonIcon = AppColors.textPrimary;
  static const BorderRadius textFieldRadius = BorderRadius.all(
    Radius.circular(28),
  );
  static const TextStyle textStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
  );
}

// ─────────────────────────────────────────────
//  SCAFFOLD / BACKGROUND THEME
// ─────────────────────────────────────────────
class ScaffoldTheme {
  ScaffoldTheme._();

  static const Color background = AppColors.scaffold;
}

// ─────────────────────────────────────────────
//  ROOT MATERIAL THEME
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffold,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent1,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.accent2,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppBarThemeConfig.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppBarThemeConfig.iconColor),
      titleTextStyle: AppBarThemeConfig.titleStyle,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent2,
      selectionColor: Color(0x558B51F5),
      selectionHandleColor: AppColors.accent1,
    ),
  );
}
