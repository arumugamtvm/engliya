import 'package:flutter/material.dart';
import '../../data/models/phase5_test_result.dart';
import '../../../../app/theme.dart';

/// Phase 5 Final Test Result Screen
/// Displays the test results with pass/fail status and English Mastery certification
/// 
/// Requirements: 7.1, 7.2, 7.3, 7.4
class Phase5FinalTestResultScreen extends StatelessWidget {
  final Phase5TestResult result;

  const Phase5FinalTestResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            _buildResultHeader(context),
            const SizedBox(height: AppTheme.spacingXL),
            _buildScoreCard(context),
            const SizedBox(height: AppTheme.spacingL),
            _buildScoreBreakdown(context),
            const SizedBox(height: AppTheme.spacingXL),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          result.passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
          size: 80,
          color: result.passed ? Colors.amber : Colors.grey,
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          result.passed ? '🎓 Congratulations!' : '❌ Not Passed',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: result.passed ? Colors.green[700] : Colors.red[700],
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          result.passed
              ? 'You have completed the English Communication Mastery Program!'
              : 'You are very close. Review Phase 5 lessons and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        if (result.passed) ...[
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingS),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  'CERTIFIED ✔️',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: result.passed
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: (result.passed ? Colors.green : Colors.orange).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Final Score',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '${result.totalScore} / ${result.maxScore}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '${result.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Passing Score: 45/60 (75%)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildBreakdownRow('MCQ Questions', '${result.mcqCorrect}/27'),
          _buildBreakdownRow('Speaking Tasks', '${result.speakingScore}/32'),
          const Divider(),
          _buildBreakdownRow('Total', '${result.totalScore}/60', isBold: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/phase5/finalTest/review',
                arguments: result.incorrectMcqAnswers,
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Review Mistakes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(AppTheme.spacingM),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (result.passed) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Future feature: Download certificate
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Certificate download coming soon!')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Certificate'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppTheme.spacingM),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Home'),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/phase5/finalTest');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Test'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppTheme.spacingM),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
