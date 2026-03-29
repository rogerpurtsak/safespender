import 'package:flutter_test/flutter_test.dart';
import 'package:safespender/features/home/domain/entities/budget_mood.dart';
import 'package:safespender/features/home/domain/entities/category_summary.dart';
import 'package:safespender/features/home/domain/services/budget_mood_evaluator.dart';

void main() {
  final evaluator = BudgetMoodEvaluator();

  CategorySummary summary({
    required bool isOverBudget,
    required bool isNearLimit,
  }) =>
      CategorySummary(
        categoryId: 'test',
        name: 'Toit',
        plannedAmount: 100,
        spentAmount: 0,
        remainingAmount: 100,
        usagePercent: 0,
        isOverBudget: isOverBudget,
        isNearLimit: isNearLimit,
      );

  group('BudgetMoodEvaluator', () {
    test('returns good for empty category list', () {
      expect(evaluator.evaluate([]), BudgetMood.good);
    });

    test('returns good when all categories are healthy', () {
      expect(
        evaluator.evaluate([
          summary(isOverBudget: false, isNearLimit: false),
          summary(isOverBudget: false, isNearLimit: false),
        ]),
        BudgetMood.good,
      );
    });

    test('returns medium when any category is near limit', () {
      expect(
        evaluator.evaluate([
          summary(isOverBudget: false, isNearLimit: false),
          summary(isOverBudget: false, isNearLimit: true),
        ]),
        BudgetMood.medium,
      );
    });

    test('returns critical when any category is over budget', () {
      expect(
        evaluator.evaluate([
          summary(isOverBudget: true, isNearLimit: false),
          summary(isOverBudget: false, isNearLimit: false),
        ]),
        BudgetMood.critical,
      );
    });

    test('returns critical even when other categories are only near limit', () {
      expect(
        evaluator.evaluate([
          summary(isOverBudget: true, isNearLimit: false),
          summary(isOverBudget: false, isNearLimit: true),
        ]),
        BudgetMood.critical,
      );
    });

    test('critical takes priority over medium', () {
      // One category over budget, one near limit → critical wins
      final mood = evaluator.evaluate([
        summary(isOverBudget: false, isNearLimit: true),
        summary(isOverBudget: true, isNearLimit: false),
      ]);
      expect(mood, BudgetMood.critical);
    });
  });
}
