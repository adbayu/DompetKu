import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(
                Icons.savings,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Atur uang lebih tenang',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Text(
                'Catat pemasukan, pengeluaran, budget, target tabungan, dan piutang dalam satu aplikasi modern.',
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
                onPressed: () async {
                  await context.read<AppProvider>().completeOnboarding();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Mulai Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
