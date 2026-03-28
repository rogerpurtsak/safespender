import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/home_summary_provider.dart';
import 'widgets/dashboard_currency.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/home_category_highlight_card.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_insight_card.dart';
import 'widgets/home_primary_summary_card.dart';
import 'widgets/home_stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Viga: $e')),
          data: (summaryState) {
            if (!summaryState.isConfigured || summaryState.summary == null) {
              return HomeEmptyState(onOpenSetup: () => context.go('/setup'));
            }

            final summary = summaryState.summary!;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(homeSummaryProvider.notifier).refresh(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [
                        DashboardHeader(displayName: summary.displayName),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sellel kuu alles',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF6B7B79),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(summary.monthlyRemaining),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF021C36),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        HomePrimarySummaryCard(summary: summary),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: HomeStatCard(
                                label: 'Püsikulud',
                                value: summary.fixedExpenses,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: HomeStatCard(
                                label: 'Puhver',
                                value: summary.safetyBuffer,
                              ),
                            ),
                          ],
                        ),
                        if (summary.highlightedCategory != null) ...[
                          const SizedBox(height: 12),
                          HomeCategoryHighlightCard(
                            category: summary.highlightedCategory!,
                          ),
                        ],
                        const SizedBox(height: 12),
                        HomeInsightCard(insight: summary.insight),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go('/addexpense'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF006763),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 26,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Lisa uus kulu',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
