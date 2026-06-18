import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/finance_transaction.dart';

class PriceChartPreview extends StatelessWidget {
  const PriceChartPreview({super.key, required this.transactions});

  final List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final values = _buildValues();
    return SizedBox(
      height: 112,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              barWidth: 4,
              color: scheme.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: .32),
                    scheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _buildValues() {
    final recent = transactions.take(7).toList().reversed.toList();
    if (recent.isEmpty) return const [3, 5, 4, 8, 7, 10, 12];
    return recent
        .map((tx) => (tx.amount / 100000).clamp(1, 20).toDouble())
        .toList();
  }
}
