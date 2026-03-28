import '../../../../core/database/app_database.dart';
import '../../domain/models/expense.dart';

class ExpenseLocalDataSource {
  final AppDatabase appDatabase;

  const ExpenseLocalDataSource({required this.appDatabase});

  Future<int> insertExpense(Expense expense) async {
    final db = await appDatabase.database;
    final map = expense.toMap()..remove('id');
    return db.insert('expenses', map);
  }

  Future<List<Expense>> getExpensesForMonth(DateTime month) async {
    final db = await appDatabase.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final result = await db.query(
      'expenses',
      where: 'expense_date >= ? AND expense_date < ?',
      whereArgs: [start, end],
      orderBy: 'expense_date DESC',
    );

    return result.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getExpensesForCategoryInMonth(
    int categoryId,
    DateTime month,
  ) async {
    final db = await appDatabase.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final result = await db.query(
      'expenses',
      where: 'budget_category_id = ? AND expense_date >= ? AND expense_date < ?',
      whereArgs: [categoryId, start, end],
      orderBy: 'expense_date DESC',
    );

    return result.map(Expense.fromMap).toList();
  }
}
