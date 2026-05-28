import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/wallet_model.dart';
import '../providers/app_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/currency_text.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Dompet',
      fab: FloatingActionButton(
        onPressed: () => _showWalletForm(context),
        child: const Icon(Icons.add),
      ),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: provider.wallets.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.account_balance_wallet),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(item.type),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CurrencyText(
                      item.balance,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) => v == 'edit'
                          ? _showWalletForm(context, item)
                          : provider.deleteWallet(item.id!),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showWalletForm(BuildContext context, [WalletModel? item]) {
    final name = TextEditingController(text: item?.name);
    final balance = TextEditingController(
      text: item?.balance.toStringAsFixed(0),
    );
    String type = item?.type ?? 'cash';
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
                  item == null ? 'Tambah Dompet' : 'Edit Dompet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: balance,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Saldo'),
                  validator: (v) => double.tryParse(v ?? '') == null
                      ? 'Saldo tidak valid'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipe'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'bank', child: Text('Bank')),
                    DropdownMenuItem(value: 'ewallet', child: Text('E-Wallet')),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await context.read<AppProvider>().saveWallet(
                      WalletModel(
                        id: item?.id,
                        name: name.text.trim(),
                        balance: double.parse(balance.text),
                        type: type,
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
