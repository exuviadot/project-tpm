import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({Key? key, required this.restaurant, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                restaurant.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(height: 110, color: Colors.grey[300]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading2.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.cuisine, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.starColor),
                      const SizedBox(width: 4),
                      Text(restaurant.rating.toString(), style: AppTextStyles.caption),
                      const Spacer(),
                      Text(restaurant.priceRange, style: AppTextStyles.price.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
