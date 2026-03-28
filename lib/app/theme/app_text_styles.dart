import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  final TextStyle brand = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.05,
    letterSpacing: -1.0,
  );

  final TextStyle introHeader = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: Colors.black,
    height: 1.05,
    letterSpacing: -1.0,
  );
}