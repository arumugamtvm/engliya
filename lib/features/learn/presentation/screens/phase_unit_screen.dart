import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/phase_config.dart';
import '../../domain/entities/phase_units.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/models/phase4_final_test_question.dart';
import '../../data/models/phase4_test_result.dart';
import '../../data/models/phase5_final_test_question.dart';
import '../../data/models/phase5_test_result.dart';
import '../../data/repositories/progress_repository.dart';
import '../../services/gating_service.dart';
import '../providers/final_test_provider.dart';
import '../providers/final_test_status_provider.dart';
import '../providers/mcq_final_test_provider.dart';
import '../providers/phase_unit_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/unit_card.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_strings.dart';

class PhaseUnitScreenConfig {
  final PhaseType phaseType;
  final String appBarTitle;
  final String finalTestTitle;
  final String finalTestSubtitle;
  final int scoreTotal;
  final Color readyColor;
  final String finalTestRoute;
  final String lessonListRoute;
  final String lockedSnackMessage;
  final List<Unit> units;

  const PhaseUnitScreenConfig({
    required this.phaseType,
    required this.appBarTitle,
    required this.finalTestTitle,
    required this.finalTestSubtitle,
    required this.scoreTotal,
    required this.readyColor,
    required this.finalTestRoute,
    required this.lessonListRoute,
    required this.lockedSnackMessage,
    required this.units,
  });

  factory PhaseUnitScreenConfig.forPhase(PhaseType phaseType) {
    final config = PhaseConfig.fromType(phaseType);
    final units = PhaseUnits.forType(phaseType);
    final phaseNumber = _phaseNumber(phaseType);
    final unitRange = _unitRangeLabel(units);
    final subtitle = unitRange.isEmpty
        ? '${config.totalQuestions} Questions'
        : 'Units $unitRange - ${config.totalQuestions} Questions';

    return PhaseUnitScreenConfig(
      phaseType: phaseType,
      appBarTitle: _appBarTitle(phaseType),
      finalTestTitle: 'Phase $phaseNumber Final Test',
      finalTestSubtitle: subtitle,
      scoreTotal: config.maxScore,
      readyColor: _readyColor(phaseType),
      finalTestRoute: _finalTestRoute(phaseType),
      lessonListRoute: _lessonListRoute(phaseType),
      lockedSnackMessage:
          'Please master all Phase $phaseNumber lessons before taking the final test',
      units: units,
    );
  }

  static String _unitRangeLabel(List<Unit> units) {
    if (units.isEmpty) return '';
    final orders = units.map((unit) => unit.order).toList()..sort();
    final first = orders.first;
    final last = orders.last;
    return first == last ? '$first' : '$first-$last';
  }

  static int _phaseNumber(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase2:
        return 2;
      case PhaseType.phase3:
        return 3;
      case PhaseType.phase4:
        return 4;
      case PhaseType.phase5:
        return 5;
      case PhaseType.phase1:
        throw ArgumentError('Phase $phaseType does not use unit screens');
    }
  }

  static String _appBarTitle(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase2:
        return 'Phase 2: Intermediate English';
      case PhaseType.phase3:
        return 'Phase 3: Real-Life Communication';
      case PhaseType.phase4:
        return 'Phase 4: Fluency & Pronunciation';
      case PhaseType.phase5:
        return 'Phase 5: Professional English';
      case PhaseType.phase1:
        throw ArgumentError('Phase $phaseType does not use unit screens');
    }
  }

  static Color _readyColor(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase2:
        return Colors.indigo;
      case PhaseType.phase3:
      case PhaseType.phase4:
        return Colors.purple;
      case PhaseType.phase5:
        return Colors.deepOrange;
      case PhaseType.phase1:
        throw ArgumentError('Phase $phaseType does not use unit screens');
    }
  }

  static String _finalTestRoute(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase2:
        return AppRoutes.phase2FinalTest;
      case PhaseType.phase3:
        return AppRoutes.phase3FinalTest;
      case PhaseType.phase4:
        return AppRoutes.phase4FinalTest;
      case PhaseType.phase5:
        return AppRoutes.phase5FinalTest;
      case PhaseType.phase1:
        throw ArgumentError('Phase $phaseType does not use unit screens');
    }
  }

  static String _lessonListRoute(PhaseType phaseType) {
    switch (phaseType) {
      case PhaseType.phase2:
        return AppRoutes.phase2LessonList;
      case PhaseType.phase3:
        return AppRoutes.phase3LessonList;
      case PhaseType.phase4:
        return AppRoutes.phase4LessonList;
      case PhaseType.phase5:
        return AppRoutes.phase5LessonList;
      case PhaseType.phase1:
        throw ArgumentError('Phase $phaseType does not use unit screens');
    }
  }
}

