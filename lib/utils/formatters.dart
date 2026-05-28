import 'package:intl/intl.dart';

class MoneyFormatter {
  static String format(num value, {String symbol = 'Rp'}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(value).replaceAll(',00', '');
  }
}

class DateFormatter {
  static String short(DateTime date) =>
      DateFormat('dd MMM yyyy', 'id_ID').format(date);
  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'id_ID').format(date);
  static String time(DateTime date) => DateFormat('HH:mm').format(date);
}
