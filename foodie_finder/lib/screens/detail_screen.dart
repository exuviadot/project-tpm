import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> placeProps;
  final double distance;

  const DetailScreen({super.key, required this.placeProps, required this.distance});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  double _dx = 0;
  double _dy = 0;

  // Static conversion rates (dummy)
  final double usdRate = 16000;
  final double eurRate = 17500;
  final double jpyRate = 110;
  final double basePriceIDR = 50000; // Estimasi Harga Makanan

  @override
  void initState() {
    super.initState();
    _startGyroscope();
  }

  void _startGyroscope() {
    _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!mounted) return;
      setState(() {
        // Adjust multiplier for sensitivity
        _dy += event.x * 2;
        _dx += event.y * 2;
        
        // Clamp values so the image doesn't fly off screen
        _dx = _dx.clamp(-30.0, 30.0);
        _dy = _dy.clamp(-30.0, 30.0);
      });
    });
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    super.dispose();
  }

  Widget _buildTimeZones() {
    // Current UTC time
    final nowUTC = DateTime.now().toUtc();
    final wib = nowUTC.add(const Duration(hours: 7));
    final wita = nowUTC.add(const Duration(hours: 8));
    final wit = nowUTC.add(const Duration(hours: 9));
    final london = nowUTC.add(const Duration(hours: 1)); // BST roughly

    String formatTime(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waktu Sekarang di Berbagai Zona:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _timeBadge('WIB', formatTime(wib)),
            _timeBadge('WITA', formatTime(wita)),
            _timeBadge('WIT', formatTime(wit)),
            _timeBadge('London', formatTime(london)),
          ],
        )
      ],
    );
  }

  Widget _timeBadge(String zone, String time) {
    return Column(
      children: [
        Text(zone, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(time),
      ],
    );
  }

  Widget _buildCurrency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimasi Harga Rata-rata', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('IDR: Rp ${basePriceIDR.toStringAsFixed(0)}'),
        Text('USD: \$ ${(basePriceIDR / usdRate).toStringAsFixed(2)}'),
        Text('EUR: € ${(basePriceIDR / eurRate).toStringAsFixed(2)}'),
        Text('JPY: ¥ ${(basePriceIDR / jpyRate).toStringAsFixed(0)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.placeProps['name'] ?? 'Restoran Tanpa Nama';
    final amenity = widget.placeProps['amenity'] ?? 'Restoran';
    final cuisine = widget.placeProps['cuisine'] ?? 'Umum';
    
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parallax Image Header using Gyroscope
            ClipRRect(
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: -15 + _dy,
                      bottom: -15 - _dy,
                      left: -15 + _dx,
                      right: -15 - _dx,
                      child: Image.network(
                        'https://via.placeholder.com/600x400/AF8F6F/FFFFFF?text=Foto+Restoran',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Gyroscope Parallax Effect',
                        style: TextStyle(color: Colors.white, fontSize: 12, backgroundColor: Colors.black45),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text('$amenity • $cuisine • Jarak: ${widget.distance.toStringAsFixed(2)} km'),
                  const Divider(height: 32),
                  
                  _buildTimeZones(),
                  
                  const Divider(height: 32),
                  
                  _buildCurrency(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
