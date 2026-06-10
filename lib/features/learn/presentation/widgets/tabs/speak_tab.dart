import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/constants/app_strings.dart';
import 'dart:async';

/// Speak tab widget with enhanced UI and mock scoring
/// Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6
class SpeakTab extends StatefulWidget {
  const SpeakTab({super.key});

  @override
  State<SpeakTab> createState() => _SpeakTabState();
}

class _SpeakTabState extends State<SpeakTab> with TickerProviderStateMixin {
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

  /// Generate a realistic mock score with varied difficulty
  /// First attempts: 40-75% (learning phase)
  /// Later attempts: 60-95% (improving phase)
  double _generateMockScore(int attemptNumber) {
    // Make it progressively easier as user practices
    if (attemptNumber == 0) {
      // First attempt: 40-75%
      return 40.0 + (_random.nextDouble() * 35.0);
    } else if (attemptNumber == 1) {
      // Second attempt: 50-85%
      return 50.0 + (_random.nextDouble() * 35.0);
    } else {
      // Third+ attempt: 60-95%
      return 60.0 + (_random.nextDouble() * 35.0);
    }
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
    final attemptNumber = _attemptScores.length;
    final score = _generateMockScore(attemptNumber);
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

  /// Generate mock recognized text based on score with realistic variations
  String _generateMockRecognizedText(String expected, double score) {
    final words = expected.split(' ');
    
    if (score >= 90) {
      // Excellent: Perfect or near-perfect match
      return expected;
    } else if (score >= 75) {
      // Good: Minor pronunciation issues
      if (words.length > 2) {
        // Change one word slightly
        final variations = [
          words.join(' ').toLowerCase(), // All lowercase
          words.map((w) => w.toLowerCase()).join(' '), // Lowercase words
          '${words.sublist(0, words.length - 1).join(' ')} ${words.last.toLowerCase()}',
        ];
        return variations[_random.nextInt(variations.length)];
      }
      return expected.toLowerCase();
    } else if (score >= 60) {
      // Fair: Missing or wrong words
      if (words.length > 2) {
        final variations = [
          words.sublist(0, words.length - 1).join(' '), // Missing last word
          '${words.first} ... ${words.last}', // Missing middle
          words.map((w) => w.toLowerCase()).take(words.length - 1).join(' '),
        ];
        return variations[_random.nextInt(variations.length)];
      } else if (words.length == 2) {
        return words.first.toLowerCase(); // Only first word
      }
      return expected.toLowerCase();
    } else if (score >= 45) {
      // Poor: Significant errors
      if (words.length > 1) {
        final variations = [
          words.first.toLowerCase(), // Only first word
          '${words.first.toLowerCase()}...', // Incomplete
          '...${words.last.toLowerCase()}', // Only last word
        ];
        return variations[_random.nextInt(variations.length)];
      }
      return '${expected.substring(0, (expected.length * 0.6).toInt())}...';
    } else {
      // Very poor: Barely recognized
      return words.isNotEmpty ? '${words.first.toLowerCase()}...' : 'unclear speech';
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
      return const Center(
        child: Text(
          AppStrings.noLessonData,
          textAlign: TextAlign.center,
        ),
      );
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

    lessonProvider.updateSpeakProgress(
      practicedCount: _attemptScores.length,
      totalCount: sentences.length,
      averageScore: averageScore / 100.0,
    );

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
                      AppStrings.speakRuleEn,
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.speakRuleTa,
                      style: AppTheme.bodyText2.copyWith(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
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
                                Expanded(
                                  child: Text(
                                    AppStrings.sayThis,
                                    style: AppTheme.bodyText2.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
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
                            isRecording
                                ? AppStrings.listening
                                : AppStrings.tapToSpeak,
                            textAlign: TextAlign.center,
                            style: AppTheme.buttonText.copyWith(
                              fontSize: 15,
                              height: 1.3,
                            ),
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
    final isExcellent = score >= 90;
    final isGoodScore = score >= 70;
    final isFairScore = score >= 50;
    
    Color scoreColor;
    if (isGoodScore) {
      scoreColor = AppTheme.correctColor;
    } else if (isFairScore) {
      scoreColor = AppTheme.warningColor;
    } else {
      scoreColor = AppTheme.incorrectColor;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor,
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
                        : isFairScore
                            ? Icons.info
                            : Icons.error_outline,
                color: scoreColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isExcellent
                      ? AppStrings.excellent
                      : isGoodScore
                          ? AppStrings.greatJob
                          : isFairScore
                              ? AppStrings.goodTry
                              : AppStrings.tryAgainListen,
                  style: AppTheme.headline3.copyWith(
                    fontSize: isGoodScore ? 18 : 15,
                    height: 1.3,
                    color: scoreColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor,
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
                      isFairScore
                          ? 'Tips: Listen to the example first, then speak clearly at a moderate pace.'
                          : 'Tips: Listen carefully to the example. Repeat each word slowly, then try the full sentence.',
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
