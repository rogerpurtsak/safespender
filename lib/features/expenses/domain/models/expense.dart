class Expense {
  final int? id;
  final int budgetCategoryId;
  final double amount;
  final DateTime expenseDate;
  final String? note;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.budgetCategoryId,
    required this.amount,
    required this.expenseDate,
    this.note,
    required this.createdAt,
  });

  Expense copyWith({
    int? id,
    int? budgetCategoryId,
    double? amount,
    DateTime? expenseDate,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      budgetCategoryId: budgetCategoryId ?? this.budgetCategoryId,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_category_id': budgetCategoryId,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      budgetCategoryId: map['budget_category_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
