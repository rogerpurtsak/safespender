import '../../domain/models/budget_category.dart';

class SetupState {
  final String monthlyIncomeInput;
  final String monthlyFixedExpensesInput;
  final String safetyBufferInput;
  final String currencyCode;
  final List<BudgetCategory> categories;
  final bool isLoading;
  final bool isSaving;
  final bool hasCompletedSetup;
  final String? errorMessage;
  final String? successMessage;

  const SetupState({
    required this.monthlyIncomeInput,
    required this.monthlyFixedExpensesInput,
    required this.safetyBufferInput,
    required this.currencyCode,
    required this.categories,
    required this.isLoading,
    required this.isSaving,
    required this.hasCompletedSetup,
    required this.errorMessage,
    required this.successMessage,
  });

  factory SetupState.initial() {
    final now = DateTime.now();

    return SetupState(
      monthlyIncomeInput: '',
      monthlyFixedExpensesInput: '',
      safetyBufferInput: '',
      currencyCode: 'EUR',
      categories: [
        BudgetCategory(
          name: 'Toit',
          allocationPercent: 0,
          plannedAmount: 0,
          sortOrder: 0,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      isLoading: false,
      isSaving: false,
      hasCompletedSetup: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  SetupState copyWith({
    String? monthlyIncomeInput,
    String? monthlyFixedExpensesInput,
    String? safetyBufferInput,
    String? currencyCode,
    List<BudgetCategory>? categories,
    bool? isLoading,
    bool? isSaving,
    bool? hasCompletedSetup,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return SetupState(
      monthlyIncomeInput: monthlyIncomeInput ?? this.monthlyIncomeInput,
      monthlyFixedExpensesInput:
          monthlyFixedExpensesInput ?? this.monthlyFixedExpensesInput,
      safetyBufferInput: safetyBufferInput ?? this.safetyBufferInput,
      currencyCode: currencyCode ?? this.currencyCode,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}