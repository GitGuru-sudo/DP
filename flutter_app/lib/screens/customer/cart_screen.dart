import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/providers/cart_provider.dart';
import 'package:dp_canteen/providers/order_provider.dart';
import 'package:dp_canteen/screens/customer/payment_screen.dart';
import 'package:dp_canteen/widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Your Cart'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearCartDialog(context, cart),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return _buildEmptyCart();
          }
          return Column(
            children: [
              Expanded(child: _buildCartItems(cart)),
              _buildOrderSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu to get started',
            style: TextStyle(
              
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return CartItemTile(
          cartItem: item,
          onIncrement: () => cart.incrementQuantity(item.menuItem.id),
          onDecrement: () => cart.decrementQuantity(item.menuItem.id),
          onRemove: () => cart.removeItem(item.menuItem.id),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Canteen name
            Row(
              children: [
                const Icon(Icons.store, color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  cart.canteenName ?? 'Canteen',
                  style: const TextStyle(
                    
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Order summary
            _buildSummaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
            if (cart.tax > 0)
              _buildSummaryRow('Tax', '₹${cart.tax.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _placeOrder(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Place Order',
                      style: TextStyle(
                        
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    final orderProvider = context.read<OrderProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      ),
    );

    try {
      final order = await orderProvider.createOrder(cart.toOrderJson());
      
      Navigator.pop(context); // Close loading dialog

      if (order != null) {
        // Clear cart after successful order creation
        cart.clear();
        
        // Navigate to payment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(order: order),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Failed to create order'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
