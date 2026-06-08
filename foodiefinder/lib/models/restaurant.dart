import 'dart:math';
import 'package:intl/intl.dart';
import 'menu_item.dart';

class Restaurant {
  final String name;
  final String locationId;
  final double rating;
  final int ranking;
  final String description;
  final String cuisine;
  final String address;
  final String openingHours;
  final String imageUrl;
  final String weatherSuggestion;
  final String amenity;
  final List<MenuItem> menu;
  final double latitude;
  final double longitude;

  const Restaurant({
    required this.name,
    required this.locationId,
    required this.rating,
    required this.ranking,
    required this.description,
    required this.cuisine,
    required this.address,
    required this.openingHours,
    required this.imageUrl,
    required this.weatherSuggestion,
    required this.amenity,
    required this.menu,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromGeoJson(Map<String, dynamic> feature) {
    final p = feature['properties'] as Map<String, dynamic>;
    final coords = feature['geometry']['coordinates'] as List;
    return Restaurant(
      name: p['name'] ?? '',
      locationId: p['location_id'] ?? '',
      rating: (p['rating'] != null)
          ? double.tryParse(p['rating'].toString()) ?? 0.0
          : 0.0,
      ranking: p['ranking'] ?? 0,
      description: p['description'] ?? '',
      cuisine: p['cuisine'] ?? '',
      address: p['address'] ?? '',
      openingHours: p['opening_hours'] ?? '',
      imageUrl: _normalizeImageUrl(p['image_url']),
      weatherSuggestion: p['weather_suggestion'] ?? '',
      amenity: p['amenity'] ?? 'restaurant',
      menu:
          (p['menu'] as List? ?? []).map((m) => MenuItem.fromJson(m)).toList(),
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'properties': {
        'name': name,
        'location_id': locationId,
        'rating': rating,
        'ranking': ranking,
        'description': description,
        'cuisine': cuisine,
        'address': address,
        'opening_hours': openingHours,
        'image_url': imageUrl,
        'weather_suggestion': weatherSuggestion,
        'amenity': amenity,
        'menu': menu.map((m) => m.toJson()).toList(),
      }
    };
  }

  int get minPrice => menu.isEmpty ? 0 : menu.map((m) => m.price).reduce(min);

  String get priceRange {
    if (menu.isEmpty) return '-';
    final prices = menu.map((m) => m.price).toList()..sort();
    if (prices.length == 1) return _formatRupiah(prices[0]);
    return '${_formatRupiah(prices.first)} - ${_formatRupiah(prices.last)}';
  }

  String _formatRupiah(int price) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(price)}';

  static String _normalizeImageUrl(dynamic value) {
    final url = value?.toString() ?? '';
    if (url.isEmpty || url.contains('source.unsplash.com')) {
      return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80';
    }
    return url;
  }
}
