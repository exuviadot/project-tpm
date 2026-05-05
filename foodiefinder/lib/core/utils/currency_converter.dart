import 'package:intl/intl.dart';

class CurrencyConverter {
  static const Map<String, String> symbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'JPY': '¥',
  };

  static String convert({
    required int priceIdr,
    required String targetCurrency,
    required double rate,
  }) {
    final symbol = symbols[targetCurrency] ?? '';
    final converted = priceIdr * rate;

    if (targetCurrency == 'IDR') {
      return 'Rp ${NumberFormat('#,###', 'id_ID').format(priceIdr)}';
    } else if (targetCurrency == 'JPY') {
      return '$symbol${converted.toStringAsFixed(0)}';
    } else {
      return '$symbol${converted.toStringAsFixed(2)}';
    }
  }
}
