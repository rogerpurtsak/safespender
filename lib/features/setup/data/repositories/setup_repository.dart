import '../../domain/models/budget_category.dart';
import '../../domain/models/budget_profile.dart';

abstract class SetupRepository {
  Future<void> saveSetup({
    required BudgetProfile profile,
    required List<BudgetCategory> categories,
  });

  Future<BudgetProfile?> getBudgetProfile();

  Future<List<BudgetCategory>> getBudgetCategories();

  Future<bool> hasCompletedSetup();

  Future<void> clearSetup();

  Future<void> updateBudgetProfile(BudgetProfile profile);

  Future<void> syncCategories({
    required int profileId,
    required double distributableAmount,
    required List<BudgetCategory> categories,
  });
}