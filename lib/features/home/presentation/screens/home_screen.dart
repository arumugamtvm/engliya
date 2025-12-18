import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../../learn/presentation/providers/progress_provider.dart';
import '../../../learn/presentation/providers/debug_provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../services/local_storage/storage_service.dart';

/// Professional animated home screen with modern UI
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _progressAnimation;
  
  int _titleLongPressCount = 0;
  DateTime? _lastLongPressTime;
  static const int _activationTapCount = 5;
  static const Duration _tapResetDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<HomeProvider>(context, listen: false).loadHomeData();
        _initializeDebugProvider();
        _startAnimations();
      }
    });
  }

  void _initAnimations() {
    _headerController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _cardsController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeDebugProvider() {
    try {
      Provider.of<DebugProvider>(context, listen: false).initialize();
    } catch (e) {
      print('DebugProvider not available: $e');
    }
  }

  void _onTitleLongPress() {
    final now = DateTime.now();
    if (_lastLongPressTime != null && now.difference(_lastLongPressTime!) > _tapResetDuration) {
      _titleLongPressCount = 0;
    }
    _titleLongPressCount++;
    _lastLongPressTime = now;
    if (_titleLongPressCount >= _activationTapCount) {
      _titleLongPressCount = 0;
      Navigator.pushNamed(context, AppRoutes.debug);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return _buildLoadingState();
          if (provider.error != null) return _buildErrorState(provider);
          return _buildMainContent(context, provider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8), AppTheme.scaffoldBackground],
          stops: const [0.0, 0.3, 0.5],
        ),
      ),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildErrorState(HomeProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text('Oops! Something went wrong', style: AppTheme.headline2),
            const SizedBox(height: 12),
            Text(provider.error!, style: AppTheme.bodyText2, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(onPressed: () => provider.refresh(), icon: const Icon(Icons.refresh), label: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, HomeProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refresh();
        _cardsController.reset();
        _cardsController.forward();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAnimatedAppBar(provider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildAnimatedProgressCard(provider),
                  const SizedBox(height: 20),
                  if (provider.hasLastAccessedLesson) ...[
                    _buildAnimatedContinueCard(context, provider),
                    const SizedBox(height: 20),
                  ],
                  _buildPhasesSection(context, provider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar(HomeProvider provider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Consumer<DebugProvider>(
          builder: (context, debugProvider, child) {
            return GestureDetector(
              onLongPress: _onTitleLongPress,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Engliya', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (debugProvider.isDebugModeEnabled) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                      child: const Text('DEV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        background: SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryDark, AppTheme.primaryColor, AppTheme.accentColor.withOpacity(0.8)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -50, right: -50, child: _buildAnimatedCircle(150, Colors.white.withOpacity(0.1))),
                  Positioned(bottom: 60, left: -30, child: _buildAnimatedCircle(100, Colors.white.withOpacity(0.08))),
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.school, size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text('Learn English Step by Step', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.smart_toy), tooltip: 'AI Tutor', onPressed: () => Navigator.pushNamed(context, AppRoutes.aiChat)),
      ],
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        );
      },
    );
  }


  Widget _buildAnimatedProgressCard(HomeProvider provider) {
    final percentage = provider.totalLessons > 0 ? (provider.masteredCount / provider.totalLessons * 100).toInt() : 0;
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        final slideValue = Curves.easeOutCubic.transform((_cardsController.value * 2).clamp(0.0, 1.0));
        final fadeValue = (_cardsController.value * 2).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - slideValue)),
          child: Opacity(
            opacity: fadeValue,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildProgressRing(provider, percentage),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Progress', style: AppTheme.headline3),
                            const SizedBox(height: 4),
                            Text('${provider.masteredCount} of ${provider.totalLessons} lessons mastered', style: AppTheme.bodyText2.copyWith(color: Colors.grey[600])),
                            const SizedBox(height: 12),
                            _buildAnimatedProgressBar(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.emoji_events, '${provider.masteredCount}', 'Mastered', AppTheme.masteredColor),
                      _buildStatItem(Icons.trending_up, '$percentage%', 'Complete', AppTheme.primaryColor),
                      _buildStatItem(Icons.timer, '${provider.totalLessons - provider.masteredCount}', 'Remaining', Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressRing(HomeProvider provider, int percentage) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: provider.totalLessons > 0 ? (provider.masteredCount / provider.totalLessons) * _progressAnimation.value : 0,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              Center(
                child: Text(
                  '${(percentage * _progressAnimation.value).toInt()}%',
                  style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedProgressBar(HomeProvider provider) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: provider.totalLessons > 0 ? (provider.masteredCount / provider.totalLessons) * _progressAnimation.value : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 8,
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.headline3.copyWith(fontSize: 18)),
        Text(label, style: AppTheme.caption),
      ],
    );
  }

  Widget _buildAnimatedContinueCard(BuildContext context, HomeProvider provider) {
    final lesson = provider.lastAccessedLesson;
    if (lesson == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        const delay = 0.15;
        const start = delay;
        final end = (delay + 0.5).clamp(0.0, 1.0);
        final slideValue = Curves.easeOutCubic.transform(((_cardsController.value - start) / (end - start)).clamp(0.0, 1.0));
        return Transform.translate(
          offset: Offset(0, 30 * (1 - slideValue)),
          child: Opacity(opacity: slideValue, child: _buildContinueCardContent(context, provider, lesson)),
        );
      },
    );
  }

  Widget _buildContinueCardContent(BuildContext context, HomeProvider provider, dynamic lesson) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, AppRoutes.lesson, arguments: lesson.id);
        if (mounted) await provider.refresh();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppTheme.accentColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Continue Learning', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(lesson.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildPhasesSection(BuildContext context, HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Learning Phases', style: AppTheme.headline2)),
        const SizedBox(height: 12),
        _buildAnimatedPhaseCard(context: context, index: 0, title: 'Phase 1', subtitle: 'Foundation', description: '6 lessons • Build your basics', icon: Icons.foundation, color: AppTheme.primaryColor, isUnlocked: true, onTap: () => Navigator.pushNamed(context, AppRoutes.phase1Unit), testWidget: _buildPhase1TestCard(context, provider)),
        const SizedBox(height: 16),
        _buildAnimatedPhaseCard(context: context, index: 1, title: 'Phase 2', subtitle: 'Intermediate', description: '25 lessons • Expand your skills', icon: Icons.trending_up, color: Colors.indigo, isUnlocked: provider.isPhase2Unlocked, onTap: () => _handlePhase2Tap(context, provider.isPhase2Unlocked), testWidget: provider.isPhase2Unlocked ? _buildPhase2TestCard(context, provider) : null),
        const SizedBox(height: 16),
        _buildAnimatedPhaseCard(context: context, index: 2, title: 'Phase 3', subtitle: 'Real-Life', description: '27 lessons • Master conversations', icon: Icons.chat_bubble, color: Colors.purple, isUnlocked: provider.isPhase3Unlocked, onTap: () => _handlePhase3Tap(context, provider.isPhase3Unlocked), testWidget: provider.isPhase3Unlocked ? _buildPhase3TestCard(context, provider) : null),
        const SizedBox(height: 16),
        _buildAnimatedPhaseCard(context: context, index: 3, title: 'Phase 4', subtitle: 'Fluency', description: '17 lessons • Fluency & Pronunciation', icon: Icons.record_voice_over, color: Colors.teal, isUnlocked: provider.isPhase4Unlocked, onTap: () => _handlePhase4Tap(context, provider.isPhase4Unlocked)),
      ],
    );
  }

  Widget _buildAnimatedPhaseCard({required BuildContext context, required int index, required String title, required String subtitle, required String description, required IconData icon, required Color color, required bool isUnlocked, required VoidCallback onTap, Widget? testWidget}) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        final delay = 0.3 + (index * 0.1);
        final start = delay.clamp(0.0, 0.7);
        final end = (delay + 0.3).clamp(0.0, 1.0);
        final progress = ((_cardsController.value - start) / (end - start)).clamp(0.0, 1.0);
        final slideValue = Curves.easeOutCubic.transform(progress);
        return Transform.translate(
          offset: Offset(50 * (1 - slideValue), 0),
          child: Opacity(
            opacity: slideValue,
            child: Column(
              children: [
                _buildPhaseCardContent(title: title, subtitle: subtitle, description: description, icon: icon, color: color, isUnlocked: isUnlocked, onTap: onTap),
                if (testWidget != null) ...[const SizedBox(height: 8), testWidget],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseCardContent({required String title, required String subtitle, required String description, required IconData icon, required Color color, required bool isUnlocked, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isUnlocked ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2), width: 2),
          boxShadow: [BoxShadow(color: (isUnlocked ? color : Colors.grey).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isUnlocked ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[300]!]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(isUnlocked ? icon : Icons.lock, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTheme.headline3.copyWith(fontSize: 18)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: (isUnlocked ? color : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isUnlocked ? color : Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: AppTheme.bodyText2.copyWith(color: Colors.grey[600], fontSize: 13)),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text('Complete previous phase to unlock', style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isUnlocked ? color : Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase1TestCard(BuildContext context, HomeProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getPhase1TestStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        final data = snapshot.data ?? {};
        final hasPassedTest = data['passed'] ?? false;
        final testScore = data['score'] as int?;
        final allMastered = data['allMastered'] ?? false;
        String statusText;
        IconData statusIcon;
        Color statusColor;
        bool canNavigate = true;
        if (hasPassedTest && testScore != null) {
          statusText = 'Final Test: Passed ($testScore/20)';
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
        } else if (testScore != null && !hasPassedTest) {
          statusText = 'Final Test: Score $testScore/20';
          statusIcon = Icons.refresh;
          statusColor = Colors.orange;
        } else if (allMastered) {
          statusText = 'Final Test: Ready';
          statusIcon = Icons.play_circle_filled;
          statusColor = Colors.blue;
        } else {
          statusText = 'Final Test: Locked';
          statusIcon = Icons.lock;
          statusColor = Colors.grey;
          canNavigate = false;
        }
        return _buildTestCard(statusText, statusIcon, statusColor, canNavigate, () => canNavigate ? Navigator.pushNamed(context, AppRoutes.phase1FinalTest) : _showLockedDialog(context, 'Phase 1 Test Locked', 'Master all Phase 1 lessons first.'));
      },
    );
  }

  Widget _buildPhase2TestCard(BuildContext context, HomeProvider provider) {
    return FutureBuilder<bool>(
      future: _checkAllPhase2LessonsMastered(context),
      builder: (context, snapshot) {
        final allMastered = snapshot.data ?? false;
        final hasPassedTest = provider.hasPassedPhase2FinalTest;
        final testScore = provider.phase2FinalTestScore;
        String statusText;
        IconData statusIcon;
        Color statusColor;
        bool canNavigate = true;
        if (hasPassedTest && testScore != null) {
          statusText = 'Final Test: Passed ($testScore/25)';
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
        } else if (testScore != null && !hasPassedTest) {
          statusText = 'Final Test: Score $testScore/25';
          statusIcon = Icons.refresh;
          statusColor = Colors.orange;
        } else if (allMastered) {
          statusText = 'Final Test: Ready';
          statusIcon = Icons.play_circle_filled;
          statusColor = Colors.indigo;
        } else {
          statusText = 'Final Test: Locked';
          statusIcon = Icons.lock;
          statusColor = Colors.grey;
          canNavigate = false;
        }
        return _buildTestCard(statusText, statusIcon, statusColor, canNavigate, () => canNavigate ? Navigator.pushNamed(context, AppRoutes.phase2FinalTest) : _showLockedDialog(context, 'Phase 2 Test Locked', 'Master all Phase 2 lessons first.'));
      },
    );
  }

  Widget _buildPhase3TestCard(BuildContext context, HomeProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getPhase3TestStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
        final data = snapshot.data ?? {};
        final hasPassedTest = data['passed'] ?? false;
        final testScore = data['score'] as int?;
        final allMastered = data['allMastered'] ?? false;
        String statusText;
        IconData statusIcon;
        Color statusColor;
        bool canNavigate = true;
        if (hasPassedTest && testScore != null) {
          statusText = 'Final Test: Passed ($testScore/30)';
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
        } else if (testScore != null && !hasPassedTest) {
          statusText = 'Final Test: Score $testScore/30';
          statusIcon = Icons.refresh;
          statusColor = Colors.orange;
        } else if (allMastered) {
          statusText = 'Final Test: Ready';
          statusIcon = Icons.play_circle_filled;
          statusColor = Colors.purple;
        } else {
          statusText = 'Final Test: Locked';
          statusIcon = Icons.lock;
          statusColor = Colors.grey;
          canNavigate = false;
        }
        return _buildTestCard(statusText, statusIcon, statusColor, canNavigate, () => canNavigate ? Navigator.pushNamed(context, AppRoutes.phase3FinalTest) : _showLockedDialog(context, 'Phase 3 Test Locked', 'Master all Phase 3 lessons first.'));
      },
    );
  }

  Widget _buildTestCard(String statusText, IconData statusIcon, Color statusColor, bool canNavigate, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(Icons.chevron_right, color: statusColor, size: 20),
          ],
        ),
      ),
    );
  }


  Future<bool> _checkAllPhase2LessonsMastered(BuildContext context) async {
    if (AppConfig.isDevelopmentMode) return true;
    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      return progressProvider.phase2Progress.masteredLessons >= 25;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _getPhase1TestStatus(BuildContext context) async {
    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      final phase1Lessons = progressProvider.getUnitLessons('phase1');
      bool allMastered = phase1Lessons.isNotEmpty;
      for (final lesson in phase1Lessons) {
        final status = progressProvider.getLessonStatus(lesson.id);
        if (status == null || !status.isMastered) {
          allMastered = false;
          break;
        }
      }
      if (AppConfig.isDevelopmentMode) allMastered = true;
      final passed = storageService.getBool('phase1_final_test_passed') ?? false;
      final score = storageService.getInt('phase1_final_test_score');
      return {'passed': passed, 'score': score, 'allMastered': allMastered};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getPhase3TestStatus(BuildContext context) async {
    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      bool allMastered = progressProvider.phase3Progress.masteredLessons >= 27;
      if (AppConfig.isDevelopmentMode) allMastered = true;
      final passed = storageService.getBool('phase3_final_test_passed') ?? false;
      final score = storageService.getInt('phase3_final_test_score');
      return {'passed': passed, 'score': score, 'allMastered': allMastered};
    } catch (e) {
      return {};
    }
  }

  void _showLockedDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [const Icon(Icons.lock, color: Colors.orange), const SizedBox(width: 8), Text(title)]),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _handlePhase2Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(context, 'Phase 2 Locked', 'Complete Phase 1 Final Test to unlock Phase 2.');
    } else {
      Navigator.pushNamed(context, AppRoutes.phase2Unit);
    }
  }

  void _handlePhase3Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(context, 'Phase 3 Locked', 'Complete Phase 2 Final Test to unlock Phase 3.');
    } else {
      Navigator.pushNamed(context, AppRoutes.phase3Unit);
    }
  }

  void _handlePhase4Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(context, 'Phase 4 Locked', 'Finish Phase 3 Final Test to unlock Phase 4 Fluency Training.');
    } else {
      Navigator.pushNamed(context, AppRoutes.phase4Unit);
    }
  }
}
