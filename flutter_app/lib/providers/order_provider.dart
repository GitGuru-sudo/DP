import 'package:flutter/foundation.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  List<Order> _managerOrders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Order> get managerOrders => _managerOrders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Order> get pendingOrders => 
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  
  List<Order> get activeOrders => _orders.where((o) => 
      o.status == OrderStatus.paid || 
      o.status == OrderStatus.confirmed ||
      o.status == OrderStatus.preparing ||
      o.status == OrderStatus.ready
  ).toList();

  List<Order> get completedOrders => _orders.where((o) => 
      o.status == OrderStatus.completed || 
      o.status == OrderStatus.cancelled
  ).toList();

  Future<void> loadOrders({String? status}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _apiService.getOrders(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> loadOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentOrder = await _apiService.getOrder(orderId);
      return _currentOrder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.createOrder(orderData);
      if (response['success'] == true && response['order'] != null) {
        final order = Order.fromJson(response['order']);
        _orders.insert(0, order);
        _currentOrder = order;
        notifyListeners();
        return order;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.cancelOrder(orderId);
      if (response['success'] == true) {
        // Update local order
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          await loadOrders();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearOrders() {
    _orders = [];
    _managerOrders = [];
    _currentOrder = null;
    notifyListeners();
  }
  
  // Alias methods for compatibility
  Future<void> fetchOrders() => loadOrders();
  
  Future<void> fetchManagerOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _managerOrders = await _apiService.getOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.updateOrder(orderId.toString(), {'status': status});
      if (response['success'] == true) {
        await fetchManagerOrders();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
