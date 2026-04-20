// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/app_constants.dart';

class AppTheme {
  /// 浅色主题 (Crystal)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.bgLightSecondary,
        surfaceContainerHighest: AppColors.bgLightTertiary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: null, // 使用系统默认字体
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      inputDecorationTheme: _buildInputTheme(Brightness.light),
      dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.05), thickness: 1),
      iconTheme: const IconThemeData(color: AppColors.textSecondaryLight, size: AppSizes.iconL),
      appBarTheme: _buildAppBarTheme(Brightness.light),
    );
  }

  /// 深色主题 (Obsidian)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.bgDarkSecondary,
        surfaceContainerHighest: AppColors.bgDarkTertiary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: null, // 使用系统默认字体
      textTheme: _buildTextTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      inputDecorationTheme: _buildInputTheme(Brightness.dark),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.1), thickness: 1),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: AppSizes.iconL),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondaryColor = brightness == Brightness.dark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final mutedColor = brightness == Brightness.dark ? AppColors.textMuted : AppColors.textMutedLight;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: color, letterSpacing: -1.0),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.8),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: color, height: 1.4),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: secondaryColor, height: 1.4),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: mutedColor),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor, letterSpacing: 0.1),
    );
  }

  static CardThemeData _buildCardTheme(Brightness brightness) {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
      color: brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.black.withOpacity(0.03),
    );
  }

  static InputDecorationTheme _buildInputTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: brightness == Brightness.dark ? AppColors.textMuted : AppColors.textMutedLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingM),
    );
  }

  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      ),
      iconTheme: IconThemeData(
        color: brightness == Brightness.dark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      ),
    );
  }

  /// 液态玻璃主题配置 (iOS 26 Liquid)
  static GlassThemeData get glassTheme {
    return GlassThemeData(
      light: GlassThemeVariant(
        settings: GlassThemeSettings(
          thickness: 25,
          blur: 15,
        ),
        quality: GlassQuality.standard,
      ),
      dark: GlassThemeVariant(
        settings: GlassThemeSettings(
          thickness: 40,
          blur: 25,
        ),
        quality: GlassQuality.standard,
      ),
    );
  }
}
