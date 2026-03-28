import '../../domain/models/expense.dart';

abstract class ExpenseRepository {
  Future<int> saveExpense(Expense expense);
  Future<List<Expense>> getExpensesForMonth(DateTime month);
  Future<List<Expense>> getExpensesForCategoryInMonth(
    int categoryId,
    DateTime month,
  );
}
