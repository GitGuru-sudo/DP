import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dp_canteen/config/api_config.dart';
import 'package:dp_canteen/models/user.dart';
import 'package:dp_canteen/models/canteen.dart';
import 'package:dp_canteen/models/order.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cachedToken;

  String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getAuthToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: 'auth_token');
    return _cachedToken;
  }
  
  Future<void> setAuthToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<void> clearAuthToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'auth_token');
  }

  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Auth APIs
  Future<Map<String, dynamic>> verifyAuth() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.verify}'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify auth: ${response.body}');
    }
  }

  Future<User> getProfile() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.profile}'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get profile');
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl${ApiConfig.profile}'),
      headers: _getHeaders(token: token),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // Canteen APIs
  Future<List<Canteen>> getCanteens() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.canteenList}'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((c) => Canteen.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load canteens');
    }
  }

  Future<Canteen> getCanteen(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.canteenDetail(id)}'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Canteen.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load canteen');
    }
  }

  Future<List<MenuItem>> getMenu(int canteenId, {int? categoryId, String? foodType}) async {
    String url = '$baseUrl${ApiConfig.canteenMenu(canteenId)}';
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (foodType != null) queryParams['food_type'] = foodType;
    
    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? data;
      return results.map((i) => MenuItem.fromJson(i)).toList();
    } else {
      throw Exception('Failed to load menu');
    }
  }

  Future<List<Category>> getCategories(int canteenId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.canteenCategories(canteenId)}'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Order APIs
  Future<List<Order>> getOrders({String? status}) async {
    final token = await _getAuthToken();
    String url = '$baseUrl${ApiConfig.orderList}';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? data;
      return results.map((o) => Order.fromJson(o)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Order> getOrder(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.orderDetail(orderId)}'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load order');
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.orderCreate}'),
      headers: _getHeaders(token: token),
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.orderCancel(orderId)}'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to cancel order');
    }
  }

  // Payment APIs
  Future<Map<String, dynamic>> initiatePayment(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.paymentInitiate}'),
      headers: _getHeaders(token: token),
      body: json.encode({
        'order_id': orderId,
        'method': 'upi',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to initiate payment');
    }
  }

  Future<Map<String, dynamic>> confirmPayment(String orderId, String transactionId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.paymentConfirm}'),
      headers: _getHeaders(token: token),
      body: json.encode({
        'order_id': orderId,
        'transaction_id': transactionId,
        'status': 'success',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to confirm payment');
    }
  }

  Future<Map<String, dynamic>> getOrderQR(String orderId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.paymentQR(orderId)}'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get QR code');
    }
  }

  // Manager APIs
  Future<List<Order>> getManagerOrders({String? status, String? date}) async {
    final token = await _getAuthToken();
    String url = '$baseUrl${ApiConfig.managerOrderList}';
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = date;
    
    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? data;
      return results.map((o) => Order.fromJson(o)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.orderStatusUpdate(orderId)}'),
      headers: _getHeaders(token: token),
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update order status');
    }
  }

  Future<Map<String, dynamic>> verifyQR(String qrData) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.verifyQR}'),
      headers: _getHeaders(token: token),
      body: json.encode({'qr_data': qrData}),
    );

    final data = json.decode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> confirmQR(String qrData) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.confirmQR}'),
      headers: _getHeaders(token: token),
      body: json.encode({'qr_data': qrData}),
    );

    final data = json.decode(response.body);
    return data;
  }
  
  // Additional methods for compatibility
  Future<Map<String, dynamic>> verifyQrCode(String qrData) async {
    return verifyQR(qrData);
  }
  
  Future<Map<String, dynamic>> generateQrCode(int orderId) async {
    return getOrderQR(orderId.toString());
  }
  
  Future<List<MenuItem>> getMenuItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/menu/items/'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? data;
      return results.map((i) => MenuItem.fromJson(i)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }
  
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> data) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/menu/items/'),
      headers: _getHeaders(token: token),
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create menu item');
    }
  }
  
  Future<Map<String, dynamic>> updateMenuItem(int id, Map<String, dynamic> data) async {
    final token = await _getAuthToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/menu/items/$id/'),
      headers: _getHeaders(token: token),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update menu item');
    }
  }
  
  Future<Map<String, dynamic>> updateOrder(String orderId, Map<String, dynamic> data) async {
    return updateOrderStatus(orderId, data['status'] ?? '');
  }
}
