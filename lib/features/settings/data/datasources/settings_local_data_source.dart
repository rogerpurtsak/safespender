import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/app_preferences.dart';

class SettingsLocalDataSource {
  final AppDatabase appDatabase;

  const SettingsLocalDataSource({required this.appDatabase});

  Future<AppPreferences> getPreferences() async {
    final db = await appDatabase.database;
    final rows = await db.query('app_preferences');

    final map = <String, String>{
      for (final row in rows)
        row['key'] as String: row['value'] as String,
    };

    return AppPreferences.fromKeyValueMap(map);
  }

  Future<void> savePreferences(AppPreferences preferences) async {
    final db = await appDatabase.database;
    final kvMap = preferences.toKeyValueMap();

    await db.transaction((txn) async {
      for (final entry in kvMap.entries) {
        await txn.insert(
          'app_preferences',
          {'key': entry.key, 'value': entry.value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
