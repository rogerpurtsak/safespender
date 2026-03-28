import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'bigbank_budget.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budget_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monthly_income REAL NOT NULL,
        monthly_fixed_expenses REAL NOT NULL,
        safety_buffer REAL NOT NULL,
        distributable_amount REAL NOT NULL,
        currency_code TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_profile_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        allocation_percent REAL NOT NULL,
        planned_amount REAL NOT NULL,
        sort_order INTEGER NOT NULL,
        is_default INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (budget_profile_id) REFERENCES budget_profiles (id)
      )
    ''');
  }
}