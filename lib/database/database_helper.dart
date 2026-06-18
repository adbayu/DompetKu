import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/debt_model.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/wallet_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = kIsWeb
        ? 'dompetku.db'
        : '${(await getApplicationDocumentsDirectory()).path}/dompetku.db';
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
    return _database!;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense'
      )
    ''');
    await db.execute('''
      CREATE TABLE wallets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        wallet_id INTEGER NOT NULL,
        goal_id INTEGER,
        FOREIGN KEY(category_id) REFERENCES categories(id),
        FOREIGN KEY(wallet_id) REFERENCES wallets(id),
        FOREIGN KEY(goal_id) REFERENCES financial_goals(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        limit_amount REAL NOT NULL,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE financial_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        deadline TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await _seed(db);
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE categories ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'",
      );
      await db.update(
        'categories',
        {'type': 'income', 'name': 'Gaji'},
        where: 'name = ?',
        whereArgs: ['Pemasukan'],
      );
    }

    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN goal_id INTEGER');
      await db.insert(
        'categories',
        CategoryModel(
          name: 'Tabungan',
          type: 'expense',
          icon: 'piggy_bank',
          color: Colors.pink.toARGB32(),
        ).toMap(),
      );
    }

    if (oldVersion < 3) {
      final incomeCategories = [
        CategoryModel(
          name: 'Gaji',
          type: 'income',
          icon: 'work',
          color: Colors.teal.toARGB32(),
        ),
        CategoryModel(
          name: 'Bonus',
          type: 'income',
          icon: 'payments',
          color: Colors.green.toARGB32(),
        ),
        CategoryModel(
          name: 'Hadiah',
          type: 'income',
          icon: 'redeem',
          color: Colors.purple.toARGB32(),
        ),
        CategoryModel(
          name: 'Investasi',
          type: 'income',
          icon: 'trending_up',
          color: Colors.blue.toARGB32(),
        ),
        CategoryModel(
          name: 'Lainnya Masuk',
          type: 'income',
          icon: 'add_circle',
          color: Colors.cyan.toARGB32(),
        ),
      ];
      for (final item in incomeCategories) {
        final exists = Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM categories WHERE name = ? AND type = ?',
                [item.name, item.type],
              ),
            ) ??
            0;
        if (exists == 0) await db.insert('categories', item.toMap());
      }
    }
  }
  Future<void> _seed(Database db) async {
    final categories = [
      CategoryModel(
        name: 'Makanan',
        type: 'expense',
        icon: 'restaurant',
        color: Colors.green.toARGB32(),
      ),
      CategoryModel(
        name: 'Transportasi',
        type: 'expense',
        icon: 'directions_bus',
        color: Colors.blue.toARGB32(),
      ),
      CategoryModel(
        name: 'Belanja',
        type: 'expense',
        icon: 'shopping_cart',
        color: Colors.orange.toARGB32(),
      ),
      CategoryModel(
        name: 'Hiburan',
        type: 'expense',
        icon: 'local_activity',
        color: Colors.purple.toARGB32(),
      ),
      CategoryModel(
        name: 'Gaji',
        type: 'income',
        icon: 'work',
        color: Colors.teal.toARGB32(),
      ),
      CategoryModel(
        name: 'Tabungan',
        type: 'expense',
        icon: 'savings',
        color: Colors.pink.toARGB32(),
      ),
    ];
    for (final item in categories) {
      await db.insert('categories', item.toMap());
    }
    await db.insert(
      'wallets',
      const WalletModel(
        name: 'Dompet Utama',
        balance: 12450000,
        type: 'cash',
      ).toMap(),
    );
    await db.insert(
      'wallets',
      const WalletModel(
        name: 'Bank BCA',
        balance: 8500000,
        type: 'bank',
      ).toMap(),
    );
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, 15);
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 15);

    final txs = [
      FinanceTransaction(
        amount: 45000,
        date: now,
        notes: 'Makan Siang',
        type: 'expense',
        categoryId: 1,
        walletId: 1,
      ),
      FinanceTransaction(
        amount: 8000000,
        date: now,
        notes: 'Gaji Bulanan',
        type: 'income',
        categoryId: 5,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 15000,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Ongkos Transport',
        type: 'expense',
        categoryId: 2,
        walletId: 1,
      ),
      FinanceTransaction(
        amount: 350000,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Belanja Bulanan',
        type: 'expense',
        categoryId: 3,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 75000,
        date: now.subtract(const Duration(days: 2)),
        notes: 'Nonton Bioskop',
        type: 'expense',
        categoryId: 4,
        walletId: 1,
      ),
      FinanceTransaction(
        amount: 1500000,
        date: now.subtract(const Duration(days: 3)),
        notes: 'Freelance Project',
        type: 'income',
        categoryId: 5,
        walletId: 2,
      ),
      // 1 Bulan Lalu
      FinanceTransaction(
        amount: 8000000,
        date: oneMonthAgo,
        notes: 'Gaji Bulanan',
        type: 'income',
        categoryId: 5,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 50000,
        date: oneMonthAgo.subtract(const Duration(days: 1)),
        notes: 'Makan Siang',
        type: 'expense',
        categoryId: 1,
        walletId: 1,
      ),
      FinanceTransaction(
        amount: 1200000,
        date: oneMonthAgo.subtract(const Duration(days: 2)),
        notes: 'Belanja Bulanan',
        type: 'expense',
        categoryId: 3,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 150000,
        date: oneMonthAgo.subtract(const Duration(days: 3)),
        notes: 'Bensin Motor',
        type: 'expense',
        categoryId: 2,
        walletId: 1,
      ),
      // 2 Bulan Lalu
      FinanceTransaction(
        amount: 8000000,
        date: twoMonthsAgo,
        notes: 'Gaji Bulanan',
        type: 'income',
        categoryId: 5,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 45000,
        date: twoMonthsAgo.subtract(const Duration(days: 1)),
        notes: 'Makan Siang',
        type: 'expense',
        categoryId: 1,
        walletId: 1,
      ),
      FinanceTransaction(
        amount: 900000,
        date: twoMonthsAgo.subtract(const Duration(days: 2)),
        notes: 'Belanja Bulanan',
        type: 'expense',
        categoryId: 3,
        walletId: 2,
      ),
      FinanceTransaction(
        amount: 200000,
        date: twoMonthsAgo.subtract(const Duration(days: 3)),
        notes: 'Tiket Bus',
        type: 'expense',
        categoryId: 2,
        walletId: 1,
      ),
    ];
    for (final item in txs) {
      await db.insert('transactions', item.toMap());
    }
    final budgetData = [
      BudgetModel(
        categoryId: 1,
        month: now.month,
        year: now.year,
        limitAmount: 2000000,
      ),
      BudgetModel(
        categoryId: 2,
        month: now.month,
        year: now.year,
        limitAmount: 1500000,
      ),
      BudgetModel(
        categoryId: 3,
        month: now.month,
        year: now.year,
        limitAmount: 2000000,
      ),
      BudgetModel(
        categoryId: 4,
        month: now.month,
        year: now.year,
        limitAmount: 1000000,
      ),
    ];
    for (final item in budgetData) {
      await db.insert('budgets', item.toMap());
    }
    await db.insert(
      'financial_goals',
      FinancialGoal(
        title: 'Dana Liburan',
        targetAmount: 10000000,
        currentAmount: 4250000,
        deadline: now.add(const Duration(days: 180)),
      ).toMap(),
    );
    await db.insert(
      'financial_goals',
      FinancialGoal(
        title: 'Laptop Baru',
        targetAmount: 15000000,
        currentAmount: 7200000,
        deadline: now.add(const Duration(days: 240)),
      ).toMap(),
    );
    await db.insert(
      'debts',
      DebtModel(
        personName: 'Raka',
        amount: 500000,
        type: 'receivable',
        dueDate: now.add(const Duration(days: 14)),
        status: 'unpaid',
      ).toMap(),
    );
    await db.insert(
      'debts',
      DebtModel(
        personName: 'Sinta',
        amount: 300000,
        type: 'debt',
        dueDate: now.add(const Duration(days: 7)),
        status: 'unpaid',
      ).toMap(),
    );
  }

  Future<void> checkAndSeedPastMonths() async {
    final db = await database;
    final now = DateTime.now();

    // Check 1 month ago
    final oneMonth = DateTime(now.year, now.month - 1, 15);
    final oneMonthStr = "${oneMonth.year}-${oneMonth.month.toString().padLeft(2, '0')}";
    final countOne = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM transactions WHERE date LIKE ?',
        ['$oneMonthStr%'],
      ),
    ) ?? 0;

    if (countOne == 0) {
      final oneMonthAgo = DateTime(now.year, now.month - 1, 15);
      final txs = [
        FinanceTransaction(
          amount: 8000000,
          date: oneMonthAgo,
          notes: 'Gaji Bulanan',
          type: 'income',
          categoryId: 5,
          walletId: 2,
        ),
        FinanceTransaction(
          amount: 50000,
          date: oneMonthAgo.subtract(const Duration(days: 1)),
          notes: 'Makan Siang',
          type: 'expense',
          categoryId: 1,
          walletId: 1,
        ),
        FinanceTransaction(
          amount: 1200000,
          date: oneMonthAgo.subtract(const Duration(days: 2)),
          notes: 'Belanja Bulanan',
          type: 'expense',
          categoryId: 3,
          walletId: 2,
        ),
        FinanceTransaction(
          amount: 150000,
          date: oneMonthAgo.subtract(const Duration(days: 3)),
          notes: 'Bensin Motor',
          type: 'expense',
          categoryId: 2,
          walletId: 1,
        ),
      ];
      for (final tx in txs) {
        await db.insert('transactions', tx.toMap());
      }
    }

    // Check 2 months ago
    final twoMonths = DateTime(now.year, now.month - 2, 15);
    final twoMonthsStr = "${twoMonths.year}-${twoMonths.month.toString().padLeft(2, '0')}";
    final countTwo = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM transactions WHERE date LIKE ?',
        ['$twoMonthsStr%'],
      ),
    ) ?? 0;

    if (countTwo == 0) {
      final twoMonthsAgo = DateTime(now.year, now.month - 2, 15);
      final txs = [
        FinanceTransaction(
          amount: 8000000,
          date: twoMonthsAgo,
          notes: 'Gaji Bulanan',
          type: 'income',
          categoryId: 5,
          walletId: 2,
        ),
        FinanceTransaction(
          amount: 45000,
          date: twoMonthsAgo.subtract(const Duration(days: 1)),
          notes: 'Makan Siang',
          type: 'expense',
          categoryId: 1,
          walletId: 1,
        ),
        FinanceTransaction(
          amount: 900000,
          date: twoMonthsAgo.subtract(const Duration(days: 2)),
          notes: 'Belanja Bulanan',
          type: 'expense',
          categoryId: 3,
          walletId: 2,
        ),
        FinanceTransaction(
          amount: 200000,
          date: twoMonthsAgo.subtract(const Duration(days: 3)),
          notes: 'Tiket Bus',
          type: 'expense',
          categoryId: 2,
          walletId: 1,
        ),
      ];
      for (final tx in txs) {
        await db.insert('transactions', tx.toMap());
      }
    }
  }

  Future<List<T>> _query<T>(
    String table,
    T Function(Map<String, Object?>) fromMap, {
    String? orderBy,
  }) async {
    final db = await database;
    final rows = await db.query(table, orderBy: orderBy);
    return rows.map(fromMap).toList();
  }

  Future<int> insert(String table, Map<String, Object?> data) async =>
      (await database).insert(table, data);
  Future<int> update(String table, Map<String, Object?> data, int id) async =>
      (await database).update(table, data, where: 'id = ?', whereArgs: [id]);
  Future<int> delete(String table, int id) async =>
      (await database).delete(table, where: 'id = ?', whereArgs: [id]);

  Future<List<CategoryModel>> getCategories() =>
      _query('categories', CategoryModel.fromMap, orderBy: 'name');
  Future<List<WalletModel>> getWallets() =>
      _query('wallets', WalletModel.fromMap, orderBy: 'name');
  Future<List<BudgetModel>> getBudgets() =>
      _query('budgets', BudgetModel.fromMap, orderBy: 'year DESC, month DESC');
  Future<List<FinancialGoal>> getGoals() =>
      _query('financial_goals', FinancialGoal.fromMap, orderBy: 'deadline ASC');
  Future<List<DebtModel>> getDebts() =>
      _query('debts', DebtModel.fromMap, orderBy: 'due_date ASC');

  Future<List<FinanceTransaction>> getTransactions({String? type}) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'date DESC',
    );
    return rows.map(FinanceTransaction.fromMap).toList();
  }
}
