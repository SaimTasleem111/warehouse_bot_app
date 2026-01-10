import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import 'app_theme.dart';
import 'gradient_text.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const GradientText(
                text: "Settings",
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Theme Setting
          _ThemeSetting(),
          
          const SizedBox(height: 16),
          
          Divider(color: AppTheme.borderColor(context)),
          
          const SizedBox(height: 16),

          // Notification Setting
          _NotificationSetting(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Theme",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: AppTheme.primary,
                    activeTrackColor: AppTheme.primary.withOpacity(0.5),
                    inactiveThumbColor: AppTheme.textSecondary(context),
                    inactiveTrackColor: AppTheme.borderColor(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 54),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.primary.withOpacity(0.1)
                          : AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.primary.withOpacity(0.3)
                            : AppTheme.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.nightlight_round : Icons.wb_sunny,
                          size: 14,
                          color: isDark ? AppTheme.primary : AppTheme.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDark ? "Dark Mode" : "Light Mode",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.primary : AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final isEnabled = notificationProvider.notificationsEnabled;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: isEnabled ? AppTheme.success : AppTheme.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                  Switch(
                    value: isEnabled,
                    onChanged: (_) => notificationProvider.toggleNotifications(),
                    activeColor: AppTheme.success,
                    activeTrackColor: AppTheme.success.withOpacity(0.5),
                    inactiveThumbColor: AppTheme.error,
                    inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 54),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isEnabled
                            ? AppTheme.success.withOpacity(0.3)
                            : AppTheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEnabled ? Icons.volume_up : Icons.volume_off,
                          size: 14,
                          color: isEnabled ? AppTheme.success : AppTheme.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isEnabled
                              ? "Allow Notifications"
                              : "Mute Notifications",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isEnabled ? AppTheme.success : AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
