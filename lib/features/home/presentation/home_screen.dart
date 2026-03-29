import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_state_screen.dart';
import 'providers/home_summary_provider.dart';
import 'providers/remote_insight_provider.dart';
import 'widgets/dashboard_currency.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/home_categories_section.dart';
import 'widgets/home_insight_card.dart';
import 'widgets/home_primary_summary_card.dart';
import 'widgets/home_stat_card.dart';
import 'widgets/remote_insight_card.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => AppStateScreen.loading(),
          error: (e, _) => AppStateScreen.error(
            onRetry: () => ref.invalidate(homeSummaryProvider),
          ),
          data: (summaryState) {
            if (!summaryState.isConfigured || summaryState.summary == null) {
              return AppStateScreen.setupRequired(
                onSetup: () => context.go('/setup'),
                body:
                    'Sisesta sissetulek, püsikulud ja kategooriad, et avaleht saaks sinu kuu ülevaate arvutada.',
              );
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
                        if (summary.categorySummaries.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          HomeCategoriesSection(
                            categories: summary.categorySummaries,
                          ),
                        ],
                        const SizedBox(height: 12),
                        ref.watch(remoteInsightProvider).when(
                          loading: () => HomeInsightCard(insight: summary.insight),
                          error: (e, st) => HomeInsightCard(insight: summary.insight),
                          data: (remote) => remote != null
                              ? RemoteInsightCard(insight: remote)
                              : HomeInsightCard(insight: summary.insight),
                        ),
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
