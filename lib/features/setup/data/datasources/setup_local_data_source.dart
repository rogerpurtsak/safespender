import 'package:sqflite/sqflite.dart';

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
}