import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/section_title.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/settings_bottom_sheet.dart';
import '../../helperFunction/logout_helper.dart';

class JobTrackingScreen extends StatefulWidget {
  const JobTrackingScreen({super.key});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  bool loading = true;
  List allJobs = [];
  bool showPendingExpanded = true;

  Future<void> fetchJobs() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final res = await ApiClient.getJobs(token: token);

      if (mounted) {
        setState(() {
          allJobs = res["data"] ?? [];
          loading = false;
        });
      }
    } catch (e) {
      print("Jobs fetch error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  List get pendingJobs => allJobs
      .where((j) =>
          j["status"]?.toString().toLowerCase() == "pending" ||
          j["status"]?.toString().toLowerCase() == "queued")
      .toList();

  List get inProgressJobs => allJobs
      .where((j) => j["status"]?.toString().toLowerCase() == "in_progress")
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        title: const GradientText(text: "Job Tracking", fontSize: 20, fontWeight: FontWeight.bold),
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
          ? const LoadingIndicator(message: "Loading jobs...")
          : SafeArea(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface(context),
                onRefresh: fetchJobs,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pendingJobsSection(),
                      const SizedBox(height: 24),
                      const SectionTitle(title: "Jobs In Progress"),
                      const SizedBox(height: 12),
                      if (inProgressJobs.isEmpty)
                        const EmptyState(
                          icon: Icons.work_outline,
                          message: "No jobs in progress",
                        )
                      else
                        ..._buildProgressJobs(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _pendingJobsSection() {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showPendingExpanded = !showPendingExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pending_actions,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Pending Jobs",
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pendingJobs.length.toString(),
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    showPendingExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary(context),
                  ),
                ],
              ),
            ),
          ),
          if (showPendingExpanded) ...[
            Divider(color: AppTheme.borderColor(context), height: 1),
            if (pendingJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "No pending jobs",
                  style: TextStyle(color: AppTheme.textSecondary(context)),
                ),
              )
            else
              ...pendingJobs.map((job) => _pendingJobItem(job)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _pendingJobItem(Map job) {
    String jobId = job["_id"]?.toString().substring(job["_id"].toString().length - 6) ?? "N/A";
    String robot = job["assignedRobot"]?.toString() ?? "Unassigned";
    String status = job["status"]?.toString() ?? "Unknown";
    List items = job["items"] ?? [];
    String itemsDesc = items.isNotEmpty
        ? items.map((i) => "${i['name']} x${i['quantity']}").join(", ")
        : "No items";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderColor(context), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Job #$jobId",
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              StatusBadge(status: status, showDot: false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InfoChip(icon: Icons.precision_manufacturing, text: robot),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  itemsDesc,
                  style: TextStyle(
                    color: AppTheme.textTertiary(context),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProgressJobs() {
    return inProgressJobs.map((job) => _progressJobCard(job)).toList();
  }

  Widget _progressJobCard(Map job) {
    String jobId = job["_id"]?.toString().substring(job["_id"].toString().length - 6) ?? "N/A";
    int progress = job["completionPercentage"] ?? 0;
    String robot = job["assignedRobot"]?.toString() ?? "Unassigned";
    List items = job["items"] ?? [];

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
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
                child: const Icon(Icons.work, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Job #$jobId",
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const StatusBadge(status: "In Progress"),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress",
                    style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13),
                  ),
                  Text(
                    "$progress%",
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceLight(context),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppTheme.borderColor(context)),
          const SizedBox(height: 12),

          _jobDetailRow(Icons.precision_manufacturing, "Robot", robot),
          const SizedBox(height: 8),
          _jobDetailRow(
            Icons.inventory_2,
            "Items",
            items.isNotEmpty
                ? items.map((i) => "${i['name']} x${i['quantity']}").join(", ")
                : "No items",
          ),
        ],
      ),
    );
  }

  Widget _jobDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textTertiary(context), size: 16),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}