import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahkan package ini di pubspec.yaml
import '../models/restaurant.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class SpecialRecommendationCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onLocationTap;
  final VoidCallback onMenuTap;

  const SpecialRecommendationCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
    required this.onLocationTap,
    required this.onMenuTap,
  }) : super(key: key);

  // Fungsi internal untuk membuka koordinat di Maps
  Future<void> _openMaps(double lat, double lng) async {
    final Uri uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      restaurant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('✨ Rekomendasi Hari Ini', style: AppTextStyles.badge),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(restaurant.cuisine, style: AppTextStyles.caption),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: AppColors.starColor),
                      const SizedBox(width: 4),
                      Text(restaurant.rating.toString(), style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(restaurant.openingHours, style: AppTextStyles.caption),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Lihat Menu'),
                        onPressed: () {
                          // Menuju ke Detail Screen
                          Navigator.pushNamed(context, '/detail', arguments: restaurant);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.location_on),
                        label: const Text('Lihat Lokasi'),
                        onPressed: () {
                          // Diarahkan ke lokasi Maps berdasarkan koordinat restaurant
                          _openMaps(restaurant.latitude, restaurant.longitude);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}