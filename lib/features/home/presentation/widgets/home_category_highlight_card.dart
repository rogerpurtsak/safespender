import 'package:flutter/material.dart';

import '../../domain/entities/category_summary.dart';
import 'dashboard_currency.dart';

class HomeCategoryHighlightCard extends StatelessWidget {
  const HomeCategoryHighlightCard({
    super.key,
    required this.category,
  });

  final CategorySummary category;

  @override
  Widget build(BuildContext context) {
    final progress = category.plannedAmount <= 0
        ? 0.0
        : (category.spentAmount / category.plannedAmount).clamp(0.0, 1.0);

    final progressColor = category.isOverBudget
        ? const Color(0xFFBA1A1A)
        : category.isNearLimit
            ? const Color(0xFFB25D36)
            : const Color(0xFF006763);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Color(0xFF006763),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(category.plannedAmount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7B79),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'jääk: ${formatCurrency(category.remainingAmount)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE3EAE9),
                    valueColor: AlwaysStoppedAnimation(progressColor),
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
