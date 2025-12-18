import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phase2_unit_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/phase2_final_test_provider.dart';
import '../widgets/unit_card.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_config.dart';

/// Phase 2 Unit Screen displaying all 5 Phase 2 units (Units 7-11)
class Phase2UnitScreen extends StatefulWidget {
  const Phase2UnitScreen({super.key});

  @override
  State<Phase2UnitScreen> createState() => _Phase2UnitScreenState();
}

class _Phase2UnitScreenState extends State<Phase2UnitScreen> {
  bool _allLessonsMastered = false;
  bool _testPassed = false;
  int? _lastTestScore;
  bool _isLoadingTestStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      await context.read<ProgressProvider>().loadAllData();
      await context.read<Phase2UnitProvider>().loadUnits();
      await _loadTestStatus();
    } catch (e) {
      debugPrint('Error loading Phase 2 data: $e');
    }
  }

  Future<void> _loadTestStatus() async {
    try {
      final testProvider = context.read<Phase2FinalTestProvider>();
      final canTake = AppConfig.isDevelopmentMode || await testProvider.canTakeTest();
      final passed = await testProvider.hasPassedBefore();
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
      appBar: AppBar(title: const Text('Phase 2: Intermediate English')),
      body: Consumer<Phase2UnitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading units', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Text(provider.error!, textAlign: TextAlign.center)),
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
      statusText = 'Passed (Score: $_lastTestScore/25)';
    } else if (_allLessonsMastered) {
      statusColor = Colors.indigo;
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
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phase 2 Final Test', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Units 7–11 • 25 Questions', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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

  void _handleFinalTestTap() async {
    await Navigator.pushNamed(context, AppRoutes.phase2FinalTest);
    if (mounted) await _loadTestStatus();
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please master all Phase 2 lessons before taking the final test'), behavior: SnackBarBehavior.floating),
    );
  }

  void _navigateToLessonList(String unitId, String unitTitle) async {
    await Navigator.pushNamed(context, AppRoutes.phase2LessonList, arguments: {'unitId': unitId, 'unitTitle': unitTitle});
    if (mounted) await context.read<Phase2UnitProvider>().reload();
  }
}
