import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, color: AppColors.textSecondary,
  );
  static const TextStyle price = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static const TextStyle badge = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}
