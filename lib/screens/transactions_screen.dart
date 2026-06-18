import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../utils/icon_constants.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/success_animation_dialog.dart';
import '../widgets/soft_banking.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.inShell = true});
  final bool inShell;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String filter = 'expense';
  DateTime? selectedMonth;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<AppProvider>(
      builder: (context, provider, _) {
        final chartSource = provider.transactions
            .where((e) => filter == 'all' || e.type == filter)
            .toList();
        final filtered = chartSource
            .where(
              (e) =>
                  selectedMonth == null ||
                  (e.date.year == selectedMonth!.year &&
                      e.date.month == selectedMonth!.month),
            )
            .toList();
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 110),
            children: [
              _StatisticsHeader(onDownload: () {}, onCalendar: () async {}),
              const SizedBox(height: 26),
              Row(
                children: [
                  _TypePill(
                    label: tr(context, 'Pengeluaran', 'Expenses'),
                    selected: filter == 'expense',
                    onTap: () => setState(() {
                      filter = 'expense';
                      selectedMonth = null;
                    }),
                  ),
                  _TypePill(
                    label: tr(context, 'Pemasukan', 'Income'),
                    selected: filter == 'income',
                    onTap: () => setState(() {
                      filter = 'income';
                      selectedMonth = null;
                    }),
                  ),
                  const Spacer(),
                  _PeriodPill(label: tr(context, 'Bulan', 'Month')),
                ],
              ),
              const SizedBox(height: 22),
              _TransactionBarChart(
                transactions: chartSource,
                currencySymbol: provider.currencySymbol,
                locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID',
                type: filter,
                selectedMonth: selectedMonth,
                onMonthSelected: (month) =>
                    setState(() => selectedMonth = month),
              ),
              const SizedBox(height: 28),
              _HistoryHeader(
                title: selectedMonth == null
                    ? (filter == 'income'
                          ? tr(context, 'Riwayat Pemasukan', 'Income History')
                          : tr(
                              context,
                              'Riwayat Pengeluaran',
                              'Expenses History',
                            ))
                    : '${DateFormatter.monthYear(selectedMonth!)} - ${MoneyFormatter.format(filtered.fold<double>(0, (sum, tx) => sum + tx.amount), symbol: provider.currencySymbol, locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID')}',
                onTap: () => setState(() => selectedMonth = null),
              ),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                EmptyState(
                  title: tr(
                    context,
                    'Belum ada transaksi',
                    'No transactions yet',
                  ),
                  subtitle: tr(
                    context,
                    'Tambahkan pemasukan atau pengeluaran baru.',
                    'Add a new income or expense.',
                  ),
                )
              else
                ...filtered.map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(tx.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => provider.deleteTransaction(tx.id!),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionFormScreen(transaction: tx),
                          ),
                        ),
                        child: _HistoryTile(tx: tx),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    if (!widget.inShell) return body;
    return AppShell(
      title: tr(context, 'Statistik', 'Statistics'),
      fab: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.add_rounded),
      ),
      child: body,
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader({required this.onDownload, required this.onCalendar});

  final VoidCallback onDownload;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'Statistik', 'Statistics'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(
                  context,
                  'Semua riwayat transaksimu',
                  'All your transaction history',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _CircleIconButton(icon: Icons.download_rounded, onTap: onDownload),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.calendar_month_rounded,
          onTap: onCalendar,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? .18
                    : .04,
              ),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.surface : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(left: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }
}

