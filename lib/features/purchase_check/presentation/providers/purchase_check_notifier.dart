import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/expenses/presentation/providers/add_expense_notifier.dart';
import '../../../../features/setup/data/datasources/setup_local_data_source.dart';
import '../../../../features/setup/domain/models/budget_category.dart';
import '../../../../features/setup/presentation/providers/setup_notifier.dart';
import '../../domain/models/purchase_check_result.dart';
import '../../domain/services/purchase_risk_evaluator.dart';

// ── State ────────────────────────────────────────────────────────────────────

class PurchaseCheckState {
  const PurchaseCheckState._({
    required this.isConfigured,
    required this.categories,
    this.amountInput = '',
    this.selectedCategoryId,
    this.isEvaluating = false,
    this.result,
    this.errorMessage,
  });

  /// No budget profile exists — user has not completed setup.
  const PurchaseCheckState.notConfigured()
      : this._(isConfigured: false, categories: const []);

  /// Profile exists but no categories have been created.
  const PurchaseCheckState.noCategories()
      : this._(isConfigured: true, categories: const []);

  /// Normal interactive state: categories loaded, form editable.
  factory PurchaseCheckState.ready({
    required List<BudgetCategory> categories,
    String amountInput = '',
    int? selectedCategoryId,
    bool isEvaluating = false,
    PurchaseCheckResult? result,
    String? errorMessage,
  }) =>
      PurchaseCheckState._(
        isConfigured: true,
        categories: categories,
        amountInput: amountInput,
        selectedCategoryId: selectedCategoryId,
        isEvaluating: isEvaluating,
        result: result,
        errorMessage: errorMessage,
      );

  final bool isConfigured;
  final List<BudgetCategory> categories;
  final String amountInput;
  final int? selectedCategoryId;
  final bool isEvaluating;
  final PurchaseCheckResult? result;
  final String? errorMessage;

  bool get hasCategories => categories.isNotEmpty;

  bool get canEvaluate {
    if (!hasCategories || selectedCategoryId == null || isEvaluating) {
      return false;
    }
    final normalized = amountInput.replaceAll(',', '.').trim();
    final amount = double.tryParse(normalized);
    return amount != null && amount > 0;
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final purchaseCheckProvider =
    AsyncNotifierProvider<PurchaseCheckNotifier, PurchaseCheckState>(
  PurchaseCheckNotifier.new,
);

// ── Notifier ─────────────────────────────────────────────────────────────────

class PurchaseCheckNotifier extends AsyncNotifier<PurchaseCheckState> {
  @override
  Future<PurchaseCheckState> build() => _loadInitialData();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadInitialData);
  }

  Future<PurchaseCheckState> _loadInitialData() async {
    final setupDataSource = SetupLocalDataSource(
      appDatabase: ref.read(appDatabaseProvider),
    );

    final profile = await setupDataSource.getBudgetProfile();
    if (profile == null) {
      return const PurchaseCheckState.notConfigured();
    }

    final categories = await setupDataSource.getBudgetCategories();
    if (categories.isEmpty) {
      return const PurchaseCheckState.noCategories();
    }

    return PurchaseCheckState.ready(categories: categories);
  }

  /// Updates the amount input; clears any previous result.
  void updateAmount(String input) {
    final current = state.asData?.value;
    if (current == null || !current.hasCategories) return;
    state = AsyncData(PurchaseCheckState.ready(
      categories: current.categories,
      amountInput: input,
      selectedCategoryId: current.selectedCategoryId,
      // intentionally no result — user is changing input
    ));
  }

  /// Selects a category; clears any previous result.
  void selectCategory(int? categoryId) {
    final current = state.asData?.value;
    if (current == null || !current.hasCategories) return;
    state = AsyncData(PurchaseCheckState.ready(
      categories: current.categories,
      amountInput: current.amountInput,
      selectedCategoryId: categoryId,
      // intentionally no result — user is changing selection
    ));
  }

  /// Runs the risk evaluation against real stored data.
  Future<void> evaluate() async {
    final current = state.asData?.value;
    if (current == null || !current.canEvaluate) return;

    final amount =
        double.parse(current.amountInput.replaceAll(',', '.').trim());
    final selectedCategory = current.categories.firstWhere(
      (c) => c.id == current.selectedCategoryId,
    );

    state = AsyncData(PurchaseCheckState.ready(
      categories: current.categories,
      amountInput: current.amountInput,
      selectedCategoryId: current.selectedCategoryId,
      isEvaluating: true,
    ));

    try {
      final setupDataSource = SetupLocalDataSource(
        appDatabase: ref.read(appDatabaseProvider),
      );
      final expenseDataSource = ref.read(expenseLocalDataSourceProvider);

      final profile = await setupDataSource.getBudgetProfile();
      if (profile == null) {
        state = AsyncData(const PurchaseCheckState.notConfigured());
        return;
      }

      final now = DateTime.now();
      final allExpenses = await expenseDataSource.getExpensesForMonth(now);
      final totalSpent =
          allExpenses.fold<double>(0, (s, e) => s + e.amount);

      final categoryExpenses =
          await expenseDataSource.getExpensesForCategoryInMonth(
        current.selectedCategoryId!,
        now,
      );
      final categorySpent =
          categoryExpenses.fold<double>(0, (s, e) => s + e.amount);

      const evaluator = PurchaseRiskEvaluator();
      final result = evaluator.evaluate(
        purchaseAmount: amount,
        categoryName: selectedCategory.name,
        categoryPlannedAmount: selectedCategory.plannedAmount,
        categorySpentAmount: categorySpent,
        distributableAmount: profile.distributableAmount,
        totalSpentThisMonth: totalSpent,
      );

      state = AsyncData(PurchaseCheckState.ready(
        categories: current.categories,
        amountInput: current.amountInput,
        selectedCategoryId: current.selectedCategoryId,
        result: result,
      ));
    } catch (_) {
      state = AsyncData(PurchaseCheckState.ready(
        categories: current.categories,
        amountInput: current.amountInput,
        selectedCategoryId: current.selectedCategoryId,
        errorMessage: 'Andmete laadimine ebaõnnestus. Proovi uuesti.',
      ));
    }
  }
}
