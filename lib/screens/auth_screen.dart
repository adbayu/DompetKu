import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool register = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (register && nameController.text.trim().isNotEmpty) {
      await context.read<AppProvider>().setUserName(nameController.text);
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: .28),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              register ? 'Buat akun DompetKu' : 'Masuk ke DompetKu',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              register
                  ? 'Mulai kelola pemasukan, pengeluaran, budget, dan targetmu.'
                  : 'Lanjutkan pencatatan finansialmu dengan tampilan baru.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            if (register) ...[
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: _continue,
              child: Text(register ? 'Daftar' : 'Masuk'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => register = !register),
              child: Text(
                register
                    ? 'Sudah punya akun? Masuk'
                    : 'Belum punya akun? Daftar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
