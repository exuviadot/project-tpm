import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/restaurant.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/distance_calculator.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/restaurant_preview_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  List<Restaurant> _filteredRestaurants = [];
  bool _isInit = false;

  static const LatLng _centerJogja = LatLng(-7.7956, 110.3695);

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, List<Restaurant> all) {
    _applyFilters(query: query, all: all);
  }

  void _applyFilter(String? filterValue, List<Restaurant> all) {
    setState(() => _selectedFilter = filterValue);
    _applyFilters(query: _searchController.text, all: all);
  }

  void _applyFilters({required String query, required List<Restaurant> all}) {
    final repo = ref.read(restaurantRepositoryProvider);
    final userLoc = ref.read(locationNotifierProvider).value;

    double? minRating = _selectedFilter == 'rating' ? 4.5 : null;
    int? maxPrice = _selectedFilter == 'cheap' ? 20000 : null;
    double? userLat = (_selectedFilter == 'nearby' && userLoc != null) ? userLoc.latitude : null;
    double? userLng = (_selectedFilter == 'nearby' && userLoc != null) ? userLoc.longitude : null;
    double? radiusKm = (_selectedFilter == 'nearby' && userLoc != null) ? 3.0 : null;

    var filtered = repo.filter(
      all,
      query: query,
      minRating: minRating,
      maxPrice: maxPrice,
      userLat: userLat,
      userLng: userLng,
      radiusKm: radiusKm,
    );

    if (_selectedFilter == 'mid') {
      filtered = all.where((r) => r.minPrice >= 20000 && r.minPrice <= 50000).toList();
    } else if (_selectedFilter == 'expensive') {
      filtered = all.where((r) => r.minPrice > 50000).toList();
    } else if (_selectedFilter == 'nearby' && userLoc != null) {
      filtered.sort((a, b) {
        final da = DistanceCalculator.km(userLoc.latitude, userLoc.longitude, a.latitude, a.longitude);
        final db = DistanceCalculator.km(userLoc.latitude, userLoc.longitude, b.latitude, b.longitude);
        return da.compareTo(db);
      });
    }

    setState(() {
      _filteredRestaurants = filtered;
    });

    if (filtered.isNotEmpty && query.isNotEmpty) {
      _animateToPosition(LatLng(filtered[0].latitude, filtered[0].longitude));
    }
  }

  void _animateToPosition(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16.0),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _filteredRestaurants
        .where((r) => r.latitude != 0 && r.longitude != 0)
        .map((r) => Marker(
              markerId: MarkerId(r.locationId),
              position: LatLng(r.latitude, r.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              onTap: () => _showPreviewCard(r),
            ))
        .toSet();
  }

  void _showPreviewCard(Restaurant restaurant) {
    final userLoc = ref.read(locationNotifierProvider).value;
    final dist = userLoc != null
        ? DistanceCalculator.formatted(userLoc.latitude, userLoc.longitude, restaurant.latitude, restaurant.longitude)
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RestaurantPreviewCard(
        restaurant: restaurant,
        distanceText: dist,
        onArrowTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/detail', arguments: restaurant);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allRestaurantsProvider);
    final safeArea = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: allAsync.when(
        data: (all) {
          if (!_isInit) {
            _filteredRestaurants = all;
            _isInit = true;
          }
          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(target: _centerJogja, zoom: 13),
                  markers: _buildMarkers(),
                  onMapCreated: (c) => _mapController = c,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
              Positioned(
                top: safeArea + 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildSearchBar(all),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: FilterChipRow(
                        selectedFilter: _selectedFilter,
                        onSelected: (val) => _applyFilter(val, all),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSearchBar(List<Restaurant> all) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _onSearchChanged(val, all),
        decoration: InputDecoration(
          hintText: 'Cari restoran...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('', all);
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}