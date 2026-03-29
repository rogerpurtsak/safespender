import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/budget_mood.dart';
import '../../domain/entities/remote_insight.dart';

class RemoteInsightCard extends StatelessWidget {
  const RemoteInsightCard({super.key, required this.insight});

  final RemoteInsight insight;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(insight.mood);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (insight.gifUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: insight.gifUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
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

_InsightColors _resolveColors(BudgetMood mood) {
  switch (mood) {
    case BudgetMood.good:
      return const _InsightColors(
        background: Color(0xFFEAF8F5),
        border: Color(0xFFCBE9E1),
        iconBackground: Color(0xFFBFE7E3),
        iconColor: Color(0xFF006763),
        icon: Icons.sentiment_very_satisfied_outlined,
        titleColor: Color(0xFF006763),
        messageColor: Color(0xFF3F5A57),
      );
    case BudgetMood.medium:
      return const _InsightColors(
        background: Color(0xFFFFF5E8),
        border: Color(0xFFFFE1B0),
        iconBackground: Color(0xFFFFE9C7),
        iconColor: Color(0xFF9A5C00),
        icon: Icons.sentiment_neutral_outlined,
        titleColor: Color(0xFF9A5C00),
        messageColor: Color(0xFF6F5937),
      );
    case BudgetMood.critical:
      return const _InsightColors(
        background: Color(0xFFFFECE9),
        border: Color(0xFFF4C7C2),
        iconBackground: Color(0xFFFFDAD6),
        iconColor: Color(0xFFBA1A1A),
        icon: Icons.sentiment_very_dissatisfied_outlined,
        titleColor: Color(0xFFBA1A1A),
        messageColor: Color(0xFF6D4B48),
      );
  }
}
