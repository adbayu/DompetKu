import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/formatters.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(this.amount, {super.key, this.style, this.sign = false});

  final num amount;
  final TextStyle? style;
  final bool sign;

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<AppProvider>().currencySymbol;
    final prefix = sign && amount > 0 ? '+' : '';
    return Text(
      '$prefix${MoneyFormatter.format(amount, symbol: symbol)}',
      style: style,
    );
  }
}
