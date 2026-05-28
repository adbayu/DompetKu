import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance/utils/formatters.dart';

void main() {
  test('formats rupiah currency', () {
    expect(MoneyFormatter.format(50000), 'Rp 50.000');
  });
}
