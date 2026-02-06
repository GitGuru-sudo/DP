import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/screens/customer/qr_display_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),
            // Order Info Card
            _buildOrderInfoCard(),
            const SizedBox(height: 20),
            // Items Card
            _buildItemsCard(),
            const SizedBox(height: 20),
            // Payment Details
            _buildPaymentCard(),
            const SizedBox(height: 24),
            // Show QR Button (for pending orders)
            if (order.status == 'paid' || order.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrDisplayScreen(order: order),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code, color: Colors.white),
                  label: const Text(
                    'Show QR Code',
                    style: TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(),
                  style: const TextStyle(
                    
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getStatusDescription(),
                  style: TextStyle(
                    
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (order.status) {
      case OrderStatus.pending:
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
        );
      case OrderStatus.confirmed:
      case OrderStatus.paid:
        return const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        );
      case OrderStatus.preparing:
        return const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
        );
      case OrderStatus.ready:
        return const LinearGradient(
          colors: [Color(0xFF9575CD), Color(0xFF673AB7)],
        );
      case OrderStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF4DB6AC), Color(0xFF009688)],
        );
      case OrderStatus.cancelled:
        return const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFF44336)],
        );
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
      case OrderStatus.paid:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.notifications_active;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusLabel() {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Payment Pending';
      case OrderStatus.confirmed:
      case OrderStatus.paid:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription() {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Complete payment to confirm order';
      case OrderStatus.confirmed:
      case OrderStatus.paid:
        return 'Your order is being processed';
      case OrderStatus.preparing:
        return 'Your order is being prepared';
      case OrderStatus.ready:
        return 'Show QR code to collect your order';
      case OrderStatus.completed:
        return 'Order collected successfully';
      case OrderStatus.cancelled:
        return 'This order has been cancelled';
    }
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Order ID', '#${order.id}'),
          _buildInfoRow('Canteen', order.canteenName ?? 'N/A'),
          _buildInfoRow('Order Time', _formatDateTime(order.createdAt)),
          if (order.estimatedTime != null)
            _buildInfoRow('Estimated Time', order.estimatedTime!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                        
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuItemName,
                        style: const TextStyle(
                          
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(2)} each',
                        style: const TextStyle(
                          
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Subtotal', '₹${order.subtotal?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2)}'),
          if (order.tax != null && order.tax! > 0)
            _buildInfoRow('Tax', '₹${order.tax!.toStringAsFixed(2)}'),
          const Divider(height: 24),
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
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
