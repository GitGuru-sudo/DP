import 'package:dp_canteen/models/canteen.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItem.id,
      'quantity': quantity,
      'special_instructions': specialInstructions ?? '',
    };
  }

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class Cart {
  final int canteenId;
  final String canteenName;
  final List<CartItem> items;

  Cart({
    required this.canteenId,
    required this.canteenName,
    required this.items,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get tax => 0; // No tax for now
  double get total => subtotal + tax;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Map<String, dynamic> toOrderJson() {
    return {
      'canteen_id': canteenId,
      'items': items.map((item) => item.toJson()).toList(),
      'special_instructions': '',
    };
  }
}
