import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dp_canteen/services/api_service.dart';
import 'package:dp_canteen/models/user.dart' as app_user;
import 'package:dp_canteen/config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  String? _currentToken;
  app_user.User? _currentUser;

  app_user.User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<app_user.User?> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentToken = data['token'];
          await _apiService.setAuthToken(_currentToken!);
          if (data['user'] != null) {
            _currentUser = app_user.User.fromJson(data['user']);
            return _currentUser;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<app_user.User?> signUpWithEmailPassword(
    String email, 
    String password, 
    String name, 
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentToken = data['token'];
          await _apiService.setAuthToken(_currentToken!);
          if (data['user'] != null) {
            _currentUser = app_user.User.fromJson(data['user']);
            return _currentUser;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<app_user.User?> signInWithGoogle() async {
    // For demo - just return a demo user
    // In production, implement actual Google Sign-In
    return null;
  }

  Future<void> signOut() async {
    try {
      await _apiService.clearAuthToken();
      _currentToken = null;
      _currentUser = null;
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<String?> getIdToken() async {
    return _currentToken;
  }

  Future<void> refreshToken() async {
    // TODO: Implement token refresh with backend
  }
}
