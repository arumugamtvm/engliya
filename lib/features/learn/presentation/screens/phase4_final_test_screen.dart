import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phase4_final_test_provider.dart';
import '../../data/models/phase4_final_test_question.dart';
import '../../data/models/phase4_test_result.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Phase 4 Final Test Screen
/// Displays a 20-question hybrid test covering all Phase 4 units (Units 18-21)
/// 
/// Test composition:
/// - 6 Pronunciation MCQs (1 point each)
/// - 6 Dialogue Response MCQs (1 point each)
/// - 4 Listening MCQs (1 point each)
/// - 4 Speaking Tasks (0-3 points each)
/// 
/// Requirements: 1.2, 12.1, 12.2, 12.3, 12.4
/// Accessibility: Semantic labels, screen reader announcements, focus management
class Phase4FinalTestScreen extends StatefulWidget {
  const Phase4FinalTestScreen({super.key});

  @override
  State<Phase4FinalTestScreen> createState() => _Phase4FinalTestScreenState();
}

class _Phase4FinalTestScreenState extends State<Phase4FinalTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _previousQuestionIndex = -1;
  
  // Focus node for keyboard navigation
  final FocusNode _questionFocusNode = FocusNode();
  
  // Speaking task state
  bool _isRecording = false;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for question transitions (300ms)
    _questionAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _questionAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _questionAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    _questionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    final provider = context.read<Phase4FinalTestProvider>();
    
    final canTake = AppConfig.isDevelopmentMode || await provider.canTakeTest();
    
    if (!canTake) {
      return;
    }
    
    try {
      await provider.startTest();
      _questionAnimationController.forward();
    } catch (e) {
      print('Test initialization failed: $e');
    }
  }

  Future<void> _retryInitializeTest() async {
    try {
      await context.read<Phase4FinalTestProvider>().retryStartTest();
      _questionAnimationController.forward();
    } catch (e) {
      print('Test retry failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<Phase4FinalTestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return FutureBuilder<bool>(
            future: provider.canTakeTest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final canTake = AppConfig.isDevelopmentMode || (snapshot.data ?? false);
              if (!canTake) {
                return _buildLockedState(context);
              }

              if (provider.error != null) {
                return _buildErrorState(context, provider);
              }

              if (provider.questions.isEmpty) {
                return const Center(
                  child: Text('No questions available'),
                );
              }

              return _buildTestContent(context, provider);
            },
          );
        },
      ),
    );
  }

  /// Build AppBar with title and subtitle
  /// Requirement: 12.1
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Semantics(
        label: 'Phase 4 Final Test, Fluency and Pronunciation Check',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phase 4 – Final Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Fluency & Pronunciation Check',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build locked state UI when lessons not mastered
  /// Requirement: 1.2
  Widget _buildLockedState(BuildContext context) {
    return Semantics(
      label: 'Test locked. Please master all Phase 4 lessons before taking the final test.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.lockedColor,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Test Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Please master all Phase 4 lessons before taking the Final Test',
                textAlign: TextAlign.center,
                style: AppTheme.bodyText1,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Semantics(
                button: true,
                label: 'Go back to previous screen',
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error state UI with retry mechanism
  Widget _buildErrorState(BuildContext context, Phase4FinalTestProvider provider) {
    return Semantics(
      label: 'Error loading test. ${provider.error}. Please check your connection and try again.',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.incorrectColor,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: AppTheme.bodyText1,
              ),
              const SizedBox(height: AppTheme.spacingS),
              const Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: 'Retry loading test',
                    child: ElevatedButton.icon(
                      onPressed: () => _retryInitializeTest(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Semantics(
                    button: true,
                    label: 'Go back to previous screen',
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main test content
  /// Requirement: 12.1
  Widget _buildTestContent(BuildContext context, Phase4FinalTestProvider provider) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          _buildProgressSection(provider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionSection(provider),
                  const SizedBox(height: AppTheme.spacingL),
                  if (provider.isCurrentQuestionMcq)
                    _buildMcqOptions(provider)
                  else if (provider.isCurrentQuestionSpeaking)
                    _buildSpeakingTask(provider),
                ],
              ),
            ),
          ),
          _buildNavigationControls(context, provider),
        ],
      ),
    );
  }

  /// Build progress section with counter and progress bar
  /// Requirement: 12.1
  Widget _buildProgressSection(Phase4FinalTestProvider provider) {
    final currentQuestion = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final progress = provider.progress;
    final progressPercent = (progress * 100).toInt();

    return Semantics(
      label: 'Question $currentQuestion of $totalQuestions. Progress: $progressPercent percent',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Text(
                'Question $currentQuestion / $totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                duration: AppAnimations.normal,
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build question display section
  Widget _buildQuestionSection(Phase4FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    if (_previousQuestionIndex != provider.currentQuestionIndex) {
      _previousQuestionIndex = provider.currentQuestionIndex;
      _questionAnimationController.forward(from: 0.0);
      // Reset speaking state when question changes
      _isRecording = false;
      _recordingSeconds = 0;
    }
    
    final questionNum = provider.currentQuestionIndex + 1;
    final totalQuestions = provider.totalQuestions;
    final questionTypeLabel = _getQuestionTypeLabel(question.type);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Focus(
          focusNode: _questionFocusNode,
          child: Semantics(
            label: 'Question $questionNum of $totalQuestions. $questionTypeLabel. ${question.prompt}',
            readOnly: true,
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getQuestionTypeColor(question.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      questionTypeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getQuestionTypeColor(question.type),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  // Audio text for listening questions
                  if (question.type == Phase4QuestionType.listening && question.audioText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              question.audioText!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  // Question prompt
                  ExcludeSemantics(
                    child: Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeLabel(Phase4QuestionType type) {
    switch (type) {
      case Phase4QuestionType.pronunciation:
        return 'Pronunciation';
      case Phase4QuestionType.dialogue:
        return 'Dialogue Response';
      case Phase4QuestionType.listening:
        return 'Listening';
      case Phase4QuestionType.speaking:
        return 'Speaking Task';
    }
  }

  Color _getQuestionTypeColor(Phase4QuestionType type) {
    switch (type) {
      case Phase4QuestionType.pronunciation:
        return Colors.purple;
      case Phase4QuestionType.dialogue:
        return Colors.teal;
      case Phase4QuestionType.listening:
        return Colors.orange;
      case Phase4QuestionType.speaking:
        return Colors.blue;
    }
  }


  /// Build MCQ answer options
  /// Requirement: 12.2
  Widget _buildMcqOptions(Phase4FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null || question.options == null) return const SizedBox.shrink();

    final selectedAnswer = provider.selectedMcqAnswer;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: List.generate(
            question.options!.length,
            (index) => _buildOptionTile(
              context: context,
              option: question.options![index],
              index: index,
              isSelected: selectedAnswer == index,
              onTap: () => provider.selectMcqAnswer(index),
            ),
          ),
        ),
      ),
    );
  }

  /// Build individual option tile
  /// Requirement: 12.2
  Widget _buildOptionTile({
    required BuildContext context,
    required String option,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final optionLabel = String.fromCharCode(65 + index);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: 'Option $optionLabel: $option',
          hint: isSelected ? 'Selected' : 'Tap to select',
          child: AnimatedScale(
            scale: isSelected ? 1.02 : 1.0,
            duration: AppAnimations.fast,
            child: Material(
              color: isSelected
                  ? const Color(0xFFE3F2FD)
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              elevation: isSelected ? 2 : 1,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                focusColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: AnimatedContainer(
                          duration: AppAnimations.normal,
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build speaking task UI
  /// Requirement: 12.3
  Widget _buildSpeakingTask(Phase4FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final speakingResult = provider.currentSpeakingResult;
    final hasRecorded = speakingResult != null;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        'Speak for 20-30 seconds. Try to use 20+ words for full points.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Microphone button
              Semantics(
                button: true,
                label: _isRecording 
                    ? 'Stop recording. Recording for $_recordingSeconds seconds'
                    : hasRecorded 
                        ? 'Re-record your response'
                        : 'Start recording your response',
                child: GestureDetector(
                  onTap: () => _toggleRecording(provider, question),
                  child: AnimatedContainer(
                    duration: AppAnimations.normal,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording 
                          ? AppTheme.incorrectColor 
                          : hasRecorded 
                              ? AppTheme.correctColor
                              : AppTheme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording 
                              ? AppTheme.incorrectColor 
                              : AppTheme.primaryColor).withValues(alpha: 0.3),
                          blurRadius: _isRecording ? 20 : 10,
                          spreadRadius: _isRecording ? 5 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording 
                          ? Icons.stop 
                          : hasRecorded 
                              ? Icons.refresh
                              : Icons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Recording status
              if (_isRecording) ...[
                Text(
                  'Recording... $_recordingSeconds s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.incorrectColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text(
                  'Tap to stop',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ] else if (hasRecorded) ...[
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.correctColor,
                  size: 32,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Recorded! Score: ${speakingResult.score}/3',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.correctColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  speakingResult.feedback,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (speakingResult.recognizedText != null && 
                    speakingResult.recognizedText!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your response:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          speakingResult.recognizedText!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          '${speakingResult.wordCount} words',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingM),
                TextButton.icon(
                  onPressed: () => _toggleRecording(provider, question),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Record Again'),
                ),
              ] else ...[
                const Text(
                  'Tap to start recording',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Toggle recording state for speaking tasks
  /// Uses mock scoring when STT is unavailable
  /// Requirement: 12.3
  void _toggleRecording(Phase4FinalTestProvider provider, Phase4FinalTestQuestion question) {
    if (_isRecording) {
      // Stop recording and score
      setState(() {
        _isRecording = false;
      });
      
      // Use mock scoring - simulate recognized text based on recording duration
      // In a real implementation, this would use STT service
      final mockText = _generateMockSpeechText(_recordingSeconds);
      
      final result = SpeakingResult.fromRecognition(
        taskId: question.id,
        prompt: question.prompt,
        recognizedText: mockText,
      );
      
      provider.recordSpeakingResult(result);
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      
      // Start timer to track recording duration
      _startRecordingTimer();
    }
  }

  /// Start a timer to track recording duration
  void _startRecordingTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      setState(() {
        _recordingSeconds++;
      });
      // Auto-stop after 30 seconds
      if (_recordingSeconds >= 30) {
        final provider = context.read<Phase4FinalTestProvider>();
        final question = provider.currentQuestion;
        if (question != null) {
          _toggleRecording(provider, question);
        }
        return false;
      }
      return true;
    });
  }

  /// Generate mock speech text based on recording duration
  /// Used when STT is unavailable
  String _generateMockSpeechText(int seconds) {
    // Simulate approximately 2 words per second of speech
    final wordCount = (seconds * 2).clamp(0, 60);
    
    final sampleWords = [
      'I', 'like', 'to', 'talk', 'about', 'my', 'daily', 'routine',
      'Every', 'morning', 'I', 'wake', 'up', 'early', 'and', 'have',
      'breakfast', 'Then', 'I', 'go', 'to', 'work', 'or', 'school',
      'In', 'the', 'evening', 'I', 'spend', 'time', 'with', 'family',
      'I', 'enjoy', 'reading', 'books', 'and', 'watching', 'movies',
      'On', 'weekends', 'I', 'like', 'to', 'relax', 'and', 'meet',
      'friends', 'We', 'often', 'go', 'shopping', 'or', 'eat', 'out',
      'This', 'is', 'how', 'I', 'spend', 'my', 'time',
    ];
    
    if (wordCount == 0) return '';
    
    final result = <String>[];
    for (int i = 0; i < wordCount && i < sampleWords.length; i++) {
      result.add(sampleWords[i]);
    }
    
    return result.join(' ');
  }


  /// Build navigation controls (Skip and Next buttons)
  /// Requirement: 12.4
  Widget _buildNavigationControls(
    BuildContext context,
    Phase4FinalTestProvider provider,
  ) {
    final canProceed = provider.canProceed;
    final isLastQuestion = provider.isLastQuestion;
    final buttonText = isLastQuestion ? 'Submit Test' : 'Next';
    final semanticLabel = canProceed
        ? (isLastQuestion ? 'Submit test and view results' : 'Go to next question')
        : 'Please answer the question to continue';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Skip button
            Semantics(
              button: true,
              label: 'Skip this question',
              child: OutlinedButton(
                onPressed: () => _handleSkip(context, provider),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                ),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            
            // Next/Submit button
            Expanded(
              child: Semantics(
                button: true,
                enabled: canProceed,
                label: semanticLabel,
                child: AnimatedScale(
                  scale: canProceed ? 1.0 : 0.98,
                  duration: AppAnimations.normal,
                  child: ElevatedButton(
                    onPressed: canProceed ? () => _handleNext(context, provider) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? AppTheme.primaryColor
                          : Colors.grey[400],
                      disabledBackgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle skip button press
  /// Requirement: 12.4
  void _handleSkip(
    BuildContext context,
    Phase4FinalTestProvider provider,
  ) {
    provider.skipQuestion();
    
    if (provider.isLastQuestion) {
      _submitTest(context, provider);
    } else {
      provider.nextQuestion();
      _announceQuestionChange(context, provider);
    }
  }

  /// Handle next button press
  /// Requirement: 12.4
  Future<void> _handleNext(
    BuildContext context,
    Phase4FinalTestProvider provider,
  ) async {
    if (provider.isLastQuestion) {
      await _submitTest(context, provider);
    } else {
      provider.nextQuestion();
      _announceQuestionChange(context, provider);
    }
  }
  
  /// Announce question change to screen readers
  void _announceQuestionChange(BuildContext context, Phase4FinalTestProvider provider) {
    final question = provider.currentQuestion;
    
    if (question != null && context.mounted) {
      _questionFocusNode.requestFocus();
    }
  }

  /// Submit test and navigate to result screen
  Future<void> _submitTest(
    BuildContext context,
    Phase4FinalTestProvider provider,
  ) async {
    if (provider.isLoading) {
      return;
    }

    try {
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      await provider.submitTest();

      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          print('Error closing loading dialog: $e');
        }
      }

      // Show warning if there was a storage error but results were calculated
      if (context.mounted && provider.error != null && provider.testResult != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry Save',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await provider.retrySubmitTest();
                  if (context.mounted && provider.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Results saved successfully!'),
                        backgroundColor: AppTheme.correctColor,
                      ),
                    );
                  }
                } catch (e) {
                  print('Retry save failed: $e');
                }
              },
            ),
          ),
        );
      }

      // Navigate to result screen if we have results
      if (context.mounted && provider.testResult != null) {
        try {
          await Navigator.of(context).pushReplacementNamed(
            '/phase4/finalTest/result',
            arguments: provider.testResult,
          );
        } catch (navError) {
          print('Navigation error: $navError');
          ErrorHandler.logError('Phase4FinalTestScreen._submitTest - Navigation', navError);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Test completed! Score: ${provider.testResult!.totalScore}/${provider.testResult!.maxScore}',
                ),
                backgroundColor: AppTheme.correctColor,
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to calculate test results. Please try again.'),
            backgroundColor: AppTheme.incorrectColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('Phase4FinalTestScreen._submitTest', e, stackTrace);
      
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${ErrorHandler.getUserMessage(e)}'),
            backgroundColor: AppTheme.incorrectColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitTest(context, provider),
            ),
          ),
        );
      }
    }
  }
}
