import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class RestaurantPreviewCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onArrowTap;
  final String? distanceText;

  const RestaurantPreviewCard({
    Key? key,
    required this.restaurant,
    required this.onArrowTap,
    this.distanceText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              restaurant.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(width: 90, height: 90, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(restaurant.name, style: AppTextStyles.heading2, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${restaurant.cuisine} • ⭐ ${restaurant.rating}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(restaurant.openingHours, style: AppTextStyles.caption),
                if (distanceText != null) ...[
                  const SizedBox(height: 4),
                  Text(distanceText!, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                ]
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
            onPressed: onArrowTap,
          ),
        ],
      ),
    );
  }
}
