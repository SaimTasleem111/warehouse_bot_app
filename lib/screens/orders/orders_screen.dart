import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import 'order_details_screen.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/section_title.dart';
import '../../widgets/empty_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  List orders = [];
  int totalOrders = 0;
  int pendingOrders = 0;
  int page = 1;
  int totalPages = 1;

  fetchOrders() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.get("/api/orders?page=$page&limit=10", token);

      if (mounted) {
        setState(() {
          orders = res["orders"] ?? [];
          totalOrders = res["totalOrders"] ?? 0;
          totalPages = res["totalPages"] ?? 1;
          pendingOrders = orders.where((o) => o["status"] == "Pending").length;
          loading = false;
        });
      }
    } catch (e) {
      print("Orders fetch error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                          const PageHeader(
                            title: "Orders",
                            subtitle: "Track and manage warehouse orders",
                          ),
                          const SizedBox(height: 20),
                          _statsCards(),
                          const SizedBox(height: 20),
                          const SectionTitle(title: "Recent Orders"),
                          const SizedBox(height: 12),
                          _ordersList(),
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
            title: "Pending Orders",
            value: pendingOrders.toString(),
            icon: Icons.hourglass_bottom,
            accentColor: AppTheme.warning,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: "Total Orders",
            value: totalOrders.toString(),
            icon: Icons.receipt_long,
            accentColor: AppTheme.primary,
            isCompact: true,
          ),
        ),
      ],
    );
  }

  Widget _ordersList() {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_outlined,
        message: "No orders found",
        submessage: "Orders will appear here when created",
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _orderCard(order);
      },
    );
  }

  Widget _orderCard(order) {
    String orderId = order["_id"]?.toString().substring(order["_id"].toString().length - 8).toUpperCase() ?? "N/A";
    String status = order["status"]?.toString() ?? "Unknown";
    int itemCount = (order["items"] as List?)?.length ?? 0;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #$orderId",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$itemCount item${itemCount != 1 ? 's' : ''}",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusBadge(status: status),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _pagination() {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Page $page of $totalPages",
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed: page > 1 ? () {
                  setState(() => page--);
                  fetchOrders();
                } : null,
                icon: const Icon(Icons.chevron_left),
                color: page > 1 ? AppTheme.primary : AppTheme.textTertiary,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: page < totalPages ? () {
                  setState(() => page++);
                  fetchOrders();
                } : null,
                icon: const Icon(Icons.chevron_right),
                color: page < totalPages ? AppTheme.primary : AppTheme.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}