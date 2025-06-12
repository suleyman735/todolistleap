import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolistleap/core/constant/colors.dart';

class AppTypography {
  static TextStyle headlineLarge = GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static TextStyle headlineMedium = GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.text,
  );

  static TextStyle bodyLarge = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal, // Regular
    color: AppColors.text,
  );

  static TextStyle bodyMedium = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal, // Regular
    color: AppColors.text,
  );

  static TextStyle labelSmall = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal, // Regular
    color: AppColors.text,
  );
}