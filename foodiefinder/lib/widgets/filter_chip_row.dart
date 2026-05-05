import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FilterChipRow extends StatelessWidget {
  final String? selectedFilter;
  final ValueChanged<String?> onSelected;

  const FilterChipRow({Key? key, this.selectedFilter, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Semua', 'value': null},
      {'label': 'Rating 4.5+', 'value': 'rating'},
      {'label': '< Rp 20.000', 'value': 'cheap'},
      {'label': 'Rp 20k-50k', 'value': 'mid'},
      {'label': '> Rp 50.000', 'value': 'expensive'},
      {'label': 'Terdekat', 'value': 'nearby'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(f['label'] as String),
            selected: selectedFilter == f['value'],
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selectedFilter == f['value'] ? Colors.white : AppColors.textPrimary,
            ),
            onSelected: (_) => onSelected(f['value'] as String?),
            backgroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )).toList(),
      ),
    );
  }
}
