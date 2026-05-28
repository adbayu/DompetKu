import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimationDialog extends StatelessWidget {
  const SuccessAnimationDialog({super.key, required this.message});

  final String message;

  static Future<void> show(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (_) => SuccessAnimationDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/lottie/success.json', width: 120, repeat: false),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
