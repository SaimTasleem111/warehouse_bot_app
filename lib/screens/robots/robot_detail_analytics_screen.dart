import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/section_title.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class RobotDetailAnalyticsScreen extends StatefulWidget {
  final Map robot;

  const RobotDetailAnalyticsScreen({super.key, required this.robot});

  @override
  State<RobotDetailAnalyticsScreen> createState() =>
      _RobotDetailAnalyticsScreenState();
}

class _RobotDetailAnalyticsScreenState
    extends State<RobotDetailAnalyticsScreen> {
  bool loading = true;
  List robotLogs = [];

  // Changed return type from void to Future<void>
  Future<void> fetchRobotLogs() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final logsRes = await ApiClient.get("/api/get-robot-logs", token);

      if (mounted) {
        String robotId = widget.robot["robotId"]?.toString() ?? "";
        setState(() {
          robotLogs = (logsRes["data"] ?? [])
              .where((log) => log["robotId"] == robotId)
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Logs fetch error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRobotLogs();
  }

  int get tasksCompleted => robotLogs
      .where((log) =>
          log["status"]?.toString().toLowerCase() == "free" ||
          (log["message"]?.toString().toLowerCase().contains("completed") ?? false))
      .length;

  int get errorCount => robotLogs
      .where((log) => log["status"]?.toString().toLowerCase() == "error")
      .length;

  double get errorRate {
    if (robotLogs.isEmpty) return 0;
    return (errorCount / robotLogs.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.robot["status"]?.toString() ?? "Unknown";
    final name = widget.robot["name"]?.toString() ?? "Robot";
    final battery = widget.robot["batteryLevel"] ?? 0;

    Color statusColor = _getStatusColor(status);

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
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const LoadingIndicator(message: "Loading robot analytics...")
          : SafeArea(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                onRefresh: fetchRobotLogs,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _robotInfoHeader(statusColor),
                      const SizedBox(height: 24),

                      const SectionTitle(title: "Performance Metrics"),
                      const SizedBox(height: 12),
                      _statsSection(battery),
                      const SizedBox(height: 24),

                      const SectionTitle(title: "Activity Trend"),
                      const SizedBox(height: 12),
                      _activityGraph(),
                      const SizedBox(height: 24),

                      const SectionTitle(title: "Recent Activity Logs"),
                      const SizedBox(height: 12),
                      _logsSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _robotInfoHeader(Color statusColor) {
    final status = widget.robot["status"]?.toString() ?? "Unknown";
    final robotId = widget.robot["robotId"]?.toString() ?? "N/A";
    final model = widget.robot["model"]?.toString() ?? "N/A";

    return CustomCard(
      padding: const EdgeInsets.all(20),
      borderColor: statusColor.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.smart_toy, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robotId,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: status, customColor: statusColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection(int battery) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Battery Level",
                value: "$battery%",
                icon: Icons.battery_charging_full,
                accentColor: AppTheme.success,
                subtitle: "Runtime: ${(battery / 12.5).toStringAsFixed(0)}h",
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Error Rate",
                value: "${errorRate.toStringAsFixed(1)}%",
                icon: Icons.error_outline,
                accentColor: AppTheme.error,
                subtitle: errorCount > 0 ? "Last: 2h ago" : "No errors",
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          title: "Tasks Completed Today",
          value: tasksCompleted.toString(),
          icon: Icons.task_alt,
          accentColor: AppTheme.primary,
          subtitle: "Avg time: 8 min",
        ),
      ],
    );
  }

  Widget _activityGraph() {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    robotLogs.length.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    "Total Activities",
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "+15% Today",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.borderColor, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const times = ['8AM', '12PM', '4PM', '8PM'];
                        if (value.toInt() >= 0 && value.toInt() < times.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              times[value.toInt()],
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 1.5),
                      FlSpot(2, 4),
                      FlSpot(3, 3.5),
                    ],
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.2),
                          AppTheme.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logsSection() {
    if (robotLogs.isEmpty) {
      return const EmptyState(icon: Icons.history, message: "No activity logs available");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: robotLogs.length > 10 ? 10 : robotLogs.length,
      itemBuilder: (context, i) {
        final log = robotLogs[i];
        final status = log["status"]?.toString() ?? "Unknown";
        final message = log["message"]?.toString() ?? "No message";
        final timestamp = log["timestamp"]?.toString() ?? "";

        Color dotColor = status.toLowerCase() == "error"
            ? AppTheme.error
            : status.toLowerCase() == "free"
                ? AppTheme.success
                : AppTheme.primary;

        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status: $status • $timestamp",
                      style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "busy":
      case "working":
        return AppTheme.success;
      case "idle":
      case "free":
        return AppTheme.primary;
      case "charging":
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }
}