import 'package:flutter/foundation.dart';
import 'package:dp_canteen/models/user.dart';
import 'package:dp_canteen/services/auth_service.dart';
import 'package:dp_canteen/services/api_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isManager => _user?.isManager ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() async {
    // Start as unauthenticated for now
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final response = await _apiService.verifyAuth();
      if (response['success'] == true && response['user'] != null) {
        _user = User.fromJson(response['user']);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithEmailPassword(email, password);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _error = 'Invalid credentials';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmailPassword(String email, String password, String name, String phone) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final user = await _authService.signUpWithEmailPassword(email, password, name, phone);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _error = 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // For demo purposes - skip login
  void setDemoUser({bool isManager = false}) {
    _user = User(
      id: 1,
      email: isManager ? 'manager@dpcanteen.com' : 'demo@dpcanteen.com',
      name: isManager ? 'Demo Manager' : 'Demo User',
      phone: '9999999999',
      profilePicture: '',
      role: isManager ? 'manager' : 'customer',
      isActive: true,
      dateJoined: DateTime.now(),
      managedCanteenId: isManager ? 1 : null,
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    // Simplified - just use demo user
    setDemoUser();
    return true;
  }

  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshUser() async {
    await _loadUserData();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final updatedUser = await _apiService.updateProfile(data);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
