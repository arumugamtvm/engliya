import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'progress_indicator.dart';
import 'status_badge.dart';
import '../constants/app_icons.dart';
import '../utils/animations.dart';
import '../../app/theme.dart';

/// Showcase widget to demonstrate all custom widgets and animations
/// This is for development/testing purposes
class WidgetsShowcase extends StatefulWidget {
  const WidgetsShowcase({super.key});

  @override
  State<WidgetsShowcase> createState() => _WidgetsShowcaseState();
}

class _WidgetsShowcaseState extends State<WidgetsShowcase> {
  int _progress = 3;
  bool _showFeedback = false;
  bool _isCorrect = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets Showcase'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // Custom Buttons Section
          _buildSection(
            'Custom Buttons',
            Column(
              children: [
                CustomButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  type: ButtonType.primary,
                ),
                const SizedBox(height: AppTheme.spacingS),
                CustomButton(
                  text: 'Secondary Button',
                  onPressed: () {},
                  type: ButtonType.secondary,
                ),
                const SizedBox(height: AppTheme.spacingS),
                CustomButton(
                  text: 'Outlined Button',
                  onPressed: () {},
                  type: ButtonType.outlined,
                ),
                const SizedBox(height: AppTheme.spacingS),
                CustomButton(
                  text: 'Button with Icon',
                  icon: AppIcons.play,
                  onPressed: () {},
                ),
                const SizedBox(height: AppTheme.spacingS),
                const CustomButton(
                  text: 'Disabled Button',
                  onPressed: null,
                ),
                const SizedBox(height: AppTheme.spacingS),
                const CustomButton(
                  text: 'Loading Button',
                  isLoading: true,
                ),
              ],
            ),
          ),

          // Progress Indicators Section
          _buildSection(
            'Progress Indicators',
            Column(
              children: [
                CustomProgressIndicator(
                  current: _progress,
                  total: 6,
                  showLabel: true,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_progress > 0) _progress--;
                        });
                      },
                      child: const Text('-'),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_progress < 6) _progress++;
                        });
                      },
                      child: const Text('+'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                const CircularLessonProgress(
                  progress: 0.75,
                  child: Text(
                    '75%',
                    style: AppTheme.bodyText2,
                  ),
                ),
              ],
            ),
          ),

          // Status Badges Section
          _buildSection(
            'Status Badges',
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    StatusBadge(status: BadgeStatus.locked),
                    StatusBadge(status: BadgeStatus.inProgress),
                    StatusBadge(status: BadgeStatus.mastered),
                    StatusBadge(status: BadgeStatus.completed),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                const StatusBadge(
                  status: BadgeStatus.locked,
                  showLabel: true,
                ),
                const SizedBox(height: AppTheme.spacingS),
                const StatusBadge(
                  status: BadgeStatus.inProgress,
                  showLabel: true,
                ),
                const SizedBox(height: AppTheme.spacingS),
                const StatusBadge(
                  status: BadgeStatus.mastered,
                  showLabel: true,
                ),
              ],
            ),
          ),

          // Feedback Badge Section
          _buildSection(
            'Feedback Animations',
            Column(
              children: [
                if (_showFeedback)
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: FeedbackBadge(
                        isCorrect: _isCorrect,
                        onComplete: () {
                          setState(() {
                            _showFeedback = false;
                          });
                        },
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCorrect = true;
                            _showFeedback = true;
                          });
                        },
                        icon: const Icon(AppIcons.check),
                        label: const Text('Show Correct'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.correctColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCorrect = false;
                            _showFeedback = true;
                          });
                        },
                        icon: const Icon(AppIcons.close),
                        label: const Text('Show Incorrect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.incorrectColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Icons Section
          _buildSection(
            'App Icons',
            Wrap(
              spacing: AppTheme.spacingM,
              runSpacing: AppTheme.spacingM,
              children: const [
                _IconDemo(icon: AppIcons.volumeUp, label: 'Volume'),
                _IconDemo(icon: AppIcons.mic, label: 'Mic'),
                _IconDemo(icon: AppIcons.checkCircle, label: 'Check'),
                _IconDemo(icon: AppIcons.cancel, label: 'Cancel'),
                _IconDemo(icon: AppIcons.lock, label: 'Lock'),
                _IconDemo(icon: AppIcons.playCircleOutline, label: 'Play'),
                _IconDemo(icon: AppIcons.star, label: 'Star'),
                _IconDemo(icon: AppIcons.home, label: 'Home'),
              ],
            ),
          ),

          // Animations Section
          _buildSection(
            'Animations',
            Column(
              children: [
                const PulseAnimation(
                  child: Icon(
                    AppIcons.star,
                    size: 48,
                    color: AppTheme.masteredColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                ...List.generate(
                  3,
                  (index) => AnimatedListItem(
                    index: index,
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text('Animated Item ${index + 1}'),
                        subtitle: const Text('Staggered animation'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.headline3,
            ),
            const Divider(),
            const SizedBox(height: AppTheme.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}

class _IconDemo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconDemo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }
}
