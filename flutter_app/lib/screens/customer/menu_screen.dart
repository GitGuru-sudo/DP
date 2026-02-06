import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/canteen.dart';
import 'package:dp_canteen/providers/cart_provider.dart';
import 'package:dp_canteen/services/api_service.dart';
import 'package:dp_canteen/widgets/menu_item_card.dart';
import 'package:dp_canteen/widgets/category_chip.dart';
import 'package:dp_canteen/widgets/loading_shimmer.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();
  
  List<Canteen> _canteens = [];
  Canteen? _selectedCanteen;
  List<Category> _categories = [];
  List<MenuItem> _menuItems = [];
  Category? _selectedCategory;
  String? _selectedFoodType;
  
  bool _isLoading = true;
  bool _isLoadingMenu = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCanteens();
  }

  Future<void> _loadCanteens() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _canteens = await _apiService.getCanteens();
      
      if (_canteens.isNotEmpty) {
        _selectedCanteen = _canteens.first;
        await _loadMenu();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMenu() async {
    if (_selectedCanteen == null) return;

    try {
      setState(() => _isLoadingMenu = true);

      _categories = await _apiService.getCategories(_selectedCanteen!.id);
      _menuItems = await _apiService.getMenu(
        _selectedCanteen!.id,
        categoryId: _selectedCategory?.id,
        foodType: _selectedFoodType,
      );
      
      // Set canteen in cart provider
      context.read<CartProvider>().setCanteen(
        _selectedCanteen!.id,
        _selectedCanteen!.name,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingMenu = false);
    }
  }

  List<MenuItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _menuItems;
    return _menuItems.where((item) =>
      item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (_canteens.length > 1) _buildCanteenSelector(),
            _buildCategoryFilter(),
            _buildFoodTypeFilter(),
            Expanded(child: _buildMenuList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryYellow],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DP Canteen',
                  style: TextStyle(
                    
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_selectedCanteen != null)
                  Row(
                    children: [
                      Icon(
                        _selectedCanteen!.isOpen 
                            ? Icons.check_circle 
                            : Icons.cancel,
                        color: _selectedCanteen!.isOpen 
                            ? Colors.greenAccent 
                            : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCanteen!.isOpen ? 'Open Now' : 'Closed',
                        style: const TextStyle(
                          
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search for food...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCanteenSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _canteens.length,
        itemBuilder: (context, index) {
          final canteen = _canteens[index];
          final isSelected = canteen.id == _selectedCanteen?.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCanteen = canteen;
                _selectedCategory = null;
              });
              _loadMenu();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primaryOrange : AppColors.grey300,
                ),
              ),
              child: Center(
                child: Text(
                  canteen.name,
                  style: TextStyle(
                    
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.grey700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: 'All',
              isSelected: _selectedCategory == null,
              onTap: () {
                setState(() => _selectedCategory = null);
                _loadMenu();
              },
            );
          }
          
          final category = _categories[index - 1];
          return CategoryChip(
            label: category.name,
            isSelected: category.id == _selectedCategory?.id,
            onTap: () {
              setState(() => _selectedCategory = category);
              _loadMenu();
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodTypeFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildFoodTypeChip(null, 'All', Icons.restaurant),
          _buildFoodTypeChip('veg', 'Veg', Icons.eco, AppColors.veg),
          _buildFoodTypeChip('non_veg', 'Non-Veg', Icons.restaurant_menu, AppColors.nonVeg),
          _buildFoodTypeChip('egg', 'Egg', Icons.egg, AppColors.egg),
        ],
      ),
    );
  }

  Widget _buildFoodTypeChip(String? type, String label, IconData icon, [Color? color]) {
    final isSelected = _selectedFoodType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFoodType = type);
        _loadMenu();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.primaryOrange) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color ?? AppColors.grey300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? Colors.white : (color ?? AppColors.grey600),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    if (_isLoading) {
      return const LoadingShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCanteens,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoadingMenu) {
      return const LoadingShimmer();
    }

    final items = _filteredItems;
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food, size: 48, color: AppColors.grey400),
            SizedBox(height: 16),
            Text('No items found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenu,
      color: AppColors.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return MenuItemCard(
            menuItem: items[index],
            onAddToCart: () {
              context.read<CartProvider>().addItem(items[index]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${items[index].name} added to cart'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
