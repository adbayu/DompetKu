import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.fab,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: fab,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: .08),
                scheme.surface,
                scheme.secondary.withValues(alpha: .06),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
