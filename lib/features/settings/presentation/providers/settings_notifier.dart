import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../grocery/presentation/providers/grocery_overview_provider.dart';
import '../../../home/presentation/providers/home_summary_provider.dart';
import '../../../purchase_check/presentation/providers/purchase_check_notifier.dart';
import '../../../setup/data/repositories/setup_repository.dart';
import '../../../setup/domain/models/budget_category.dart';
import '../../../setup/domain/services/setup_budget_calculator.dart';
import '../../../setup/presentation/providers/setup_notifier.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import 'settings_state.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  );
});

final _settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    localDataSource: ref.watch(_settingsLocalDataSourceProvider),
  );
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

// ── Notifier ──────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<SettingsState> {
  late final SetupRepository _setupRepository;
  late final SettingsRepository _settingsRepository;
  late final SetupBudgetCalculator _calculator;

  @override
  SettingsState build() {
    _setupRepository = ref.read(setupRepositoryProvider);
    _settingsRepository = ref.read(_settingsRepositoryProvider);
    _calculator = ref.read(setupBudgetCalculatorProvider);
    return SettingsState.initial();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadCurrentSettings() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final profile = await _setupRepository.getBudgetProfile();
      final preferences = await _settingsRepository.getPreferences();
      final categories = await _setupRepository.getBudgetCategories();

      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          hasProfile: false,
          notificationsEnabled: preferences.notificationsEnabled,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        hasProfile: true,
        safetyBufferInput: _fmt(profile.safetyBuffer),
        currencyCode: profile.currencyCode,
        categories: categories,
        notificationsEnabled: preferences.notificationsEnabled,
        monthlyIncome: profile.monthlyIncome,
        monthlyFixedExpenses: profile.monthlyFixedExpenses,
        distributableAmount: profile.distributableAmount,
      );
    } catch (e, st) {
      debugPrint('SettingsNotifier.load error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Seadete laadimine ebaõnnestus.',
      );
    }
  }

  // ── Profile field updates ─────────────────────────────────────────────────

  void updateSafetyBufferInput(String value) {
    state = state.copyWith(
      safetyBufferInput: value,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCurrencyCode(String code) {
    state = state.copyWith(
      currencyCode: code,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  // ── Category management ───────────────────────────────────────────────────

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (state.categories.length >= 5) {
      state = state.copyWith(errorMessage: 'Maksimaalselt 5 kategooriat.');
      return;
    }
    final alreadyExists = state.categories
        .any((c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) {
      state =
          state.copyWith(errorMessage: 'Selline kategooria on juba olemas.');
      return;
    }

    final now = DateTime.now();
    final updated = [
      ...state.categories,
      BudgetCategory(
        name: trimmed,
        allocationPercent: 0,
        plannedAmount: 0,
        sortOrder: state.categories.length,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    state = state.copyWith(
      categories: updated,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void removeCategory(int index) {
    if (index < 0 || index >= state.categories.length) return;
    if (state.categories[index].isDefault) {
      state = state.copyWith(
          errorMessage: 'Vaikimisi kategooriat ei saa eemaldada.');
      return;
    }

    final updated = [...state.categories]..removeAt(index);
    state = state.copyWith(
      categories: _rebuildSortOrders(updated),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCategoryName(int index, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || index < 0 || index >= state.categories.length) {
      return;
    }
    final alreadyExists = state.categories.asMap().entries.any(
      (e) =>
          e.key != index &&
          e.value.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) {
      state =
          state.copyWith(errorMessage: 'Selline kategooria on juba olemas.');
      return;
    }

    final updated = [...state.categories];
    updated[index] = updated[index].copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      categories: updated,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void updateCategoryAllocationPercent(int index, double newPercent) {
    if (index < 0 || index >= state.categories.length) return;

    final otherTotal = state.categories
        .asMap()
        .entries
        .where((e) => e.key != index)
        .fold<double>(0, (s, e) => s + e.value.allocationPercent);

    final max = 100.0 - otherTotal;
    final clamped = newPercent.clamp(0.0, max < 0 ? 0.0 : max);
    final rounded = double.parse(clamped.toStringAsFixed(2));

    final updated = [...state.categories];
    updated[index] = updated[index].copyWith(
      allocationPercent: rounded,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      categories: updated,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  // ── Preferences ───────────────────────────────────────────────────────────

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _persistPreferences();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveChanges() async {
    if (!state.isFormValid) {
      state = state.copyWith(errorMessage: _validationError());
      return;
    }

    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final existing = await _setupRepository.getBudgetProfile();
      if (existing == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Eelarveprofiil puudub. Seadistage esmalt rakendus.',
        );
        return;
      }

      // Build updated profile, preserving income + fixed expenses from DB
      final updatedProfile = _calculator.buildBudgetProfile(
        id: existing.id,
        monthlyIncome: existing.monthlyIncome,
        monthlyFixedExpenses: existing.monthlyFixedExpenses,
        safetyBuffer: state.safetyBuffer,
        currencyCode: state.currencyCode,
        createdAt: existing.createdAt,
      );

      await _setupRepository.updateBudgetProfile(updatedProfile);

      await _setupRepository.syncCategories(
        profileId: existing.id!,
        distributableAmount: updatedProfile.distributableAmount,
        categories: state.categories,
      );

      // Update local distributableAmount to reflect new safetyBuffer
      state = state.copyWith(
        distributableAmount: updatedProfile.distributableAmount,
      );

      ref.invalidate(homeSummaryProvider);
      ref.invalidate(categoryBudgetOverviewProvider);
      ref.invalidate(purchaseCheckProvider);

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Seaded salvestatud.',
      );
    } catch (e, st) {
      debugPrint('SettingsNotifier.save error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Salvestamine ebaõnnestus. Proovi uuesti.',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _persistPreferences() async {
    try {
      final current = await _settingsRepository.getPreferences();
      await _settingsRepository.savePreferences(
        current.copyWith(notificationsEnabled: state.notificationsEnabled),
      );
    } catch (e) {
      debugPrint('SettingsNotifier._persistPreferences error: $e');
    }
  }

  String? _validationError() {
    if (state.safetyBuffer < 0) return 'Puhver ei saa olla negatiivne.';
    final newDistributable =
        state.monthlyIncome - state.monthlyFixedExpenses - state.safetyBuffer;
    if (newDistributable <= 0) {
      return 'Pärast püsikulusid ja puhvrit peab jääma jagatav summa.';
    }
    if (state.totalAllocatedPercent > 100) {
      return 'Kategooriate protsendid ületavad 100%.';
    }
    return null;
  }

  List<BudgetCategory> _rebuildSortOrders(List<BudgetCategory> cats) {
    final now = DateTime.now();
    return List.generate(
      cats.length,
      (i) => cats[i].copyWith(sortOrder: i, updatedAt: now),
    );
  }

  String _fmt(double value) => value.toStringAsFixed(2);
}
