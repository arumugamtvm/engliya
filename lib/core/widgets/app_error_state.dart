import 'package:flutter/material.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.red[700], size: 56),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
