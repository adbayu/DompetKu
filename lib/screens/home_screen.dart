import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/icon_constants.dart';
import '../widgets/currency_text.dart';
import '../widgets/finance_donut_chart.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'debts_screen.dart';
import 'financial_goals_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';
import 'wallets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardView(),
      const TransactionsScreen(inShell: false),
      const BudgetsScreen(inShell: false),
      const MoreScreen(),
    ];
    return Scaffold(
      body: pages[index],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Lainnya'),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final expenseByCategory = <int, double>{};
        for (final tx in provider.transactions.where(
          (e) => e.type == 'expense',
        )) {
          expenseByCategory[tx.categoryId] =
              (expenseByCategory[tx.categoryId] ?? 0) + tx.amount;
        }
        final segments = expenseByCategory.entries.map((entry) {
          final category = provider.categoryById(entry.key);
          return DonutSegment(
            label: category.name,
            value: entry.value,
            color: Color(category.color),
          );
        }).toList();
        final recent = provider.transactions.take(4).toList();
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${provider.userName}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Text('Kelola keuanganmu dengan bijak!'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF009F89), Color(0xFF10BFA6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(color: Colors.white70),
                      ),
                      CurrencyText(
                        provider.totalBalance,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Dompet Utama',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MetricCard(
                      title: 'Pemasukan',
                      amount: provider.totalIncome,
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _MetricCard(
                      title: 'Pengeluaran',
                      amount: provider.totalExpense,
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Pengeluaran',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            FinanceDonutChart(
                              segments: segments,
                              totalLabel: MoneyFormatter.format(
                                provider.totalExpense,
                                symbol: provider.currencySymbol,
                              ),
                              size: 168,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                children: segments.map((s) {
                                  final percent = provider.totalExpense == 0
                                      ? 0
                                      : (s.value / provider.totalExpense * 100)
                                            .round();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 5,
                                          backgroundColor: s.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            s.label,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text('$percent%'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _QuickActions(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transaksi Terbaru',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      ),
                      child: const Text('Lihat semua'),
                    ),
                  ],
                ),
                ...recent.map((tx) => TransactionTile(tx: tx)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .14),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              CurrencyText(
                amount,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Kategori', Icons.category, const CategoriesScreen()),
      ('Dompet', Icons.account_balance_wallet, const WalletsScreen()),
      ('Target', Icons.flag, const FinancialGoalsScreen()),
      ('Utang', Icons.handshake, const DebtsScreen()),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: actions.map((item) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.$3),
          ),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(item.$1, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.tx});

  final FinanceTransaction tx;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final category = provider.categoryById(tx.categoryId);
    final color = tx.type == 'income' ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withValues(alpha: .14),
          child: Icon(
            _iconFromName(category.icon),
            color: Color(category.color),
          ),
        ),
        title: Text(
          tx.notes,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${category.name} • ${DateFormatter.short(tx.date)}'),
        trailing: CurrencyText(
          tx.type == 'income' ? tx.amount : -tx.amount,
          sign: true,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

IconData _iconFromName(String name) {
  return IconConstants.getIcon(name);
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Kategori', Icons.category, const CategoriesScreen()),
      ('Dompet / Akun', Icons.account_balance_wallet, const WalletsScreen()),
      ('Target Finansial', Icons.flag, const FinancialGoalsScreen()),
      ('Utang & Piutang', Icons.handshake, const DebtsScreen()),
      ('Pengaturan', Icons.settings, const SettingsScreen()),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Lainnya',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(item.$2),
                title: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.$3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
