import 'package:flutter/material.dart';
import 'gradient_text.dart';
import 'app_theme.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color>? gradientColors;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            text: title,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            gradient: LinearGradient(
              colors: gradientColors ?? [
                AppTheme.primary,
                AppTheme.purple,
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle( // 👈 UPDATED
              fontSize: 15,
              color: AppTheme.textSecondary(context),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}