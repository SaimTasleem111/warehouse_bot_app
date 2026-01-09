import 'package:flutter/material.dart';
import 'app_theme.dart';


class StatusBadge extends StatelessWidget {
  final String status;
  final Color? customColor;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.customColor,
    this.showDot = true,
  });

  Color getStatusColor() {
    if (customColor != null) return customColor!;
    
    switch (status.toLowerCase()) {
      case "completed":
      case "busy":
      case "working":
      case "active":
      case "in stock":
        return AppTheme.success;
      case "pending":
      case "queued":
      case "low stock":
        return AppTheme.warning;
      case "in transit":
      case "in_progress":
      case "idle":
        return AppTheme.primary;
      case "error":
      case "failed":
      case "out of stock":
        return AppTheme.error;
      case "charging":
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}