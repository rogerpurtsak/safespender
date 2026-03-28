class CategorySummary {
  const CategorySummary({
    required this.categoryId,
    required this.name,
    required this.plannedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.usagePercent,
    required this.isOverBudget,
    required this.isNearLimit,
  });

  final String categoryId;
  final String name;
  final double plannedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double usagePercent;
  final bool isOverBudget;
  final bool isNearLimit;
}
