import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../utils/icon_constants.dart';
import '../widgets/currency_text.dart';
import '../widgets/finance_donut_chart.dart';
import '../widgets/glass_panel.dart';
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

  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );
    if (!mounted) return;
    await context.read<AppProvider>().refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardView(),
      const TransactionsScreen(inShell: false),
      const BudgetsScreen(inShell: false),
      const SettingsScreen(),
    ];
    final items = [
      _BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: tr(context, 'Beranda', 'Home'),
      ),
      _BottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: tr(context, 'Transaksi', 'Transactions'),
      ),
      _BottomNavItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        label: tr(context, 'Laporan', 'Reports'),
      ),
      _BottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: tr(context, 'Pengaturan', 'Settings'),
      ),
    ];

    return Scaffold(
      body: pages[index],
      extendBody: true,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _openAddTransaction,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomAppBar(
            height: 76,
            shape: const CircularNotchedRectangle(),
            notchMargin: 9,
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            child: Row(
              children: [
                _BottomNavButton(
                  item: items[0],
                  selected: index == 0,
                  onTap: () => setState(() => index = 0),
                ),
                _BottomNavButton(
                  item: items[1],
                  selected: index == 1,
                  onTap: () => setState(() => index = 1),
                ),
                const SizedBox(width: 74),
                _BottomNavButton(
                  item: items[2],
                  selected: index == 2,
                  onTap: () => setState(() => index = 2),
                ),
                _BottomNavButton(
                  item: items[3],
                  selected: index == 3,
                  onTap: () => setState(() => index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .68);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
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
        for (final tx in provider.transactions.where((e) => e.type == 'expense')) {
          expenseByCategory[tx.categoryId] =
              (expenseByCategory[tx.categoryId] ?? 0) + tx.amount;
        }
        const chartColors = [
          Color(0xFF2F6CEF),
          Color(0xFF4C83FF),
          Color(0xFF7AA2FF),
          Color(0xFFB9D0FF),
          Color(0xFF1E40AF),
        ];
        var colorIndex = 0;
        final segments = expenseByCategory.entries.map((entry) {
          final category = provider.categoryById(entry.key);
          final color = chartColors[colorIndex % chartColors.length];
          colorIndex++;
          return DonutSegment(
            label: category.name,
            value: entry.value,
            color: color,
          );
        }).toList();
        final recent = provider.transactions.take(4).toList();
        final isEn = provider.languagePref == 'en';

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
              children: [
                _DashboardHeader(userName: provider.userName),
                const SizedBox(height: 20),
                _WalletHeroCard(provider: provider),
                const SizedBox(height: 22),
                _QuickActions(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _MetricCard(
                      title: tr(context, 'Pemasukan', 'Income'),
                      amount: provider.totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      title: tr(context, 'Pengeluaran', 'Expense'),
                      amount: provider.totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: tr(context, 'Transaksi Terbaru', 'Recent Transactions'),
                  action: tr(context, 'Lihat semua', 'See all'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  _EmptyRecentCard(isEn: isEn)
                else
                  Column(
                    children: recent
                        .map(
                          (tx) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(tx: tx),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 22),
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3F75F2).withValues(alpha: .10),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(context, 'Ringkasan Pengeluaran', 'Expense Summary'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          FinanceDonutChart(
                            segments: segments,
                            totalLabel: MoneyFormatter.format(
                              provider.totalExpense,
                              symbol: provider.currencySymbol,
                              locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID',
                            ),
                            size: 150,
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: _SegmentLegend(segments: segments, total: provider.totalExpense)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'Selamat Datang', 'Welcome Back'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.notifications_none_rounded, size: 28),
                ),
                Positioned(
                  right: 8,
                  top: 7,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3F75F2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletHeroCard extends StatelessWidget {
  const _WalletHeroCard({required this.provider});

  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3FB9), Color(0xFF1D4ED8), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6CEF).withValues(alpha: .24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo_Dompetku.png',
                    width: 34,
                    height: 34,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '.... ${provider.wallets.isEmpty ? '0000' : provider.wallets.length.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: CurrencyText(
                  provider.totalBalance,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(context, 'Saldo DompetKu', 'DompetKu Balance'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    tr(context, 'Aman', 'Secure'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .78),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: tr(context, 'Uang Masuk', 'Income'),
        icon: Icons.south_west_rounded,
        screen: const TransactionFormScreen(initialType: 'income'),
      ),
      _QuickAction(
        label: tr(context, 'Uang Keluar', 'Expense'),
        icon: Icons.north_east_rounded,
        screen: const TransactionFormScreen(initialType: 'expense'),
      ),
      _QuickAction(
        label: tr(context, 'Dompet', 'Wallet'),
        icon: Icons.account_balance_wallet_outlined,
        screen: const WalletsScreen(),
      ),
      _QuickAction(
        label: tr(context, 'Lainnya', 'More'),
        icon: Icons.more_horiz_rounded,
        screen: const MoreScreen(),
      ),
    ];
    return Row(
      children: actions.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.screen),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.icon,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon, required this.screen});
  final String label;
  final IconData icon;
  final Widget screen;
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .035),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            CurrencyText(
              amount,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, required this.onTap});

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard({required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Text(
        isEn ? 'No transactions yet. Add your first transaction.' : 'Belum ada transaksi. Tambahkan transaksi pertama.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SegmentLegend extends StatelessWidget {
  const _SegmentLegend({required this.segments, required this.total});

  final List<DonutSegment> segments;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return Text(
        tr(context, 'Belum ada pengeluaran', 'No expenses yet'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      );
    }
    return Column(
      children: segments.take(5).map((s) {
        final percent = total == 0 ? 0 : (s.value / total * 100).round();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: s.color),
              const SizedBox(width: 8),
              Expanded(child: Text(s.label, overflow: TextOverflow.ellipsis)),
              Text('$percent%'),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * .2, size.height * .1), 82, paint);
    canvas.drawCircle(Offset(size.width * .85, size.height * .45), 62, paint);
    canvas.drawCircle(Offset(size.width * .45, size.height * .92), 104, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.tx});

  final FinanceTransaction tx;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final category = provider.categoryById(tx.categoryId);
    final color = tx.type == 'income'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);
    final bgColor = tx.type == 'income'
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final amount = tx.type == 'income' ? tx.amount : -tx.amount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .035),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: bgColor,
            child: Icon(_iconFromName(category.icon), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.notes.isEmpty ? category.name : tx.notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${category.name} - ${DateFormatter.short(tx.date)} ${DateFormatter.time(tx.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CurrencyText(
            amount,
            sign: true,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
      {
        'label': tr(context, 'Kategori', 'Categories'),
        'icon': Icons.category,
        'screen': const CategoriesScreen(),
      },
      {
        'label': tr(context, 'Dompet / Akun', 'Wallets / Accounts'),
        'icon': Icons.account_balance_wallet,
        'screen': const WalletsScreen(),
      },
      {
        'label': tr(context, 'Target Finansial', 'Financial Goals'),
        'icon': Icons.flag,
        'screen': const FinancialGoalsScreen(),
      },
      {
        'label': tr(context, 'Utang & Piutang', 'Debts & Credits'),
        'icon': Icons.handshake,
        'screen': const DebtsScreen(),
      },
      {
        'label': tr(context, 'Pengaturan', 'Settings'),
        'icon': Icons.settings,
        'screen': const SettingsScreen(),
      },
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            tr(context, 'Lainnya', 'More'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(item['icon'] as IconData),
                title: Text(
                  item['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
