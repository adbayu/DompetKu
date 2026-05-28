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

  Future<void> setUserName(String value) async {
    await prefs.setString(
      'userName',
      value.trim().isEmpty ? 'Pengguna' : value.trim(),
    );
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String value) async {
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
    item.id == null
        ? await _db.insert('transactions', item.toMap())
        : await _db.update('transactions', item.toMap(), item.id!);
    await refreshAll();
  }

  Future<void> deleteTransaction(int id) async {
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
