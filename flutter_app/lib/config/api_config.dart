class ApiConfig {
  // Base URL for development (use localhost for web, 10.0.2.2 for Android emulator)
  static const String devBaseUrl = 'http://localhost:8000/api';
  
  // Base URL for production (update with your deployed backend URL)
  static const String prodBaseUrl = 'https://your-backend.railway.app/api';
  
  // Current environment
  static const bool isProduction = false;
  
  // Get current base URL
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
  
  // API Endpoints
  static const String auth = '/auth';
  static const String verify = '/auth/verify/';
  static const String profile = '/auth/profile/';
  static const String logout = '/auth/logout/';
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  
  static const String canteen = '/canteen';
  static const String canteenList = '/canteen/';
  static String canteenDetail(int id) => '/canteen/$id/';
  static String canteenMenu(int id) => '/canteen/$id/menu/';
  static String canteenCategories(int id) => '/canteen/$id/categories/';
  
  static const String orders = '/orders';
  static const String orderList = '/orders/';
  static const String orderCreate = '/orders/create/';
  static String orderDetail(String orderId) => '/orders/$orderId/';
  static String orderCancel(String orderId) => '/orders/$orderId/cancel/';
  static const String managerOrderList = '/orders/manager/list/';
  static String orderStatusUpdate(String orderId) => '/orders/manager/$orderId/status/';
  
  static const String payments = '/payments';
  static const String paymentInitiate = '/payments/initiate/';
  static const String paymentConfirm = '/payments/confirm/';
  static String paymentQR(String orderId) => '/payments/qr/$orderId/';
  static const String verifyQR = '/payments/verify-qr/';
  static const String confirmQR = '/payments/confirm-qr/';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
