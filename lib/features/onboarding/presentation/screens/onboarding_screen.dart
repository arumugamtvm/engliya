import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/user_level.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding screen for level selection
/// Displays when user first opens the app
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // App logo and title section
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon/logo placeholder
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.welcomeTitleEn,
                          style: AppTheme.headline1.copyWith(fontSize: 34),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.welcomeTitleTa,
                          style: AppTheme.headline2.copyWith(
                            fontSize: 20,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.bilingual(
                            AppStrings.welcomeSubtitleEn,
                            AppStrings.welcomeSubtitleTa,
                          ),
                          style: AppTheme.bodyText1.copyWith(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Level selection section
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Text(
                              AppStrings.chooseLevelEn,
                              style: AppTheme.headline2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.chooseLevelTa,
                              style: AppTheme.bodyText2.copyWith(
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: UserLevel.availableLevels.length,
                          itemBuilder: (context, index) {
                            final level = UserLevel.availableLevels[index];
                            final isSelected =
                                provider.selectedLevel?.id == level.id;

                            return _LevelSelectionCard(
                              level: level,
                              isSelected: isSelected,
                              onTap: () => provider.selectLevel(level),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Continue button section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppTheme.incorrectColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ||
                                  !provider.hasSelectedLevel
                              ? null
                              : () => _handleContinue(context, provider),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 4,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  AppStrings.continueLabel,
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleContinue(
    BuildContext context,
    OnboardingProvider provider,
  ) async {
    final success = await provider.completeOnboarding();

    if (success && context.mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }
}

/// Card widget for level selection
class _LevelSelectionCard extends StatelessWidget {
  final UserLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelSelectionCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 6 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.08),
                      AppTheme.accentColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade400,
                    width: 2.5,
                  ),
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 18),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: AppTheme.headline2.copyWith(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level.displayDescription,
                      style: AppTheme.bodyText2.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
