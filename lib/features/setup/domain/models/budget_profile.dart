class BudgetProfile {
  final int? id;
  final double monthlyIncome;
  final double monthlyFixedExpenses;
  final double safetyBuffer;
  final double distributableAmount;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetProfile({
    this.id,
    required this.monthlyIncome,
    required this.monthlyFixedExpenses,
    required this.safetyBuffer,
    required this.distributableAmount,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetProfile copyWith({
    int? id,
    double? monthlyIncome,
    double? monthlyFixedExpenses,
    double? safetyBuffer,
    double? distributableAmount,
    String? currencyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetProfile(
      id: id ?? this.id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyFixedExpenses:
          monthlyFixedExpenses ?? this.monthlyFixedExpenses,
      safetyBuffer: safetyBuffer ?? this.safetyBuffer,
      distributableAmount: distributableAmount ?? this.distributableAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthly_income': monthlyIncome,
      'monthly_fixed_expenses': monthlyFixedExpenses,
      'safety_buffer': safetyBuffer,
      'distributable_amount': distributableAmount,
      'currency_code': currencyCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetProfile.fromMap(Map<String, dynamic> map) {
    return BudgetProfile(
      id: map['id'] as int?,
      monthlyIncome: (map['monthly_income'] as num).toDouble(),
      monthlyFixedExpenses: (map['monthly_fixed_expenses'] as num).toDouble(),
      safetyBuffer: (map['safety_buffer'] as num).toDouble(),
      distributableAmount: (map['distributable_amount'] as num).toDouble(),
      currencyCode: map['currency_code'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'BudgetProfile(id: $id, monthlyIncome: $monthlyIncome, '
        'monthlyFixedExpenses: $monthlyFixedExpenses, '
        'safetyBuffer: $safetyBuffer, distributableAmount: '
        '$distributableAmount, currencyCode: $currencyCode)';
  }
}