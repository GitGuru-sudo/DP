import 'package:flutter/foundation.dart';
import 'package:dp_canteen/models/canteen.dart';
import 'package:dp_canteen/models/cart.dart';

class CartProvider extends ChangeNotifier {
  int? _canteenId;
  String? _canteenName;
  final Map<int, CartItem> _items = {};

  int? get canteenId => _canteenId;
  String? get canteenName => _canteenName;
  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  double get tax => 0; // No tax for now
  double get total => subtotal + tax;

  Cart? get cart {
    if (_canteenId == null || _items.isEmpty) return null;
    return Cart(
      canteenId: _canteenId!,
      canteenName: _canteenName ?? '',
      items: items,
    );
  }

  void setCanteen(int canteenId, String canteenName) {
    if (_canteenId != canteenId) {
      // Clear cart if switching canteens
      _items.clear();
    }
    _canteenId = canteenId;
    _canteenName = canteenName;
    notifyListeners();
  }

  void addItem(MenuItem menuItem, {int quantity = 1, String? specialInstructions}) {
    if (_canteenId != null && menuItem.canteenId != _canteenId) {
      // Different canteen - clear cart first
      _items.clear();
      _canteenId = menuItem.canteenId;
    }

    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity += quantity;
    } else {
      _items[menuItem.id] = CartItem(
        menuItem: menuItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );
    }
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    _items.remove(menuItemId);
    if (_items.isEmpty) {
      _canteenId = null;
      _canteenName = null;
    }
    notifyListeners();
  }

  void updateQuantity(int menuItemId, int quantity) {
    if (_items.containsKey(menuItemId)) {
      if (quantity <= 0) {
        removeItem(menuItemId);
      } else {
        _items[menuItemId]!.quantity = quantity;
        notifyListeners();
      }
    }
  }

  void incrementQuantity(int menuItemId) {
    if (_items.containsKey(menuItemId)) {
      _items[menuItemId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int menuItemId) {
    if (_items.containsKey(menuItemId)) {
      if (_items[menuItemId]!.quantity > 1) {
        _items[menuItemId]!.quantity--;
      } else {
        removeItem(menuItemId);
      }
      notifyListeners();
    }
  }

  void updateSpecialInstructions(int menuItemId, String? instructions) {
    if (_items.containsKey(menuItemId)) {
      _items[menuItemId]!.specialInstructions = instructions;
      notifyListeners();
    }
  }

  int getItemQuantity(int menuItemId) {
    return _items[menuItemId]?.quantity ?? 0;
  }
  
  // Alias for compatibility
  int getQuantity(int menuItemId) => getItemQuantity(menuItemId);

  bool hasItem(int menuItemId) {
    return _items.containsKey(menuItemId);
  }

  void clear() {
    _items.clear();
    _canteenId = null;
    _canteenName = null;
    notifyListeners();
  }

  Map<String, dynamic> toOrderJson() {
    return {
      'canteen_id': _canteenId,
      'items': _items.values.map((item) => item.toJson()).toList(),
      'special_instructions': '',
    };
  }
}
