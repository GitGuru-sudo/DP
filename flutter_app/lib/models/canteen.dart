class Canteen {
  final int id;
  final String name;
  final String description;
  final String location;
  final String? image;
  final String openingTime;
  final String closingTime;
  final String? upiId;
  final String? upiName;
  final bool isActive;
  final bool isOpen;
  final List<Category>? categories;
  final int? menuItemsCount;

  Canteen({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.image,
    required this.openingTime,
    required this.closingTime,
    this.upiId,
    this.upiName,
    required this.isActive,
    required this.isOpen,
    this.categories,
    this.menuItemsCount,
  });

  factory Canteen.fromJson(Map<String, dynamic> json) {
    List<Category>? categories;
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((c) => Category.fromJson(c))
          .toList();
    }

    return Canteen(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      image: json['image'],
      openingTime: json['opening_time'] ?? '08:00',
      closingTime: json['closing_time'] ?? '20:00',
      upiId: json['upi_id'],
      upiName: json['upi_name'],
      isActive: json['is_active'] ?? true,
      isOpen: json['is_open'] ?? false,
      categories: categories,
      menuItemsCount: json['menu_items_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'image': image,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'upi_id': upiId,
      'upi_name': upiName,
      'is_active': isActive,
      'is_open': isOpen,
    };
  }
}

class Category {
  final int id;
  final int? canteenId;
  final String name;
  final String description;
  final String? image;
  final int displayOrder;
  final bool isActive;
  final List<MenuItem>? items;
  final int? itemsCount;

  Category({
    required this.id,
    this.canteenId,
    required this.name,
    required this.description,
    this.image,
    required this.displayOrder,
    required this.isActive,
    this.items,
    this.itemsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<MenuItem>? items;
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((i) => MenuItem.fromJson(i))
          .toList();
    }

    return Category(
      id: json['id'] ?? 0,
      canteenId: json['canteen'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      items: items,
      itemsCount: json['items_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canteen': canteenId,
      'name': name,
      'description': description,
      'image': image,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}

enum FoodType { veg, nonVeg, egg }

class MenuItem {
  final int id;
  final int canteenId;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final String description;
  final double price;
  final String? image;
  final FoodType foodType;
  final bool isAvailable;
  final bool isActive;
  final int prepTime;
  final int displayOrder;

  MenuItem({
    required this.id,
    required this.canteenId,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.foodType,
    required this.isAvailable,
    required this.isActive,
    required this.prepTime,
    required this.displayOrder,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    FoodType foodType;
    switch (json['food_type']) {
      case 'non_veg':
        foodType = FoodType.nonVeg;
        break;
      case 'egg':
        foodType = FoodType.egg;
        break;
      default:
        foodType = FoodType.veg;
    }

    return MenuItem(
      id: json['id'] ?? 0,
      canteenId: json['canteen'] ?? 0,
      categoryId: json['category'],
      categoryName: json['category_name'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      foodType: foodType,
      isAvailable: json['is_available'] ?? true,
      isActive: json['is_active'] ?? true,
      prepTime: json['prep_time'] ?? 10,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    String foodTypeStr;
    switch (foodType) {
      case FoodType.nonVeg:
        foodTypeStr = 'non_veg';
        break;
      case FoodType.egg:
        foodTypeStr = 'egg';
        break;
      default:
        foodTypeStr = 'veg';
    }

    return {
      'id': id,
      'canteen': canteenId,
      'category': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'food_type': foodTypeStr,
      'is_available': isAvailable,
      'is_active': isActive,
      'prep_time': prepTime,
      'display_order': displayOrder,
    };
  }
}
