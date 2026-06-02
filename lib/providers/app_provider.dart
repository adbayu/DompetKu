import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/debt_model.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/wallet_model.dart';
import '../services/preferences_service.dart';

class AppProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final prefs = PreferencesService();

  List<FinanceTransaction> transactions = [];
  List<CategoryModel> categories = [];
  List<WalletModel> wallets = [];
  List<BudgetModel> budgets = [];
  List<FinancialGoal> goals = [];
  List<DebtModel> debts = [];
  bool loading = true;

  bool get isDarkMode => prefs.isDarkMode;
  String get currencySymbol => prefs.currencySymbol;
  String get userName => prefs.userName;
  bool get isFirstTimeOpen => prefs.isFirstTimeOpen;
  bool get monthlyLimitAlert => prefs.monthlyLimitAlert;
  double get monthlyLimit => prefs.monthlyLimit;
  String get languagePref => prefs.languagePref;

  double get totalIncome => transactions
      .where((e) => e.type == 'income')
      .fold(0, (v, e) => v + e.amount);
  double get totalExpense => transactions
      .where((e) => e.type == 'expense')
      .fold(0, (v, e) => v + e.amount);
  double get totalBalance => wallets.fold(0, (v, e) => v + e.balance);

  Future<void> initialize() async {
    await prefs.init();
    await refreshAll();
  }

  Future<void> refreshAll() async {
    loading = true;
    notifyListeners();
    categories = await _db.getCategories();
    wallets = await _db.getWallets();
    transactions = await _db.getTransactions();
    budgets = await _db.getBudgets();
    goals = await _db.getGoals();
    debts = await _db.getDebts();
    loading = false;
    notifyListeners();
  }

  CategoryModel categoryById(int id) => categories.firstWhere(
    (e) => e.id == id,
    orElse: () => const CategoryModel(
      name: 'Lainnya',
      icon: 'more_horiz',
      color: 0xFF9CA3AF,
    ),
  );
  WalletModel walletById(int id) => wallets.firstWhere(
    (e) => e.id == id,
    orElse: () => const WalletModel(name: 'Dompet', balance: 0, type: 'cash'),
  );

  Future<void> completeOnboarding() async {
    await prefs.setBool('isFirstTimeOpen', false);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setMonthlyLimitAlert(bool value) async {
    await prefs.setBool('monthlyLimitAlert', value);
    notifyListeners();
  }

  Future<void> setMonthlyLimit(double value) async {
    await prefs.setDouble('monthlyLimit', value);
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    await prefs.setString(
      'userName',
      value.trim().isEmpty ? 'Pengguna' : value.trim(),
    );
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String value) async {
    final oldSymbol = prefs.currencySymbol;
    if (oldSymbol != value) {
      double rate = 1.0;

      // Convert to IDR base first
      if (oldSymbol == r'$') {
        rate = 15000.0;
      } else if (oldSymbol == 'EUR') {
        rate = 16000.0;
      }

      // Convert from IDR to new currency
      if (value == r'$') {
        rate /= 15000.0;
      } else if (value == 'EUR') {
        rate /= 16000.0;
      }

      if (rate != 1.0) {
        for (var w in wallets) {
          await _db.update(
            'wallets',
            w.copyWith(balance: w.balance * rate).toMap(),
            w.id!,
          );
        }
        for (var t in transactions) {
          await _db.update(
            'transactions',
            t.copyWith(amount: t.amount * rate).toMap(),
            t.id!,
          );
        }
        for (var b in budgets) {
          await _db.update(
            'budgets',
            b.copyWith(limitAmount: b.limitAmount * rate).toMap(),
            b.id!,
          );
        }
        for (var g in goals) {
          await _db.update(
            'financial_goals',
            g
                .copyWith(
                  targetAmount: g.targetAmount * rate,
                  currentAmount: g.currentAmount * rate,
                )
                .toMap(),
            g.id!,
          );
        }
        for (var d in debts) {
          await _db.update(
            'debts',
            d.copyWith(amount: d.amount * rate).toMap(),
            d.id!,
          );
        }
        await prefs.setDouble('monthlyLimit', prefs.monthlyLimit * rate);
        await refreshAll();
      }
    }

    await prefs.setString('currencySymbol', value);
    notifyListeners();
  }

  Future<void> setLanguagePref(String value) async {
    await prefs.setString('languagePref', value);
    notifyListeners();
  }

  Future<void> saveCategory(CategoryModel item) async {
    item.id == null
        ? await _db.insert('categories', item.toMap())
        : await _db.update('categories', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> deleteCategory(int id) async {
    await _db.delete('categories', id);
    await refreshAll();
  }

  Future<void> saveWallet(WalletModel item) async {
    item.id == null
        ? await _db.insert('wallets', item.toMap())
        : await _db.update('wallets', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> deleteWallet(int id) async {
    await _db.delete('wallets', id);
    await refreshAll();
  }

  Future<void> saveTransaction(FinanceTransaction item) async {
    // Get the Tabungan category id
    final tabunganCat = categories
        .where((c) => c.name == 'Tabungan')
        .firstOrNull;
    final isTabunganTx = item.categoryId == tabunganCat?.id;

    // If editing an existing transaction
    if (item.id != null) {
      // Get old transaction to compare
      final oldTx = transactions.where((t) => t.id == item.id).firstOrNull;

      // If old transaction had a goal, revert the old amount first
      if (oldTx != null && oldTx.goalId != null) {
        final goal = goals.where((g) => g.id == oldTx.goalId).firstOrNull;
        if (goal != null) {
          // Determine direction based on old transaction type
          final direction = oldTx.type == 'expense' ? -1.0 : 1.0;
          final updatedGoal = goal.copyWith(
            currentAmount: (goal.currentAmount - (oldTx.amount * direction))
                .clamp(0, double.infinity),
          );
          await _db.update('financial_goals', updatedGoal.toMap(), goal.id!);
        }
      }
    }

    // Save the transaction
    item.id == null
        ? await _db.insert('transactions', item.toMap())
        : await _db.update('transactions', item.toMap(), item.id!);

    // If transaction is for Tabungan and has a goal, update goal amount
    if (isTabunganTx && item.goalId != null) {
      // Fetch fresh from DB to get the correct current amount after any previous updates
      final freshGoals = await _db.getGoals();
      final goal = freshGoals.where((g) => g.id == item.goalId).firstOrNull;
      if (goal != null) {
        // Determine direction based on transaction type
        // expense (pengeluaran) = menabung = goal naik = add
        // income (pemasukan) = ambil dari tabungan = goal turun = subtract
        final direction = item.type == 'expense' ? 1.0 : -1.0;
        final updatedGoal = goal.copyWith(
          currentAmount: (goal.currentAmount + (item.amount * direction)).clamp(
            0,
            double.infinity,
          ),
        );
        await _db.update('financial_goals', updatedGoal.toMap(), goal.id!);
      }
    }

    await refreshAll();
  }

  Future<void> deleteTransaction(int id) async {
    // Get transaction to check if it has a goal
    final tx = transactions.where((t) => t.id == id).firstOrNull;

    if (tx != null && tx.goalId != null) {
      final goal = goals.where((g) => g.id == tx.goalId).firstOrNull;
      if (goal != null) {
        final updatedGoal = goal.copyWith(
          currentAmount: (goal.currentAmount - tx.amount).clamp(
            0,
            double.infinity,
          ),
        );
        await _db.update('financial_goals', updatedGoal.toMap(), goal.id!);
      }
    }

    await _db.delete('transactions', id);
    await refreshAll();
  }

  Future<void> saveBudget(BudgetModel item) async {
    item.id == null
        ? await _db.insert('budgets', item.toMap())
        : await _db.update('budgets', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> deleteBudget(int id) async {
    await _db.delete('budgets', id);
    await refreshAll();
  }

  Future<void> saveGoal(FinancialGoal item) async {
    item.id == null
        ? await _db.insert('financial_goals', item.toMap())
        : await _db.update('financial_goals', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> deleteGoal(int id) async {
    await _db.delete('financial_goals', id);
    await refreshAll();
  }

  Future<void> saveDebt(DebtModel item) async {
    item.id == null
        ? await _db.insert('debts', item.toMap())
        : await _db.update('debts', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> markDebtPaid(DebtModel item) =>
      saveDebt(item.copyWith(status: 'paid'));

  Future<void> deleteDebt(int id) async {
    await _db.delete('debts', id);
    await refreshAll();
  }
}
