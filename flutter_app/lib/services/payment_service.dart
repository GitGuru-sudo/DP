import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:dp_canteen/services/api_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final ApiService _apiService = ApiService();

  /// Initiate UPI payment for an order
  Future<UPIPaymentResult> initiateUPIPayment(String orderId) async {
    try {
      // Get UPI intent data from backend
      final response = await _apiService.initiatePayment(orderId);
      
      if (response['success'] != true) {
        return UPIPaymentResult(
          status: UPIPaymentStatus.failed,
          error: response['error'] ?? 'Failed to initiate payment',
        );
      }

      final upiIntent = response['upi_intent'];
      final upiUrl = upiIntent['upi_intent_url'] as String;

      // Try to launch UPI app
      final uri = Uri.parse(upiUrl);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return UPIPaymentResult(
            status: UPIPaymentStatus.launched,
            orderId: orderId,
            upiUrl: upiUrl,
            upiId: upiIntent['upi_id'],
            amount: upiIntent['amount'],
          );
        }
      }

      // If UPI app launch failed, return with fallback info
      return UPIPaymentResult(
        status: UPIPaymentStatus.noApp,
        orderId: orderId,
        upiUrl: upiUrl,
        upiId: upiIntent['upi_id'],
        payeeName: upiIntent['payee_name'],
        amount: upiIntent['amount'],
        transactionNote: upiIntent['transaction_note'],
      );
    } catch (e) {
      return UPIPaymentResult(
        status: UPIPaymentStatus.failed,
        error: e.toString(),
      );
    }
  }

  /// Confirm payment after UPI transaction
  Future<PaymentConfirmResult> confirmPayment(
    String orderId,
    String transactionId,
  ) async {
    try {
      final response = await _apiService.confirmPayment(orderId, transactionId);
      
      if (response['success'] == true) {
        return PaymentConfirmResult(
          success: true,
          qrCode: response['qr_code']?['data'],
          qrExpiresAt: response['qr_code']?['expires_at'],
        );
      } else {
        return PaymentConfirmResult(
          success: false,
          error: response['message'] ?? 'Payment confirmation failed',
        );
      }
    } catch (e) {
      return PaymentConfirmResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get QR code for an order
  Future<QRCodeResult> getOrderQR(String orderId) async {
    try {
      final response = await _apiService.getOrderQR(orderId);
      
      if (response['success'] == true) {
        return QRCodeResult(
          success: true,
          qrData: response['qr_code']['data'],
          expiresAt: DateTime.parse(response['qr_code']['expires_at']),
          isExpired: response['qr_code']['is_expired'] ?? false,
        );
      } else {
        return QRCodeResult(
          success: false,
          error: response['error'] ?? 'Failed to get QR code',
        );
      }
    } catch (e) {
      return QRCodeResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Check if UPI apps are available on the device
  Future<bool> hasUPIApps() async {
    final testUrl = Uri.parse('upi://pay?pa=test@upi');
    return await canLaunchUrl(testUrl);
  }

  /// Get list of available UPI apps (Android only)
  List<String> getPopularUPIApps() {
    if (Platform.isAndroid) {
      return [
        'Google Pay',
        'PhonePe',
        'Paytm',
        'BHIM',
        'Amazon Pay',
        'WhatsApp Pay',
      ];
    } else if (Platform.isIOS) {
      return [
        'Google Pay',
        'PhonePe',
        'Paytm',
        'BHIM',
      ];
    }
    return [];
  }
  
  /// Alias method for compatibility - case insensitive usage
  Future<bool> initiateUpiPayment({
    required String orderId,
    required double amount,
    String? upiId,
  }) async {
    final result = await initiateUPIPayment(orderId);
    return result.status == UPIPaymentStatus.launched;
  }
}

enum UPIPaymentStatus {
  launched,
  noApp,
  failed,
}

class UPIPaymentResult {
  final UPIPaymentStatus status;
  final String? orderId;
  final String? upiUrl;
  final String? upiId;
  final String? payeeName;
  final String? amount;
  final String? transactionNote;
  final String? error;

  UPIPaymentResult({
    required this.status,
    this.orderId,
    this.upiUrl,
    this.upiId,
    this.payeeName,
    this.amount,
    this.transactionNote,
    this.error,
  });
}

class PaymentConfirmResult {
  final bool success;
  final String? qrCode;
  final String? qrExpiresAt;
  final String? error;

  PaymentConfirmResult({
    required this.success,
    this.qrCode,
    this.qrExpiresAt,
    this.error,
  });
}

class QRCodeResult {
  final bool success;
  final String? qrData;
  final DateTime? expiresAt;
  final bool isExpired;
  final String? error;

  QRCodeResult({
    required this.success,
    this.qrData,
    this.expiresAt,
    this.isExpired = false,
    this.error,
  });
}
