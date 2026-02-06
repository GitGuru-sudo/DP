import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/providers/auth_provider.dart';
import 'package:dp_canteen/screens/customer/customer_home_screen.dart';
import 'package:dp_canteen/screens/manager/manager_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        Widget nextScreen;
        if (authProvider.isManager) {
          nextScreen = const ManagerHomeScreen();
        } else {
          nextScreen = const CustomerHomeScreen();
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else {
        _showError('Sign in was cancelled');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to sign in: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryOrange,
              AppColors.primaryYellow,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                // Logo and Welcome
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🍽️',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  'DP Canteen',
                  style: TextStyle(
                    
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order your favorite food from the\ncollege canteen with ease',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Features
                _buildFeature(Icons.restaurant_menu, 'Browse Menu'),
                const SizedBox(height: 12),
                _buildFeature(Icons.shopping_cart, 'Quick Order'),
                const SizedBox(height: 12),
                _buildFeature(Icons.qr_code, 'Easy Pickup'),
                const Spacer(),
                // Sign In Button
                _buildGoogleSignInButton(),
                const SizedBox(height: 16),
                const Text(
                  'By signing in, you agree to our\nTerms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.g_mobiledata, size: 24);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
