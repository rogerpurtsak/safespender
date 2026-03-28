import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/setup_local_data_source.dart';
import '../../data/repositories/setup_repository.dart';
import '../../data/repositories/setup_repository_impl.dart';
import '../../domain/models/budget_category.dart';
import '../../domain/models/budget_profile.dart';
import '../../domain/services/setup_budget_calculator.dart';
import 'setup_state.dart';

final setupBudgetCalculatorProvider = Provider<SetupBudgetCalculator>(
  (ref) => const SetupBudgetCalculator(),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

final setupLocalDataSourceProvider = Provider<SetupLocalDataSource>(
  (ref) => SetupLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  ),
);

final setupRepositoryProvider = Provider<SetupRepository>(
  (ref) => SetupRepositoryImpl(
    localDataSource: ref.watch(setupLocalDataSourceProvider),
  ),
);

final setupNotifierProvider =
    NotifierProvider<SetupNotifier, SetupState>(SetupNotifier.new);

class SetupNotifier extends Notifier<SetupState> {
  late final SetupBudgetCalculator calculator;
  late final SetupRepository repository;

  @override
  SetupState build() {
    calculator = ref.read(setupBudgetCalculatorProvider);
    repository = ref.read(setupRepositoryProvider);
    return SetupState.initial();
  }

  double get monthlyIncome => _parseMoney(state.monthlyIncomeInput);

  double get monthlyFixedExpenses =>
      _parseMoney(state.monthlyFixedExpensesInput);

  double get safetyBuffer => _parseMoney(state.safetyBufferInput);

  double get distributableAmount {
    return calculator.calculateDistributableAmount(
      monthlyIncome: monthlyIncome,
      monthlyFixedExpenses: monthlyFixedExpenses,
      safetyBuffer: safetyBuffer,
    );
  }

  double get totalAllocatedPercent {
    return calculator.calculateTotalAllocationPercent(state.categories);
  }

  double get unallocatedPercent {
    return calculator.calculateUnallocatedPercent(state.categories);
  }

  List<BudgetCategory> get previewCategories {
    return calculator.calculatePlannedAmounts(
      distributableAmount: distributableAmount,
      categories: state.categories,
    );
  }

  BudgetProfile get previewProfile {
    return calculator.buildBudgetProfile(
      monthlyIncome: monthlyIncome,
      monthlyFixedExpenses: monthlyFixedExpenses,
      safetyBuffer: safetyBuffer,
      currencyCode: state.currencyCode,
    );
  }

