enum OrderStatus {
  pending,
  paid,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

class Order {
  final int id;
  final String orderId;
  final int userId;
  final String? userEmail;
  final String? userName;
  final int canteenId;
  final String? canteenName;
  final OrderStatus status;
  final String statusDisplay;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final String? specialInstructions;
  final bool qrCodeUsed;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  
  // Alias getters for compatibility
  String? get customerName => userName;
  String? get estimatedTime => null; // TODO: Add from backend

  Order({
    required this.id,
    required this.orderId,
    required this.userId,
    this.userEmail,
    this.userName,
    required this.canteenId,
    this.canteenName,
    required this.status,
    required this.statusDisplay,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    this.specialInstructions,
    required this.qrCodeUsed,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.confirmedAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderStatus status;
    switch (json['status']) {
      case 'paid':
        status = OrderStatus.paid;
        break;
      case 'confirmed':
        status = OrderStatus.confirmed;
        break;
      case 'preparing':
        status = OrderStatus.preparing;
        break;
      case 'ready':
        status = OrderStatus.ready;
        break;
      case 'completed':
        status = OrderStatus.completed;
        break;
      case 'cancelled':
        status = OrderStatus.cancelled;
        break;
      default:
        status = OrderStatus.pending;
    }

    List<OrderItem> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList();
    }

    return Order(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      userId: json['user'] ?? 0,
      userEmail: json['user_email'],
      userName: json['user_name'],
      canteenId: json['canteen'] ?? 0,
      canteenName: json['canteen_name'],
      status: status,
      statusDisplay: json['status_display'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      specialInstructions: json['special_instructions'],
      qrCodeUsed: json['qr_code_used'] ?? false,
      items: items,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  bool get isPending => status == OrderStatus.pending;
  bool get isPaid => status == OrderStatus.paid;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.paid;
  bool get needsPayment => status == OrderStatus.pending;
  bool get showQR => status == OrderStatus.paid && !qrCodeUsed;
}

class OrderItem {
  final int id;
  final int? menuItemId;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final String? specialInstructions;
  final double totalPrice;
  
  // Alias getters for compatibility
  String get menuItemName => itemName;
  double get price => itemPrice;

  OrderItem({
    required this.id,
    this.menuItemId,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    this.specialInstructions,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      menuItemId: json['menu_item'],
      itemName: json['item_name'] ?? '',
      itemPrice: (json['item_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['special_instructions'],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}
