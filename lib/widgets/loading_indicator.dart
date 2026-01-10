import 'package:flutter/material.dart';
import 'app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(color: AppTheme.textSecondary(context)), // 👈 UPDATED
            ),
          ],
        ],
      ),
    );
  }
}
