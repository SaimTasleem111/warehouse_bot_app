import 'package:flutter/material.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../../api_client.dart';
import '../robots/robot_details_screen.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_title.dart';
import '../../widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool loading = true;
  List robots = [];
  int totalOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int inTransitOrders = 0;

  // Changed return type from void to Future<void>
  Future<void> fetchData() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final robotRes = await ApiClient.get("/api/fetch-robots", token);
      final orderRes = await ApiClient.get("/api/orders?limit=1000", token);

      if (mounted) {
        final allOrders = orderRes["orders"] ?? [];

        setState(() {
          robots = robotRes["data"] ?? [];
          totalOrders = orderRes["totalOrders"] ?? allOrders.length;
          pendingOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "pending").length;
          completedOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "completed").length;
          inTransitOrders = allOrders.where((o) => o["status"]?.toString().toLowerCase() == "in transit").length;
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Dashboard fetch error: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: loading
          ? const LoadingIndicator(message: "Loading dashboard...")
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: fetchData,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageHeader(
                        title: "Dashboard",
                        subtitle: "Real-time warehouse monitoring",
                      ),
                      const SizedBox(height: 20),
                      _quickStats(),
                      const SizedBox(height: 28),
                      const SectionTitle(title: "Active Robots"),
                      const SizedBox(height: 16),
                      _robotsList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _quickStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Active Robots",
                value: robots.length.toString(),
                icon: Icons.smart_toy,
                accentColor: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "In Transit",
                value: inTransitOrders.toString(),
                icon: Icons.local_shipping,
                accentColor: AppTheme.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Completed",
                value: completedOrders.toString(),
                icon: Icons.check_circle,
                accentColor: AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Pending",
                value: pendingOrders.toString(),
                icon: Icons.hourglass_bottom,
                accentColor: AppTheme.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _robotsList() {
    if (robots.isEmpty) {
      return const EmptyState(
        icon: Icons.smart_toy_outlined,
        message: "No active robots found",
        submessage: "Robots will appear here when they're online",
      );
    }

    return ListView.builder(
      itemCount: robots.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final r = robots[i];
        String status = r["status"] ?? "Unknown";
        String name = r["name"] ?? "Unknown";
        String model = r["model"] ?? "N/A";
        String robotId = r["robotId"] ?? "N/A";
        int battery = r["batteryLevel"] ?? 0;
        String currentJob = r["currentJob"]?.toString() ?? "None";

        Color statusColor;
        switch (status.toLowerCase()) {
          case "busy":
          case "working":
            statusColor = AppTheme.success;
            break;
          case "idle":
            statusColor = AppTheme.primary;
            break;
          default:
            statusColor = AppTheme.textTertiary;
        }

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderColor: statusColor.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RobotDetailsScreen(robotId: robotId),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Icon(Icons.smart_toy, size: 28, color: statusColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusBadge(status: status, customColor: statusColor),
                        const SizedBox(width: 10),
                        InfoChip(
                          icon: Icons.battery_std,
                          text: "$battery%",
                          color: battery > 50
                              ? AppTheme.success
                              : battery > 20
                                  ? AppTheme.warning
                                  : AppTheme.error,
                        ),
                      ],
                    ),
                    if (currentJob != "None") ...[
                      const SizedBox(height: 8),
                      Text(
                        "Job: $currentJob",
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}