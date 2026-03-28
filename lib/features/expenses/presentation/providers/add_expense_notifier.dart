import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/data/datasources/setup_local_data_source.dart';
import '../../../setup/domain/models/budget_category.dart';
import '../../../setup/presentation/providers/setup_notifier.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/models/expense.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  );
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    localDataSource: ref.watch(expenseLocalDataSourceProvider),
  );
});

/// Loads saved categories so the form can populate the dropdown.
final categoriesForPickerProvider =
    FutureProvider<List<BudgetCategory>>((ref) async {
  final dataSource = SetupLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  );
  return dataSource.getBudgetCategories();
});

final addExpenseNotifierProvider =
    NotifierProvider<AddExpenseNotifier, AddExpenseState>(
  AddExpenseNotifier.new,
);

// ── State ───────────────────────────────────────────────────────────────────

class AddExpenseState {
  const AddExpenseState({
    this.isSaving = false,
    this.errorMessage,
    this.savedSuccessfully = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool savedSuccessfully;

  AddExpenseState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? savedSuccessfully,
  }) {
    return AddExpenseState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedSuccessfully: savedSuccessfully ?? this.savedSuccessfully,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AddExpenseNotifier extends Notifier<AddExpenseState> {
  late final ExpenseRepository _repository;

  @override
  AddExpenseState build() {
    _repository = ref.read(expenseRepositoryProvider);
    return const AddExpenseState();
  }

  /// Validates inputs and saves the expense. Returns true on success.
  Future<bool> save({
    required String amountInput,
    required int? budgetCategoryId,
    required DateTime expenseDate,
    required String note,
  }) async {
    final validationError = _validate(
      amountInput: amountInput,
      budgetCategoryId: budgetCategoryId,
    );

    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    final amount = double.parse(amountInput.replaceAll(',', '.').trim());

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final expense = Expense(
        budgetCategoryId: budgetCategoryId!,
        amount: amount,
        expenseDate: expenseDate,
        note: note.trim().isEmpty ? null : note.trim(),
        createdAt: DateTime.now(),
      );

      await _repository.saveExpense(expense);

      state = state.copyWith(isSaving: false, savedSuccessfully: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Salvestamine ebaõnnestus. Proovi uuesti.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetAfterSave() {
    state = const AddExpenseState();
  }

  String? _validate({
    required String amountInput,
    required int? budgetCategoryId,
  }) {
    final normalized = amountInput.replaceAll(',', '.').trim();
    final amount = double.tryParse(normalized);

    if (normalized.isEmpty || amount == null || amount <= 0) {
      return 'Summa peab olema suurem kui 0.';
    }
    if (budgetCategoryId == null) {
      return 'Vali kategooria.';
    }
    return null;
  }
}
