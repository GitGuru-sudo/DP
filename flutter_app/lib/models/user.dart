class User {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String profilePicture;
  final String role;
  final bool isActive;
  final DateTime dateJoined;
  final int? managedCanteenId;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.role,
    required this.isActive,
    required this.dateJoined,
    this.managedCanteenId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      role: json['role'] ?? 'customer',
      isActive: json['is_active'] ?? true,
      dateJoined: DateTime.parse(json['date_joined'] ?? DateTime.now().toIso8601String()),
      managedCanteenId: json['managed_canteen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profile_picture': profilePicture,
      'role': role,
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
      'managed_canteen': managedCanteenId,
    };
  }

  bool get isCustomer => role == 'customer';
  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';
  
  // Alias getter for compatibility
  String? get profileImage => profilePicture.isNotEmpty ? profilePicture : null;

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? profilePicture,
    String? role,
    bool? isActive,
    DateTime? dateJoined,
    int? managedCanteenId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined ?? this.dateJoined,
      managedCanteenId: managedCanteenId ?? this.managedCanteenId,
    );
  }
}
