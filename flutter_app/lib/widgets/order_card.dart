import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${order.id}',
                            style: const TextStyle(
                              
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(),
                      ],
                    ),
                    Text(
                      _formatTime(order.createdAt),
                      style: const TextStyle(
                        
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Canteen name
                if (order.canteenName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.store,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.canteenName!,
                        style: const TextStyle(
                          
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                const Divider(height: 20),
                // Items summary
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.menuItemName,
                          style: const TextStyle(
                            
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} more items',
                    style: const TextStyle(
                      
                      fontSize: 12,
                      color: AppColors.grey500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 12),
                // Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items',
                      style: const TextStyle(
                        
                        fontSize: 13,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
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
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (order.status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        label = 'Pending';
        break;
      case OrderStatus.confirmed:
      case OrderStatus.paid:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        label = 'Confirmed';
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = 'Preparing';
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        label = 'Ready';
        break;
      case OrderStatus.completed:
        backgroundColor = Colors.teal.withOpacity(0.1);
        textColor = Colors.teal;
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
