import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Map<String, double>? _cachedRates;
  static DateTime? _cachedAt;
  static const Duration _cacheDuration = Duration(minutes: 15);

  static bool get _hasValidCache {
    if (_cachedRates == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < _cacheDuration;
  }

  static Future<Map<String, double>> getRates({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasValidCache) return _cachedRates!;

    final urls = [
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/idr.json',
      'https://latest.currency-api.pages.dev/v1/currencies/idr.json',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final base = Map<String, dynamic>.from(data['idr'] ?? {});

        final rates = <String, double>{
          'IDR': 1.0,
          'USD': (base['usd'] as num).toDouble(),
          'EUR': (base['eur'] as num).toDouble(),
          'JPY': (base['jpy'] as num).toDouble(),
        };

        _cachedRates = rates;
        _cachedAt = DateTime.now();
        return rates;
      } catch (_) {
        continue;
      }
    }

    throw Exception('Gagal mengambil currency rates dari primary maupun fallback API.');
  }

  static void clearCache() {
    _cachedRates = null;
    _cachedAt = null;
  }
}