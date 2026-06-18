import 'package:flutter/material.dart';
import '../models/finance_transaction.dart';
import '../utils/formatters.dart';

class TransactionBarChart extends StatelessWidget {
  const TransactionBarChart({
    super.key,
    required this.transactions,
    required this.currencySymbol,
    required this.locale,
    required this.type,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final List<FinanceTransaction> transactions;
  final String currencySymbol;
  final String locale;
  final String type;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      3,
      (i) => DateTime(now.year, now.month - 2 + i),
    );
    final values = months.map((month) {
      return transactions
          .where(
            (tx) => tx.date.year == month.year && tx.date.month == month.month,
          )
          .fold<double>(0, (sum, tx) => sum + tx.amount);
    }).toList();
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final selectedIndex = selectedMonth == null
        ? values.lastIndexWhere((value) => value > 0)
        : months.indexWhere(
            (month) =>
                month.year == selectedMonth!.year &&
                month.month == selectedMonth!.month,
          );
    final activeIndex = selectedIndex == -1 ? months.length - 1 : selectedIndex;
    final activeValue = values[activeIndex];
    final chartColor = type == 'income'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return SizedBox(
      height: 260,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final slot = constraints.maxWidth / months.length;
                    final tappedIndex = (details.localPosition.dx / slot)
                        .floor()
                        .clamp(0, months.length - 1);
                    onMonthSelected(months[tappedIndex]);
                  },
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: values,
                      activeIndex: activeIndex,
                      maxValue: maxValue <= 0 ? 1 : maxValue,
                      color: chartColor,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chartColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          MoneyFormatter.format(
                            activeValue,
                            symbol: currencySymbol,
                            locale: locale,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: months.map((month) {
              final monthIndex = months.indexOf(month);
              final active = monthIndex == activeIndex;
              return Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onMonthSelected(month),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        DateFormatter.monthYear(
                          month,
                        ).split(' ').first.substring(0, 3),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant
                                    .withValues(alpha: .62),
                          fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.values,
    required this.activeIndex,
    required this.maxValue,
    required this.color,
  });

  final List<double> values;
  final int activeIndex;
  final double maxValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final slot = size.width / values.length;
    final base = size.height - 18;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] / maxValue).clamp(0.08, 1.0);
      final height = normalized * (size.height * .50);
      final left = i * slot + slot * .24;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, base - height, slot * .52, height),
        const Radius.circular(18),
      );
      paint.color = i == activeIndex
          ? color
          : color.withValues(alpha: .15);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.color != color;
}
