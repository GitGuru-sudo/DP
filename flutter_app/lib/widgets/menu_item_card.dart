import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/canteen.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/providers/cart_provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.grey100,
                      ),
                      child: menuItem.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                menuItem.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              ),
                            )
                          : _buildPlaceholder(),
                    ),
                    // Food type indicator (veg/non-veg)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: menuItem.foodType == 'veg'
                                ? Colors.green
                                : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: menuItem.foodType == 'veg'
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
                        menuItem.name,
                        style: const TextStyle(
                          
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (menuItem.description != null)
                        Text(
                          menuItem.description!,
                          style: const TextStyle(
                            
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${menuItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          _buildAddButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 40,
        color: AppColors.grey300,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final quantity = cart.getQuantity(menuItem.id);

        if (quantity == 0) {
          return SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: menuItem.isAvailable
                  ? () => cart.addItem(menuItem)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: menuItem.isAvailable
                    ? AppColors.primaryOrange
                    : AppColors.grey300,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                menuItem.isAvailable ? 'ADD' : 'N/A',
                style: const TextStyle(
                  
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () => cart.decrementQuantity(menuItem.id),
                  icon: const Icon(Icons.remove, size: 18),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 24),
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () => cart.incrementQuantity(menuItem.id),
                  icon: const Icon(Icons.add, size: 18),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
