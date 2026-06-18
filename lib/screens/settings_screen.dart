import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'onboarding_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/glass_panel.dart';
import '../widgets/soft_banking.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.inShell = true});
  final bool inShell;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _t(bool isEn, String id, String en) => isEn ? en : id;

  Future<void> _checkBiometric(bool isEn) async {
    final auth = LocalAuthentication();
    final available =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          available
              ? _t(
                  isEn,
                  'Biometric tersedia di perangkat',
                  'Biometric available on device',
                )
              : _t(isEn, 'Biometric tidak tersedia', 'Biometric unavailable'),
        ),
      ),
    );
  }

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

  Future<void> _restartOnboarding(AppProvider provider) async {
    final isEn = provider.languagePref == 'en';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(isEn, 'Mulai ulang onboarding?', 'Restart onboarding?')),
        content: Text(
          _t(
            isEn,
            'Kamu akan keluar dari halaman utama dan kembali ke layar onboarding.',
            'You will leave the main page and return to onboarding.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t(isEn, 'Batal', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_t(isEn, 'Mulai Lagi', 'Restart')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await provider.restartOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  void _editMonthlyLimit(AppProvider provider) {
    final isEn = provider.languagePref == 'en';
    final ctrl = TextEditingController(
      text: provider.monthlyLimit.toInt().toString(),
    );
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
          SoftHeroCard(
            title: provider.userName,
            subtitle: _t(
              isEn,
              'Profil, keamanan, preferensi, dan info aplikasi.',
              'Profile, security, preferences, and app info.',
            ),
            icon: Icons.person_outline,
            trailing: IconButton.filledTonal(
              onPressed: () => _editName(provider),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),

          _buildHeader(
            Icons.light_mode_outlined,
            _t(isEn, 'Tampilan', 'Display'),
          ),
          SoftCard(
            child: ListTile(
              title: Text(
                _t(isEn, 'Mode Gelap', 'Dark Mode'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Key: isDarkMode',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Switch(
                value: provider.isDarkMode,
                onChanged: provider.setDarkMode,
              ),
            ),
          ),

          _buildHeader(
            Icons.account_balance_wallet_outlined,
            _t(isEn, 'Keuangan', 'Finance'),
          ),
          SoftCard(
            child: ListTile(
              title: Text(
                _t(isEn, 'Limit pengeluaran bulanan', 'Monthly expense limit'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Key: monthlyLimit',
                style: TextStyle(fontSize: 12),
              ),
              trailing: InkWell(
                onTap: () => _editMonthlyLimit(provider),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoneyFormatter.format(
                          provider.monthlyLimit,
                          symbol: provider.currencySymbol,
                          locale: provider.languagePref == 'en'
                              ? 'en_US'
                              : 'id_ID',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, size: 16, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _buildHeader(Icons.language, _t(isEn, 'Preferensi', 'Preferences')),
          SoftCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined),
                  title: Text(_t(isEn, 'Simbol mata uang', 'Currency symbol')),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.currencySymbol,
                      items: const [
                        DropdownMenuItem(
                          value: 'Rp',
                          child: Text('Rp - Rupiah'),
                        ),
                        DropdownMenuItem(
                          value: r'$',
                          child: Text(r'$ - Dollar'),
                        ),
                        DropdownMenuItem(
                          value: 'EUR',
                          child: Text('EUR - Euro'),
                        ),
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

          _buildHeader(Icons.security, _t(isEn, 'Keamanan', 'Security')),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.fingerprint, color: colorScheme.primary),
                  title: Text(_t(isEn, 'Biometric lock', 'Biometric lock')),
                  subtitle: Text(
                    _t(
                      isEn,
                      'Cek dukungan sidik jari/face unlock untuk keamanan aplikasi.',
                      'Check fingerprint/face unlock support for app security.',
                    ),
                  ),
                  trailing: FilledButton(
                    onPressed: () => _checkBiometric(isEn),
                    child: Text(_t(isEn, 'Cek', 'Check')),
                  ),
                ),
              ],
            ),
          ),

          _buildHeader(Icons.info_outline, _t(isEn, 'Lainnya', 'Others')),
          Card(
            elevation: 0,
            color: colorScheme.surface,
            child: ListTile(
              title: Text(
                _t(isEn, 'SharedPreferences aktif', 'SharedPreferences active'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'isFirstTimeOpen: ${provider.isFirstTimeOpen}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: colorScheme.errorContainer.withValues(alpha: .35),
            child: ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: colorScheme.error,
              ),
              title: Text(
                _t(isEn, 'Keluar & mulai dari onboarding', 'Logout & restart onboarding'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                _t(
                  isEn,
                  'Reset status onboarding, lalu kembali ke halaman awal.',
                  'Reset onboarding status, then return to the welcome page.',
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _restartOnboarding(provider),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _t(
                      isEn,
                      'Perubahan berhasil disimpan',
                      'Changes saved successfully',
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: Text(_t(isEn, 'Simpan Perubahan', 'Save Changes')),
          ),
        ],
      ),
    );
  }
}
