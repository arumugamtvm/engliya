import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lesson_provider.dart';
import '../../../services/audio_service.dart';
import '../../../../../app/theme.dart';
import '../../../../../core/utils/error_handler.dart';

/// Examples tab widget that displays example sentences with audio playback
/// Requirements: 7.1, 7.2, 7.3, 7.4, 7.5
class ExamplesTab extends StatefulWidget {
  const ExamplesTab({super.key});

  @override
  State<ExamplesTab> createState() => _ExamplesTabState();
}

class _ExamplesTabState extends State<ExamplesTab> {
  final AudioService _audioService = AudioService();
  final Set<int> _playedExamples = {};
  bool _hasMarkedComplete = false;
  int? _currentlyPlayingIndex;
  bool _ttsUnavailable = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioService.init();
    } catch (e) {
      ErrorHandler.logError('ExamplesTab.initAudio', e);
      setState(() {
        _ttsUnavailable = true;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  Future<void> _playExample(int index, String text) async {
    if (_ttsUnavailable) {
      ErrorHandler.showInfoSnackbar(
        context,
        'Audio playback is currently unavailable',
      );
      return;
    }

    setState(() {
      _currentlyPlayingIndex = index;
    });

    try {
      await _audioService.speak(text);
      
      // Mark this example as played
      _playedExamples.add(index);
      
      // Check if we've played 3+ examples
      if (_playedExamples.length >= 3 && !_hasMarkedComplete) {
        _hasMarkedComplete = true;
        if (mounted) {
          final lessonProvider = context.read<LessonProvider>();
          lessonProvider.markExamplesDone();
        }
      }
    } catch (e) {
      ErrorHandler.logError('ExamplesTab.playExample', e);
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
      setState(() {
        _ttsUnavailable = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _currentlyPlayingIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final lesson = lessonProvider.currentLesson;

    if (lesson == null) {
      return const Center(
        child: Text('No lesson data available'),
      );
    }

    final examples = lesson.examples;

    if (examples.isEmpty) {
      return const Center(
        child: Text('No examples available'),
      );
    }

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.headphones,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listen to at least 3 examples',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Played: ${_playedExamples.length} / ${examples.length}',
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_playedExamples.length >= 3)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
        ),

        // Examples list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: examples.length,
            itemBuilder: (context, index) {
              final example = examples[index];
              final isPlayed = _playedExamples.contains(index);
              final isPlaying = _currentlyPlayingIndex == index;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isPlayed
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Audio button
                      Container(
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? AppTheme.accentColor
                              : AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.volume_up,
                            color: Colors.white,
                          ),
                          onPressed: isPlaying
                              ? () => _audioService.stop()
                              : () => _playExample(index, example.en),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // English text
                            Text(
                              example.en,
                              style: AppTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tamil translation
                            Text(
                              example.ta,
                              style: AppTheme.bodyText2.copyWith(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Played indicator
                      if (isPlayed)
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
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
}
