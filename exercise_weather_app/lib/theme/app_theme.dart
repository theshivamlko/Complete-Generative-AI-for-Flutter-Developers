import 'package:flutter/material.dart';

class AppColors {
  static const Color seedBlue = Color(0xFF2F80ED);
  static const Color primaryDarkBlue = Color(0xFF1A3A6B);
  static const Color accentCyan = Color(0xFF56CCF2);
  static const Color statusTeal = Color(0xFF4ECDC4);
  static const Color backgroundLight = Color(0xFFF0F6FF);
  static const Color inputBorder = Color(0xFFBDD3EF);
  static const Color textDark = Color(0xFF1A2E4A);
  static const Color textMuted = Color(0xFF9EAEC0);
  static const Color botBubbleStart = Color(0xFFE8F4FD);
  static const Color botBubbleEnd = Color(0xFFDDEEFB);
  static const Color userBubbleStart = Color(0xFFFF9966);
  static const Color userBubbleEnd = Color(0xFFFF5E62);
}

class AppGradients {
  static const LinearGradient header = LinearGradient(
    colors: [AppColors.primaryDarkBlue, AppColors.seedBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient botAvatar = LinearGradient(
    colors: [AppColors.accentCyan, AppColors.seedBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient userAvatar = LinearGradient(
    colors: [AppColors.userBubbleStart, AppColors.userBubbleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient botBubble = LinearGradient(
    colors: [AppColors.botBubbleStart, AppColors.botBubbleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sendButton = LinearGradient(
    colors: [AppColors.accentCyan, AppColors.seedBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.seedBlue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
}

