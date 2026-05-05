// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$restaurantRepositoryHash() =>
    r'b03efd8f1649539844ddf93de64bc3952ff59827';

/// See also [restaurantRepository].
@ProviderFor(restaurantRepository)
final restaurantRepositoryProvider =
    AutoDisposeProvider<RestaurantRepository>.internal(
  restaurantRepository,
  name: r'restaurantRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$restaurantRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RestaurantRepositoryRef = AutoDisposeProviderRef<RestaurantRepository>;
String _$allRestaurantsHash() => r'2bb543761ae97e7919b69e5d0566f300d9c1ca04';

/// See also [allRestaurants].
@ProviderFor(allRestaurants)
final allRestaurantsProvider =
    AutoDisposeFutureProvider<List<Restaurant>>.internal(
  allRestaurants,
  name: r'allRestaurantsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allRestaurantsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllRestaurantsRef = AutoDisposeFutureProviderRef<List<Restaurant>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
