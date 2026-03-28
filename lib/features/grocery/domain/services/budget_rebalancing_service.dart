import '../models/category_budget_overview.dart';
import '../models/category_budget_status.dart';

class BudgetRebalancingService {
  const BudgetRebalancingService();

  CategoryBudgetOverview calculate({
    required int categoryId,
    required String categoryName,
    required double plannedAmount,
    required double spentAmount,
    required DateTime now,
  }) {
    final totalDays = _daysInMonth(now.year, now.month);

    final elapsedDays = now.day;
    final remainingDays = totalDays - elapsedDays;

    final remainingAmount = _round(plannedAmount - spentAmount);

    final usagePercent = plannedAmount <= 0
        ? (spentAmount > 0 ? 2.0 : 0.0)
        : (spentAmount / plannedAmount).clamp(0.0, 2.0);

    final status = _determineStatus(
      plannedAmount: plannedAmount,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      usagePercent: usagePercent,
      elapsedDays: elapsedDays,
      totalDays: totalDays,
    );

    final suggestedDailyAmount = _suggestDaily(
      remainingAmount: remainingAmount,
      remainingDays: remainingDays,
      status: status,
    );

    return CategoryBudgetOverview(
      categoryId: categoryId,
      categoryName: categoryName,
      plannedAmount: plannedAmount,
      spentAmount: _round(spentAmount),
      remainingAmount: remainingAmount,
      totalDaysInMonth: totalDays,
      elapsedDays: elapsedDays,
      remainingDays: remainingDays,
      status: status,
      usagePercent: usagePercent,
      suggestedDailyAmount: suggestedDailyAmount,
    );
  }

  CategoryBudgetStatus _determineStatus({
    required double plannedAmount,
    required double spentAmount,
    required double remainingAmount,
    required double usagePercent,
    required int elapsedDays,
    required int totalDays,
  }) {
    if (remainingAmount < 0) return CategoryBudgetStatus.overBudget;
    if (usagePercent >= 0.85) return CategoryBudgetStatus.nearLimit;

    if (plannedAmount > 0 && totalDays > 0 && elapsedDays > 0) {
      final expectedByNow = plannedAmount * (elapsedDays / totalDays);
      if (spentAmount < expectedByNow * 0.8) {
        return CategoryBudgetStatus.underBudget;
      }
    }

    return CategoryBudgetStatus.onTrack;
  }

  double? _suggestDaily({
    required double remainingAmount,
    required int remainingDays,
    required CategoryBudgetStatus status,
  }) {
    if (status == CategoryBudgetStatus.overBudget) return null;
    if (remainingDays <= 0) return null;
    return _round(remainingAmount / remainingDays);
  }

  static int _daysInMonth(int year, int month) {

    return DateTime(year, month + 1, 0).day;
  }

  static double _round(double value) {
    return (value * 100).round() / 100;
  }
}
