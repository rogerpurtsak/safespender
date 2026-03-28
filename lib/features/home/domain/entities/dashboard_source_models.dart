class DashboardBudgetProfileData {
  const DashboardBudgetProfileData({
    required this.id,
    required this.monthlyIncome,
    required this.monthlyFixedExpenses,
    required this.safetyBuffer,
    required this.distributableAmount,
    required this.currencyCode,
    this.displayName,
  });

  final String id;
  final double monthlyIncome;
  final double monthlyFixedExpenses;
  final double safetyBuffer;
  final double distributableAmount;
  final String currencyCode;
  final String? displayName;
}

class DashboardCategoryData {
  const DashboardCategoryData({
    required this.id,
    required this.name,
    required this.allocationPercent,
    required this.plannedAmount,
    required this.sortOrder,
    required this.isDefault,
  });

  final String id;
  final String name;
  final double allocationPercent;
  final double plannedAmount;
  final int sortOrder;
  final bool isDefault;
}

class DashboardExpenseData {
  const DashboardExpenseData({
    required this.id,
    required this.budgetCategoryId,
    required this.amount,
    required this.expenseDate,
  });

  final String id;
  final String budgetCategoryId;
  final double amount;
  final DateTime expenseDate;
}
