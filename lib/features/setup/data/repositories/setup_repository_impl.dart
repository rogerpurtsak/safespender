import '../../domain/models/budget_category.dart';
import '../../domain/models/budget_profile.dart';
import '../datasources/setup_local_data_source.dart';
import 'setup_repository.dart';

class SetupRepositoryImpl implements SetupRepository {
  final SetupLocalDataSource localDataSource;

  const SetupRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> saveSetup({
    required BudgetProfile profile,
    required List<BudgetCategory> categories,
  }) {
    return localDataSource.saveSetup(
      profile: profile,
      categories: categories,
    );
  }

  @override
  Future<BudgetProfile?> getBudgetProfile() {
    return localDataSource.getBudgetProfile();
  }

  @override
  Future<List<BudgetCategory>> getBudgetCategories() {
    return localDataSource.getBudgetCategories();
  }

  @override
  Future<bool> hasCompletedSetup() {
    return localDataSource.hasCompletedSetup();
  }

  @override
  Future<void> clearSetup() {
    return localDataSource.clearSetup();
  }

  @override
  Future<void> updateBudgetProfile(BudgetProfile profile) {
    return localDataSource.updateBudgetProfile(profile);
  }

  @override
  Future<void> syncCategories({
    required int profileId,
    required double distributableAmount,
    required List<BudgetCategory> categories,
  }) {
    return localDataSource.syncCategories(
      profileId: profileId,
      distributableAmount: distributableAmount,
      categories: categories,
    );
  }
}