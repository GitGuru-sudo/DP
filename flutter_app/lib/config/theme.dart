import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Orange & Yellow
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryYellow = Color(0xFFFFB74D);
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color lightOrange = Color(0xFFFFE0B2);
  static const Color darkOrange = Color(0xFFE65100);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Food Type Colors
  static const Color veg = Color(0xFF4CAF50);
  static const Color nonVeg = Color(0xFFF44336);
  static const Color egg = Color(0xFFFF9800);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFF8E1);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrange, primaryYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.grey50,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryYellow,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.grey900,
        onError: AppColors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
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
          foregroundColor: AppColors.primaryOrange,
          side: const BorderSide(color: AppColors.primaryOrange),
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
          foregroundColor: AppColors.primaryOrange,
          textStyle: const TextStyle(
            
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          
          color: AppColors.grey500,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          
          fontSize: 12,
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightOrange,
        selectedColor: AppColors.primaryOrange,
        labelStyle: const TextStyle(
          
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        displayMedium: TextStyle(
          
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        displaySmall: TextStyle(
          
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        headlineMedium: TextStyle(
          
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        headlineSmall: TextStyle(
          
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        titleLarge: TextStyle(
          
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        titleMedium: TextStyle(
          
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
        ),
        bodyLarge: TextStyle(
          
          fontSize: 16,
          color: AppColors.grey800,
        ),
        bodyMedium: TextStyle(
          
          fontSize: 14,
          color: AppColors.grey700,
        ),
        bodySmall: TextStyle(
          
          fontSize: 12,
          color: AppColors.grey600,
        ),
        labelLarge: TextStyle(
          
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryYellow,
        surface: AppColors.grey900,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.grey900,
        foregroundColor: AppColors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.grey800,
      ),
      
      
    );
  }
}
