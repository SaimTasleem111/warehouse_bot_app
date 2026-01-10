import 'package:flutter/material.dart';
import 'app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context), // 👈 UPDATED
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)), // 👈 UPDATED
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: AppTheme.textPrimary(context)), // 👈 UPDATED
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppTheme.textTertiary(context)), // 👈 UPDATED
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary(context)), // 👈 UPDATED
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
