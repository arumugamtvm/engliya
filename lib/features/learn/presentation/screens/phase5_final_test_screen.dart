import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/phase5_final_test_provider.dart';
import '../../data/models/phase5_final_test_question.dart';
import '../../data/models/phase5_test_result.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/constants/app_config.dart';

/// Phase 5 Final Test Screen
/// Displays a 35-task professional English mastery test covering Units 22-25
/// 
/// Test composition:
/// - 8 Business English MCQs (1 point each)
/// - 7 Interview Response MCQs (1 point each)
/// - 6 Presentation Language MCQs (1 point each)
/// - 6 Writing Logic MCQs (1 point each)
/// - 8 Professional Speaking Tasks (0-4 points each)
/// 
/// Requirements: 1.2, 13.1, 13.2, 13.3, 13.4
class Phase5FinalTestScreen extends StatefulWidget {
  const Phase5FinalTestScreen({super.key});

  @override
  State<Phase5FinalTestScreen> createState() => _Phase5FinalTestScreenState();
}

class _Phase5FinalTestScreenState extends State<Phase5FinalTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isRecording = false;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    
    _questionAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeOutCubic),
    );
    
    _questionAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    final provider = context.read<Phase5FinalTestProvider>();
    final canTake = AppConfig.isDevelopmentMode || await provider.canTakeTest();
    
    if (!canTake) return;
    
    try {
      await provider.startTest();
      _questionAnimationController.forward();
    } catch (e) {
      print('Test initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<Phase5FinalTestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<bool>(
            future: provider.canTakeTest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final canTake = AppConfig.isDevelopmentMode || (snapshot.data ?? false);
              if (!canTake) {
                return _buildLockedState(context);
              }

              if (provider.error != null) {
                return _buildErrorState(context, provider);
              }

              if (provider.questions.isEmpty) {
                return const Center(child: Text('No questions available'));
              }

              return _buildTestContent(context, provider);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Phase 5 – Final Test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('Professional English Mastery', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildLockedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            const Text('Test Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacingS),
            const Text('Please master all Phase 5 lessons before taking the Final Test', textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Phase5FinalTestProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(provider.error ?? 'An error occurred', textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: () => provider.retryStartTest(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestContent(BuildContext context, Phase5FinalTestProvider provider) {
    return Column(
      children: [
        _buildProgressSection(provider),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildQuestionContent(context, provider),
            ),
          ),
        ),
        _buildNavigationButtons(context, provider),
      ],
    );
  }

  Widget _buildProgressSection(Phase5FinalTestProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Text('Question ${provider.currentQuestionIndex + 1} / ${provider.totalQuestions}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: AppTheme.spacingS),
          LinearProgressIndicator(value: provider.progress, minHeight: 8),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, Phase5FinalTestProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionTypeChip(question.type),
          const SizedBox(height: AppTheme.spacingM),
          Text(question.prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: AppTheme.spacingL),
          if (question.isMcq)
            _buildMcqOptions(context, provider, question)
          else
            _buildSpeakingTask(context, provider, question),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeChip(Phase5QuestionType type) {
    String label;
    Color color;
    
    switch (type) {
      case Phase5QuestionType.businessEnglish:
        label = 'Business English';
        color = Colors.blue;
        break;
      case Phase5QuestionType.interview:
        label = 'Interview';
        color = Colors.green;
        break;
      case Phase5QuestionType.presentation:
        label = 'Presentation';
        color = Colors.orange;
        break;
      case Phase5QuestionType.writing:
        label = 'Writing';
        color = Colors.purple;
        break;
      case Phase5QuestionType.speaking:
        label = 'Speaking';
        color = Colors.red;
        break;
    }
    
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }

  Widget _buildMcqOptions(BuildContext context, Phase5FinalTestProvider provider, Phase5FinalTestQuestion question) {
    final options = question.options ?? [];
    final selectedIndex = provider.selectedMcqAnswer;

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: InkWell(
            onTap: () => provider.selectMcqAnswer(index),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!, width: isSelected ? 2 : 1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[400]!, width: 2),
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                    child: Center(
                      child: Text(String.fromCharCode(65 + index),
                          style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600])),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(child: Text(option, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpeakingTask(BuildContext context, Phase5FinalTestProvider provider, Phase5FinalTestQuestion question) {
    final speakingResult = provider.currentSpeakingResult;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Column(
            children: [
              Icon(_isRecording ? Icons.mic : Icons.mic_none, size: 64, color: _isRecording ? Colors.red : Colors.grey),
              const SizedBox(height: AppTheme.spacingM),
              Text(_isRecording ? 'Recording... $_recordingSeconds s' : 'Tap to start recording',
                  style: TextStyle(fontSize: 16, color: _isRecording ? Colors.red : Colors.grey[600])),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton.icon(
                onPressed: () => _toggleRecording(provider, question),
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                style: ElevatedButton.styleFrom(backgroundColor: _isRecording ? Colors.red : AppTheme.primaryColor),
              ),
            ],
          ),
        ),
        if (speakingResult != null) ...[
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: AppTheme.spacingS),
                    Text('Score: ${speakingResult.score}/4', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(speakingResult.feedback),
                Text('Words: ${speakingResult.wordCount}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _toggleRecording(Phase5FinalTestProvider provider, Phase5FinalTestQuestion question) {
    if (_isRecording) {
      // Stop recording and create mock result
      setState(() => _isRecording = false);
      
      // Create mock speaking result (in real app, use STT)
      final mockResult = Phase5SpeakingResult.fromRecognition(
        taskId: question.id,
        prompt: question.prompt,
        recognizedText: 'This is a mock response for testing purposes. The actual implementation would use speech-to-text to capture the user response and score it based on word count and clarity.',
      );
      
      provider.recordSpeakingResult(mockResult);
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      
      // Simulate recording timer
      _startRecordingTimer();
    }
  }

  void _startRecordingTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) return false;
      setState(() => _recordingSeconds++);
      return _recordingSeconds < 60; // Max 60 seconds
    });
  }

  Widget _buildNavigationButtons(BuildContext context, Phase5FinalTestProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                provider.skipQuestion();
                if (!provider.isLastQuestion) {
                  provider.nextQuestion();
                  _questionAnimationController.reset();
                  _questionAnimationController.forward();
                }
              },
              child: const Text('Skip'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: provider.canProceed
                  ? () {
                      if (provider.isLastQuestion) {
                        _submitTest(context, provider);
                      } else {
                        provider.nextQuestion();
                        _questionAnimationController.reset();
                        _questionAnimationController.forward();
                      }
                    }
                  : null,
              child: Text(provider.isLastQuestion ? 'Submit Test' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest(BuildContext context, Phase5FinalTestProvider provider) async {
    try {
      await provider.submitTest();
      if (provider.testResult != null && mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/phase5/finalTest/result',
          arguments: provider.testResult,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit test: ${provider.error}')),
      );
    }
  }
}
