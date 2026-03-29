// ignore: avoid_print
import 'dart:developer' as dev;

import '../entities/category_summary.dart';
import '../entities/dashboard_source_models.dart';
import '../entities/home_insight.dart';
import '../entities/home_summary.dart';

class HomeSummaryCalculator {
  const HomeSummaryCalculator();

  HomeSummary calculate({
    required DashboardBudgetProfileData profile,
    required List<DashboardCategoryData> categories,
    required List<DashboardExpenseData> expenses,
  }) {
    final spentByCategory = <String, double>{};

    for (final expense in expenses) {
      dev.log('EXPENSE: id=${expense.id} categoryId="${expense.budgetCategoryId}" amount=${expense.amount}');
      spentByCategory.update(
        expense.budgetCategoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    dev.log('spentByCategory keys: ${spentByCategory.keys.toList()}');

    final categorySummaries = categories
        .map(
          (category) {
            final spentAmount = spentByCategory[category.id] ?? 0;
            dev.log('CATEGORY: id="${category.id}" name="${category.name}" spent=$spentAmount');
            final plannedAmount = category.plannedAmount;
            final remainingAmount = plannedAmount - spentAmount;
            final usagePercent = plannedAmount <= 0
                ? (spentAmount > 0 ? 1.0 : 0.0)
                : (spentAmount / plannedAmount).clamp(0.0, 2.0);

            return CategorySummary(
              categoryId: category.id,
              name: category.name,
              plannedAmount: plannedAmount,
              spentAmount: spentAmount,
              remainingAmount: remainingAmount,
              usagePercent: usagePercent,
              isOverBudget: remainingAmount < 0,
              isNearLimit: remainingAmount >= 0 && usagePercent >= 0.85,
            );
          },
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final totalSpentThisMonth = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final monthlyRemaining =
        profile.monthlyIncome - profile.monthlyFixedExpenses - totalSpentThisMonth;

    final safelySpendable = (monthlyRemaining - profile.safetyBuffer)
        .clamp(0.0, double.infinity);

    final highlightedCategory = _pickHighlightedCategory(categorySummaries);

    return HomeSummary(
      displayName: profile.displayName?.trim().isNotEmpty == true
          ? profile.displayName!.trim()
          : 'Patrik',
      currencyCode: profile.currencyCode,
      monthlyRemaining: monthlyRemaining,
      safelySpendable: safelySpendable,
      monthlyIncome: profile.monthlyIncome,
      fixedExpenses: profile.monthlyFixedExpenses,
      safetyBuffer: profile.safetyBuffer,
      distributableAmount: profile.distributableAmount,
      totalSpentThisMonth: totalSpentThisMonth,
      categorySummaries: categorySummaries,
      highlightedCategory: highlightedCategory,
      insight: _buildInsight(
        categorySummaries: categorySummaries,
        expenses: expenses,
        safelySpendable: safelySpendable,
        monthlyRemaining: monthlyRemaining,
      ),
    );
  }

  CategorySummary? _pickHighlightedCategory(List<CategorySummary> categories) {
    if (categories.isEmpty) {
      return null;
    }

    final foodMatch = categories.where(
      (category) => category.name.toLowerCase().contains('toit'),
    );

    if (foodMatch.isNotEmpty) {
      return foodMatch.first;
    }

    final sorted = [...categories]
      ..sort((a, b) => b.plannedAmount.compareTo(a.plannedAmount));

    return sorted.first;
  }

  HomeInsight _buildInsight({
    required List<CategorySummary> categorySummaries,
    required List<DashboardExpenseData> expenses,
    required double safelySpendable,
    required double monthlyRemaining,
  }) {
    final overBudget = categorySummaries.where((item) => item.isOverBudget).toList();
    if (overBudget.isNotEmpty) {
      final first = overBudget.first;
      return HomeInsight(
        title: 'Tähelepanu',
        message:
            'Kategooria "${first.name}" on oma eelarve ületanud. Vaata järgmised kulud seal üle.',
        tone: HomeInsightTone.danger,
      );
    }

    final nearLimit = categorySummaries.where((item) => item.isNearLimit).toList();
    if (nearLimit.isNotEmpty) {
      final first = nearLimit.first;
      return HomeInsight(
        title: 'Jälgi tempot',
        message:
            'Kategooria "${first.name}" on piirile lähedal. Seal on jäänud vähe ruumi.',
        tone: HomeInsightTone.warning,
      );
    }

    if (expenses.isEmpty) {
      return const HomeInsight(
        title: 'Nutikas nõuanne',
        message: 'Lisa esimene kulu ja avaleht hakkab sinu päris tempot paremini näitama.',
        tone: HomeInsightTone.neutral,
      );
    }

    if (monthlyRemaining <= 0 || safelySpendable <= 0) {
      return const HomeInsight(
        title: 'Hoia tagasi',
        message: 'Selle kuu turvaline varu on otsas. Uued kulud tasub teha ettevaatlikult.',
        tone: HomeInsightTone.warning,
      );
    }

    return const HomeInsight(
      title: 'Nutikas nõuanne',
      message: 'Sinu kulutempo tundub hetkel stabiilne ja puhver on alles.',
      tone: HomeInsightTone.positive,
    );
  }
}
