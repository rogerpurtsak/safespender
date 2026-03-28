import 'category_summary.dart';
import 'home_insight.dart';

class HomeSummary {
  const HomeSummary({
    required this.displayName,
    required this.currencyCode,
    required this.monthlyRemaining,
    required this.safelySpendable,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.safetyBuffer,
    required this.distributableAmount,
    required this.totalSpentThisMonth,
    required this.categorySummaries,
    required this.highlightedCategory,
    required this.insight,
  });

  final String displayName;
  final String currencyCode;
  final double monthlyRemaining;
  final double safelySpendable;
  final double monthlyIncome;
  final double fixedExpenses;
  final double safetyBuffer;
  final double distributableAmount;
  final double totalSpentThisMonth;
  final List<CategorySummary> categorySummaries;
  final CategorySummary? highlightedCategory;
  final HomeInsight insight;
}
