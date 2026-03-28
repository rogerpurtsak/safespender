import 'category_budget_status.dart';

class CategoryBudgetOverview {
  const CategoryBudgetOverview({
    required this.categoryId,
    required this.categoryName,
    required this.plannedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.totalDaysInMonth,
    required this.elapsedDays,
    required this.remainingDays,
    required this.status,
    required this.usagePercent,
    this.suggestedDailyAmount,
  });

  final int categoryId;
  final String categoryName;

  final double plannedAmount;

  final double spentAmount;

  final double remainingAmount;

  final int totalDaysInMonth;


  final int elapsedDays;

  final int remainingDays;

  final CategoryBudgetStatus status;

  final double usagePercent;

  final double? suggestedDailyAmount;

  double get overspentAmount => remainingAmount < 0 ? remainingAmount.abs() : 0;

  bool get isOverBudget => status == CategoryBudgetStatus.overBudget;
}
