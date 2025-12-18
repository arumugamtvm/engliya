import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debug_provider.dart';
import '../../../../app/theme.dart';

/// Debug Screen UI
/// Provides developer controls for enabling debug mode, unlocking all content, and resetting progress
/// 
/// Requirements: 9.3, 9.4, 10.1, 10.13, 11.1, 11.11, 11.12
/// Accessibility: Screen reader announcements for debug mode state changes - Requirement: 13.8
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize debug provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebugProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Build AppBar with back button and title
  /// Requirement: 9.3
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Semantics(
        button: true,
        label: 'Back',
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      title: const Text(
        'Debug Mode',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }


  /// Build main body content
  Widget _buildBody(BuildContext context) {
    return Consumer<DebugProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacingL),
                
                // Debug mode toggle section
                _buildDebugModeToggleSection(provider),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                // Action buttons section
                _buildActionButtonsSection(provider),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                // Status message display
                if (provider.statusMessage != null)
                  _buildStatusMessage(provider),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                // Close button
                _buildCloseButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build debug mode toggle section
  /// Requirement: 9.4
  /// Accessibility: Announces debug mode state changes to screen readers - Requirement: 13.8
  Widget _buildDebugModeToggleSection(DebugProvider provider) {
    return Semantics(
      label: 'Debug Mode toggle. Currently ${provider.isDebugModeEnabled ? 'enabled' : 'disabled'}',
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
            const Text(
              'Debug Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Debug Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Semantics(
                  toggled: provider.isDebugModeEnabled,
                  label: 'Debug Mode',
                  hint: provider.isDebugModeEnabled 
                      ? 'Double tap to disable debug mode' 
                      : 'Double tap to enable debug mode',
                  child: Switch(
                    value: provider.isDebugModeEnabled,
                    onChanged: provider.isProcessing
                        ? null
                        : (value) {
                            provider.toggleDebugMode(value);
                            // Announce debug mode state change to screen readers
                            _announceDebugModeChange(context, value);
                          },
                    activeTrackColor: Colors.deepOrange.withValues(alpha: 0.5),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.deepOrange;
                      }
                      return null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'When enabled, all phases and lessons become accessible regardless of completion status.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons section
  /// Requirement: 10.1, 11.1
  Widget _buildActionButtonsSection(DebugProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Unlock All button
          _buildUnlockAllButton(provider),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Reset All button
          _buildResetAllButton(provider),
        ],
      ),
    );
  }

  /// Build Unlock All Phases & Lessons button
  /// Requirement: 10.1
  Widget _buildUnlockAllButton(DebugProvider provider) {
    return Semantics(
      button: true,
      label: 'Unlock All Phases and Lessons',
      hint: 'Marks all lessons as mastered and unlocks all phases',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: provider.isProcessing ? null : () => provider.unlockAll(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.correctColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            elevation: 2,
          ),
          icon: provider.isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.lock_open),
          label: Text(
            provider.isProcessing ? 'Processing...' : 'Unlock All Phases & Lessons',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build Reset All Progress button
  /// Requirement: 11.1
  Widget _buildResetAllButton(DebugProvider provider) {
    return Semantics(
      button: true,
      label: 'Reset All Progress',
      hint: 'Clears all lesson progress and resets to fresh state',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: provider.isProcessing
              ? null
              : () => _showResetConfirmationDialog(context, provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.incorrectColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            elevation: 2,
          ),
          icon: provider.isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.restart_alt),
          label: Text(
            provider.isProcessing ? 'Processing...' : 'Reset All Progress',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Announce debug mode state change to screen readers
  /// Accessibility: Uses ScaffoldMessenger for announcements - Requirement: 13.8
  void _announceDebugModeChange(BuildContext context, bool enabled) {
    final message = enabled 
        ? 'Debug mode enabled. All content is now accessible.' 
        : 'Debug mode disabled. Normal gating logic restored.';
    
    // Use SnackBar for visual and screen reader announcement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: enabled ? Colors.deepOrange : AppTheme.primaryColor,
      ),
    );
  }

  /// Show confirmation dialog before resetting all progress
  void _showResetConfirmationDialog(BuildContext context, DebugProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset All Progress?'),
          content: const Text(
            'This will clear all lesson progress, test scores, and unlock status. '
            'Debug mode will also be disabled. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.resetAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.incorrectColor,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  /// Build status message display
  /// Requirement: 10.13, 11.11
  /// Accessibility: Uses liveRegion for automatic screen reader announcements - Requirement: 13.8
  Widget _buildStatusMessage(DebugProvider provider) {
    final isSuccess = provider.statusMessage?.startsWith('✓') ?? false;
    final backgroundColor = isSuccess
        ? const Color(0xFFE8F5E9) // Light green
        : const Color(0xFFFFEBEE); // Light red
    // Use darker colors for better contrast (WCAG 4.5:1 ratio)
    final textColor = isSuccess
        ? const Color(0xFF1B5E20) // Dark green - 7.1:1 contrast on light green bg
        : const Color(0xFFB71C1C); // Dark red - 7.2:1 contrast on light red bg

    return Semantics(
      label: provider.statusMessage,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: textColor,
              size: 24,
              semanticLabel: isSuccess ? 'Success' : 'Error',
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                provider.statusMessage ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Dismiss message',
              child: IconButton(
                icon: Icon(Icons.close, color: textColor, size: 20),
                onPressed: () => provider.clearStatus(),
                tooltip: 'Dismiss',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build close button
  /// Requirement: 11.12
  Widget _buildCloseButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close Debug Screen',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            side: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          icon: const Icon(Icons.close),
          label: const Text(
            'Close',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
