import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/app_shell.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _t(bool isEn, String id, String en) => isEn ? en : id;

  void _editName(AppProvider provider) {
    final isEn = provider.languagePref == 'en';
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(isEn, 'Ubah Nama', 'Edit Name')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: _t(isEn, 'Nama pengguna', 'Username'),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t(isEn, 'Batal', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              provider.setUserName(ctrl.text);
              Navigator.pop(ctx);
            },
            child: Text(_t(isEn, 'Simpan', 'Save')),
          ),
        ],
      ),
    );
  }

  void _editMonthlyLimit(AppProvider provider) {
    final isEn = provider.languagePref == 'en';
    final ctrl = TextEditingController(text: provider.monthlyLimit.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(isEn, 'Ubah Limit Bulanan', 'Edit Monthly Limit')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: _t(isEn, 'Limit bulanan', 'Monthly limit'),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t(isEn, 'Batal', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text) ?? 5000000.0;
              provider.setMonthlyLimit(val);
              Navigator.pop(ctx);
            },
            child: Text(_t(isEn, 'Simpan', 'Save')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 24),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEn = provider.languagePref == 'en';
    final colorScheme = Theme.of(context).colorScheme;

    return AppShell(
      title: _t(isEn, 'Pengaturan', 'Settings'),
      child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Card
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_outline,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t(isEn, 'Nama pengguna', 'Username'),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              provider.userName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () => _editName(provider),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(_t(isEn, 'Ubah', 'Edit')),
                      ),
                    ],
                  ),
                ),
              ),

              _buildHeader(Icons.light_mode_outlined, _t(isEn, 'Tampilan', 'Display')),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: Text(_t(isEn, 'Mode Gelap', 'Dark Mode'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Key: isDarkMode', style: TextStyle(fontSize: 12)),
                  trailing: Switch(
                    value: provider.isDarkMode,
                    onChanged: provider.setDarkMode,
                  ),
                ),
              ),

              _buildHeader(Icons.account_balance_wallet_outlined, _t(isEn, 'Keuangan', 'Finance')),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: Text(_t(isEn, 'Limit pengeluaran bulanan', 'Monthly expense limit'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Key: monthlyLimit', style: TextStyle(fontSize: 12)),
                  trailing: InkWell(
                    onTap: () => _editMonthlyLimit(provider),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MoneyFormatter.format(provider.monthlyLimit, symbol: provider.currencySymbol, locale: provider.languagePref == 'en' ? 'en_US' : 'id_ID')),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              _buildHeader(Icons.language, _t(isEn, 'Preferensi', 'Preferences')),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined),
                      title: Text(_t(isEn, 'Simbol mata uang', 'Currency symbol')),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.currencySymbol,
                          items: const [
                            DropdownMenuItem(value: 'Rp', child: Text('Rp - Rupiah')),
                            DropdownMenuItem(value: r'$', child: Text(r'$ - Dollar')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                          ],
                          onChanged: (v) {
                            if (v != null) provider.setCurrencySymbol(v);
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.translate),
                      title: Text(_t(isEn, 'Bahasa', 'Language')),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.languagePref,
                          items: const [
                            DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                          onChanged: (v) {
                            if (v != null) provider.setLanguagePref(v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildHeader(Icons.info_outline, _t(isEn, 'Lainnya', 'Others')),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: Text(_t(isEn, 'SharedPreferences aktif', 'SharedPreferences active'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('isFirstTimeOpen: ${provider.isFirstTimeOpen}', style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _t(isEn, 'Aktif', 'Active'),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_t(isEn, 'Perubahan berhasil disimpan', 'Changes saved successfully')),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: Text(_t(isEn, 'Simpan Perubahan', 'Save Changes')),
              )
            ],
      ),
    );
  }
}
