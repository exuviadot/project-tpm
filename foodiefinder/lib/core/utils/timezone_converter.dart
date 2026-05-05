class TimezoneConverter {
  // opening_hours format: "09:00 - 21:00" (WIB = UTC+7)
  static Map<String, String> convertAll(String openingHours) {
    if (openingHours.isEmpty) return {};
    
    // Some basic parsing. OpenStreetMap format might vary, but assuming "09:00-21:00" or similar.
    final cleanStr = openingHours.replaceAll('Mo-Su', '').trim();
    final parts = cleanStr.split(RegExp(r'\s*-\s*'));
    if (parts.length != 2) return {'WIB': openingHours};

    try {
      final openWib  = _parseTime(parts[0]);
      final closeWib = _parseTime(parts[1]);

      return {
        'WIB':    '${_fmt(openWib)} - ${_fmt(closeWib)} WIB',
        'WITA':   '${_fmt(openWib.add(const Duration(hours: 1)))} - '
                  '${_fmt(closeWib.add(const Duration(hours: 1)))} WITA',
        'WIT':    '${_fmt(openWib.add(const Duration(hours: 2)))} - '
                  '${_fmt(closeWib.add(const Duration(hours: 2)))} WIT',
        'London': '${_fmt(openWib.subtract(const Duration(hours: 7)))} - '
                  '${_fmt(closeWib.subtract(const Duration(hours: 7)))} LON',
      };
    } catch (e) {
      return {'WIB': openingHours};
    }
  }

  static DateTime _parseTime(String t) {
    final s = t.trim().split(':');
    return DateTime(2024, 1, 1, int.parse(s[0]), int.parse(s[1]));
  }

  static String _fmt(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
