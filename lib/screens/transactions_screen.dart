import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../widgets/app_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/success_animation_dialog.dart';
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'all',
                    label: Text(tr(context, 'Semua', 'All')),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text(tr(context, 'Pemasukan', 'Income')),
                  ),
                  ButtonSegment(
                    value: 'expense',
                    label: Text(tr(context, 'Pengeluaran', 'Expense')),
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
                          child: TransactionTile(tx: items[i]),
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
        child: const Icon(Icons.add),
      ),
      child: body,
    );
  }
}

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});
  final FinanceTransaction? transaction;

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
                SegmentedButton<String>(
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
  if (value == null || value <= 0)
    return tr(context, 'Masukkan jumlah valid', 'Enter a valid amount');
  return null;
}
