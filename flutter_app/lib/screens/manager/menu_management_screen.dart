import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/canteen.dart';
import 'package:dp_canteen/services/api_service.dart';
import 'package:dp_canteen/widgets/loading_shimmer.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final ApiService _apiService = ApiService();
  List<MenuItem> _menuItems = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Using canteen ID 1 as default - in production, get from auth provider
      final categories = await _apiService.getCategories(1);
      final menuItems = await _apiService.getMenuItems();
      
      setState(() {
        _categories = categories;
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategoryId == null) return _menuItems;
    return _menuItems
        .where((item) => item.categoryId == _selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Menu Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: AppColors.primaryOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Category filter
                    _buildCategoryFilter(),
                    // Menu items list
                    Expanded(child: _buildMenuList()),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(height: 100),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', null);
          }
          final category = _categories[index - 1];
          return _buildCategoryChip(category.name, category.id);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, int? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = categoryId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.grey700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: AppColors.grey300),
            const SizedBox(height: 16),
            const Text(
              'No menu items found',
              style: TextStyle(
                
                fontSize: 16,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildManageableMenuItem(item);
        },
      ),
    );
  }

  Widget _buildManageableMenuItem(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.grey100,
                  ),
                  child: item.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
                // Food type indicator
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: item.foodType == 'veg' ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.foodType == 'veg' ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: item.isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                Switch(
                  value: item.isAvailable,
                  activeColor: AppColors.primaryOrange,
                  onChanged: (value) => _toggleAvailability(item, value),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.grey600,
                  onPressed: () => _showEditItemDialog(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 32,
        color: AppColors.grey300,
      ),
    );
  }

  Future<void> _toggleAvailability(MenuItem item, bool value) async {
    try {
      await _apiService.updateMenuItem(item.id, {'is_available': value});
      setState(() {
        final index = _menuItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _menuItems[index] = MenuItem(
            id: item.id,
            name: item.name,
            description: item.description,
            price: item.price,
            image: item.image,
            categoryId: item.categoryId,
            categoryName: item.categoryName,
            canteenId: item.canteenId,
            foodType: item.foodType,
            isAvailable: value,
            isActive: item.isActive,
            prepTime: item.prepTime,
            displayOrder: item.displayOrder,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? '${item.name} is now available' : '${item.name} is now unavailable',
          ),
          backgroundColor: value ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddItemDialog() {
    _showItemDialog(null);
  }

  void _showEditItemDialog(MenuItem item) {
    _showItemDialog(item);
  }

  void _showItemDialog(MenuItem? item) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(
      text: item?.price.toStringAsFixed(2) ?? '',
    );
    String foodType = item != null ? (item.foodType == FoodType.veg ? 'veg' : item.foodType == FoodType.nonVeg ? 'non_veg' : 'egg') : 'veg';
    int? categoryId = item?.categoryId;
    bool isAvailable = item?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => categoryId = v),
                ),
                const SizedBox(height: 16),
                const Text('Food Type'),
                Row(
                  children: [
                    Radio<String>(
                      value: 'veg',
                      groupValue: foodType,
                      onChanged: (v) => setDialogState(() => foodType = v!),
                      activeColor: Colors.green,
                    ),
                    const Text('Veg'),
                    Radio<String>(
                      value: 'non-veg',
                      groupValue: foodType,
                      onChanged: (v) => setDialogState(() => foodType = v!),
                      activeColor: Colors.red,
                    ),
                    const Text('Non-Veg'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isAvailable,
                      onChanged: (v) => setDialogState(() => isAvailable = v!),
                      activeColor: AppColors.primaryOrange,
                    ),
                    const Text('Available'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  return;
                }
                
                final data = {
                  'name': nameController.text,
                  'description': descController.text,
                  'price': double.parse(priceController.text),
                  'category': categoryId,
                  'food_type': foodType,
                  'is_available': isAvailable,
                };

                try {
                  if (item == null) {
                    await _apiService.createMenuItem(data);
                  } else {
                    await _apiService.updateMenuItem(item.id, data);
                  }
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(item == null ? 'Item added' : 'Item updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: Text(
                item == null ? 'Add' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
