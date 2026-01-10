// ============================================
// lib/screens/orders/order_details_screen.dart - FIXED
// ============================================
import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/info_chip.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    String orderId = order["_id"]?.toString().substring(order["_id"].toString().length - 8).toUpperCase() ?? "N/A";
    String status = order["status"]?.toString() ?? "Unknown";
    List items = order["items"] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: GradientText(
          text: "Order #$orderId",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 48,
                      color: _getStatusColor(status, context), // ✅ FIXED - Pass context
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status, context), // ✅ FIXED - Pass context
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Order #$orderId",
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const SectionTitle(title: "Order Items"),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _itemCard(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context, item) {
    String name = item["name"]?.toString() ?? "Unknown Product";
    int quantity = item["quantity"] ?? 0;
    String category = item["category"]?.toString() ?? "N/A";

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InfoChip(icon: Icons.category, text: category),
                    const SizedBox(width: 10),
                    InfoChip(icon: Icons.numbers, text: "Qty: $quantity"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Icons.check_circle;
      case "pending":
        return Icons.hourglass_bottom;
      case "in transit":
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status, BuildContext context) { // ✅ FIXED - Added context parameter
    switch (status.toLowerCase()) {
      case "completed":
        return AppTheme.success;
      case "pending":
        return AppTheme.warning;
      case "in transit":
        return AppTheme.primary;
      default:
        return AppTheme.textTertiary(context); // ✅ Now works!
    }
  }
}