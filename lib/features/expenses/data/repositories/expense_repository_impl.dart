import '../../domain/models/expense.dart';
import '../datasources/expense_local_data_source.dart';
import 'expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl({required this.localDataSource});

  final ExpenseLocalDataSource localDataSource;

  @override
  Future<int> saveExpense(Expense expense) {
    return localDataSource.insertExpense(expense);
  }

  @override
  Future<List<Expense>> getExpensesForMonth(DateTime month) {
    return localDataSource.getExpensesForMonth(month);
  }

  @override
  Future<List<Expense>> getExpensesForCategoryInMonth(
    int categoryId,
    DateTime month,
  ) {
    return localDataSource.getExpensesForCategoryInMonth(categoryId, month);
  }
}
