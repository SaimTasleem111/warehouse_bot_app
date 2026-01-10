import 'package:flutter/material.dart';
import 'app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? submessage;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.submessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textTertiary(context).withOpacity(0.5), // 👈 UPDATED
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle( // 👈 UPDATED
                color: AppTheme.textSecondary(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (submessage != null) ...[
              const SizedBox(height: 8),
              Text(
                submessage!,
                style: TextStyle( // 👈 UPDATED
                  color: AppTheme.textTertiary(context),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
