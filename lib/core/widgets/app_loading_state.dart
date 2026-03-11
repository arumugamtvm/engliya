import 'package:flutter/material.dart';

class AppLoadingState extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry padding;
  final Color? indicatorColor;

  const AppLoadingState({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(24),
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: indicatorColor ?? Theme.of(context).colorScheme.primary,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
