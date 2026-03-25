import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

enum StatusCardType { info, success, warning }

class StatusCard extends StatelessWidget {
  final StatusCardType type;
  final String title;
  final String message;

  const StatusCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusCardType.success:
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case StatusCardType.warning:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      case StatusCardType.info:
        bg = AppColors.infoBg;
        fg = AppColors.info;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(color: fg)),
          const SizedBox(height: 6),
          Text(message, style: AppTextStyles.body.copyWith(color: fg)),
        ],
      ),
    );
  }
}