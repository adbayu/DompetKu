import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/app_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Pengaturan',
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (nameCtrl.text.isEmpty) nameCtrl.text = provider.userName;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama pengguna',
                        ),
                        onFieldSubmitted: provider.setUserName,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => provider.setUserName(nameCtrl.text),
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Nama'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: provider.isDarkMode,
                onChanged: provider.setDarkMode,
                title: const Text('Dark Mode'),
                subtitle: const Text('Key: isDarkMode'),
              ),
              SwitchListTile(
                value: provider.monthlyLimitAlert,
                onChanged: provider.setMonthlyLimitAlert,
                title: const Text('Peringatan limit bulanan'),
                subtitle: const Text('Key: monthlyLimitAlert'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: provider.currencySymbol,
                decoration: const InputDecoration(
                  labelText: 'Simbol mata uang',
                ),
                items: const [
                  DropdownMenuItem(value: 'Rp', child: Text('Rp - Rupiah')),
                  DropdownMenuItem(value: r'$', child: Text(r'$ - Dollar')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                ],
                onChanged: (v) => provider.setCurrencySymbol(v ?? 'Rp'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: provider.languagePref,
                decoration: const InputDecoration(labelText: 'Bahasa'),
                items: const [
                  DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) => provider.setLanguagePref(v ?? 'id'),
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('SharedPreferences aktif'),
                  subtitle: Text(
                    'isFirstTimeOpen: ${provider.isFirstTimeOpen}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
