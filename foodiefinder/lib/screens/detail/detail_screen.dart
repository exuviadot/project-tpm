import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../models/restaurant.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_converter.dart';
import '../../widgets/timezone_row.dart';
import '../../widgets/currency_selector.dart';
import '../../services/currency_service.dart';

class DetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  const DetailScreen({Key? key, required this.restaurant}) : super(key: key);

  void _openGoogleMaps() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude},${restaurant.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _GyroscopeHeroImage(imageUrl: restaurant.imageUrl),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Text(restaurant.name, style: AppTextStyles.heading1.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Chip(label: Text(restaurant.cuisine, style: const TextStyle(fontSize: 12))),
                              const Spacer(),
                              const Icon(Icons.star, color: AppColors.starColor, size: 20),
                              const SizedBox(width: 4),
                              Text('${restaurant.rating} (#${restaurant.ranking})', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(restaurant.address, style: AppTextStyles.body)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(restaurant.weatherSuggestion, style: AppTextStyles.body)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Jam Buka', style: AppTextStyles.heading2),
                  const SizedBox(height: 12),
                  TimezoneRow(openingHours: restaurant.openingHours),
                  
                  const SizedBox(height: 24),
                  const Text('Menu', style: AppTextStyles.heading2),
                  const SizedBox(height: 12),
                  _MenuSection(menu: restaurant.menu),
                  
                  const SizedBox(height: 24),
                  const Text('Lokasi', style: AppTextStyles.heading2),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(restaurant.latitude, restaurant.longitude),
                          zoom: 15,
                        ),
                        markers: {Marker(
                          markerId: const MarkerId('detail'),
                          position: LatLng(restaurant.latitude, restaurant.longitude),
                        )},
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                      ),
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text('Buka di Google Maps', style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: _openGoogleMaps,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MenuSection extends StatefulWidget {
  final List menu;
  const _MenuSection({required this.menu});

  @override
  State<_MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<_MenuSection> {
  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  void _fetchRates() async {
    try {
      final rates = await CurrencyService.getRates();
      if (!mounted) return;

      setState(() {
        _rates = rates;
        _isLoading = false;
        _error = null;
      });
    } catch (e, st) {
      debugPrint('Failed to load currency rates: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat kurs mata uang.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CurrencySelector(
          selectedCurrency: _selectedCurrency,
          onSelected: (c) => setState(() => _selectedCurrency = c),
        ),
        const SizedBox(height: 16),
        ...widget.menu.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.item, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            trailing: Text(
              _isLoading 
              ? '...'
              : CurrencyConverter.convert(
                priceIdr: item.price,
                targetCurrency: _selectedCurrency,
                rate: _rates[_selectedCurrency] ?? 1.0,
              ),
              style: AppTextStyles.price,
            ),
          ),
        )).toList(),
      ],
    );
  }
}

class _GyroscopeHeroImage extends StatefulWidget {
  final String imageUrl;
  const _GyroscopeHeroImage({required this.imageUrl});

  @override
  State<_GyroscopeHeroImage> createState() => _GyroscopeHeroImageState();
}

class _GyroscopeHeroImageState extends State<_GyroscopeHeroImage> {
  double _x = 0, _y = 0;
  late StreamSubscription _gyroSub;

  @override
  void initState() {
    super.initState();
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (mounted) {
        setState(() {
          _x = event.y.clamp(-10.0, 10.0);
          _y = event.x.clamp(-10.0, 10.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _gyroSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_x * 0.01)
        ..rotateY(_y * 0.01),
      alignment: Alignment.center,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
      ),
    );
  }
}
