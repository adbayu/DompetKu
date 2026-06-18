import 'package:flutter/material.dart';
import '../providers/app_provider.dart';

class LimitAlertCard extends StatelessWidget {
  const LimitAlertCard({super.key, required this.provider});

  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEn = provider.languagePref == 'en';
    return GestureDetector(
      onDoubleTap: () => provider.dismissLimitAlert(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.error.withValues(alpha: .4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.error.withValues(alpha: .06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: scheme.onErrorContainer.withValues(alpha: .12),
              child: Icon(
                Icons.warning_amber_rounded,
                color: scheme.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn
                        ? 'Monthly Limit Exceeded!'
                        : 'Batas Bulanan Terlampaui!',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEn
                        ? 'Double tap to dismiss'
                        : 'Ketuk 2x untuk menutup',
                    style: TextStyle(
                      color: scheme.onErrorContainer.withValues(alpha: .68),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
