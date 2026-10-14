import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;

  static InputDecorationTheme _inputTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusedColor,
    required Color labelColor,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: BorderSide(color: borderColor),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: focusedColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: labelColor.withValues(alpha: 0.7)),
      prefixIconColor: AppColors.primaryRose,
    );
  }

  static ButtonStyle _elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryRose,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.softRose.withValues(alpha: 0.5),
      disabledForegroundColor: Colors.white70,
      elevation: 0,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryRose,
        secondary: AppColors.softRose,
        surface: AppColors.warmSurface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: AppColors.deepCharcoal,
        onSurface: AppColors.deepCharcoal,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.warmCream,
      dividerColor: AppColors.warmBrown.withValues(alpha: 0.12),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmCream,
        foregroundColor: AppColors.deepCharcoal,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.deepCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedStyle()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRose,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRose,
          side: const BorderSide(color: AppColors.primaryRose),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRose,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      cardTheme: CardThemeData(
        color: AppColors.warmSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: AppColors.softRose.withValues(alpha: 0.22)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: AppColors.warmSurface,
        borderColor: AppColors.warmBrown.withValues(alpha: 0.2),
        focusedColor: AppColors.primaryRose,
        labelColor: AppColors.warmBrown,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.warmSurface,
        selectedItemColor: AppColors.primaryRose,
        unselectedItemColor: AppColors.warmBrown.withValues(alpha: 0.55),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.warmSurface,
        indicatorColor: AppColors.blush,
        elevation: 1,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.primaryRose
                : AppColors.warmBrown.withValues(alpha: 0.55),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? AppColors.primaryRose
                : AppColors.warmBrown.withValues(alpha: 0.55),
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.blush,
        selectedColor: AppColors.softRose,
        labelStyle: const TextStyle(color: AppColors.deepCharcoal, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryRose,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
        showDragHandle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF1F1B1D);
    const darkSurface = Color(0xFF2A2428);
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.softRose,
        secondary: AppColors.primaryRose,
        surface: darkSurface,
        error: AppColors.danger,
        onPrimary: AppColors.deepCharcoal,
        onSecondary: Colors.white,
        onSurface: AppColors.warmCream,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBg,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: AppColors.warmCream,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.warmCream,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedStyle()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.softRose,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.softRose,
          side: const BorderSide(color: AppColors.softRose),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRose,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: darkSurface,
        borderColor: Colors.white.withValues(alpha: 0.12),
        focusedColor: AppColors.softRose,
        labelColor: AppColors.softRose.withValues(alpha: 0.8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkSurface,
        selectedItemColor: AppColors.softRose,
        unselectedItemColor: AppColors.warmCream.withValues(alpha: 0.45),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: AppColors.primaryRose.withValues(alpha: 0.28),
        elevation: 1,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.softRose
                : AppColors.warmCream.withValues(alpha: 0.45),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? AppColors.softRose
                : AppColors.warmCream.withValues(alpha: 0.45),
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: AppColors.primaryRose.withValues(alpha: 0.35),
        labelStyle: const TextStyle(color: AppColors.warmCream, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.softRose,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
        showDragHandle: true,
      ),
    );
  }
}
