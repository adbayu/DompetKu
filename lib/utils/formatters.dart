import 'package:intl/intl.dart';

class MoneyFormatter {
  static String format(num value, {String symbol = 'Rp', String locale = 'id_ID'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}

class DateFormatter {
  static String short(DateTime date, {String locale = 'id_ID'}) =>
      DateFormat('dd MMM yyyy', locale).format(date);
  static String monthYear(DateTime date, {String locale = 'id_ID'}) =>
      DateFormat('MMMM yyyy', locale).format(date);
  static String time(DateTime date, {String locale = 'id_ID'}) => DateFormat('HH:mm', locale).format(date);
}
