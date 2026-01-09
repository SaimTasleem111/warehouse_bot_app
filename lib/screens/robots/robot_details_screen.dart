import 'package:flutter/material.dart';
import '../../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/section_title.dart';

class RobotDetailsScreen extends StatefulWidget {
  final String robotId;

  const RobotDetailsScreen({super.key, required this.robotId});

  @override
  State<RobotDetailsScreen> createState() => _RobotDetailsScreenState();
}

class _RobotDetailsScreenState extends State<RobotDetailsScreen> {
  bool loading = true;
  Map robot = {};
  Map latestLog = {};

  Future<void> fetchDetails() async {
    try {
      final token = await TokenStorage.getToken() ?? "";

      final robotRes = await ApiClient.get("/api/fetch-robots", token);
      List robotsList = robotRes["data"] ?? [];

      robot = robotsList.firstWhere(
        (r) => r["robotId"].toString() == widget.robotId,
        orElse: () => {},
      );

      final logRes = await ApiClient.get(
        "/api/get-robot-logs?robotId=${widget.robotId}",
        token,
      );

      latestLog = logRes["data"] != null && logRes["data"].isNotEmpty
          ? logRes["data"][0]
          : {};

      if (mounted) setState(() => loading = false);
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Color getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case "busy":
      case "working":
        return AppTheme.success;
      case "idle":
        return AppTheme.primary;
      case "charging":
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }

  IconData getBatteryIcon(int level) {
    if (level < 30) return Icons.battery_alert;
    if (level >= 80) return Icons.battery_full;
    return Icons.battery_std;
  }

  Color getBatteryColor(int level) {
    if (level < 30) return AppTheme.error;
    if (level >= 80) return AppTheme.success;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    final status = robot["status"]?.toString() ?? "unknown";
    final battery = robot["batteryLevel"] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          robot["name"] ?? "Robot Details",
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: fetchDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _robotHeader(status, battery),
                    const SizedBox(height: 24),

                    const SectionTitle(title: "Robot Information"),
                    const SizedBox(height: 12),
                    _infoCard(icon: Icons.tag, title: "Robot ID", value: widget.robotId),
                    _infoCard(icon: Icons.settings, title: "Model", value: robot["model"] ?? "Unknown"),
                    _infoCard(
                      icon: Icons.circle,
                      title: "Status",
                      value: status,
                      valueColor: getStatusColor(status),
                    ),
                    _infoCard(
                      icon: getBatteryIcon(battery),
                      title: "Battery Level",
                      value: "$battery%",
                      valueColor: getBatteryColor(battery),
                    ),
                    _infoCard(icon: Icons.work, title: "Current Job", value: robot["currentJob"]?.toString() ?? "None"),

                    const SizedBox(height: 24),
                    const SectionTitle(title: "Live Position"),
                    const SizedBox(height: 12),
                    _positionCard(),

                    const SizedBox(height: 24),
                    const SectionTitle(title: "System Metrics"),
                    const SizedBox(height: 12),
                    _infoCard(icon: Icons.warning_amber, title: "Error Rate", value: robot["errorRate"]?.toString() ?? "0%"),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _robotHeader(String status, int battery) {
    Color statusColor = getStatusColor(status);

    return CustomCard(
      padding: const EdgeInsets.all(20),
      borderColor: statusColor.withOpacity(0.2),
      boxShadow: [
        BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 16),
      ],
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Icon(Icons.smart_toy, size: 40, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robot["name"] ?? "Unknown Robot",
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  robot["model"] ?? "",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          StatusBadge(status: status, customColor: statusColor),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: valueColor ?? AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionCard() {
    final posX = latestLog["position"]?["x"]?.toString() ?? "N/A";
    final posY = latestLog["position"]?["y"]?.toString() ?? "N/A";
    final timestamp = latestLog["timestamp"]?.toString() ?? "Unknown";

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.error, size: 28),
                    const SizedBox(height: 8),
                    const Text("X Position", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(posX, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: AppTheme.borderColor),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.error, size: 28),
                    const SizedBox(height: 8),
                    const Text("Y Position", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(posY, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.update, size: 16, color: AppTheme.textTertiary),
              const SizedBox(width: 6),
              Text("Last updated: $timestamp", style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}