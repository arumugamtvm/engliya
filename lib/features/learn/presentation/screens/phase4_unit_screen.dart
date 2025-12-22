import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phase4_unit_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/phase4_final_test_provider.dart';
import '../widgets/unit_card.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_config.dart';

/// Phase 4 Unit Screen displaying all 4 Phase 4 units (Units 18-21)
/// Shows unit cards with progress and allows navigation to lesson lists
/// Requirements: 2.1, 2.2, 2.3, 1.1, 1.2
class Phase4UnitScreen extends StatefulWidget {
  const Phase4UnitScreen({super.key});

  @override
  State<Phase4UnitScreen> createState() => _Phase4UnitScreenState();
}

class _Phase4UnitScreenState extends State<Phase4UnitScreen> {
  bool _allLessonsMastered = false;
  bool _testPassed = false;
  int? _lastTestScore;
  bool _isLoadingTestStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      final progressProvider = context.read<ProgressProvider>();
      final unitProvider = context.read<Phase4UnitProvider>();
      await progressProvider.loadAllData();
      await unitProvider.loadUnits();
      await _loadTestStatus();
    } catch (e) {
      debugPrint('Error loading Phase 4 data: $e');
    }
  }

  Future<void> _loadTestStatus() async {
    try {
      final testProvider = context.read<Phase4FinalTestProvider>();
      final canTake = AppConfig.isDevelopmentMode || await testProvider.canTakeTest();
      final passed = await testProvider.hasPassedTest();
      final score = await testProvider.getLastTestScore();
      if (mounted) {
        setState(() {
          _allLessonsMastered = canTake;
          _testPassed = passed;
          _lastTestScore = score;
          _isLoadingTestStatus = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTestStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 4: Fluency & Pronunciation')),
      body: Consumer<Phase4UnitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading units', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(provider.error!, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => provider.reload(), child: const Text('Retry')),
                ],
              ),
            );
          }

          final units = provider.units;
          if (units.isEmpty) return const Center(child: Text('No units available'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: units.length + 1,
            itemBuilder: (context, index) {
              if (index == units.length) return _buildFinalTestCard();
              final unit = units[index];
              return UnitCard(unit: unit, onTap: () => _navigateToLessonList(unit.id, unit.title));
            },
          );
        },
      ),
    );
  }

  /// Build Final Test card showing locked/unlocked status
  /// Requirements: 1.1, 1.2
  Widget _buildFinalTestCard() {
    if (_isLoadingTestStatus) {
      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
    }
    Color statusColor;
    IconData statusIcon;
    String statusText;
    if (_testPassed) {
      statusColor = AppTheme.correctColor;
      statusIcon = Icons.check_circle;
      statusText = 'Passed (Score: $_lastTestScore/24)';
    } else if (_allLessonsMastered) {
      statusColor = Colors.purple;
      statusIcon = Icons.play_circle_filled;
      statusText = 'Ready to take';
    } else {
      statusColor = AppTheme.lockedColor;
      statusIcon = Icons.lock;
      statusText = 'Locked - Master all lessons first';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: _allLessonsMastered ? () => _handleFinalTestTap() : () => _showLockedMessage(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phase 4 Final Test', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Units 18–21 • 20 Questions', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle Final Test card tap - navigate to test screen
  /// Requirements: 1.1
  void _handleFinalTestTap() async {
    await Navigator.pushNamed(context, AppRoutes.phase4FinalTest);
    if (mounted) await _loadTestStatus();
  }

  /// Show locked message when test is not accessible
  /// Requirements: 1.2
  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please master all Phase 4 lessons before taking the final test'), behavior: SnackBarBehavior.floating),
    );
  }

  /// Navigate to Phase4LessonListScreen with the selected unit
  /// Requirements: 2.2
  void _navigateToLessonList(String unitId, String unitTitle) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.phase4LessonList,
      arguments: {'unitId': unitId, 'unitTitle': unitTitle},
    );
    if (mounted) await context.read<Phase4UnitProvider>().reload();
  }
}
