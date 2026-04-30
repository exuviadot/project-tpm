import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import 'detail_screen.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _allPlaces = [];
  List<dynamic> _filteredPlaces = [];
  Position? _currentPosition;

  String _searchQuery = '';
  String _selectedAmenity = '';
  String _selectedCuisine = '';

  final List<String> _amenities = ['restaurant', 'cafe', 'fast_food', 'food_court'];
  final List<String> _cuisines = ['pizza', 'noodle', 'burger', 'coffee', 'asian', 'indonesian'];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getLocation();
    await _fetchData();
  }

  Future<void> _getLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> _fetchData() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/restaurants'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null) {
          setState(() {
            _allPlaces = data['features'];
            _filteredPlaces = _allPlaces;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<dynamic> results = _allPlaces;

    if (_searchQuery.isNotEmpty) {
      results = results.where((place) {
        final props = place['properties'];
        final name = props['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedAmenity.isNotEmpty) {
      results = results.where((place) {
        final props = place['properties'];
        return props['amenity'] == _selectedAmenity;
      }).toList();
    }

    if (_selectedCuisine.isNotEmpty) {
      results = results.where((place) {
        final props = place['properties'];
        final cuisine = props['cuisine']?.toString().toLowerCase() ?? '';
        return cuisine.contains(_selectedCuisine.toLowerCase());
      }).toList();
    }

    // Sort by distance if location is available
    if (_currentPosition != null) {
      results.sort((a, b) {
        final geomA = a['geometry'];
        final geomB = b['geometry'];
        if (geomA == null || geomB == null) return 0;

        final distA = _calculateDistance(geomA['coordinates'][1], geomA['coordinates'][0]);
        final distB = _calculateDistance(geomB['coordinates'][1], geomB['coordinates'][0]);
        return distA.compareTo(distB);
      });
    }

    setState(() {
      _filteredPlaces = results;
    });
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    ) / 1000; // return in km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Restoran')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        tooltip: 'Tanya AI',
        child: const Icon(Icons.smart_toy),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan nama restoran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Tipe: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._amenities.map((a) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FilterChip(
                    label: Text(a),
                    selected: _selectedAmenity == a,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAmenity = selected ? a : '';
                        _applyFilters();
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Kuliner: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._cuisines.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FilterChip(
                    label: Text(c),
                    selected: _selectedCuisine == c,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCuisine = selected ? c : '';
                        _applyFilters();
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _filteredPlaces[index];
                      final props = place['properties'];
                      final geom = place['geometry'];
                      
                      double dist = 0.0;
                      if (geom != null && geom['coordinates'] != null) {
                        // GeoJSON coords: [lon, lat]
                        final lon = geom['coordinates'][0];
                        final lat = geom['coordinates'][1];
                        dist = _calculateDistance(lat, lon);
                      }

                      return ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: Text(props['name'] ?? 'Tanpa Nama'),
                        subtitle: Text('${props['amenity'] ?? '-'} | ${props['cuisine'] ?? '-'}'),
                        trailing: Text('${dist.toStringAsFixed(1)} km'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                placeProps: props,
                                distance: dist,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
