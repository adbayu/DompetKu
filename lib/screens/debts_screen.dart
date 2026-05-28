import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_shell.dart';
import '../widgets/currency_text.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Utang & Piutang',
      fab: FloatingActionButton(
        onPressed: () => _showDebtForm(context),
        child: const Icon(Icons.add),
      ),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: provider.debts.map((item) {
            final isReceivable = item.type == 'receivable';
            final paid = item.status == 'paid';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (isReceivable ? Colors.green : Colors.red)
                      .withValues(alpha: .16),
                  child: Icon(
                    isReceivable ? Icons.call_received : Icons.call_made,
                    color: isReceivable ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  item.personName,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    decoration: paid ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${isReceivable ? 'Piutang' : 'Utang'} • jatuh tempo ${DateFormatter.short(item.dueDate)} • ${paid ? 'Lunas' : 'Belum lunas'}',
                ),
                trailing: PopupMenuButton<String>(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CurrencyText(
                        item.amount,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  onSelected: (v) {
                    if (v == 'edit') _showDebtForm(context, item);
                    if (v == 'paid') provider.markDebtPaid(item);
                    if (v == 'delete') provider.deleteDebt(item.id!);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'paid', child: Text('Tandai lunas')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDebtForm(BuildContext context, [DebtModel? item]) {
    final name = TextEditingController(text: item?.personName);
    final amount = TextEditingController(text: item?.amount.toStringAsFixed(0));
    String type = item?.type ?? 'debt';
    DateTime dueDate =
        item?.dueDate ?? DateTime.now().add(const Duration(days: 14));
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item == null ? 'Tambah Catatan' : 'Edit Catatan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'debt', label: Text('Utang')),
                    ButtonSegment(value: 'receivable', label: Text('Piutang')),
                  ],
                  selected: {type},
                  onSelectionChanged: (v) => setState(() => type = v.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nama orang'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  validator: (v) => double.tryParse(v ?? '') == null
                      ? 'Jumlah tidak valid'
                      : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  title: const Text('Jatuh tempo'),
                  subtitle: Text(DateFormatter.short(dueDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await context.read<AppProvider>().saveDebt(
                      DebtModel(
                        id: item?.id,
                        personName: name.text.trim(),
                        amount: double.parse(amount.text),
                        type: type,
                        dueDate: dueDate,
                        status: item?.status ?? 'unpaid',
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
