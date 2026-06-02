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
    final provider = context.watch<AppProvider>();
    final symbol = provider.currencySymbol;
    final locale = provider.languagePref == 'en' ? 'en_US' : 'id_ID';
    final prefix = sign && amount > 0 ? '+' : '';
    return Text(
      '$prefix${MoneyFormatter.format(amount, symbol: symbol, locale: locale)}',
      style: style,
    );
  }
}
