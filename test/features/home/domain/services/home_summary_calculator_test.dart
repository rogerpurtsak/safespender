import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/home/domain/entities/dashboard_source_models.dart';
import 'package:safespender/features/home/domain/entities/home_insight.dart';
import 'package:safespender/features/home/domain/services/home_summary_calculator.dart';

void main() {
  const calculator = HomeSummaryCalculator();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  DashboardBudgetProfileData profile({
    double income = 2000,
    double fixed = 500,
    double buffer = 100,
    double distributable = 1400,
    String? displayName,
  }) =>
      DashboardBudgetProfileData(
        id: 'profile-1',
        monthlyIncome: income,
        monthlyFixedExpenses: fixed,
        safetyBuffer: buffer,
        distributableAmount: distributable,
        currencyCode: 'EUR',
        displayName: displayName,
      );

  DashboardCategoryData category({
    required String id,
    required String name,
    double plannedAmount = 300,
    double allocationPercent = 30,
    bool isDefault = false,
  }) =>
      DashboardCategoryData(
        id: id,
        name: name,
        allocationPercent: allocationPercent,
        plannedAmount: plannedAmount,
        sortOrder: 0,
        isDefault: isDefault,
      );

  DashboardExpenseData expense({
    required String categoryId,
    required double amount,
  }) =>
      DashboardExpenseData(
        id: 'exp-$amount',
        budgetCategoryId: categoryId,
        amount: amount,
        expenseDate: DateTime(2025, 7, 10),
      );

  // ── Category summaries ───────────────────────────────────────────────────────

  group('category summaries', () {
    test('spent amount is aggregated per category', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 300)],
        expenses: [
          expense(categoryId: 'cat-1', amount: 50),
          expense(categoryId: 'cat-1', amount: 30),
        ],
      );

      final summary = result.categorySummaries.first;
      expect(summary.spentAmount, closeTo(80.0, 0.01));
    });

    test('remaining amount is planned minus spent', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 300)],
        expenses: [expense(categoryId: 'cat-1', amount: 100)],
      );

      expect(result.categorySummaries.first.remainingAmount, closeTo(200.0, 0.01));
    });

    test('remaining amount is negative when over budget', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 150)],
      );

      expect(result.categorySummaries.first.remainingAmount, closeTo(-50.0, 0.01));
    });

    test('isOverBudget is true when remaining is negative', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 110)],
      );

      expect(result.categorySummaries.first.isOverBudget, isTrue);
    });

    test('isOverBudget is false when within budget', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 300)],
        expenses: [expense(categoryId: 'cat-1', amount: 100)],
      );

      expect(result.categorySummaries.first.isOverBudget, isFalse);
    });

    test('isNearLimit is true at 85% usage', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 85)],
      );

      expect(result.categorySummaries.first.isNearLimit, isTrue);
    });

    test('isNearLimit is false below 85% usage', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 80)],
      );

      expect(result.categorySummaries.first.isNearLimit, isFalse);
    });

    test('isNearLimit is false when over budget (isOverBudget takes priority)', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 120)],
      );

      expect(result.categorySummaries.first.isNearLimit, isFalse);
    });

    test('category with no expenses has zero spent and full remaining', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 300)],
        expenses: [],
      );

      final summary = result.categorySummaries.first;
      expect(summary.spentAmount, 0.0);
      expect(summary.remainingAmount, closeTo(300.0, 0.01));
    });

    test('expenses for other categories do not bleed into wrong category', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [
          category(id: 'cat-1', name: 'Toit', plannedAmount: 300),
          category(id: 'cat-2', name: 'Meelelahutus', plannedAmount: 200),
        ],
        expenses: [expense(categoryId: 'cat-2', amount: 50)],
      );

      final toit = result.categorySummaries.firstWhere((s) => s.name == 'Toit');
      expect(toit.spentAmount, 0.0);
    });
  });

  // ── Monthly totals ───────────────────────────────────────────────────────────

  group('monthly totals', () {
    test('totalSpentThisMonth sums all expenses', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [
          category(id: 'cat-1', name: 'Toit', plannedAmount: 300),
          category(id: 'cat-2', name: 'Transport', plannedAmount: 200),
        ],
        expenses: [
          expense(categoryId: 'cat-1', amount: 100),
          expense(categoryId: 'cat-2', amount: 50),
        ],
      );

      expect(result.totalSpentThisMonth, closeTo(150.0, 0.01));
    });

    test('totalSpentThisMonth is zero with no expenses', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit')],
        expenses: [],
      );

      expect(result.totalSpentThisMonth, 0.0);
    });

    test('monthlyRemaining is income minus fixed expenses minus total spent', () {
      // income=2000, fixed=500, spent=300 → remaining = 2000-500-300 = 1200
      final result = calculator.calculate(
        profile: profile(income: 2000, fixed: 500, buffer: 100),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 500)],
        expenses: [expense(categoryId: 'cat-1', amount: 300)],
      );

      expect(result.monthlyRemaining, closeTo(1200.0, 0.01));
    });

    test('safelySpendable is monthlyRemaining minus safety buffer, clamped to 0', () {
      // remaining = 1200, buffer = 100 → spendable = 1100
      final result = calculator.calculate(
        profile: profile(income: 2000, fixed: 500, buffer: 100),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 500)],
        expenses: [expense(categoryId: 'cat-1', amount: 300)],
      );

      expect(result.safelySpendable, closeTo(1100.0, 0.01));
    });

    test('safelySpendable is 0 when monthly remaining is below safety buffer', () {
      // income=600, fixed=500, spent=50 → remaining = 50; buffer=100 → spendable=0
      final result = calculator.calculate(
        profile: profile(income: 600, fixed: 500, buffer: 100, distributable: 0),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 50)],
        expenses: [expense(categoryId: 'cat-1', amount: 50)],
      );

      expect(result.safelySpendable, 0.0);
    });
  });

  // ── Highlighted category ─────────────────────────────────────────────────────

  group('highlighted category', () {
    test('prefers category whose name contains "toit"', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [
          category(id: 'cat-1', name: 'Meelelahutus', plannedAmount: 500),
          category(id: 'cat-2', name: 'Toit', plannedAmount: 200),
        ],
        expenses: [],
      );

      expect(result.highlightedCategory?.name, 'Toit');
    });

    test('falls back to highest planned amount when no "toit" category', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [
          category(id: 'cat-1', name: 'Transport', plannedAmount: 150),
          category(id: 'cat-2', name: 'Meelelahutus', plannedAmount: 300),
        ],
        expenses: [],
      );

      expect(result.highlightedCategory?.name, 'Meelelahutus');
    });

    test('is null when there are no categories', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [],
        expenses: [],
      );

      expect(result.highlightedCategory, isNull);
    });
  });

  // ── Insights ─────────────────────────────────────────────────────────────────

  group('insight', () {
    test('danger tone when any category is over budget', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 150)],
      );

      expect(result.insight.tone, HomeInsightTone.danger);
    });

    test('warning tone when a category is near limit but none over budget', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 90)],
      );

      expect(result.insight.tone, HomeInsightTone.warning);
    });

    test('neutral tone when no expenses have been added yet', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 300)],
        expenses: [],
      );

      expect(result.insight.tone, HomeInsightTone.neutral);
    });

    test('positive tone when expenses exist and budget is healthy', () {
      final result = calculator.calculate(
        profile: profile(income: 2000, fixed: 200, buffer: 100, distributable: 1700),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 500)],
        expenses: [expense(categoryId: 'cat-1', amount: 50)],
      );

      expect(result.insight.tone, HomeInsightTone.positive);
    });

    test('danger insight title is "Tähelepanu"', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 150)],
      );

      expect(result.insight.title, 'Tähelepanu');
    });

    test('danger insight message contains the over-budget category name', () {
      final result = calculator.calculate(
        profile: profile(),
        categories: [category(id: 'cat-1', name: 'Toit', plannedAmount: 100)],
        expenses: [expense(categoryId: 'cat-1', amount: 150)],
      );

      expect(result.insight.message, contains('Toit'));
    });
  });

  // ── Display name ─────────────────────────────────────────────────────────────

  group('displayName', () {
    test('uses profile displayName when set', () {
      final result = calculator.calculate(
        profile: profile(displayName: 'Mari'),
        categories: [],
        expenses: [],
      );

      expect(result.displayName, 'Mari');
    });

    test('falls back to "Patrik" when displayName is null', () {
      final result = calculator.calculate(
        profile: profile(displayName: null),
        categories: [],
        expenses: [],
      );

      expect(result.displayName, 'Patrik');
    });

    test('falls back to "Patrik" when displayName is blank', () {
      final result = calculator.calculate(
        profile: profile(displayName: '   '),
        categories: [],
        expenses: [],
      );

      expect(result.displayName, 'Patrik');
    });
  });
}
