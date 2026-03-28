import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'bigbank_budget.db';
  static const _databaseVersion = 2;

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
    final dbDirectory = Directory(p.join(directory.path, 'databases'));

    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    final dbPath = p.join(dbDirectory.path, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await _createExpensesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createExpensesTable(db);
    }
  }

  Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (budget_category_id) REFERENCES budget_categories (id)
      )
    ''');
  }
}