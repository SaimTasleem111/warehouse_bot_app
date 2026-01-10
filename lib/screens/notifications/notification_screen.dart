import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  List<Map<String, dynamic>> notifications = [];

  Future<void> fetchNotifications() async {
    setState(() => loading = true);

    try {
      final token = await TokenStorage.getToken() ?? "";
      final userId = await TokenStorage.getUserId();

      if (userId == null || userId.isEmpty) {
        print("❌ User ID not found");
        if (mounted) setState(() => loading = false);
        return;
      }

      final response = await ApiClient.fetchNotifications(
        token: token,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          if (response["data"] != null && response["data"].isNotEmpty) {
            var notificationData = response["data"][0];
            if (notificationData["messages"] != null) {
              notifications = List<Map<String, dynamic>>.from(
                notificationData["messages"].reversed,
              );
            }
          }
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  IconData _getNotificationIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('battery')) {
      return Icons.battery_alert;
    } else if (lowerTitle.contains('completed') || lowerTitle.contains('daily')) {
      return Icons.check_circle;
    } else if (lowerTitle.contains('malfunction') || lowerTitle.contains('error')) {
      return Icons.error;
    }
    return Icons.notifications;
  }

  Color _getNotificationColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('battery')) {
      return AppTheme.warning;
    } else if (lowerTitle.contains('completed') || lowerTitle.contains('daily')) {
      return AppTheme.success;
    } else if (lowerTitle.contains('malfunction') || lowerTitle.contains('error')) {
      return AppTheme.error;
    }
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context), // 👈 UPDATED
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context), // 👈 UPDATED
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)), // 👈 UPDATED
          onPressed: () => Navigator.pop(context),
        ),
        title: const GradientText( // 👈 UPDATED to use gradient
          text: 'Notifications',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface(context), // 👈 UPDATED
              onRefresh: fetchNotifications,
              child: notifications.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 500,
                        child: EmptyState(
                          icon: Icons.notifications_none,
                          message: "No notifications yet",
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final title = notification["title"]?.toString() ?? "Notification";
    final body = notification["body"]?.toString() ?? "";
    final icon = _getNotificationIcon(title);
    final color = _getNotificationColor(title);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle( // 👈 UPDATED
                    color: AppTheme.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle( // 👈 UPDATED
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon( // 👈 UPDATED
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textTertiary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Just now",
                      style: TextStyle( // 👈 UPDATED
                        color: AppTheme.textTertiary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}