class _TransactionBarChart extends StatelessWidget {
  const _TransactionBarChart({
    required this.transactions,
    required this.currencySymbol,
    required this.locale,
    required this.type,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final List<FinanceTransaction> transactions;
  final String currencySymbol;
  final String locale;
  final String type;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      7,
      (i) => DateTime(now.year, now.month - 5 + i),
    );
    final values = months.map((month) {
      return transactions
          .where(
            (tx) => tx.date.year == month.year && tx.date.month == month.month,
          )
          .fold<double>(0, (sum, tx) => sum + tx.amount);
    }).toList();
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final selectedIndex = selectedMonth == null
        ? values.lastIndexWhere((value) => value > 0)
        : months.indexWhere(
            (month) =>
                month.year == selectedMonth!.year &&
                month.month == selectedMonth!.month,
          );
    final activeIndex = selectedIndex == -1 ? months.length - 1 : selectedIndex;
    final activeValue = values[activeIndex];
    final chartColor = type == 'income'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return SizedBox(
      height: 214,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final slot = constraints.maxWidth / months.length;
                    final tappedIndex = (details.localPosition.dx / slot)
                        .floor()
                        .clamp(0, months.length - 1);
                    onMonthSelected(months[tappedIndex]);
                  },
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: values,
                      activeIndex: activeIndex,
                      maxValue: maxValue <= 0 ? 1 : maxValue,
                      color: chartColor,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chartColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          MoneyFormatter.format(
                            activeValue,
                            symbol: currencySymbol,
                            locale: locale,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: months.map((month) {
              final monthIndex = months.indexOf(month);
              final active = monthIndex == activeIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onMonthSelected(month),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    DateFormatter.monthYear(
                      month,
                    ).split(' ').first.substring(0, 3),
                    style: TextStyle(
                      color: active
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant
                                .withValues(alpha: .62),
                      fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.values,
    required this.activeIndex,
    required this.maxValue,
    required this.color,
  });

  final List<double> values;
  final int activeIndex;
  final double maxValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final slot = size.width / values.length;
    final base = size.height - 18;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] / maxValue).clamp(0.08, 1.0);
      final height = normalized * (size.height * .68);
      final left = i * slot + slot * .24;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, base - height, slot * .52, height),
        const Radius.circular(18),
      );
      paint.color = i == activeIndex
          ? color.withValues(alpha: .22)
          : color.withValues(alpha: .08);
      canvas.drawRRect(rect, paint);
      if (i == activeIndex) {
        paint.color = color;
        canvas.drawCircle(Offset(left + slot * .26, base - height), 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.color != color;
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(tr(context, 'Lihat semua', 'See all')),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.tx});

  final FinanceTransaction tx;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final category = provider.categoryById(tx.categoryId);
    final color = tx.type == 'income'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);
    final signedAmount = tx.type == 'income' ? tx.amount : -tx.amount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(IconConstants.getIcon(category.icon), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.notes.isEmpty ? category.name : tx.notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${DateFormatter.short(tx.date)} - ${DateFormatter.time(tx.date)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.format(
                  signedAmount,
                  symbol: provider.currencySymbol,
                  locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID',
                ),
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                provider.walletById(tx.walletId).name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction, this.initialType});
  final FinanceTransaction? transaction;
  final String? initialType;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  String type = 'expense';
  int? categoryId;
  int? walletId;
  int? goalId;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    type = widget.initialType ?? type;
    final tx = widget.transaction;
    if (tx != null) {
      amountCtrl.text = tx.amount.toStringAsFixed(0);
      notesCtrl.text = tx.notes;
      type = tx.type;
      categoryId = tx.categoryId;
      walletId = tx.walletId;
      goalId = tx.goalId;
      date = tx.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.transaction == null
          ? tr(context, 'Tambah Transaksi', 'Add Transaction')
          : tr(context, 'Edit Transaksi', 'Edit Transaction'),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final typedCategories = provider.categories
              .where((category) => category.type == type)
              .toList();
          if (categoryId == null ||
              !typedCategories.any((category) => category.id == categoryId)) {
            categoryId = typedCategories.isNotEmpty
                ? typedCategories.first.id
                : null;
          }
          walletId ??= provider.wallets.isNotEmpty
              ? provider.wallets.first.id
              : null;
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                SoftHeroCard(
                  title: widget.transaction == null
                      ? tr(context, 'Transaksi Baru', 'New Transaction')
                      : tr(context, 'Edit Transaksi', 'Edit Transaction'),
                  subtitle: tr(
                    context,
                    'Catat uang masuk dan keluar dengan rapi.',
                    'Track money in and out neatly.',
                  ),
                  icon: type == 'income'
                      ? Icons.trending_up
                      : Icons.trending_down,
                ),
                const SizedBox(height: 16),
                SoftCard(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'expense',
                        label: Text(tr(context, 'Pengeluaran', 'Expense')),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text(tr(context, 'Pemasukan', 'Income')),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (v) => setState(() {
                      type = v.first;
                      categoryId = null;
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Jumlah', 'Amount'),
                  ),
                  validator: (v) => _moneyValidator(context, v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Catatan', 'Notes'),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? tr(context, 'Catatan wajib diisi', 'Notes are required')
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: categoryId,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Kategori', 'Category'),
                  ),
                  items: typedCategories
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => categoryId = v),
                  validator: (v) => v == null
                      ? tr(context, 'Pilih kategori', 'Choose category')
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: walletId,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Dompet', 'Wallet'),
                  ),
                  items: provider.wallets
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => walletId = v),
                  validator: (v) => v == null ? 'Pilih dompet' : null,
                ),
                const SizedBox(height: 12),
                if (_isTabunganCategory(provider))
                  DropdownButtonFormField<int?>(
                    initialValue: goalId,
                    decoration: InputDecoration(
                      labelText: tr(
                        context,
                        'Target Tabungan (Opsional)',
                        'Savings Target (Optional)',
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          tr(context, 'Tidak ada target', 'No target'),
                        ),
                      ),
                      ...provider.goals.map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.title)),
                      ),
                    ],
                    onChanged: (v) => setState(() => goalId = v),
                  ),
                if (_isTabunganCategory(provider)) const SizedBox(height: 12),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  title: Text(tr(context, 'Tanggal', 'Date')),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await provider.saveTransaction(
                      FinanceTransaction(
                        id: widget.transaction?.id,
                        amount: double.parse(amountCtrl.text),
                        date: date,
                        notes: notesCtrl.text.trim(),
                        type: type,
                        categoryId: categoryId!,
                        walletId: walletId!,
                        goalId: goalId,
                      ),
                    );
                    if (context.mounted) {
                      await SuccessAnimationDialog.show(
                        context,
                        tr(
                          context,
                          'Transaksi berhasil disimpan',
                          'Transaction saved successfully',
                        ),
                      );

                      final currentMonthExpenses = provider.transactions
                          .where(
                            (t) =>
                                t.type == 'expense' &&
                                t.date.month == DateTime.now().month &&
                                t.date.year == DateTime.now().year,
                          )
                          .fold(0.0, (sum, t) => sum + t.amount);

                      if (context.mounted) {
                        if (currentMonthExpenses >= provider.monthlyLimit) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${tr(context, 'Peringatan: Pengeluaran bulan ini telah mencapai/melebihi limit!', 'Warning: This month\'s expenses have reached/exceeded the limit!')} (${MoneyFormatter.format(currentMonthExpenses, symbol: provider.currencySymbol, locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID')})',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(tr(context, 'Simpan', 'Save')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isTabunganCategory(AppProvider provider) {
    if (categoryId == null) return false;
    final category = provider.categories
        .where((c) => c.id == categoryId)
        .firstOrNull;
    return category?.name == 'Tabungan';
  }
}

String? _moneyValidator(BuildContext context, String? v) {
  final value = double.tryParse(v ?? '');
  if (value == null || value <= 0) {
    return tr(context, 'Masukkan jumlah valid', 'Enter a valid amount');
  }
  return null;
}
