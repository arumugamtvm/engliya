import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phase4_unit_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/unit_card.dart';
import '../../../../app/routes.dart';

/// Phase 4 Unit Screen displaying all 4 Phase 4 units (Units 18-21)
/// Shows unit cards with progress and allows navigation to lesson lists
/// Requirements: 2.1, 2.2, 2.3
class Phase4UnitScreen extends StatefulWidget {
  const Phase4UnitScreen({super.key});

  @override
  State<Phase4UnitScreen> createState() => _Phase4UnitScreenState();
}

class _Phase4UnitScreenState extends State<Phase4UnitScreen> {
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
    } catch (e) {
      debugPrint('Error loading Phase 4 data: $e');
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
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              return UnitCard(unit: unit, onTap: () => _navigateToLessonList(unit.id, unit.title));
            },
          );
        },
      ),
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
