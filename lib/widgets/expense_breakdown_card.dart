import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/app_provider.dart';
import '../utils/icon_constants.dart';
import '../utils/localization.dart';
import 'currency_text.dart';
import 'finance_donut_chart.dart';
import 'soft_banking.dart';

class ExpenseBreakdownCard extends StatelessWidget {
  const ExpenseBreakdownCard({
    super.key,
    required this.segments,
    required this.totalExpense,
  });

  final List<DonutSegment> segments;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final visibleSegments = segments;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StackedExpenseBar(
            segments: visibleSegments,
            totalExpense: totalExpense,
          ),
          const SizedBox(height: 18),
          if (visibleSegments.isEmpty)
            Text(
              tr(context, 'Belum ada pengeluaran', 'No expenses yet'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...visibleSegments.map(
              (segment) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ExpenseCompositionRow(
                  segment: segment,
                  totalExpense: totalExpense,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StackedExpenseBar extends StatelessWidget {
  const _StackedExpenseBar({
    required this.segments,
    required this.totalExpense,
  });

  final List<DonutSegment> segments;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty || totalExpense == 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 24,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 24,
        child: Row(
          children: segments.map((segment) {
            final percent = segment.value / totalExpense;
            final percentage = (percent * 100).round();
            return Expanded(
              flex: (percent * 1000).round().clamp(1, 1000),
              child: Container(
                alignment: Alignment.center,
                color: segment.color,
                child: percentage >= 6
                    ? Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExpenseCompositionRow extends StatelessWidget {
  const _ExpenseCompositionRow({
    required this.segment,
    required this.totalExpense,
  });

  final DonutSegment segment;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final category = provider.categories.firstWhere(
      (c) => c.name == segment.label,
      orElse: () => const CategoryModel(name: '', icon: 'category', color: 0xFF9CA3AF),
    );
    final percent = totalExpense == 0 ? 0.0 : segment.value / totalExpense;
    final percentText = '${(percent * 100).round()}%';
    final categoryColor = Color(category.color);
    final categoryBgColor = categoryColor.withValues(alpha: .14);
    final iconData = IconConstants.getIcon(category.icon);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: categoryBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(iconData, size: 18, color: categoryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            segment.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: categoryBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            percentText,
            style: TextStyle(
              color: categoryColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: percent,
              color: categoryColor,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 82,
          child: Align(
            alignment: Alignment.centerRight,
            child: CurrencyText(
              segment.value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
