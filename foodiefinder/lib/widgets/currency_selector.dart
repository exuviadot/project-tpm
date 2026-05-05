import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onSelected;

  const CurrencySelector({Key? key, required this.selectedCurrency, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const currencies = ['IDR', 'USD', 'EUR', 'JPY'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: currencies.map((c) => GestureDetector(
          onTap: () => onSelected(c),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedCurrency == c ? AppColors.primary : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              c,
              style: TextStyle(
                color: selectedCurrency == c ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
