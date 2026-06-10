import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/constants/app_strings.dart';
import 'dart:async';

/// Speak tab widget with enhanced UI and mock scoring (fallback version)
/// This version works without speech recognition dependencies
class SpeakTabFallback extends StatefulWidget {
  const SpeakTabFallback({super.key});

  @override
  State<SpeakTabFallback> createState() => _SpeakTabFallbackState();
}

class _SpeakTabFallbackState extends State<SpeakTabFallback> with TickerProviderStateMixin {
  final Map<int, double> _attemptScores = {};
  final Map<int, String> _recognizedTexts = {};
  final Map<int, bool> _isRecording = {};
  final Random _random = Random();
  bool _hasMarkedComplete = false;
  
  final Map<int, AnimationController> _waveControllers = {};
  final Map<int, double> _soundLevels = {};
  
  @override
  void dispose() {
    for (var controller in _waveControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Generate a mock score between 70 and 100
  double _generateMockScore() {
    return 70.0 + (_random.nextDouble() * 30.0);
  }

  /// Simulate recording with enhanced feedback
  Future<void> _recordSentence(int index, String expectedText) async {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);
    
    setState(() {
      _isRecording[index] = true;
      _waveControllers[index] = controller;
      _soundLevels[index] = 0.0;
    });

    // Simulate sound level changes
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording[index]!) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          _soundLevels[index] = 0.3 + (_random.nextDouble() * 0.7);
        });
      }
    });

    // Simulate recording delay
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Generate mock score and simulated recognized text
    final score = _generateMockScore();
    final recognizedText = _generateMockRecognizedText(expectedText, score);

    setState(() {
      _isRecording[index] = false;
      _attemptScores[index] = score;
      _recognizedTexts[index] = recognizedText;
      _soundLevels[index] = 0.0;
    });

    controller.dispose();
    _waveControllers.remove(index);

    _checkCompletion();
  }

  /// Generate mock recognized text based on score
  String _generateMockRecognizedText(String expected, double score) {
    if (score >= 90) {
      return expected; // Perfect match
    } else if (score >= 75) {
      // Minor variation
      final words = expected.split(' ');
      if (words.length > 2) {
        words[words.length - 1] = words[words.length - 1].toLowerCase();
      }
      return words.join(' ');
    } else {
      // More variation
      final words = expected.split(' ');
      if (words.length > 1) {
        return '${words.sublist(0, words.length - 1).join(' ')}...';
      }
      return expected.toLowerCase();
    }
  }

  void _checkCompletion() {
    if (_attemptScores.length < 3) return;

    double totalScore = _attemptScores.values.reduce((a, b) => a + b);
    double averageScore = totalScore / _attemptScores.length;
    double averagePercentage = averageScore / 100.0;

    if (averagePercentage >= 0.7 && !_hasMarkedComplete) {
      _hasMarkedComplete = true;
      if (mounted) {
        final lessonProvider = context.read<LessonProvider>();
        lessonProvider.updateSpeakingScore(averagePercentage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lesson = lessonProvider.currentLesson;

    if (lesson == null) {
      return const Center(child: Text('No lesson data available'));
    }

    final sentences = lesson.speakSentences;
    if (sentences.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.noSpeakingExercises,
          textAlign: TextAlign.center,
        ),
      );
    }

    double averageScore = 0.0;
    if (_attemptScores.isNotEmpty) {
      double totalScore = _attemptScores.values.reduce((a, b) => a + b);
      averageScore = totalScore / _attemptScores.length;
    }

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.1),
                AppTheme.accentColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Practice at least 3 sentences with 70%+ average',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Practiced: ${_attemptScores.length} / ${sentences.length} | Average: ${averageScore.toStringAsFixed(0)}%',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_attemptScores.length >= 3 && averageScore >= 70)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.correctColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.correctColor,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),

        // Sentences list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sentences.length,
            itemBuilder: (context, index) {
              final sentence = sentences[index];
              final score = _attemptScores[index];
              final isRecording = _isRecording[index] ?? false;
              final hasAttempted = score != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: hasAttempted ? 3 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: hasAttempted
                        ? AppTheme.primaryColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Sentence ${index + 1}',
                              style: AppTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (hasAttempted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: score >= 70
                                      ? [AppTheme.correctColor, AppTheme.correctColor.withValues(alpha: 0.8)]
                                      : [AppTheme.warningColor, AppTheme.warningColor.withValues(alpha: 0.8)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (score >= 70 ? AppTheme.correctColor : AppTheme.warningColor)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${score.toStringAsFixed(0)}%',
                                style: AppTheme.bodyText2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Target sentence
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.record_voice_over,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Say this:',
                                  style: AppTheme.bodyText2.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              sentence.en,
                              style: AppTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 18,
                              ),
                            ),
                            if (sentence.ta != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                sentence.ta!,
                                style: AppTheme.bodyText2.copyWith(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Wave animation (when recording)
                      if (isRecording) ...[
                        _buildWaveAnimation(index),
                        const SizedBox(height: 20),
                      ],

                      // Microphone button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: isRecording
                              ? null
                              : () => _recordSentence(index, sentence.en),
                          icon: Icon(
                            isRecording ? Icons.mic : Icons.mic_none,
                            size: 28,
                          ),
                          label: Text(
                            isRecording ? 'Listening...' : 'Tap to Speak',
                            style: AppTheme.buttonText.copyWith(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRecording
                                ? AppTheme.incorrectColor
                                : AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(220, 60),
                            elevation: isRecording ? 8 : 4,
                          ),
                        ),
                      ),

                      // Result display
                      if (hasAttempted) ...[
                        const SizedBox(height: 20),
                        _buildResultDisplay(index, sentence.en, score),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWaveAnimation(int index) {
    final soundLevel = _soundLevels[index] ?? 0.0;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(20, (i) {
          final baseHeight = 10.0;
          final maxHeight = 60.0;
          final height = baseHeight + (soundLevel * maxHeight);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 4,
            height: height.clamp(baseHeight, maxHeight),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.accentColor,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResultDisplay(int index, String expectedText, double score) {
    final recognizedText = _recognizedTexts[index] ?? 'Recording...';
    final isGoodScore = score >= 70;
    final isExcellent = score >= 90;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isGoodScore
                ? AppTheme.correctColor.withValues(alpha: 0.1)
                : AppTheme.warningColor.withValues(alpha: 0.1),
            isGoodScore
                ? AppTheme.correctColor.withValues(alpha: 0.05)
                : AppTheme.warningColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGoodScore ? AppTheme.correctColor : AppTheme.warningColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExcellent
                    ? Icons.star
                    : isGoodScore
                        ? Icons.check_circle
                        : Icons.info,
                color: isGoodScore ? AppTheme.correctColor : AppTheme.warningColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isExcellent
                      ? 'Excellent! 🎉'
                      : isGoodScore
                          ? 'Great job! 👍'
                          : 'Keep practicing! 💪',
                  style: AppTheme.headline3.copyWith(
                    fontSize: 20,
                    color: isGoodScore ? AppTheme.correctColor : AppTheme.warningColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isGoodScore ? AppTheme.correctColor : AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '${score.toStringAsFixed(0)}%',
                  style: AppTheme.bodyText1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You said:',
                      style: AppTheme.bodyText2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  recognizedText,
                  style: AppTheme.bodyText1.copyWith(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expected:',
                      style: AppTheme.bodyText2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  expectedText,
                  style: AppTheme.bodyText1.copyWith(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          if (!isGoodScore) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.infoColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 22,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tips: Speak clearly and at a moderate pace. Make sure you\'re in a quiet environment.',
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 14,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
