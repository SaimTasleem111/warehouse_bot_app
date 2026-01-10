import 'package:flutter/material.dart';
import 'app_theme.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.textSecondary(context); // 👈 UPDATED

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight(context), // 👈 UPDATED
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor(context)), // 👈 UPDATED
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
