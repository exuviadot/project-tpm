import 'package:intl/intl.dart';

class MenuItem {
  final String item;
  final int price;

  MenuItem({required this.item, required this.price});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
    MenuItem(item: json['item'], price: json['price']);

  Map<String, dynamic> toJson() => {'item': item, 'price': price};

  // Formatted price
  String get formattedPrice =>
    'Rp ${NumberFormat('#,###', 'id_ID').format(price)}';
}
