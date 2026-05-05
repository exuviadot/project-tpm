import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../core/utils/distance_calculator.dart';

class RestaurantRepository {
  final ApiService _api = ApiService();
  static const String _hiveBoxKey = 'restaurants_cache';

  Future<List<Restaurant>> getAll() async {
    try {
      final response = await _api.get('/api/restaurants');
      final features = response['features'] as List;
      final restaurants = features.map((f) => Restaurant.fromGeoJson(f)).toList();
      await _saveToCache(restaurants);
      return restaurants;
    } catch (e) {
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) return cached;
      return await _loadFromAssets();
    }
  }

  Future<void> _saveToCache(List<Restaurant> restaurants) async {
    final box = await Hive.openBox(_hiveBoxKey);
    final data = restaurants.map((r) => r.toJson()).toList();
    await box.put('data', jsonEncode(data));
  }

  Future<List<Restaurant>?> _loadFromCache() async {
    final box = await Hive.openBox(_hiveBoxKey);
    final dataStr = box.get('data') as String?;
    if (dataStr == null) return null;
    final List list = jsonDecode(dataStr);
    return list.map((f) => Restaurant.fromGeoJson(f)).toList();
  }

  Future<List<Restaurant>> _loadFromAssets() async {
    final String response = await rootBundle.loadString('assets/data/restaurants.json');
    final data = await json.decode(response);
    final features = data['features'] as List;
    return features.map((f) => Restaurant.fromGeoJson(f)).toList();
  }

  List<Restaurant> filter(List<Restaurant> all, {
    String? query,
    String? cuisine,
    double? minRating,
    int? maxPrice,
    double? userLat,
    double? userLng,
    double? radiusKm,
  }) {
    var result = all;

    if (query != null && query.isNotEmpty) {
      result = result.where((r) =>
        r.name.toLowerCase().contains(query.toLowerCase()) ||
        r.cuisine.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    if (cuisine != null && cuisine != 'Semua') {
      result = result.where((r) => r.cuisine == cuisine).toList();
    }
    if (minRating != null) {
      result = result.where((r) => r.rating >= minRating).toList();
    }
    if (maxPrice != null) {
      result = result.where((r) => r.minPrice <= maxPrice && r.minPrice > 0).toList();
    }
    if (userLat != null && userLng != null && radiusKm != null) {
      result = result.where((r) {
        final d = DistanceCalculator.km(userLat, userLng, r.latitude, r.longitude);
        return d <= radiusKm;
      }).toList();
    }
    return result;
  }
}
