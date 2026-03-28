import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/home_summary.dart';
import '../../domain/services/home_summary_calculator.dart';
import 'dashboard_dependencies.dart';

class HomeSummaryState {
  const HomeSummaryState._({
    required this.isConfigured,
    required this.summary,
  });

  const HomeSummaryState.notConfigured()
      : this._(
          isConfigured: false,
          summary: null,
        );

  const HomeSummaryState.configured(HomeSummary summary)
      : this._(
          isConfigured: true,
          summary: summary,
        );

  final bool isConfigured;
  final HomeSummary? summary;
}

final homeSummaryCalculatorProvider = Provider<HomeSummaryCalculator>(
  (ref) => const HomeSummaryCalculator(),
);

final homeSummaryProvider =
    AsyncNotifierProvider<HomeSummaryNotifier, HomeSummaryState>(
  HomeSummaryNotifier.new,
);

class HomeSummaryNotifier extends AsyncNotifier<HomeSummaryState> {
  @override
  Future<HomeSummaryState> build() async {
    final gateway = ref.read(dashboardDataGatewayProvider);
    final calculator = ref.read(homeSummaryCalculatorProvider);

    final profile = await gateway.getBudgetProfile();
    if (profile == null) {
      return const HomeSummaryState.notConfigured();
    }

    final categories = await gateway.getCategoriesForProfile(profile.id);
    final expenses = await gateway.getExpensesForMonth(month: DateTime.now());

    final summary = calculator.calculate(
      profile: profile,
      categories: categories,
      expenses: expenses,
    );

    return HomeSummaryState.configured(summary);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
