import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/success_animation_dialog.dart';
import '../widgets/soft_banking.dart';
import 'home_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, this.inShell = true});
  final bool inShell;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final body = Consumer<AppProvider>(
      builder: (context, provider, _) {
        final items = provider.transactions
            .where((e) => filter == 'all' || e.type == filter)
            .toList();
        final income = provider.totalIncome;
        final expense = provider.totalExpense;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: SoftHeroCard(
                title: tr(context, 'Transaksi', 'Transactions'),
                subtitle: tr(
                  context,
                  '${items.length} catatan tersaring',
                  '${items.length} filtered records',
                ),
                icon: Icons.receipt_long,
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniTotal(
                        label: tr(context, 'Masuk', 'In'),
                        value: income,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniTotal(
                        label: tr(context, 'Keluar', 'Out'),
                        value: expense,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'all',
                    label: Text(tr(context, 'Semua', 'All')),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(tr(context, 'Masuk', 'Income')),
                  ),
                  ButtonSegment(
                    value: 'expense',
                    label: Text(tr(context, 'Keluar', 'Expense')),
                  ),
                ],
                selected: {filter},
                onSelectionChanged: (value) =>
                    setState(() => filter = value.first),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
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
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: items.length,
                      itemBuilder: (context, i) => Dismissible(
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            provider.deleteTransaction(items[i].id!),
                        key: ValueKey(items[i].id),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionFormScreen(transaction: items[i]),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(tx: items[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
    if (!widget.inShell) return SafeArea(child: body);
    return AppShell(
      title: tr(context, 'Transaksi', 'Transactions'),
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

class _MiniTotal extends StatelessWidget {
  const _MiniTotal({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 4),
          Text(
            MoneyFormatter.format(
              value,
              symbol: context.read<AppProvider>().currencySymbol,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
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
          categoryId ??= provider.categories.isNotEmpty
              ? provider.categories.first.id
              : null;
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
                    onSelectionChanged: (v) => setState(() => type = v.first),
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
                  items: provider.categories
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => categoryId = v),
                  validator: (v) => v == null ? 'Pilih kategori' : null,
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
