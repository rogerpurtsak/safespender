import 'package:flutter/material.dart';

import '../../domain/entities/home_insight.dart';

class HomeInsightCard extends StatelessWidget {
  const HomeInsightCard({
    super.key,
    required this.insight,
  });

  final HomeInsight insight;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(insight.tone);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(colors.icon, color: colors.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.messageColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightColors {
  const _InsightColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.titleColor,
    required this.messageColor,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final Color titleColor;
  final Color messageColor;
}

_InsightColors _resolveColors(HomeInsightTone tone) {
  switch (tone) {
    case HomeInsightTone.positive:
      return const _InsightColors(
        background: Color(0xFFEAF8F5),
        border: Color(0xFFCBE9E1),
        iconBackground: Color(0xFFBFE7E3),
        iconColor: Color(0xFF006763),
        icon: Icons.lightbulb_outline,
        titleColor: Color(0xFF006763),
        messageColor: Color(0xFF3F5A57),
      );
    case HomeInsightTone.warning:
      return const _InsightColors(
        background: Color(0xFFFFF5E8),
        border: Color(0xFFFFE1B0),
        iconBackground: Color(0xFFFFE9C7),
        iconColor: Color(0xFF9A5C00),
        icon: Icons.warning_amber_rounded,
        titleColor: Color(0xFF9A5C00),
        messageColor: Color(0xFF6F5937),
      );
    case HomeInsightTone.danger:
      return const _InsightColors(
        background: Color(0xFFFFECE9),
        border: Color(0xFFF4C7C2),
        iconBackground: Color(0xFFFFDAD6),
        iconColor: Color(0xFFBA1A1A),
        icon: Icons.error_outline,
        titleColor: Color(0xFFBA1A1A),
        messageColor: Color(0xFF6D4B48),
      );
    case HomeInsightTone.neutral:
      return const _InsightColors(
        background: Color(0xFFF1F6F6),
        border: Color(0xFFD9E4E3),
        iconBackground: Color(0xFFE3ECEB),
        iconColor: Color(0xFF436C68),
        icon: Icons.info_outline,
        titleColor: Color(0xFF436C68),
        messageColor: Color(0xFF4E6160),
      );
  }
}
