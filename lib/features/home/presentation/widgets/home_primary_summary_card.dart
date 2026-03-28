import 'package:flutter/material.dart';

import '../../domain/entities/home_summary.dart';
import 'dashboard_currency.dart';

class HomePrimarySummaryCard extends StatelessWidget {
  const HomePrimarySummaryCard({
    super.key,
    required this.summary,
  });

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final distributable = summary.distributableAmount <= 0
        ? 1.0
        : summary.distributableAmount;
    final progress = (summary.safelySpendable / distributable).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EAE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turvaliselt kulutatav'.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6B7B79),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(summary.safelySpendable),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF006763),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE7EFEE),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF006763)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF6B7B79),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
