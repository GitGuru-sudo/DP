import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/services/api_service.dart';
import 'package:dp_canteen/screens/customer/customer_home_screen.dart';

class QrDisplayScreen extends StatefulWidget {
  final Order order;

  const QrDisplayScreen({super.key, required this.order});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final ApiService _apiService = ApiService();
  String? _encryptedQrData;
  bool _isLoading = true;
  String? _error;
  Timer? _expiryTimer;
  int _secondsRemaining = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQrCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final qrData = await _apiService.generateQrCode(widget.order.id);
      setState(() {
        _encryptedQrData = qrData['qr_code']?['data'] ?? qrData.toString();
        _isLoading = false;
        _secondsRemaining = 300;
      });
      _startExpiryTimer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Order QR Code'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Successful!',
                          style: TextStyle(
                            
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Show this QR code to collect your order',
                          style: TextStyle(
                            
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // QR Code Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Order ID
                  Text(
                    'Order #${widget.order.id}',
                    style: const TextStyle(
                      
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // QR Code
                  if (_isLoading)
                    const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    )
                  else if (_error != null)
                    _buildErrorState()
                  else if (_secondsRemaining <= 0)
                    _buildExpiredState()
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryOrange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: QrImageView(
                            data: _encryptedQrData!,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primaryOrange,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _secondsRemaining < 60
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 18,
                                color: _secondsRemaining < 60
                                    ? AppColors.error
                                    : AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expires in ${_formatTime(_secondsRemaining)}',
                                style: TextStyle(
                                  
                                  fontWeight: FontWeight.w600,
                                  color: _secondsRemaining < 60
                                      ? AppColors.error
                                      : AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Order Details
            _buildOrderDetails(),
            const SizedBox(height: 24),
            // Regenerate Button (if expired)
            if (_secondsRemaining <= 0 && !_isLoading)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _generateQrCode,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Generate New QR Code',
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
            const SizedBox(height: 16),
            // Home Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                  (route) => false,
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryOrange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 60, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          'Failed to generate QR code\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _generateQrCode,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildExpiredState() {
    return Column(
      children: [
        const Icon(Icons.timer_off, size: 60, color: AppColors.grey400),
        const SizedBox(height: 16),
        const Text(
          'QR Code Expired',
          style: TextStyle(
            
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the button below to generate a new one',
          textAlign: TextAlign.center,
          style: TextStyle(
            
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          ...widget.order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
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
                      
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${widget.order.totalAmount.toStringAsFixed(2)}',
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
    );
  }
}
