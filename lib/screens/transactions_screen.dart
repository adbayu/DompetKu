import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/app_provider.dart';
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
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                ],
                selected: {filter},
                onSelectionChanged: (value) =>
                    setState(() => filter = value.first),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      title: 'Belum ada transaksi',
                      subtitle: 'Tambahkan pemasukan atau pengeluaran baru.',
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
      title: 'Transaksi',
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
      title: widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
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
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                    ButtonSegment(value: 'income', label: Text('Pemasukan')),
                  ],
                  selected: {type},
                  onSelectionChanged: (v) => setState(() => type = v.first),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  validator: _moneyValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Catatan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori'),
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
                  decoration: const InputDecoration(labelText: 'Dompet'),
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
                    decoration: const InputDecoration(
                      labelText: 'Target Tabungan (Opsional)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tidak ada target'),
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
                  title: const Text('Tanggal'),
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
                        'Transaksi berhasil disimpan',
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
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

String? _moneyValidator(String? v) {
  final value = double.tryParse(v ?? '');
  if (value == null || value <= 0) return 'Masukkan jumlah valid';
  return null;
}
