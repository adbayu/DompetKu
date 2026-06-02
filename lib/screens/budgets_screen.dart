import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/localization.dart';
import '../widgets/app_shell.dart';
import '../widgets/currency_text.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key, this.inShell = true});
  final bool inShell;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<AppProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final monthBudgets = provider.budgets
            .where((e) => e.month == now.month && e.year == now.year)
            .toList();
        final totalBudget = monthBudgets.fold<double>(
          0,
          (v, e) => v + e.limitAmount,
        );
        final spent = provider.transactions
            .where(
              (e) =>
                  e.type == 'expense' &&
                  e.date.month == now.month &&
                  e.date.year == now.year,
            )
            .fold<double>(0, (v, e) => v + e.amount);
        final ratio = totalBudget == 0
            ? 0.0
            : (spent / totalBudget).clamp(0.0, 1.0);
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009F89), Color(0xFF10BFA6)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, 'Budget Bulanan', 'Monthly Budget'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    DateFormatter.monthYear(now),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: ratio,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(30),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(ratio * 100).round()}% ${tr(context, 'terpakai', 'used')}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _BudgetSummary(
              label: tr(context, 'Total Budget', 'Total Budget'),
              amount: totalBudget,
            ),
            _BudgetSummary(
              label: tr(context, 'Terpakai', 'Used'),
              amount: spent,
              danger: true,
            ),
            _BudgetSummary(
              label: tr(context, 'Sisa Budget', 'Remaining Budget'),
              amount: totalBudget - spent,
            ),
            const SizedBox(height: 12),
            Text(
              tr(context, 'Budget per Kategori', 'Budget by Category'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...monthBudgets.map((budget) {
              final category = provider.categoryById(budget.categoryId);
              final used = provider.transactions
                  .where(
                    (e) =>
                        e.type == 'expense' &&
                        e.categoryId == budget.categoryId &&
                        e.date.month == budget.month &&
                        e.date.year == budget.year,
                  )
                  .fold<double>(0, (v, e) => v + e.amount);
              final p = budget.limitAmount == 0
                  ? 0.0
                  : (used / budget.limitAmount).clamp(0.0, 1.0);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      category.color,
                    ).withValues(alpha: .16),
                    child: Icon(Icons.pie_chart, color: Color(category.color)),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrencyText(budget.limitAmount),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: p,
                        color: Color(category.color),
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit'
                        ? _showBudgetForm(context, budget)
                        : provider.deleteBudget(budget.id!),
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
                ),
              );
            }),
          ],
        );
      },
    );
    if (!inShell) return SafeArea(child: body);
    return AppShell(
      title: tr(context, 'Budget', 'Budgets'),
      fab: FloatingActionButton(
        onPressed: () => _showBudgetForm(context),
        child: const Icon(Icons.add),
      ),
      child: body,
    );
  }

  void _showBudgetForm(BuildContext context, [BudgetModel? item]) {
    final now = DateTime.now();
    final amount = TextEditingController(
      text: item?.limitAmount.toStringAsFixed(0),
    );
    int? categoryId = item?.categoryId;
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Consumer<AppProvider>(
        builder: (context, provider, _) {
          categoryId ??= provider.categories.firstOrNull?.id;
          return Padding(
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
                      item == null ? 'Tambah Budget' : 'Edit Budget',
                      item == null ? 'Add Budget' : 'Edit Budget',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: categoryId,
                    decoration: InputDecoration(
                      labelText: tr(context, 'Kategori', 'Category'),
                    ),
                    items: provider.categories
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => categoryId = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr(context, 'Limit Budget', 'Budget Limit'),
                    ),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? tr(context, 'Nominal tidak valid', 'Invalid amount')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate() ||
                          categoryId == null) {
                        return;
                      }
                      await provider.saveBudget(
                        BudgetModel(
                          id: item?.id,
                          categoryId: categoryId!,
                          month: now.month,
                          year: now.year,
                          limitAmount: double.parse(amount.text),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(tr(context, 'Simpan', 'Save')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({
    required this.label,
    required this.amount,
    this.danger = false,
  });
  final String label;
  final double amount;
  final bool danger;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      title: Text(label),
      trailing: CurrencyText(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: danger ? Colors.red : null,
        ),
      ),
    ),
  );
}