  void updateMonthlyIncomeInput(String value) {
    state = state.copyWith(
      monthlyIncomeInput: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateMonthlyFixedExpensesInput(String value) {
    state = state.copyWith(
      monthlyFixedExpensesInput: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateSafetyBufferInput(String value) {
    state = state.copyWith(
      safetyBufferInput: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCurrencyCode(String currencyCode) {
    state = state.copyWith(
      currencyCode: currencyCode,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void addCategory(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _setError('Pane kategooriale nimi.');
      return;
    }

    if (state.categories.length >= 5) {
      _setError('Maksimaalselt 5 kategooriat.');
      return;
    }

    final alreadyExists = state.categories.any(
      (category) => category.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (alreadyExists) {
      _setError('Selline kategooria on juba olemas.');
      return;
    }

    final now = DateTime.now();

    final updatedCategories = [
      ...state.categories,
      BudgetCategory(
        name: trimmedName,
        allocationPercent: 0,
        plannedAmount: 0,
        sortOrder: state.categories.length,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    state = state.copyWith(
      categories: updatedCategories,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void removeCategory(int index) {
    if (index < 0 || index >= state.categories.length) {
      return;
    }

    final category = state.categories[index];

    if (category.isDefault) {
      _setError('Toit kategooriat ei saa eemaldada.');
      return;
    }

    final updatedCategories = [...state.categories]..removeAt(index);

    state = state.copyWith(
      categories: _rebuildSortOrders(updatedCategories),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCategoryName({
    required int index,
    required String name,
  }) {
    if (index < 0 || index >= state.categories.length) {
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _setError('Kategooria nimi ei tohi olla tühi.');
      return;
    }

    final alreadyExists = state.categories.asMap().entries.any((entry) {
      if (entry.key == index) {
        return false;
      }

      return entry.value.name.toLowerCase() == trimmedName.toLowerCase();
    });

    if (alreadyExists) {
      _setError('Selline kategooria on juba olemas.');
      return;
    }

    final updatedCategories = [...state.categories];
    final current = updatedCategories[index];

    updatedCategories[index] = current.copyWith(
      name: trimmedName,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      categories: updatedCategories,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCategoryAllocationPercent({
    required int index,
    required double newPercent,
  }) {
    if (index < 0 || index >= state.categories.length) {
      return;
    }

    final safePercent = newPercent < 0 ? 0.0 : newPercent;
    final currentCategory = state.categories[index];

    final otherTotal = state.categories
        .asMap()
        .entries
        .where((entry) => entry.key != index)
        .fold<double>(
          0,
          (sum, entry) => sum + entry.value.allocationPercent,
        );

    final maxAllowedForThisCategory = 100.0 - otherTotal;
    final clampedPercent = safePercent.clamp(
      0.0,
      maxAllowedForThisCategory < 0 ? 0.0 : maxAllowedForThisCategory,
    );

    final updatedCategories = [...state.categories];
    updatedCategories[index] = currentCategory.copyWith(
      allocationPercent: _roundTo2(clampedPercent),
      updatedAt: DateTime.now(),
    );

    final categoriesWithPlannedAmounts = calculator.calculatePlannedAmounts(
      distributableAmount: distributableAmount,
      categories: updatedCategories,
    );

    state = state.copyWith(
      categories: categoriesWithPlannedAmounts,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void distributeRemainingPercentEvenly() {
    if (state.categories.isEmpty) {
      return;
    }

    final remaining = unallocatedPercent;

    if (remaining <= 0) {
      return;
    }

    final extraPerCategory = remaining / state.categories.length;
    final now = DateTime.now();

    final updatedCategories = state.categories.map((category) {
      return category.copyWith(
        allocationPercent: _roundTo2(
          category.allocationPercent + extraPerCategory,
        ),
        updatedAt: now,
      );
    }).toList();

    final normalizedCategories = _normalizePercentOverflow(updatedCategories);

    state = state.copyWith(
      categories: calculator.calculatePlannedAmounts(
        distributableAmount: distributableAmount,
        categories: normalizedCategories,
      ),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void loadExistingSetup({
    required BudgetProfile profile,
    required List<BudgetCategory> categories,
  }) {
    state = state.copyWith(
      monthlyIncomeInput: _formatMoney(profile.monthlyIncome),
      monthlyFixedExpensesInput: _formatMoney(profile.monthlyFixedExpenses),
      safetyBufferInput: _formatMoney(profile.safetyBuffer),
      currencyCode: profile.currencyCode,
      categories: categories,
      hasCompletedSetup: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  SetupValidationResult validateCurrentSetup() {
    final validation = calculator.validateSetup(
      monthlyIncome: monthlyIncome,
      monthlyFixedExpenses: monthlyFixedExpenses,
      safetyBuffer: safetyBuffer,
      categories: state.categories,
    );

    if (!validation.isValid) {
      _setError(validation.errorMessage ?? 'Setup ei ole korrektne.');
    } else {
      state = state.copyWith(clearErrorMessage: true);
    }

    return validation;
  }

  Future<bool> saveSetup() async {
    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final validation = validateCurrentSetup();

    if (!validation.isValid) {
      state = state.copyWith(isSaving: false);
      return false;
    }

    try {
      final profile = calculator.buildBudgetProfile(
        monthlyIncome: monthlyIncome,
        monthlyFixedExpenses: monthlyFixedExpenses,
        safetyBuffer: safetyBuffer,
        currencyCode: state.currencyCode,
      );

      final categories = calculator.buildCategoriesForSave(
        budgetProfileId: null,
        distributableAmount: profile.distributableAmount,
        categories: state.categories,
      );

      await repository.saveSetup(
        profile: profile,
        categories: categories,
      );

      final savedProfile = await repository.getBudgetProfile();
      final savedCategories = await repository.getBudgetCategories();

      if (savedProfile != null) {
        loadExistingSetup(
          profile: savedProfile,
          categories: savedCategories,
        );
      }

      state = state.copyWith(
        isSaving: false,
        hasCompletedSetup: true,
        successMessage: 'Setup salvestati edukalt.',
      );

      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Setup salvestamine ebaõnnestus.',
      );
      return false;
    }
  }

  Future<void> loadSavedSetupIfExists() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final profile = await repository.getBudgetProfile();
      final categories = await repository.getBudgetCategories();

      if (profile != null) {
        loadExistingSetup(
          profile: profile,
          categories: categories,
        );
      }

      state = state.copyWith(
        isLoading: false,
        hasCompletedSetup: profile != null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Salvestatud setupi laadimine ebaõnnestus.',
      );
    }
  }

  Future<bool> checkHasCompletedSetup() async {
    try {
      return await repository.hasCompletedSetup();
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSavedSetup() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await repository.clearSetup();
      state = SetupState.initial();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Setupi kustutamine ebaõnnestus.',
      );
    }
  }

  void markSetupCompleted() {
    state = state.copyWith(
      hasCompletedSetup: true,
      clearErrorMessage: true,
    );
  }

  void clearMessages() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  double allocationPercentFor(int index) {
    if (index < 0 || index >= state.categories.length) {
      return 0;
    }

    return state.categories[index].allocationPercent;
  }

  double plannedAmountFor(int index) {
    if (index < 0 || index >= previewCategories.length) {
      return 0;
    }

    return previewCategories[index].plannedAmount;
  }

  double maxAllowedPercentFor(int index) {
    if (index < 0 || index >= state.categories.length) {
      return 0;
    }

    final otherTotal = state.categories
        .asMap()
        .entries
        .where((entry) => entry.key != index)
        .fold<double>(
          0,
          (sum, entry) => sum + entry.value.allocationPercent,
        );

    final left = 100.0 - otherTotal;

    if (left < 0) {
      return 0;
    }

    return _roundTo2(left);
  }

  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      clearSuccessMessage: true,
    );
  }

  double _parseMoney(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0;
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  double _roundTo2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  List<BudgetCategory> _rebuildSortOrders(List<BudgetCategory> categories) {
    final now = DateTime.now();

    return List.generate(categories.length, (index) {
      final category = categories[index];

      return category.copyWith(
        sortOrder: index,
        updatedAt: now,
      );
    });
  }

  List<BudgetCategory> _normalizePercentOverflow(
    List<BudgetCategory> categories,
  ) {
    final total = categories.fold<double>(
      0,
      (sum, category) => sum + category.allocationPercent,
    );

    if (total <= 100.0 || total == 0) {
      return categories;
    }

    final factor = 100.0 / total;
    final now = DateTime.now();

    return categories.map((category) {
      return category.copyWith(
        allocationPercent: _roundTo2(category.allocationPercent * factor),
        updatedAt: now,
      );
    }).toList();
  }
}