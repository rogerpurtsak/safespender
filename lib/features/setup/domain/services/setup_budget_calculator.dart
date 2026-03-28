import '../models/budget_category.dart';
import '../models/budget_profile.dart';

class SetupBudgetCalculator {
  const SetupBudgetCalculator();

  double calculateDistributableAmount({
    required double monthlyIncome,
    required double monthlyFixedExpenses,
    required double safetyBuffer,
  }) {
    final amount = monthlyIncome - monthlyFixedExpenses - safetyBuffer;

    if (amount < 0) {
      return 0;
    }

    return _roundTo2(amount);
  }

  SetupValidationResult validateSetup({
    required double monthlyIncome,
    required double monthlyFixedExpenses,
    required double safetyBuffer,
    required List<BudgetCategory> categories,
  }) {
    if (monthlyIncome <= 0) {
      return const SetupValidationResult.invalid(
        'Sisesta korrektne igakuine sissetulek.',
      );
    }

    if (monthlyFixedExpenses < 0) {
      return const SetupValidationResult.invalid(
        'Püsikulud ei saa olla negatiivsed.',
      );
    }

    if (safetyBuffer < 0) {
      return const SetupValidationResult.invalid(
        'Puhver ei saa olla negatiivne.',
      );
    }

    final distributableAmount = calculateDistributableAmount(
      monthlyIncome: monthlyIncome,
      monthlyFixedExpenses: monthlyFixedExpenses,
      safetyBuffer: safetyBuffer,
    );

    if (distributableAmount <= 0) {
      return const SetupValidationResult.invalid(
        'Pärast püsikulusid ja puhvrit peab jääma raha kategooriate jaoks.',
      );
    }

    if (categories.isEmpty) {
      return const SetupValidationResult.invalid(
        'Vähemalt üks kategooria peab olemas olema.',
      );
    }

    final hasFoodCategory = categories.any(
      (category) => category.isDefault,
    );

    if (!hasFoodCategory) {
      return const SetupValidationResult.invalid(
        'Vaikimisi Toit kategooria peab alles jääma.',
      );
    }

    for (final category in categories) {
      if (category.name.trim().isEmpty) {
        return const SetupValidationResult.invalid(
          'Kategooria nimi ei tohi olla tühi.',
        );
      }

      if (category.allocationPercent < 0) {
        return SetupValidationResult.invalid(
          'Kategooria "${category.name}" osakaal ei saa olla negatiivne.',
        );
      }
    }

    final totalPercent = calculateTotalAllocationPercent(categories);

    if (totalPercent > 100.0) {
      return SetupValidationResult.invalid(
        'Kategooriate kogusumma on ${totalPercent.toStringAsFixed(2)}%. '
        'See ei tohi ületada 100%.',
      );
    }

    return const SetupValidationResult.valid();
  }

  double calculateTotalAllocationPercent(List<BudgetCategory> categories) {
    final total = categories.fold<double>(
      0,
      (sum, category) => sum + category.allocationPercent,
    );

    return _roundTo2(total);
  }

  double calculateUnallocatedPercent(List<BudgetCategory> categories) {
    final total = calculateTotalAllocationPercent(categories);
    final left = 100.0 - total;

    if (left < 0) {
      return 0;
    }

    return _roundTo2(left);
  }

  List<BudgetCategory> calculatePlannedAmounts({
    required double distributableAmount,
    required List<BudgetCategory> categories,
  }) {
    return categories.map((category) {
      final plannedAmount =
          distributableAmount * (category.allocationPercent / 100);

      return category.copyWith(
        plannedAmount: _roundTo2(plannedAmount),
      );
    }).toList();
  }

  BudgetProfile buildBudgetProfile({
    int? id,
    required double monthlyIncome,
    required double monthlyFixedExpenses,
    required double safetyBuffer,
    String currencyCode = 'EUR',
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    final distributableAmount = calculateDistributableAmount(
      monthlyIncome: monthlyIncome,
      monthlyFixedExpenses: monthlyFixedExpenses,
      safetyBuffer: safetyBuffer,
    );

    return BudgetProfile(
      id: id,
      monthlyIncome: _roundTo2(monthlyIncome),
      monthlyFixedExpenses: _roundTo2(monthlyFixedExpenses),
      safetyBuffer: _roundTo2(safetyBuffer),
      distributableAmount: distributableAmount,
      currencyCode: currencyCode,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  List<BudgetCategory> buildCategoriesForSave({
    required int? budgetProfileId,
    required double distributableAmount,
    required List<BudgetCategory> categories,
  }) {
    final now = DateTime.now();
    final categoriesWithPlannedAmounts = calculatePlannedAmounts(
      distributableAmount: distributableAmount,
      categories: categories,
    );

    return List.generate(categoriesWithPlannedAmounts.length, (index) {
      final category = categoriesWithPlannedAmounts[index];

      return category.copyWith(
        budgetProfileId: budgetProfileId,
        sortOrder: index,
        updatedAt: now,
        createdAt: category.createdAt,
      );
    });
  }

  double _roundTo2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

class SetupValidationResult {
  final bool isValid;
  final String? errorMessage;

  const SetupValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  const SetupValidationResult.valid()
      : this._(
          isValid: true,
        );

  const SetupValidationResult.invalid(String message)
      : this._(
          isValid: false,
          errorMessage: message,
        );
}