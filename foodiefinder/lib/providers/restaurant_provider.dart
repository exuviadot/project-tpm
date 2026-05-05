import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';

part 'restaurant_provider.g.dart';

@riverpod
RestaurantRepository restaurantRepository(RestaurantRepositoryRef ref) {
  return RestaurantRepository();
}

@riverpod
Future<List<Restaurant>> allRestaurants(AllRestaurantsRef ref) async {
  return await ref.read(restaurantRepositoryProvider).getAll();
}
