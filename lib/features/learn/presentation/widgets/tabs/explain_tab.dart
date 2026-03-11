import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/lesson_provider.dart';
import '../../../../../app/theme.dart';

class ExplainTab extends StatefulWidget {
  const ExplainTab({super.key});

  @override
  State<ExplainTab> createState() => _ExplainTabState();
}

class _ExplainTabState extends State<ExplainTab> {
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  bool _hasMarkedComplete = false;
  bool _isSpeakingTamil = false;
  bool _isSpeakingEnglish = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5); // Slower for learning
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeakingTamil = false;
          _isSpeakingEnglish = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakTamil(String text) async {
    if (_isSpeakingTamil) {
      await _flutterTts.stop();
      setState(() => _isSpeakingTamil = false);
      return;
    }

    setState(() => _isSpeakingTamil = true);
    await _flutterTts.setLanguage('ta-IN'); // Tamil
    await _flutterTts.speak(text);
  }

  Future<void> _speakEnglish(String text) async {
    if (_isSpeakingEnglish) {
      await _flutterTts.stop();
      setState(() => _isSpeakingEnglish = false);
      return;
    }

    setState(() => _isSpeakingEnglish = true);
    await _flutterTts.setLanguage('en-US'); // English
    await _flutterTts.speak(text);
  }

  void _onScroll() {
    final lessonProvider = context.read<LessonProvider>();
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;
    lessonProvider.updateExplainProgress(scrolledToBottom: isAtBottom);

    if (_hasMarkedComplete) return;

    // Check if scrolled to bottom
    if (isAtBottom) {
      _hasMarkedComplete = true;
      lessonProvider.markExplainDone();
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

    final explain = lesson.explain;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro video/image section (if available)
          if (lesson.explain.videoUrl != null || lesson.explain.images != null) ...[
            _buildMediaSection(lesson.explain),
            const SizedBox(height: 24),
          ],

          // Tamil explanation section with speaker
          _buildSectionHeaderWithSpeaker(
            'விளக்கம் (Tamil)',
            Icons.translate,
            () => _speakTamil(explain.ta),
            _isSpeakingTamil,
          ),
          const SizedBox(height: 12),
          _buildExplanationText(explain.ta),
          const SizedBox(height: 24),

          // English explanation section with speaker
          _buildSectionHeaderWithSpeaker(
            'Explanation (English)',
            Icons.language,
            () => _speakEnglish(explain.en),
            _isSpeakingEnglish,
          ),
          const SizedBox(height: 12),
          _buildExplanationText(explain.en),

          // Table section (if present and has valid data)
          if (_hasValidTableData(explain.table)) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Reference Table', Icons.table_chart),
            const SizedBox(height: 12),
            _buildTable(explain.table!),
          ],

          // Bottom spacing
          const SizedBox(height: 40),
          
          // Completion indicator - only show if not completed
          if (!_hasMarkedComplete && !(lessonProvider.currentStatus?.explainDone ?? false)) ...[
            Center(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.grey[400],
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Scroll to bottom to complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Icon(
                Icons.check_circle,
                color: AppTheme.correctColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Completed!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.correctColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderWithSpeaker(
    String title,
    IconData icon,
    VoidCallback onSpeak,
    bool isSpeaking,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        // Speaker button
        Container(
          decoration: BoxDecoration(
            color: isSpeaking
                ? AppTheme.accentColor
                : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isSpeaking ? Icons.stop : Icons.volume_up,
              color: isSpeaking ? Colors.white : AppTheme.primaryColor,
            ),
            onPressed: onSpeak,
            tooltip: isSpeaking ? 'Stop' : 'Listen',
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection(dynamic explain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visual Learning', Icons.play_circle_outline),
        const SizedBox(height: 12),
        
        // Video placeholder (if videoUrl exists)
        if (explain.videoUrl != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video Explanation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to play',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Images/GIFs (if images exist)
        if (explain.images != null && explain.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: explain.images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visual ${index + 1}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Info message
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.infoColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Videos and images will be added soon to enhance your learning experience!',
                  style: TextStyle(
                    color: AppTheme.infoColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTheme.bodyText1.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  /// Check if table has valid data (at least one row with non-empty content)
  bool _hasValidTableData(List<dynamic>? tableRows) {
    if (tableRows == null || tableRows.isEmpty) return false;
    return tableRows.any((row) {
      final pronoun = row.pronoun ?? '';
      final descEn = row.descriptionEn ?? '';
      final descTa = row.descriptionTa ?? '';
      return pronoun.isNotEmpty || descEn.isNotEmpty || descTa.isNotEmpty;
    });
  }

  Widget _buildTable(List<dynamic> tableRows) {
    // Filter out empty rows
    final validRows = tableRows.where((row) {
      final pronoun = row.pronoun ?? '';
      final descEn = row.descriptionEn ?? '';
      final descTa = row.descriptionTa ?? '';
      return pronoun.isNotEmpty || descEn.isNotEmpty || descTa.isNotEmpty;
    }).toList();

    if (validRows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            children: [
              _buildTableCell('Pronoun', isHeader: true),
              _buildTableCell('English', isHeader: true),
              _buildTableCell('Tamil', isHeader: true),
            ],
          ),
          // Data rows (only valid ones)
          ...validRows.map((row) {
            return TableRow(
              children: [
                _buildTableCell(row.pronoun ?? ''),
                _buildTableCell(row.descriptionEn ?? ''),
                _buildTableCell(row.descriptionTa ?? ''),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 16 : 15,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppTheme.primaryColor : Colors.black87,
        ),
      ),
    );
  }
}
