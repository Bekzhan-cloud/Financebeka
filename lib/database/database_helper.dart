import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Удаляет файл базы данных (для разработческой стадии)
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finances.db');
    await deleteDatabase(path);
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finances.db');
    return _database!;
  }


  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Создание таблиц версии 2
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        balance REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        account TEXT,
        date TEXT,
        place TEXT,
        repeat INTEGER,
        type TEXT
      )
    ''');
  }
  Future<void> updateAccountBalance(String accountName, double amountChange) async {
    final db = await instance.database;

    await db.rawUpdate('''
    UPDATE accounts
    SET balance = balance + ?
    WHERE name = ?
  ''', [amountChange, accountName]);
  }
  /// Миграция структуры базы при обновлении версии
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Добавляем в transactions новое поле account
      await db.execute('ALTER TABLE transactions ADD COLUMN account TEXT');
    }
  }

  /// Добавление счёта
  Future<void> insertAccount(Map<String, dynamic> account) async {
    final db = await instance.database;
    await db.insert('accounts', account);
  }
  /// Получение счёта по имени
  Future<Map<String, dynamic>?> getAccountByName(String name) async {
    final db = await instance.database;
    final result = await db.query(
      'accounts',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Получение всех счетов
  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await instance.database;
    return await db.query('accounts');
  }
  /// Добавление транзакции и обновление баланса счета
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await instance.database;

    // Обновляем баланс в таблице accounts
    final accountName = transaction['account'] as String;
    final amount = transaction['amount'] as num;

    // Получаем текущий баланс
    final accountRows = await db.query(
      'accounts',
      where: 'name = ?',
      whereArgs: [accountName],
      limit: 1,
    );
    if (accountRows.isNotEmpty) {
      final currentBalance = accountRows.first['balance'] as num;
      final newBalance = currentBalance + amount;
      await db.update(
        'accounts',
        {'balance': newBalance},
        where: 'name = ?',
        whereArgs: [accountName],
      );
    }

    // Сохраняем транзакцию
    await db.insert('transactions', transaction);
  }

  /// Получение всех транзакций
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'date DESC');
  }
}
