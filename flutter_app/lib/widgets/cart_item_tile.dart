import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/cart.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food type indicator and image
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.grey100,
                ),
                child: cartItem.menuItem.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          cartItem.menuItem.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: cartItem.menuItem.foodType == 'veg'
                          ? Colors.green
                          : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cartItem.menuItem.foodType == 'veg'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuItem.name,
                  style: const TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem.menuItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              onPressed: onDecrement,
                              icon: const Icon(Icons.remove, size: 16),
                              color: AppColors.primaryOrange,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 32),
                            child: Text(
                              '${cartItem.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              onPressed: onIncrement,
                              icon: const Icon(Icons.add, size: 16),
                              color: AppColors.primaryOrange,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Total price
                    Text(
                      '₹${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.grey400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 32,
        color: AppColors.grey300,
      ),
    );
  }
}
