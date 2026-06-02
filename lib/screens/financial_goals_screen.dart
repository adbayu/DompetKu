import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/financial_goal.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_shell.dart';
import '../widgets/currency_text.dart';
import '../utils/localization.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: tr(context, 'Target Finansial', 'Financial Goals'),
      fab: FloatingActionButton(
        onPressed: () => _showGoalForm(context),
        child: const Icon(Icons.add),
      ),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: provider.goals.map((goal) {
            final p = goal.targetAmount == 0
                ? 0.0
                : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) => v == 'edit'
                              ? _showGoalForm(context, goal)
                              : provider.deleteGoal(goal.id!),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(tr(context, 'Edit', 'Edit')),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(tr(context, 'Hapus', 'Delete')),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${tr(context, 'Deadline', 'Deadline')} ${DateFormatter.short(goal.deadline)}',
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: p,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CurrencyText(
                          goal.currentAmount,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Text(' / '),
                        CurrencyText(goal.targetAmount),
                        const Spacer(),
                        Text('${(p * 100).round()}%'),
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

  void _showGoalForm(BuildContext context, [FinancialGoal? item]) {
    final title = TextEditingController(text: item?.title);
    final target = TextEditingController(
      text: item?.targetAmount.toStringAsFixed(0),
    );
    final current = TextEditingController(
      text: item?.currentAmount.toStringAsFixed(0) ?? '0',
    );
    DateTime deadline =
        item?.deadline ?? DateTime.now().add(const Duration(days: 90));
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
                  tr(
                    context,
                    item == null ? 'Tambah Target' : 'Edit Target',
                    item == null ? 'Add Goal' : 'Edit Goal',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Judul', 'Title'),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? tr(context, 'Judul wajib diisi', 'Title is required')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: target,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Target', 'Target'),
                  ),
                  validator: (v) => _amountValidator(context, v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: current,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr(context, 'Terkumpul', 'Collected'),
                  ),
                  validator: (v) => _amountValidator(context, v),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  title: Text(tr(context, 'Deadline', 'Deadline')),
                  subtitle: Text(DateFormatter.short(deadline)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => deadline = picked);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await context.read<AppProvider>().saveGoal(
                      FinancialGoal(
                        id: item?.id,
                        title: title.text.trim(),
                        targetAmount: double.parse(target.text),
                        currentAmount: double.parse(current.text),
                        deadline: deadline,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(tr(context, 'Simpan', 'Save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _amountValidator(BuildContext context, String? v) {
  final parsed = double.tryParse(v ?? '');
  return parsed == null || parsed < 0
      ? tr(context, 'Nominal tidak valid', 'Invalid amount')
      : null;
}
