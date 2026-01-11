import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/section_title.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/settings_bottom_sheet.dart';
import '../../helperFunction/logout_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool loading = true;
  List products = [];
  List filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  
  int page = 1;
  int totalPages = 1;
  int totalProducts = 0;
  int totalItems = 0;
  int totalCategories = 0;
  int outOfStockItems = 0;

  Future<void> fetchAllProductsForStats() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/products?limit=1000", token);
      
      if (mounted) {
        List allProducts = res["products"] ?? [];
        Set<String> uniqueCategories = {};
        int outOfStock = 0;
        
        for (var item in allProducts) {
          String category = item["category"]?.toString() ?? "Unknown";
          uniqueCategories.add(category);
          int quantity = item["quantity"] ?? 0;
          if (quantity == 0) outOfStock++;
        }
        
        setState(() {
          totalItems = allProducts.length;
          totalCategories = uniqueCategories.length;
          outOfStockItems = outOfStock;
        });
      }
    } catch (e) {
      print("Error fetching all products: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/products?page=$page&limit=10", token);
      if (mounted) {
        setState(() {
          products = res["products"] ?? [];
          filteredProducts = products;
          totalPages = res["pages"] ?? 1;
          totalProducts = res["total"] ?? 0;
          loading = false;
        });
      }
    } catch (e) {
      print("Inventory fetch error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllProductsForStats();
    fetchProducts();
    searchController.addListener(() {
      filterProducts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => filteredProducts = products);
      return;
    }
    setState(() {
      filteredProducts = products.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? "";
        final category = item["category"]?.toString().toLowerCase() ?? "";
        return name.contains(query.toLowerCase()) || category.contains(query.toLowerCase());
      }).toList();
    });
  }

  String getStockStatus(int quantity) {
    if (quantity == 0) return "Out of Stock";
    if (quantity < 10) return "Low Stock";
    return "In Stock";
  }

  Color getStockStatusColor(int quantity) {
    if (quantity == 0) return AppTheme.error;
    if (quantity < 10) return AppTheme.warning;
    return AppTheme.success;
  }

  void changePage(int newPage) {
    if (newPage >= 1 && newPage <= totalPages) {
      setState(() {
        page = newPage;
        loading = true;
      });
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        title: const GradientText(text: "Inventory", fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
            tooltip: "Settings",
            onPressed: () => SettingsBottomSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            tooltip: "Logout",
            onPressed: () => LogoutHelper.showLogoutDialog(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Manage your product catalog",
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
                          ),
                          const SizedBox(height: 20),
                          _statsCards(),
                          const SizedBox(height: 20),
                          CustomSearchBar(
                            controller: searchController,
                            hintText: "Search products...",
                          ),
                          const SizedBox(height: 20),
                          const SectionTitle(title: "Products"),
                          const SizedBox(height: 12),
                          ...filteredProducts.isEmpty
                              ? [
                                  const EmptyState(
                                    icon: Icons.inventory_2_outlined,
                                    message: "No products found",
                                    submessage: "Try adjusting your search criteria",
                                  )
                                ]
                              : filteredProducts.map((item) => _inventoryCard(item)).toList(),
                        ],
                      ),
                    ),
                  ),
                  _pagination(),
                ],
              ),
            ),
    );
  }

  Widget _statsCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Total Items",
            value: totalItems.toString(),
            icon: Icons.inventory_2,
            accentColor: AppTheme.primary,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: "Categories",
            value: totalCategories.toString(),
            icon: Icons.category,
            accentColor: AppTheme.purple,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: "Out of Stock",
            value: outOfStockItems.toString(),
            icon: Icons.warning_rounded,
            accentColor: AppTheme.error,
            isCompact: true,
          ),
        ),
      ],
    );
  }

  Widget _inventoryCard(item) {
    final quantity = item["quantity"] ?? 0;
    final status = getStockStatus(quantity);
    final statusColor = getStockStatusColor(quantity);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"] ?? "Unnamed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Category: ${item["category"] ?? "Unknown"}",
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: status, customColor: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quantity Available",
                style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page $page of $totalPages",
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: page > 1 ? () => changePage(page - 1) : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: page > 1 ? AppTheme.primary : AppTheme.textTertiary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              if (totalPages <= 5)
                ...List.generate(totalPages, (index) {
                  int pageNumber = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => changePage(pageNumber),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: page == pageNumber
                              ? AppTheme.primary
                              : AppTheme.surfaceLight(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: page == pageNumber
                                ? Colors.white
                                : AppTheme.textSecondary(context),
                            fontSize: 13,
                            fontWeight: page == pageNumber
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(width: 8),
              IconButton(
                onPressed: page < totalPages ? () => changePage(page + 1) : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: page < totalPages ? AppTheme.primary : AppTheme.textTertiary(context),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}