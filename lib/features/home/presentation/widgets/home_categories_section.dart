import 'package:flutter/material.dart';

import '../../domain/entities/category_summary.dart';
import 'dashboard_currency.dart';

/// Shows all budget categories in a compact stacked card on the home screen.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    super.key,
    required this.categories,
  });

  final List<CategorySummary> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategooriad',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7B79),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (int i = 0; i < categories.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE8EEF3),
                    indent: 16,
                    endIndent: 16,
                  ),
                _CategoryRow(category: categories[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final CategorySummary category;

  @override
  Widget build(BuildContext context) {
    final progress = category.plannedAmount <= 0
        ? 0.0
        : (category.spentAmount / category.plannedAmount).clamp(0.0, 1.0);

    final Color statusColor;
    if (category.isOverBudget) {
      statusColor = const Color(0xFFBA1A1A);
    } else if (category.isNearLimit) {
      statusColor = const Color(0xFFB25D36);
    } else {
      statusColor = const Color(0xFF006763);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF021C36),
                      ),
                ),
              ),
              Text(
                formatCurrency(category.remainingAmount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE3EAE9),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(category.usagePercent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${formatCurrency(category.spentAmount)} / ${formatCurrency(category.plannedAmount)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7B79),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
