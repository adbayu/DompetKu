import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/localization.dart';
import '../widgets/currency_text.dart';
import '../widgets/finance_donut_chart.dart';
import '../widgets/soft_banking.dart';
import '../widgets/expense_breakdown_card.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) {
    final newMonth = DateTime(selectedMonth.year, selectedMonth.month + delta);
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month);
    
    if (newMonth.isAfter(currentMonthStart)) {
      return;
    }

    setState(() {
      selectedMonth = newMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final monthlyTransactions = provider.transactions
            .where(
              (tx) =>
                  tx.date.year == selectedMonth.year &&
                  tx.date.month == selectedMonth.month,
            )
            .toList();
        final income = _sum(monthlyTransactions, 'income');
        final expense = _sum(monthlyTransactions, 'expense');
        final balance = income - expense;
        final expenseSegments = _expenseSegments(
          context,
          provider,
          monthlyTransactions,
        );

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 110),
            children: [
              _ReportHeader(
                month: selectedMonth,
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
              const SizedBox(height: 18),
              _MonthlySummaryCard(
                income: income,
                expense: expense,
                balance: balance,
              ),
              const SizedBox(height: 18),
              _ReportSectionTitle(
                title: tr(
                  context,
                  'Komposisi Pengeluaran',
                  'Expense Breakdown',
                ),
              ),
              const SizedBox(height: 10),
              ExpenseBreakdownCard(
                segments: expenseSegments,
                totalExpense: expense,
              ),
            ],
          ),
        );
      },
    );
  }

  double _sum(List<FinanceTransaction> transactions, String type) {
    return transactions
        .where((tx) => tx.type == type)
        .fold(0, (total, tx) => total + tx.amount);
  }

  List<DonutSegment> _expenseSegments(
    BuildContext context,
    AppProvider provider,
    List<FinanceTransaction> transactions,
  ) {
    final totals = <int, double>{};
    for (final tx in transactions.where((tx) => tx.type == 'expense')) {
      totals[tx.categoryId] = (totals[tx.categoryId] ?? 0) + tx.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((entry) {
      final category = provider.categoryById(entry.key);
      return DonutSegment(
        label: category.name,
        value: entry.value,
        color: Color(category.color),
      );
    }).toList();
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentOrFuture = month.year > now.year || (month.year == now.year && month.month >= now.month);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'Laporan Bulanan', 'Monthly Report'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(
                  context,
                  'Ringkasan pemasukan dan pengeluaran',
                  'Income and expense summary',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _MonthButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        const SizedBox(width: 8),
        _MonthLabel(month: month),
        const SizedBox(width: 8),
        _MonthButton(
          icon: Icons.chevron_right_rounded,
          onTap: isCurrentOrFuture ? null : onNext,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final disabled = onTap == null;
    final bgColor = isLight ? Colors.white : Theme.of(context).colorScheme.surface;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: CircleAvatar(
        radius: 21,
        backgroundColor: disabled
            ? bgColor.withValues(alpha: .5)
            : bgColor,
        child: Icon(
          icon,
          color: disabled
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: .3)
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _MonthLabel extends StatelessWidget {
  const _MonthLabel({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '${month.month}/${month.year}',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return SoftHeroCard(
      title: tr(context, 'Arus Kas Bulan Ini', 'This Month Cash Flow'),
      subtitle: balance >= 0
          ? tr(context, 'Kondisi keuangan positif', 'Positive cash flow')
          : tr(
              context,
              'Pengeluaran melebihi pemasukan',
              'Expenses exceed income',
            ),
      icon: Icons.insights_rounded,
      child: Column(
        children: [
          CurrencyText(
            balance,
            sign: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryPill(
                  label: tr(context, 'Pemasukan', 'Income'),
                  amount: income,
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryPill(
                  label: tr(context, 'Pengeluaran', 'Expense'),
                  amount: expense,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          CurrencyText(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}






class _ReportSectionTitle extends StatelessWidget {
  const _ReportSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
