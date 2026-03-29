import '../../../../core/database/app_database.dart';
import '../../domain/models/budget_category.dart';
import '../../domain/models/budget_profile.dart';

class SetupLocalDataSource {
  final AppDatabase appDatabase;

  const SetupLocalDataSource({
    required this.appDatabase,
  });

  Future<void> saveSetup({
    required BudgetProfile profile,
    required List<BudgetCategory> categories,
  }) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      await txn.delete('budget_categories');
      await txn.delete('budget_profiles');

      final profileId = await txn.insert(
        'budget_profiles',
        profile.toMap()..remove('id'),
      );

      for (final category in categories) {
        final categoryMap = category.copyWith(
          budgetProfileId: profileId,
        ).toMap()..remove('id');

        await txn.insert('budget_categories', categoryMap);
      }
    });
  }

  Future<BudgetProfile?> getBudgetProfile() async {
    final db = await appDatabase.database;

    final result = await db.query(
      'budget_profiles',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return BudgetProfile.fromMap(result.first);
  }

  Future<List<BudgetCategory>> getBudgetCategories() async {
    final db = await appDatabase.database;

    final result = await db.query(
      'budget_categories',
      orderBy: 'sort_order ASC',
    );

    return result.map(BudgetCategory.fromMap).toList();
  }

  Future<bool> hasCompletedSetup() async {
    final profile = await getBudgetProfile();
    return profile != null;
  }

  Future<void> clearSetup() async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      await txn.delete('budget_categories');
      await txn.delete('budget_profiles');
    });
  }

  Future<void> updateBudgetProfile(BudgetProfile profile) async {
    assert(profile.id != null, 'Cannot update a profile without an id');
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      await txn.update(
        'budget_profiles',
        {
          'monthly_income': profile.monthlyIncome,
          'monthly_fixed_expenses': profile.monthlyFixedExpenses,
          'safety_buffer': profile.safetyBuffer,
          'distributable_amount': profile.distributableAmount,
          'currency_code': profile.currencyCode,
          'updated_at': profile.updatedAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      final categoryRows = await txn.query(
        'budget_categories',
        columns: ['id', 'allocation_percent'],
        where: 'budget_profile_id = ?',
        whereArgs: [profile.id],
      );

      final now = DateTime.now().toIso8601String();

      for (final row in categoryRows) {
        final allocationPercent = (row['allocation_percent'] as num).toDouble();
        final newPlannedAmount =
            _roundTo2(profile.distributableAmount * (allocationPercent / 100));

        await txn.update(
          'budget_categories',
          {'planned_amount': newPlannedAmount, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    });
  }

  /// Syncs categories for a profile: updates existing (by id), inserts new
  /// (no id), deletes removed ones. Recalculates plannedAmount from
  /// [distributableAmount] × allocationPercent. Preserves category IDs so
  /// existing expenses remain linked.
  Future<void> syncCategories({
    required int profileId,
    required double distributableAmount,
    required List<BudgetCategory> categories,
  }) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'budget_categories',
        columns: ['id'],
        where: 'budget_profile_id = ?',
        whereArgs: [profileId],
      );
      final existingIds = existing.map((r) => r['id'] as int).toSet();
      final keepIds =
          categories.where((c) => c.id != null).map((c) => c.id!).toSet();

      // Delete categories removed by user
      for (final id in existingIds.difference(keepIds)) {
        await txn.delete(
          'budget_categories',
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      final now = DateTime.now().toIso8601String();

      for (int i = 0; i < categories.length; i++) {
        final cat = categories[i];
        final plannedAmount =
            _roundTo2(distributableAmount * (cat.allocationPercent / 100));

        if (cat.id != null && existingIds.contains(cat.id)) {
          await txn.update(
            'budget_categories',
            {
              'name': cat.name,
              'allocation_percent': cat.allocationPercent,
              'planned_amount': plannedAmount,
              'sort_order': i,
              'updated_at': now,
            },
            where: 'id = ?',
            whereArgs: [cat.id],
          );
        } else {
          await txn.insert('budget_categories', {
            'budget_profile_id': profileId,
            'name': cat.name,
            'allocation_percent': cat.allocationPercent,
            'planned_amount': plannedAmount,
            'sort_order': i,
            'is_default': cat.isDefault ? 1 : 0,
            'created_at': now,
            'updated_at': now,
          });
        }
      }
    });
  }

  double _roundTo2(double value) =>
      double.parse(value.toStringAsFixed(2));
}