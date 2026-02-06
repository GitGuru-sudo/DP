import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/order.dart';
import 'package:dp_canteen/services/payment_service.dart';
import 'package:dp_canteen/screens/customer/qr_display_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _selectedUpiApp;

  final List<Map<String, dynamic>> _upiApps = [
    {'name': 'Google Pay', 'package': 'com.google.android.apps.nbu.paisa.user', 'icon': Icons.payment},
    {'name': 'PhonePe', 'package': 'com.phonepe.app', 'icon': Icons.phone_android},
    {'name': 'Paytm', 'package': 'net.one97.paytm', 'icon': Icons.account_balance_wallet},
    {'name': 'BHIM', 'package': 'in.org.npci.upiapp', 'icon': Icons.account_balance},
    {'name': 'Other UPI', 'package': 'other', 'icon': Icons.qr_code},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(),
            const SizedBox(height: 24),
            // Payment Methods
            const Text(
              'Select Payment Method',
              style: TextStyle(
                
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // UPI Apps
            ..._upiApps.map((app) => _buildPaymentOption(app)),
            const SizedBox(height: 24),
            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedUpiApp != null && !_isProcessing
                    ? _processPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  disabledBackgroundColor: AppColors.grey300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Pay ₹${widget.order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryYellow),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'After successful payment, you will receive a QR code. Show this QR code to collect your order.',
                      style: TextStyle(
                        
                        fontSize: 13,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${widget.order.id}',
                  style: const TextStyle(
                    
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Order Items
          ...widget.order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.menuItemName}',
                    style: const TextStyle(
                      
                      color: AppColors.grey700,
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
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${widget.order.totalAmount.toStringAsFixed(2)}',
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

  Widget _buildPaymentOption(Map<String, dynamic> app) {
    final isSelected = _selectedUpiApp == app['package'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedUpiApp = app['package']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  app['icon'],
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  app['name'],
                  style: const TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryOrange,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Launch UPI payment
      final success = await _paymentService.initiateUpiPayment(
        orderId: widget.order.id.toString(),
        amount: widget.order.totalAmount,
        upiId: 'dpcanteen@upi', // Replace with actual UPI ID
      );

      if (success) {
        // Navigate to QR display screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QrDisplayScreen(order: widget.order),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed or cancelled. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
