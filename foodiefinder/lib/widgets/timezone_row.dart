import 'package:flutter/material.dart';
import '../core/utils/timezone_converter.dart';
import '../core/constants/app_text_styles.dart';

class TimezoneRow extends StatelessWidget {
  final String openingHours;

  const TimezoneRow({Key? key, required this.openingHours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final zones = TimezoneConverter.convertAll(openingHours);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: zones.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(e.value, style: AppTextStyles.body),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