class PhaseUnitScreen extends StatefulWidget {
  final PhaseType phaseType;

  const PhaseUnitScreen({super.key, required this.phaseType});

  @override
  State<PhaseUnitScreen> createState() => _PhaseUnitScreenState();
}

class _PhaseUnitScreenState extends State<PhaseUnitScreen> {
  late final PhaseUnitScreenConfig _config;
  late final PhaseUnitProvider _unitProvider;
  bool _allLessonsMastered = false;
  bool _testPassed = false;
  int? _lastTestScore;
  bool _isLoadingTestStatus = true;

  @override
  void initState() {
    super.initState();
    _config = PhaseUnitScreenConfig.forPhase(widget.phaseType);
    _unitProvider = PhaseUnitProvider(
      context.read<ProgressProvider>(),
      widget.phaseType,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _unitProvider.dispose();
    super.dispose();
  }

  FinalTestStatusProvider _testProvider(BuildContext context) {
    switch (widget.phaseType) {
      case PhaseType.phase2:
        return _buildMcqProvider(context, PhaseConfig.phase2);
      case PhaseType.phase3:
        return _buildMcqProvider(context, PhaseConfig.phase3);
      case PhaseType.phase4:
        return context
            .read<
              FinalTestProvider<
                Phase4FinalTestQuestion,
                SpeakingResult,
                Phase4TestResult
              >
            >();
      case PhaseType.phase5:
        return context
            .read<
              FinalTestProvider<
                Phase5FinalTestQuestion,
                Phase5SpeakingResult,
                Phase5TestResult
              >
            >();
      case PhaseType.phase1:
        throw ArgumentError(
          'Phase ${widget.phaseType} has no final test status provider',
        );
    }
  }

  McqFinalTestProvider _buildMcqProvider(
    BuildContext context,
    PhaseConfig config,
  ) {
    return McqFinalTestProvider(
      config: config,
      testRepository: context.read<TestRepository>(),
      progressRepository: context.read<ProgressRepository>(),
      gatingService: context.read<GatingService>(),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      await context.read<ProgressProvider>().loadAllData();
      await _unitProvider.loadUnits();
      await _loadTestStatus();
    } catch (e) {
      debugPrint('Error loading ${_config.appBarTitle} data: $e');
    }
  }

  Future<void> _loadTestStatus() async {
    try {
      final testProvider = _testProvider(context);
      final canTake = AppConfig.devMode || await testProvider.canTakeTest();
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
      if (mounted) {
        setState(() => _isLoadingTestStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _unitProvider,
      child: Scaffold(
        appBar: AppBar(title: Text(_config.appBarTitle)),
        body: Consumer<PhaseUnitProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.errorLoadingUnits,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(provider.error!, textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.reload(),
                      child: const Text(AppStrings.tryAgain),
                    ),
                  ],
                ),
              );
            }

            final units = provider.units;
            if (units.isEmpty) {
              return const Center(
                child: Text(
                  AppStrings.noUnitsAvailable,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: units.length + 1,
              itemBuilder: (context, index) {
                if (index == units.length) return _buildFinalTestCard();
                final unit = units[index];
                return UnitCard(
                  unit: unit,
                  onTap: () => _navigateToLessonList(unit.id, unit.title),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinalTestCard() {
    if (_isLoadingTestStatus) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    Color statusColor;
    IconData statusIcon;
    String statusText;
    if (_testPassed) {
      statusColor = AppTheme.correctColor;
      statusIcon = Icons.check_circle;
      statusText = 'Passed (Score: $_lastTestScore/${_config.scoreTotal})';
    } else if (_allLessonsMastered) {
      statusColor = _config.readyColor;
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
          onTap: _allLessonsMastered
              ? () => _handleFinalTestTap()
              : () => _showLockedMessage(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _config.finalTestTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _config.finalTestSubtitle,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    await Navigator.pushNamed(context, _config.finalTestRoute);
    if (mounted) await _loadTestStatus();
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_config.lockedSnackMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToLessonList(String unitId, String unitTitle) async {
    await Navigator.pushNamed(
      context,
      _config.lessonListRoute,
      arguments: {'unitId': unitId, 'unitTitle': unitTitle},
    );
    if (mounted) await _unitProvider.reload();
  }
}
