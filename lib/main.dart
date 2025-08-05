// =============================================================================
// | main.dart (Entry Point Aplikasi)                                        |
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

// --- Halaman-halaman Aplikasi (Screens) ---
// Biasanya file-file ini dipisah ke dalam folder `lib/screens/`
part 'screens/login_screen.dart';
part 'screens/register_screen.dart';
part 'screens/event_list_screen.dart';
part 'screens/create_event_screen.dart';
part 'screens/splash_screen.dart'; // Pastikan ini ada dan merujuk ke file yang benar

// --- Service untuk Komunikasi API ---
// Biasanya file ini ditaruh di `lib/services/`
part 'services/api_service.dart';

// --- Model Data ---
// Biasanya file ini ditaruh di `lib/models/`
part 'models/event.dart';

// --- Utilitas (misal: warna) ---
// Biasanya file ini ditaruh di `lib/utils/`
part 'utils/app_colors.dart';


void main() {
  runApp(const AcaraKitaApp());
}

class AcaraKitaApp extends StatelessWidget {
  const AcaraKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Google Fonts untuk tampilan yang lebih modern
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'AcaraKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primaryMaterialColor,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(textTheme).copyWith(
          bodyLarge: GoogleFonts.inter(textStyle: textTheme.bodyLarge),
          bodyMedium: GoogleFonts.inter(textStyle: textTheme.bodyMedium),
          displayLarge: GoogleFonts.inter(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.inter(textStyle: textTheme.displayMedium, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.inter(textStyle: textTheme.displaySmall, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.inter(textStyle: textTheme.headlineMedium, fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.inter(textStyle: textTheme.headlineSmall, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.inter(textStyle: textTheme.titleLarge, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primaryText),
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.secondaryText),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      home: const SplashScreen(), // Mengatur SplashScreen sebagai halaman awal
    );
  }
}