import '../../domain/models/app_preferences.dart';
import '../datasources/settings_local_data_source.dart';
import 'settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  const SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<AppPreferences> getPreferences() {
    return localDataSource.getPreferences();
  }

  @override
  Future<void> savePreferences(AppPreferences preferences) {
    return localDataSource.savePreferences(preferences);
  }
}
