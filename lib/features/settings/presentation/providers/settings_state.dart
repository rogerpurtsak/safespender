import '../../../setup/domain/models/budget_category.dart';

class SettingsState {
  final bool isLoading;
  final bool isSaving;
  final bool hasProfile;
  final String? errorMessage;
  final String? successMessage;

  // Profile fields (edited in bottom sheets)
  final String safetyBufferInput;
  final String currencyCode;

  // Categories (edited inline / bottom sheet)
  final List<BudgetCategory> categories;

  // Preferences
  final bool notificationsEnabled;

  // Computed from profile (read-only, set on load)
  final double monthlyIncome;
  final double monthlyFixedExpenses;
  final double distributableAmount;

  const SettingsState({
    required this.isLoading,
    required this.isSaving,
    required this.hasProfile,
    this.errorMessage,
    this.successMessage,
    this.safetyBufferInput = '',
    this.currencyCode = 'EUR',
    this.categories = const [],
    this.notificationsEnabled = false,
    this.monthlyIncome = 0,
    this.monthlyFixedExpenses = 0,
    this.distributableAmount = 0,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isLoading: true,
      isSaving: false,
      hasProfile: false,
    );
  }

  double get safetyBuffer =>
      double.tryParse(safetyBufferInput.replaceAll(',', '.').trim()) ?? 0;

  double get totalAllocatedPercent {
    final total =
        categories.fold<double>(0, (s, c) => s + c.allocationPercent);
    return double.parse(total.toStringAsFixed(2));
  }

  double get unallocatedPercent {
    final left = 100.0 - totalAllocatedPercent;
    return left < 0 ? 0 : double.parse(left.toStringAsFixed(2));
  }

  bool get isFormValid {
    if (safetyBuffer < 0) return false;
    final newDistributable =
        monthlyIncome - monthlyFixedExpenses - safetyBuffer;
    if (newDistributable <= 0) return false;
    if (totalAllocatedPercent > 100) return false;
    return true;
  }

  /// Currency symbol for display.
  String get currencySymbol {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      default:
        return '€';
    }
  }

  /// Human-readable currency label shown in the row.
  String get currencyLabel {
    switch (currencyCode) {
      case 'USD':
        return 'Dollar - USD';
      case 'GBP':
        return 'Naelsterling - GBP';
      default:
        return 'Euro - EUR';
    }
  }

  SettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? hasProfile,
    String? errorMessage,
    String? successMessage,
    String? safetyBufferInput,
    String? currencyCode,
    List<BudgetCategory>? categories,
    bool? notificationsEnabled,
    double? monthlyIncome,
    double? monthlyFixedExpenses,
    double? distributableAmount,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasProfile: hasProfile ?? this.hasProfile,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      safetyBufferInput: safetyBufferInput ?? this.safetyBufferInput,
      currencyCode: currencyCode ?? this.currencyCode,
      categories: categories ?? this.categories,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyFixedExpenses:
          monthlyFixedExpenses ?? this.monthlyFixedExpenses,
      distributableAmount: distributableAmount ?? this.distributableAmount,
    );
  }
}
