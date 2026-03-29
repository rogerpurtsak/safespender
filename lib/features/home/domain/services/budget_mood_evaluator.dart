import '../entities/budget_mood.dart';
import '../entities/category_summary.dart';

class BudgetMoodEvaluator {

  BudgetMood evaluate(List<CategorySummary> categories) {

    if (categories.isEmpty) return BudgetMood.good;

    final hasOverBudget = categories.any((c) => c.isOverBudget);
    if (hasOverBudget) return BudgetMood.critical;

    final hasNearLimit = categories.any((c) => c.isNearLimit);
    if (hasNearLimit) return BudgetMood.medium;

    return BudgetMood.good;
  }
}