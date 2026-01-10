import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import 'robot_detail_analytics_screen.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/settings_bottom_sheet.dart';
import '../auth/login_screen.dart';

class RobotAnalyticsScreen extends StatefulWidget {
  const RobotAnalyticsScreen({super.key});

  @override
  State<RobotAnalyticsScreen> createState() => _RobotAnalyticsScreenState();
}

class _RobotAnalyticsScreenState extends State<RobotAnalyticsScreen> {
  bool loading = true;
  List robots = [];

  Future<void> fetchRobots() async {
    setState(() => loading = true);
    try {
      final token = await TokenStorage.getToken() ?? "";
      final robotRes = await ApiClient.get("/api/fetch-robots", token);

      if (mounted) {
        setState(() {
          robots = robotRes["data"] ?? [];
          loading = false;
        });
      }
    } catch (e) {
      print("Robot analytics fetch error: $e");
      if (mounted) setState(() => loading = false);
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
    fetchRobots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        title: const GradientText(text: "Robot Analytics", fontSize: 20, fontWeight: FontWeight.bold),
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
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monitor fleet performance and health",
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
                    ),
                    const SizedBox(height: 20),

                    robots.isEmpty
                        ? const EmptyState(
                            icon: Icons.smart_toy_outlined,
                            message: "No robots available",
                            submessage: "Robots will appear here when they're registered",
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.80,
                            ),
                            itemCount: robots.length,
                            itemBuilder: (context, index) {
                              return _robotCard(robots[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _robotCard(Map robot) {
    final status = robot["status"]?.toString() ?? "Unknown";
    final name = robot["name"]?.toString() ?? "Robot";
    final robotId = robot["robotId"]?.toString() ?? "N/A";
    final battery = robot["batteryLevel"] ?? 0;

    Color statusColor = _getStatusColor(status);

    return CustomCard(
      padding: const EdgeInsets.all(16),
      borderColor: statusColor.withOpacity(0.2),
      boxShadow: [
        BoxShadow(
          color: statusColor.withOpacity(0.1),
          blurRadius: 12,
        ),
      ],
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => RobotDetailAnalyticsScreen(robot: robot),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.smart_toy, color: statusColor, size: 28),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "ID: $robotId",
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
          ),

          const SizedBox(height: 12),

          StatusBadge(status: status, customColor: statusColor),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                battery > 50
                    ? Icons.battery_full
                    : battery > 20
                        ? Icons.battery_std
                        : Icons.battery_alert,
                size: 16,
                color: battery > 50
                    ? AppTheme.success
                    : battery > 20
                        ? AppTheme.warning
                        : AppTheme.error,
              ),
              const SizedBox(width: 6),
              Text(
                "$battery%",
                style: TextStyle(
                  fontSize: 12,
                  color: battery > 50
                      ? AppTheme.success
                      : battery > 20
                          ? AppTheme.warning
                          : AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "busy":
      case "working":
        return AppTheme.success;
      case "idle":
        return AppTheme.primary;
      case "charging":
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary(context);
    }
  }
}