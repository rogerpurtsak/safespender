import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expenses/presentation/providers/add_expense_notifier.dart';
import '../../../setup/data/datasources/setup_local_data_source.dart';
import '../../../setup/presentation/providers/setup_notifier.dart';
import '../../domain/models/category_budget_overview.dart';
import '../../domain/services/budget_rebalancing_service.dart';

// ── State ────────────────────────────────────────────────────────────────────

class CategoryBudgetOverviewState {
  const CategoryBudgetOverviewState._({
    required this.isConfigured,
    required this.overviews,
  });

  /// User has not completed setup — no profile exists.
  const CategoryBudgetOverviewState.notConfigured()
      : this._(isConfigured: false, overviews: const []);

  /// Setup exists but no categories have been created yet.
  const CategoryBudgetOverviewState.noCategories()
      : this._(isConfigured: true, overviews: const []);

  /// Successfully loaded — [overviews] contains one entry per category.
  const CategoryBudgetOverviewState.loaded(List<CategoryBudgetOverview> overviews)
      : this._(isConfigured: true, overviews: overviews);

  final bool isConfigured;

  /// One [CategoryBudgetOverview] per user-created category, sorted by
  /// sort_order as stored in the database.
  final List<CategoryBudgetOverview> overviews;

  bool get hasCategories => overviews.isNotEmpty;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final categoryBudgetOverviewProvider = AsyncNotifierProvider<
    CategoryBudgetOverviewNotifier, CategoryBudgetOverviewState>(
  CategoryBudgetOverviewNotifier.new,
);

// ── Notifier ─────────────────────────────────────────────────────────────────

class CategoryBudgetOverviewNotifier
    extends AsyncNotifier<CategoryBudgetOverviewState> {
  @override
  Future<CategoryBudgetOverviewState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CategoryBudgetOverviewState> _load() async {
    final setupDataSource = SetupLocalDataSource(
      appDatabase: ref.read(appDatabaseProvider),
    );
    final expenseDataSource = ref.read(expenseLocalDataSourceProvider);
    const service = BudgetRebalancingService();

    final profile = await setupDataSource.getBudgetProfile();
    if (profile == null) {
      return const CategoryBudgetOverviewState.notConfigured();
    }

    final categories = await setupDataSource.getBudgetCategories();
    if (categories.isEmpty) {
      return const CategoryBudgetOverviewState.noCategories();
    }

    final now = DateTime.now();

    final overviews = <CategoryBudgetOverview>[];
    for (final category in categories) {
      if (category.id == null) continue;

      final expenses = await expenseDataSource.getExpensesForCategoryInMonth(
        category.id!,
        now,
      );
      final spentAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);

      overviews.add(
        service.calculate(
          categoryId: category.id!,
          categoryName: category.name,
          plannedAmount: category.plannedAmount,
          spentAmount: spentAmount,
          now: now,
        ),
      );
    }

    return CategoryBudgetOverviewState.loaded(overviews);
  }
}
