import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/setup/domain/models/budget_category.dart';
import 'package:safespender/features/setup/domain/services/setup_budget_calculator.dart';

void main() {
  const calculator = SetupBudgetCalculator();
  final now = DateTime(2025, 1, 1);

  BudgetCategory cat(
    String name,
    double percent, {
    bool isDefault = false,
  }) =>
      BudgetCategory(
        name: name,
        allocationPercent: percent,
        isDefault: isDefault,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

  // ── calculateDistributableAmount ────────────────────────────────────────────

  group('calculateDistributableAmount', () {
    test('returns income minus fixed expenses minus safety buffer', () {
      expect(
        calculator.calculateDistributableAmount(
          monthlyIncome: 2000,
          monthlyFixedExpenses: 800,
          safetyBuffer: 200,
        ),
        1000.0,
      );
    });

    test('returns 0 when expenses and buffer exceed income', () {
      expect(
        calculator.calculateDistributableAmount(
          monthlyIncome: 500,
          monthlyFixedExpenses: 600,
          safetyBuffer: 0,
        ),
        0.0,
      );
    });

    test('returns 0 when result is exactly zero', () {
      expect(
        calculator.calculateDistributableAmount(
          monthlyIncome: 1000,
          monthlyFixedExpenses: 800,
          safetyBuffer: 200,
        ),
        0.0,
      );
    });

    test('rounds result to 2 decimal places', () {
      // 1500 - 333.333 = 1166.667 → rounded to 1166.67
      expect(
        calculator.calculateDistributableAmount(
          monthlyIncome: 1500,
          monthlyFixedExpenses: 333.333,
          safetyBuffer: 0,
        ),
        closeTo(1166.67, 0.001),
      );
    });

    test('works with zero fixed expenses and zero buffer', () {
      expect(
        calculator.calculateDistributableAmount(
          monthlyIncome: 1500,
          monthlyFixedExpenses: 0,
          safetyBuffer: 0,
        ),
        1500.0,
      );
    });
  });

  // ── validateSetup ────────────────────────────────────────────────────────────

  group('validateSetup', () {
    test('returns valid when all parameters are correct', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('invalid when income is zero', () {
      final result = calculator.validateSetup(
        monthlyIncome: 0,
        monthlyFixedExpenses: 0,
        safetyBuffer: 0,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('sissetulek'));
    });

    test('invalid when income is negative', () {
      final result = calculator.validateSetup(
        monthlyIncome: -100,
        monthlyFixedExpenses: 0,
        safetyBuffer: 0,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isFalse);
    });

    test('invalid when fixed expenses are negative', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: -100,
        safetyBuffer: 0,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Püsikulud'));
    });

    test('invalid when safety buffer is negative', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 0,
        safetyBuffer: -50,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Puhver'));
    });

    test('invalid when distributable amount is zero after deductions', () {
      final result = calculator.validateSetup(
        monthlyIncome: 1000,
        monthlyFixedExpenses: 800,
        safetyBuffer: 200,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('kategooriate jaoks'));
    });

    test('invalid when no categories provided', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('kategooria'));
    });

    test('invalid when default food category is missing', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [cat('Meelelahutus', 50)],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Toit'));
    });

    test('invalid when a category name is blank or whitespace', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [
          cat('Toit', 40, isDefault: true),
          cat('   ', 10),
        ],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('nimi'));
    });

    test('invalid when a category has negative allocation', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [
          cat('Toit', 50, isDefault: true),
          cat('Meelelahutus', -10),
        ],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('negatiivne'));
    });

    test('invalid when total allocation exceeds 100%', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [
          cat('Toit', 60, isDefault: true),
          cat('Meelelahutus', 50),
        ],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('100%'));
    });

    test('valid when total allocation is exactly 100%', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [
          cat('Toit', 60, isDefault: true),
          cat('Meelelahutus', 40),
        ],
      );
      expect(result.isValid, isTrue);
    });

    test('valid when total allocation is under 100% (unallocated remainder allowed)', () {
      final result = calculator.validateSetup(
        monthlyIncome: 2000,
        monthlyFixedExpenses: 500,
        safetyBuffer: 100,
        categories: [
          cat('Toit', 50, isDefault: true),
          cat('Meelelahutus', 30),
        ],
      );
      expect(result.isValid, isTrue);
    });
  });

  // ── calculatePlannedAmounts ─────────────────────────────────────────────────

  group('calculatePlannedAmounts', () {
    test('calculates planned amount as distributableAmount * allocation / 100', () {
      final result = calculator.calculatePlannedAmounts(
        distributableAmount: 1000,
        categories: [cat('Toit', 50, isDefault: true)],
      );
      expect(result.first.plannedAmount, closeTo(500.0, 0.01));
    });

    test('distributes correctly across multiple categories', () {
      final result = calculator.calculatePlannedAmounts(
        distributableAmount: 1000,
        categories: [
          cat('Toit', 40, isDefault: true),
          cat('Meelelahutus', 30),
          cat('Transport', 20),
        ],
      );
      expect(result[0].plannedAmount, closeTo(400.0, 0.01));
      expect(result[1].plannedAmount, closeTo(300.0, 0.01));
      expect(result[2].plannedAmount, closeTo(200.0, 0.01));
    });

    test('returns 0 planned amount for 0% allocation', () {
      final result = calculator.calculatePlannedAmounts(
        distributableAmount: 1000,
        categories: [cat('Toit', 0, isDefault: true)],
      );
      expect(result.first.plannedAmount, 0.0);
    });

    test('preserves all other category fields', () {
      final original = cat('Toit', 50, isDefault: true);
      final result = calculator.calculatePlannedAmounts(
        distributableAmount: 1000,
        categories: [original],
      );
      final updated = result.first;
      expect(updated.name, original.name);
      expect(updated.allocationPercent, original.allocationPercent);
      expect(updated.isDefault, original.isDefault);
    });

    test('rounds planned amounts to 2 decimal places', () {
      final result = calculator.calculatePlannedAmounts(
        distributableAmount: 1000,
        categories: [cat('Toit', 33.333, isDefault: true)],
      );
      final amount = result.first.plannedAmount;
      expect(amount, closeTo(333.33, 0.01));
    });
  });

  // ── calculateTotalAllocationPercent ────────────────────────────────────────

  group('calculateTotalAllocationPercent', () {
    test('returns sum of all category allocations', () {
      expect(
        calculator.calculateTotalAllocationPercent([
          cat('Toit', 30),
          cat('Meelelahutus', 40),
        ]),
        closeTo(70.0, 0.01),
      );
    });

    test('returns 0 for empty list', () {
      expect(calculator.calculateTotalAllocationPercent([]), 0.0);
    });

    test('returns 100 when fully allocated', () {
      expect(
        calculator.calculateTotalAllocationPercent([
          cat('Toit', 60),
          cat('Meelelahutus', 40),
        ]),
        closeTo(100.0, 0.01),
      );
    });
  });

  // ── calculateUnallocatedPercent ─────────────────────────────────────────────

  group('calculateUnallocatedPercent', () {
    test('returns 100 minus total allocation', () {
      expect(
        calculator.calculateUnallocatedPercent([
          cat('Toit', 30),
          cat('Meelelahutus', 40),
        ]),
        closeTo(30.0, 0.01),
      );
    });

    test('returns 0 when fully allocated', () {
      expect(
        calculator.calculateUnallocatedPercent([
          cat('Toit', 60),
          cat('Meelelahutus', 40),
        ]),
        0.0,
      );
    });

    test('returns 0 when allocations exceed 100 (no negative unallocated)', () {
      expect(
        calculator.calculateUnallocatedPercent([
          cat('Toit', 60),
          cat('Meelelahutus', 60),
        ]),
        0.0,
      );
    });

    test('returns 100 for empty category list', () {
      expect(calculator.calculateUnallocatedPercent([]), closeTo(100.0, 0.01));
    });
  });
}
