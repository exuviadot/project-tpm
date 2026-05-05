import 'dart:math';

class DistanceCalculator {
  static double km(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat/2)*sin(dLat/2) +
              cos(_rad(lat1))*cos(_rad(lat2))*sin(dLng/2)*sin(dLng/2);
    return R * 2 * atan2(sqrt(a), sqrt(1-a));
  }
  static double _rad(double deg) => deg * pi / 180;

  static String formatted(double lat1, double lng1, double lat2, double lng2) {
    final d = km(lat1, lng1, lat2, lng2);
    return d < 1 ? '${(d * 1000).toStringAsFixed(0)} m' : '${d.toStringAsFixed(1)} km';
  }
}
