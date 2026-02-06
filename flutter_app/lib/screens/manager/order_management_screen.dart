import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/providers/order_provider.dart';
import 'package:dp_canteen/widgets/loading_shimmer.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchManagerOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Order Management'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Preparing'),
            Tab(text: 'Ready'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().fetchManagerOrders(),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.managerOrders.isEmpty) {
            return _buildLoadingState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(
                orderProvider.managerOrders
                    .where((o) => o.status == 'paid' || o.status == 'confirmed')
                    .toList(),
                'No new orders',
              ),
              _buildOrderList(
                orderProvider.managerOrders
                    .where((o) => o.status == 'preparing')
                    .toList(),
                'No orders being prepared',
              ),
              _buildOrderList(
                orderProvider.managerOrders
                    .where((o) => o.status == 'ready')
                    .toList(),
                'No orders ready for pickup',
              ),
              _buildOrderList(
                orderProvider.managerOrders
                    .where((o) => o.status == 'delivered')
                    .toList(),
                'No completed orders',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LoadingShimmer(height: 180),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                
                fontSize: 16,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().fetchManagerOrders(),
      color: AppColors.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildManagerOrderCard(order);
        },
      ),
    );
  }

  Widget _buildManagerOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${order.id}',
                        style: const TextStyle(
                          
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(order.createdAt),
                      style: const TextStyle(
                        
                        fontSize: 13,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: const TextStyle(
                      
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer info
                if (order.customerName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: AppColors.grey500),
                        const SizedBox(width: 8),
                        Text(
                          order.customerName!,
                          style: const TextStyle(
                            
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Order items
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
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
                        child: Text(
                          item.menuItemName,
                          style: const TextStyle(
                            
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 20),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        
                        fontWeight: FontWeight.bold,
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
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildActionButtons(order),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.paid:
      case OrderStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateOrderStatus(order.id, 'cancelled'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order.id, 'preparing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Start Preparing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateOrderStatus(order.id, 'ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Mark as Ready',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      case OrderStatus.ready:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Scan QR to deliver',
                style: TextStyle(
                  
                  fontWeight: FontWeight.w500,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStatusLabelFromString(String status) {
    switch (status) {
      case 'paid':
      case 'confirmed':
        return 'New';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final provider = context.read<OrderProvider>();
    final success = await provider.updateOrderStatus(orderId, status);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to ${_getStatusLabelFromString(status)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update order'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
      case OrderStatus.confirmed:
        return 'New';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return status.name;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';

    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
