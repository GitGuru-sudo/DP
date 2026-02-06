import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/providers/order_provider.dart';
import 'package:dp_canteen/screens/customer/order_detail_screen.dart';
import 'package:dp_canteen/widgets/order_card.dart';
import 'package:dp_canteen/widgets/loading_shimmer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
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
        title: const Text('My Orders'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return _buildLoadingState();
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return _buildErrorState(orderProvider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProvider.activeOrders, 'No active orders'),
              _buildOrderList(orderProvider.completedOrders, 'No completed orders'),
              _buildOrderList(orderProvider.orders, 'No orders yet'),
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
        child: LoadingShimmer(height: 150),
      ),
    );
  }

  Widget _buildErrorState(OrderProvider orderProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            orderProvider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => orderProvider.fetchOrders(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().fetchOrders(),
      color: AppColors.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderCard(
              order: order,
              onTap: () => _navigateToOrderDetail(order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              
              fontSize: 16,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order),
      ),
    );
  }
}
