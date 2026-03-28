import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/grocery/domain/models/category_budget_status.dart';
import 'package:safespender/features/grocery/domain/services/budget_rebalancing_service.dart';

void main() {
  const service = BudgetRebalancingService();

  // Mid-month date where elapsed == 15 out of 31 days (July)
  final july15 = DateTime(2025, 7, 15); // 15/31 ≈ 48% elapsed

  group('BudgetRebalancingService.calculate', () {
    group('remaining amount', () {
      test('is planned minus spent', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 80,
          now: july15,
        );
        expect(result.remainingAmount, closeTo(120.0, 0.01));
      });

      test('is negative when spent exceeds planned', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 230,
          now: july15,
        );
        expect(result.remainingAmount, closeTo(-30.0, 0.01));
        expect(result.overspentAmount, closeTo(30.0, 0.01));
      });

      test('overspentAmount is 0 when within budget', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 50,
          now: july15,
        );
        expect(result.overspentAmount, 0.0);
      });
    });

    group('period fields', () {
      test('totalDaysInMonth is correct for July', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 50,
          now: july15,
        );
        expect(result.totalDaysInMonth, 31);
      });

      test('elapsedDays equals day-of-month', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 50,
          now: july15,
        );
        expect(result.elapsedDays, 15);
      });

      test('remainingDays is totalDays minus elapsedDays', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 50,
          now: july15,
        );
        expect(result.remainingDays, 16); // 31 - 15
      });

      test('last day of month gives 0 remaining days', () {
        final lastDay = _date(2025, 7, 31);
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 50,
          now: lastDay,
        );
        expect(result.remainingDays, 0);
      });

      test('works correctly for February in a leap year', () {
        final feb29 = _date(2024, 2, 29);
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 0,
          now: feb29,
        );
        expect(result.totalDaysInMonth, 29);
        expect(result.remainingDays, 0);
      });
    });

    group('status — onTrack', () {
      test('returns onTrack when spending matches expected pace', () {
        // 15/31 days elapsed → ~48% of month gone. Spending 48% of 200 = 96.
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 96,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.onTrack);
        expect(result.isOverBudget, isFalse);
      });
    });

    group('status — underBudget', () {
      test('returns underBudget when spending is well below expected pace', () {
        // 15/31 elapsed, expected ≈ 96.77. 80% of that ≈ 77.4.
        // Spending 20 is well below the threshold.
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 20,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.underBudget);
      });

      test('returns underBudget on first day with zero spending', () {
        final firstDay = _date(2025, 7, 1);
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 0,
          now: firstDay,
        );
        // 1/31 elapsed, expected ≈ 6.45. 0 < 6.45 * 0.8 → underBudget.
        expect(result.status, CategoryBudgetStatus.underBudget);
      });
    });

    group('status — nearLimit', () {
      test('returns nearLimit when usage >= 85% and not yet over', () {
        // 85% of 200 = 170
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 170,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.nearLimit);
        expect(result.isOverBudget, isFalse);
      });

      test('returns nearLimit at exactly 85% usage', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 100,
          spentAmount: 85,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.nearLimit);
      });
    });

    group('status — overBudget', () {
      test('returns overBudget when spent exceeds planned', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 201,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.overBudget);
        expect(result.isOverBudget, isTrue);
      });

      test('overBudget takes priority over nearLimit threshold', () {
        // If remaining < 0, must be overBudget regardless of usagePercent.
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 100,
          spentAmount: 110,
          now: july15,
        );
        expect(result.status, CategoryBudgetStatus.overBudget);
      });
    });

    group('daily suggestion', () {
      test('is remaining divided by remaining days when under budget', () {
        // remaining = 120, remainingDays = 16 → 7.50
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 80,
          now: july15,
        );
        expect(result.suggestedDailyAmount, closeTo(7.50, 0.01));
      });

      test('is null when overBudget', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 250,
          now: july15,
        );
        expect(result.suggestedDailyAmount, isNull);
      });

      test('is null on the last day of the month (0 remaining days)', () {
        final lastDay = _date(2025, 7, 31);
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 80,
          now: lastDay,
        );
        expect(result.suggestedDailyAmount, isNull);
      });

      test('rounds to 2 decimal places', () {
        // remaining = 100, remainingDays = 16 → 6.25 (exact)
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 180,
          spentAmount: 80,
          now: july15,
        );
        // remaining = 100, days = 16 → 6.25
        expect(result.suggestedDailyAmount, closeTo(6.25, 0.001));
      });
    });

    group('edge cases', () {
      test('handles zero planned amount without crashing', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 0,
          spentAmount: 50,
          now: july15,
        );
        // usagePercent clamps to 2.0 when planned is 0 and spent > 0
        expect(result.usagePercent, 2.0);
        expect(result.status, CategoryBudgetStatus.overBudget);
      });

      test('handles zero spent without crashing', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 200,
          spentAmount: 0,
          now: july15,
        );
        expect(result.spentAmount, 0.0);
        expect(result.remainingAmount, closeTo(200.0, 0.01));
      });

      test('usagePercent is 0 when both planned and spent are 0', () {
        final result = service.calculate(
          categoryId: 1,
          categoryName: 'Toit',
          plannedAmount: 0,
          spentAmount: 0,
          now: july15,
        );
        expect(result.usagePercent, 0.0);
      });
    });
  });
}

DateTime _date(int year, int month, int day) => DateTime(year, month, day);
