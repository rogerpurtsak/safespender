class BudgetCategory {
  final int? id;
  final int? budgetProfileId;
  final String name;
  final double allocationPercent;
  final double plannedAmount;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetCategory({
    this.id,
    this.budgetProfileId,
    required this.name,
    required this.allocationPercent,
    this.plannedAmount = 0.0,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetCategory copyWith({
    int? id,
    int? budgetProfileId,
    String? name,
    double? allocationPercent,
    double? plannedAmount,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      budgetProfileId: budgetProfileId ?? this.budgetProfileId,
      name: name ?? this.name,
      allocationPercent: allocationPercent ?? this.allocationPercent,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_profile_id': budgetProfileId,
      'name': name,
      'allocation_percent': allocationPercent,
      'planned_amount': plannedAmount,
      'is_default': isDefault ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      id: map['id'] as int?,
      budgetProfileId: map['budget_profile_id'] as int?,
      name: map['name'] as String,
      allocationPercent: (map['allocation_percent'] as num).toDouble(),
      plannedAmount: (map['planned_amount'] as num).toDouble(),
      isDefault: (map['is_default'] as int) == 1,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'BudgetCategory(id: $id, name: $name, '
        'allocationPercent: $allocationPercent, plannedAmount: $plannedAmount, '
        'isDefault: $isDefault, sortOrder: $sortOrder)';
  }
}
