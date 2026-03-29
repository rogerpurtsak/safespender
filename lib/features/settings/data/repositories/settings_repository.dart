import '../../domain/models/app_preferences.dart';

abstract class SettingsRepository {
  Future<AppPreferences> getPreferences();
  Future<void> savePreferences(AppPreferences preferences);
}
