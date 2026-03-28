import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../setup/data/datasources/setup_local_data_source.dart';
import '../../../setup/data/repositories/setup_repository.dart';
import '../../../setup/data/repositories/setup_repository_impl.dart';
import '../../../setup/presentation/providers/setup_notifier.dart';
import '../../domain/entities/dashboard_source_models.dart';

abstract class DashboardDataGateway {
  Future<DashboardBudgetProfileData?> getBudgetProfile();

  Future<List<DashboardCategoryData>> getCategoriesForProfile(String profileId);

  Future<List<DashboardExpenseData>> getExpensesForMonth({
    required DateTime month,
  });
}

class _SetupRepositoryGateway implements DashboardDataGateway {
  const _SetupRepositoryGateway(this._repository);

  final SetupRepository _repository;

  @override
  Future<DashboardBudgetProfileData?> getBudgetProfile() async {
    final profile = await _repository.getBudgetProfile();
    if (profile == null) return null;

    return DashboardBudgetProfileData(
      id: profile.id?.toString() ?? '0',
      monthlyIncome: profile.monthlyIncome,
      monthlyFixedExpenses: profile.monthlyFixedExpenses,
      safetyBuffer: profile.safetyBuffer,
      distributableAmount: profile.distributableAmount,
      currencyCode: profile.currencyCode,
    );
  }

  @override
  Future<List<DashboardCategoryData>> getCategoriesForProfile(
    String profileId,
  ) async {
    final categories = await _repository.getBudgetCategories();

    return categories
        .map(
          (c) => DashboardCategoryData(
            id: c.id?.toString() ?? c.name,
            name: c.name,
            allocationPercent: c.allocationPercent,
            plannedAmount: c.plannedAmount,
            sortOrder: c.sortOrder,
            isDefault: c.isDefault,
          ),
        )
        .toList();
  }

  @override
  Future<List<DashboardExpenseData>> getExpensesForMonth({
    required DateTime month,
  }) async {
    return [];
  }
}

final dashboardDataGatewayProvider = Provider<DashboardDataGateway>((ref) {
  final localDataSource = SetupLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  );
  final repository = SetupRepositoryImpl(localDataSource: localDataSource);
  return _SetupRepositoryGateway(repository);
});
