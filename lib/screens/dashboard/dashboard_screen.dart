import 'package:flutter/material.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../api_client.dart';
import '../robots/robot_details_screen.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_title.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/settings_bottom_sheet.dart';
import '../auth/login_screen.dart';

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

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Logout", style: TextStyle(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to logout?", style: TextStyle(color: AppTheme.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await TokenStorage.clearToken();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (_) => false,
      );
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
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        title: const GradientText(text: "Dashboard", fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
            tooltip: "Settings",
            onPressed: () => SettingsBottomSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            tooltip: "Logout",
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: loading
          ? const LoadingIndicator(message: "Loading dashboard...")
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface(context),
              onRefresh: fetchData,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Real-time warehouse monitoring",
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
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
            statusColor = AppTheme.textTertiary(context);
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => RobotDetailsScreen(robotId: robotId),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
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
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model,
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
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
                        style: TextStyle(
                          color: AppTheme.textTertiary(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary(context),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}