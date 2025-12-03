import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/constant/colors.dart';
/// App Theme Configuration
class AppTheme {
static ThemeData get lightTheme {
return ThemeData(
useMaterial3: true,
primaryColor: AppColors.primary,
scaffoldBackgroundColor: AppColors.cream,
colorScheme: const ColorScheme.light(
primary: AppColors.primary,
secondary: AppColors.orange,
error: AppColors.error,
surface: AppColors.surface,
),
// Text Theme
textTheme: GoogleFonts.interTextTheme(
const TextTheme(
displayLarge: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
displayMedium: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
displaySmall: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
headlineLarge: TextStyle(
fontSize: 22,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
headlineMedium: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
headlineSmall: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
titleLarge: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
titleMedium: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
titleSmall: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
bodyLarge: TextStyle(
fontSize: 16,
color: AppColors.textPrimary,
),
bodyMedium: TextStyle(
fontSize: 14,
color: AppColors.textPrimary,
),
bodySmall: TextStyle(
fontSize: 12,
color: AppColors.textSecondary,
),
labelLarge: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w500,
color: AppColors.textPrimary,
),
labelMedium: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w500,
color: AppColors.textPrimary,
),
labelSmall: TextStyle(
fontSize: 11,
fontWeight: FontWeight.w500,
color: AppColors.textSecondary,
),
),
),
// AppBar Theme
appBarTheme: const AppBarTheme(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
centerTitle: false,
titleTextStyle: TextStyle(
fontSize: 20,
fontWeight: FontWeight.w600,
color: Colors.white,
),
),
// Card Theme
cardTheme: CardThemeData(
color: Colors.white,
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
// Button Theme
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 2,
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
textStyle: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
outlinedButtonTheme: OutlinedButtonThemeData(
style: OutlinedButton.styleFrom(
foregroundColor: AppColors.primary,
side: const BorderSide(color: AppColors.primary, width: 1.5),
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
textStyle: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: AppColors.primary,
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
textStyle: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
),
// Input Theme
inputDecorationTheme: InputDecorationTheme(
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide(
color: AppColors.textSecondary.withOpacity(0.1),
),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.primary,
width: 2,
),
),
errorBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: AppColors.error,
),
),
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 16,
),
),
// Bottom Navigation
bottomNavigationBarTheme: const BottomNavigationBarThemeData(
backgroundColor: Colors.white,
selectedItemColor: AppColors.primary,
unselectedItemColor: AppColors.textSecondary,
type: BottomNavigationBarType.fixed,
elevation: 8,
),
);
}
static ThemeData get darkTheme {
// Dark theme akan diimplementasi nanti jika diperlukan
return lightTheme;
}
}
