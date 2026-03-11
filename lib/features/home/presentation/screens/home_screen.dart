import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../../learn/presentation/providers/progress_provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../services/local_storage/storage_service.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';

/// Refined home screen with compact header and cleaner information hierarchy.
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

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<HomeProvider>(context, listen: false).loadHomeData();
        _startAnimations();
      }
    });
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 520),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.14), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
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
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
            AppTheme.scaffoldBackground,
          ],
          stops: const [0.0, 0.30, 0.54],
        ),
      ),
      child: const AppLoadingState(indicatorColor: Colors.white),
    );
  }

  Widget _buildErrorState(HomeProvider provider) {
    return AppErrorState(
      title: 'Oops! Something went wrong',
      message: provider.error ?? 'Unable to load your home data.',
      retryLabel: 'Try Again',
      onRetry: () => provider.refresh(),
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
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spacingM),
                  _buildAnimatedProgressCard(provider),
                  const SizedBox(height: AppTheme.spacingM),
                  if (provider.hasLastAccessedLesson) ...[
                    _buildAnimatedContinueCard(context, provider),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  _buildPhasesSection(context, provider),
                  const SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      collapsedHeight: 76,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Engliya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryColor,
                    AppTheme.accentColor.withOpacity(0.58),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.smart_toy),
          tooltip: 'AI Tutor',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.aiChat),
        ),
      ],
    );
  }

  Widget _buildAnimatedProgressCard(HomeProvider provider) {
    final percentage = provider.totalLessons > 0
        ? (provider.masteredCount / provider.totalLessons * 100).toInt()
        : 0;

    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        final slideValue = Curves.easeOutCubic.transform(
          (_cardsController.value * 2).clamp(0.0, 1.0),
        );
        final fadeValue = (_cardsController.value * 2).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 16 * (1 - slideValue)),
          child: Opacity(
            opacity: fadeValue,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildProgressRing(provider, percentage),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Progress',
                              style: AppTheme.headline3.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              '${provider.masteredCount} of ${provider.totalLessons} lessons mastered',
                              style: AppTheme.bodyText2.copyWith(
                                color: Colors.grey[700],
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            _buildAnimatedProgressBar(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Icons.emoji_events_outlined,
                          '${provider.masteredCount}',
                          'Mastered',
                          AppTheme.masteredColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: _buildStatItem(
                          Icons.trending_up_rounded,
                          '$percentage%',
                          'Complete',
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: _buildStatItem(
                          Icons.schedule_rounded,
                          '${provider.totalLessons - provider.masteredCount}',
                          'Remaining',
                          Colors.grey.shade600,
                        ),
                      ),
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
        return Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: provider.totalLessons > 0
                      ? (provider.masteredCount / provider.totalLessons) *
                            _progressAnimation.value
                      : 0,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${(percentage * _progressAnimation.value).toInt()}%',
                  style: AppTheme.headline3.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
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
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: provider.totalLessons > 0
                ? (provider.masteredCount / provider.totalLessons) *
                      _progressAnimation.value
                : 0,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
            minHeight: 10,
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.headline3.copyWith(fontSize: 18, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContinueCard(
    BuildContext context,
    HomeProvider provider,
  ) {
    final lesson = provider.lastAccessedLesson;
    if (lesson == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        const delay = 0.12;
        const start = delay;
        const end = 0.62;
        final progress = ((_cardsController.value - start) / (end - start))
            .clamp(0.0, 1.0);
        final slideValue = Curves.easeOutCubic.transform(progress);
        return Transform.translate(
          offset: Offset(0, 16 * (1 - slideValue)),
          child: Opacity(
            opacity: slideValue,
            child: _buildContinueCardContent(context, provider, lesson),
          ),
        );
      },
    );
  }

  Widget _buildContinueCardContent(
    BuildContext context,
    HomeProvider provider,
    dynamic lesson,
  ) {
    return Semantics(
      button: true,
      label: 'Continue learning ${lesson.title}',
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.lesson,
            arguments: lesson.id,
          );
          if (mounted) await provider.refresh();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor,
                AppTheme.accentColor.withOpacity(0.86),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.04),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue Learning',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white.withOpacity(0.90),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhasesSection(BuildContext context, HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
          child: Text('Learning Phases', style: AppTheme.headline2),
        ),
        const SizedBox(height: AppTheme.spacingS),
        if (provider.hasPhaseLessons(1)) ...[
          _buildAnimatedPhaseCard(
            context: context,
            index: 0,
            title: 'Phase 1',
            subtitle: 'Foundation',
            description: 'Core lessons from assets',
            icon: Icons.foundation,
            color: AppTheme.primaryColor,
            isUnlocked: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.phase1Unit),
            testWidget: _buildPhase1TestCard(context, provider),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        if (provider.hasPhaseLessons(2)) ...[
          _buildAnimatedPhaseCard(
            context: context,
            index: 1,
            title: 'Phase 2',
            subtitle: 'Intermediate',
            description: 'Lessons loaded from assets',
            icon: Icons.trending_up,
            color: Colors.indigo,
            isUnlocked: provider.isPhase2Unlocked,
            onTap: () => _handlePhase2Tap(context, provider.isPhase2Unlocked),
            testWidget: provider.isPhase2Unlocked
                ? _buildPhase2TestCard(context, provider)
                : null,
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        if (provider.hasPhaseLessons(3)) ...[
          _buildAnimatedPhaseCard(
            context: context,
            index: 2,
            title: 'Phase 3',
            subtitle: 'Real-Life',
            description: 'Lessons loaded from assets',
            icon: Icons.chat_bubble,
            color: Colors.purple,
            isUnlocked: provider.isPhase3Unlocked,
            onTap: () => _handlePhase3Tap(context, provider.isPhase3Unlocked),
            testWidget: provider.isPhase3Unlocked
                ? _buildPhase3TestCard(context, provider)
                : null,
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        if (provider.hasPhaseLessons(4)) ...[
          _buildAnimatedPhaseCard(
            context: context,
            index: 3,
            title: 'Phase 4',
            subtitle: 'Fluency',
            description: 'Lessons loaded from assets',
            icon: Icons.record_voice_over,
            color: Colors.teal,
            isUnlocked: provider.isPhase4Unlocked,
            onTap: () => _handlePhase4Tap(context, provider.isPhase4Unlocked),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        if (provider.hasPhaseLessons(5))
          _buildAnimatedPhaseCard(
            context: context,
            index: 4,
            title: 'Phase 5',
            subtitle: 'Professional',
            description: 'Lessons loaded from assets',
            icon: Icons.workspace_premium,
            color: Colors.deepOrange,
            isUnlocked: provider.isPhase5Unlocked,
            onTap: () => _handlePhase5Tap(context, provider.isPhase5Unlocked),
          ),
      ],
    );
  }

  Widget _buildAnimatedPhaseCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
    required VoidCallback onTap,
    Widget? testWidget,
  }) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        final delay = 0.24 + (index * 0.08);
        final start = delay.clamp(0.0, 0.8);
        final end = (delay + 0.26).clamp(0.0, 1.0);
        final progress = ((_cardsController.value - start) / (end - start))
            .clamp(0.0, 1.0);
        final slideValue = Curves.easeOutCubic.transform(progress);

        return Transform.translate(
          offset: Offset(20 * (1 - slideValue), 0),
          child: Opacity(
            opacity: slideValue,
            child: Column(
              children: [
                _buildPhaseCardContent(
                  title: title,
                  subtitle: subtitle,
                  description: description,
                  icon: icon,
                  color: color,
                  isUnlocked: isUnlocked,
                  onTap: onTap,
                ),
                if (testWidget != null) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  testWidget,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseCardContent({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title, $description',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isUnlocked
                  ? color.withOpacity(0.32)
                  : Colors.grey.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUnlocked ? color : Colors.grey).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? LinearGradient(colors: [color, color.withOpacity(0.70)])
                      : LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[300]!],
                        ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isUnlocked ? icon : Icons.lock,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.headline3.copyWith(
                              fontSize: 20,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (isUnlocked ? color : Colors.grey)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isUnlocked ? color : Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Complete previous phase to unlock',
                        style: AppTheme.caption.copyWith(
                          fontSize: 12,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Icon(
                Icons.chevron_right_rounded,
                color: isUnlocked ? color : Colors.grey[400],
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhase1TestCard(BuildContext context, HomeProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getPhase1TestStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox.shrink();
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
        return _buildTestCard(
          statusText,
          statusIcon,
          statusColor,
          canNavigate,
          () => canNavigate
              ? Navigator.pushNamed(context, AppRoutes.phase1FinalTest)
              : _showLockedDialog(
                  context,
                  'Phase 1 Test Locked',
                  'Master all Phase 1 lessons first.',
                ),
        );
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
        return _buildTestCard(
          statusText,
          statusIcon,
          statusColor,
          canNavigate,
          () => canNavigate
              ? Navigator.pushNamed(context, AppRoutes.phase2FinalTest)
              : _showLockedDialog(
                  context,
                  'Phase 2 Test Locked',
                  'Master all Phase 2 lessons first.',
                ),
        );
      },
    );
  }

  Widget _buildPhase3TestCard(BuildContext context, HomeProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getPhase3TestStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox.shrink();
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
        return _buildTestCard(
          statusText,
          statusIcon,
          statusColor,
          canNavigate,
          () => canNavigate
              ? Navigator.pushNamed(context, AppRoutes.phase3FinalTest)
              : _showLockedDialog(
                  context,
                  'Phase 3 Test Locked',
                  'Master all Phase 3 lessons first.',
                ),
        );
      },
    );
  }

  Widget _buildTestCard(
    String statusText,
    IconData statusIcon,
    Color statusColor,
    bool canNavigate,
    VoidCallback onTap,
  ) {
    return Semantics(
      button: true,
      enabled: canNavigate,
      label: statusText,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          margin: const EdgeInsets.only(left: 82),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withOpacity(0.35),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: statusColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAllPhase2LessonsMastered(BuildContext context) async {
    if (AppConfig.devMode) return true;
    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      return progressProvider.phase2Progress.masteredLessons >= 25;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _getPhase1TestStatus(
    BuildContext context,
  ) async {
    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final storageService = Provider.of<StorageService>(
        context,
        listen: false,
      );
      final phase1Lessons = progressProvider.getUnitLessons('phase1');
      bool allMastered = phase1Lessons.isNotEmpty;
      for (final lesson in phase1Lessons) {
        final status = progressProvider.getLessonStatus(lesson.id);
        if (status == null || !status.isMastered) {
          allMastered = false;
          break;
        }
      }
      if (AppConfig.devMode) allMastered = true;
      final passed =
          storageService.getBool('phase1_final_test_passed') ?? false;
      final score = storageService.getInt('phase1_final_test_score');
      return {'passed': passed, 'score': score, 'allMastered': allMastered};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getPhase3TestStatus(
    BuildContext context,
  ) async {
    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final storageService = Provider.of<StorageService>(
        context,
        listen: false,
      );
      bool allMastered = progressProvider.phase3Progress.masteredLessons >= 27;
      if (AppConfig.devMode) allMastered = true;
      final passed =
          storageService.getBool('phase3_final_test_passed') ?? false;
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
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePhase2Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(
        context,
        'Phase 2 Locked',
        'Complete Phase 1 Final Test to unlock Phase 2.',
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.phase2Unit);
    }
  }

  void _handlePhase3Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(
        context,
        'Phase 3 Locked',
        'Complete Phase 2 Final Test to unlock Phase 3.',
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.phase3Unit);
    }
  }

  void _handlePhase4Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(
        context,
        'Phase 4 Locked',
        'Finish Phase 3 Final Test to unlock Phase 4 Fluency Training.',
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.phase4Unit);
    }
  }

  void _handlePhase5Tap(BuildContext context, bool isUnlocked) {
    if (!isUnlocked) {
      _showLockedDialog(
        context,
        'Phase 5 Locked',
        'Finish Phase 4 Final Test to unlock Phase 5 Professional English.',
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.phase5Unit);
    }
  }
}
