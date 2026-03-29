import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../domain/models/category_budget_overview.dart';
import '../domain/models/category_budget_status.dart';
import 'providers/grocery_overview_provider.dart';

class GroceryOverviewScreen extends ConsumerWidget {
  const GroceryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(categoryBudgetOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: e.toString()),
          data: (state) {
            if (!state.isConfigured) {
              return const _NotConfiguredState();
            }
            if (!state.hasCategories) {
              return const _NoCategoriesState();
            }
            return _OverviewBody(state: state);
          },
        ),
      ),
    );
  }
}


class _OverviewBody extends ConsumerWidget {
  const _OverviewBody({required this.state});

  final CategoryBudgetOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthLabel = '${_estonianMonth(now.month)} ${now.year}';

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(categoryBudgetOverviewProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _ScreenHeader(monthLabel: monthLabel),
          const SizedBox(height: 8),
          _MonthSummaryRow(overviews: state.overviews),
          const SizedBox(height: 20),
          ...state.overviews.map(
            (overview) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCard(overview: overview),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategooriad',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF021C36),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          monthLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}


class _MonthSummaryRow extends StatelessWidget {
  const _MonthSummaryRow({required this.overviews});

  final List<CategoryBudgetOverview> overviews;

  @override
  Widget build(BuildContext context) {
    final totalPlanned =
        overviews.fold<double>(0, (s, o) => s + o.plannedAmount);
    final totalSpent = overviews.fold<double>(0, (s, o) => s + o.spentAmount);
    final totalRemaining = totalPlanned - totalSpent;
    final overBudgetCount = overviews.where((o) => o.isOverBudget).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Kokku plaan',
              value: _fmt(totalPlanned),
              color: AppColors.textPrimary,
            ),
          ),
          _Divider(),
          Expanded(
            child: _SummaryItem(
              label: 'Kulutatud',
              value: _fmt(totalSpent),
              color: AppColors.textPrimary,
            ),
          ),
          _Divider(),
          Expanded(
            child: _SummaryItem(
              label: 'Alles',
              value: _fmt(totalRemaining),
              color: totalRemaining < 0
                  ? AppColors.error
                  : AppColors.success,
            ),
          ),
          if (overBudgetCount > 0) ...[
            _Divider(),
            Expanded(
              child: _SummaryItem(
                label: 'Üle eelarve',
                value: '$overBudgetCount',
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.border,
    );
  }
}


class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.overview});

  final CategoryBudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    final statusColors = _StatusColors.from(overview.status);
    final progress = overview.usagePercent.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overview.categoryName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              _StatusBadge(status: overview.status, colors: statusColors),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _AmountItem(
                  label: 'Planeeritud',
                  value: _fmt(overview.plannedAmount),
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: _AmountItem(
                  label: 'Kulutatud',
                  value: _fmt(overview.spentAmount),
                  color: overview.isOverBudget
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _AmountItem(
                  label: 'Alles',
                  value: _fmtSigned(overview.remainingAmount),
                  color: overview.isOverBudget
                      ? AppColors.error
                      : overview.status == CategoryBudgetStatus.nearLimit
                          ? AppColors.warning
                          : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: statusColors.accent.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColors.accent),
            ),
          ),

          if (overview.suggestedDailyAmount != null &&
              overview.remainingDays > 0) ...[
            const SizedBox(height: 12),
            _DailySuggestionLine(overview: overview),
          ],

          if (overview.isOverBudget) ...[
            const SizedBox(height: 12),
            _OverspentLine(amount: overview.overspentAmount),
          ],
        ],
      ),
    );
  }
}

class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _DailySuggestionLine extends StatelessWidget {
  const _DailySuggestionLine({required this.overview});

  final CategoryBudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 13,
          color: Color(0xFF006763),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Ülejäänud ${overview.remainingDays} päevaks ~${_fmt(overview.suggestedDailyAmount!)} päevas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF3F5A57),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _OverspentLine extends StatelessWidget {
  const _OverspentLine({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 13, color: Color(0xFFBA1A1A)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${_fmt(amount)} üle planeeritud summa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFBA1A1A),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}


class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.colors});

  final CategoryBudgetStatus status;
  final _StatusColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.iconBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(colors.icon, size: 12, color: colors.accent),
          const SizedBox(width: 4),
          Text(
            _label(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _label(CategoryBudgetStatus s) {
    switch (s) {
      case CategoryBudgetStatus.underBudget:
        return 'Ees plaanis';
      case CategoryBudgetStatus.onTrack:
        return 'Graafikus';
      case CategoryBudgetStatus.nearLimit:
        return 'Läheneb piirile';
      case CategoryBudgetStatus.overBudget:
        return 'Üle eelarve';
    }
  }
}


class _NotConfiguredState extends StatelessWidget {
  const _NotConfiguredState();

  @override
  Widget build(BuildContext context) {
    return _EmptyLayout(
      icon: Icons.tune_outlined,
      title: 'Seadistus puudub',
      message: 'Eelarve ülevaate nägemiseks lõpeta esmalt esialgne seadistamine.',
    );
  }
}

class _NoCategoriesState extends StatelessWidget {
  const _NoCategoriesState();

  @override
  Widget build(BuildContext context) {
    return _EmptyLayout(
      icon: Icons.category_outlined,
      title: 'Kategooriaid pole',
      message: 'Lisa seadistuses kulukategooriad, et siin ülevaadet näha.',
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyLayout(
      icon: Icons.error_outline,
      title: 'Midagi läks valesti',
      message: message,
    );
  }
}

class _EmptyLayout extends StatelessWidget {
  const _EmptyLayout({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


String _fmt(double amount) =>
    '${amount.abs().toStringAsFixed(2).replaceAll('.', ',')} €';

/// Formats a possibly-negative amount, prefixing "−" when negative.
String _fmtSigned(double amount) {
  final abs = amount.abs().toStringAsFixed(2).replaceAll('.', ',');
  return amount < 0 ? '−$abs €' : '$abs €';
}

class _StatusColors {
  const _StatusColors({
    required this.accent,
    required this.iconBackground,
    required this.icon,
  });

  factory _StatusColors.from(CategoryBudgetStatus status) {
    switch (status) {
      case CategoryBudgetStatus.underBudget:
      case CategoryBudgetStatus.onTrack:
        return const _StatusColors(
          accent: Color(0xFF006763),
          iconBackground: Color(0xFFBFE7E3),
          icon: Icons.check_circle_outline,
        );
      case CategoryBudgetStatus.nearLimit:
        return const _StatusColors(
          accent: Color(0xFF9A5C00),
          iconBackground: Color(0xFFFFE9C7),
          icon: Icons.warning_amber_rounded,
        );
      case CategoryBudgetStatus.overBudget:
        return const _StatusColors(
          accent: Color(0xFFBA1A1A),
          iconBackground: Color(0xFFFFDAD6),
          icon: Icons.error_outline,
        );
    }
  }

  final Color accent;
  final Color iconBackground;
  final IconData icon;
}

const _estonianMonths = [
  'jaanuar', 'veebruar', 'märts', 'aprill', 'mai', 'juuni',
  'juuli', 'august', 'september', 'oktoober', 'november', 'detsember',
];

String _estonianMonth(int month) => _estonianMonths[month - 1];
