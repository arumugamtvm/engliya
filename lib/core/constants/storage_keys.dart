enum StorageKey {
  onboardingCompleted('onboarding_completed'),
  userName('user_name'),
  userLevel('user_level'),
  lessonProgress('lesson_progress'),
  lessonProgressV2('lesson_progress_v2'),
  masteryData('mastery_data'),
  phase1TestCompleted('phase1_test_completed'),
  phase1TestResult('phase1_test_result'),
  phase1FinalTestPassed('phase_1_final_test_passed'),
  phase2TestCompleted('phase2_test_completed'),
  phase2TestResult('phase2_test_result'),
  phase2FinalTestPassed('phase_2_final_test_passed'),
  phase3TestCompleted('phase3_test_completed'),
  phase3TestResult('phase3_test_result'),
  phase3FinalTestPassed('phase_3_final_test_passed'),
  phase4TestCompleted('phase4_test_completed'),
  phase4TestResult('phase4_test_result'),
  phase4FinalTestPassed('phase_4_final_test_passed'),
  phase5TestCompleted('phase5_test_completed'),
  phase5TestResult('phase5_test_result'),
  phase5FinalTestPassed('phase_5_final_test_passed'),
  debugModeEnabled('debug_mode_enabled'),
  aiApiKey('ai_api_key'),
  lastSyncTime('last_sync_time');

  const StorageKey(this.key);
  final String key;

  String withSuffix(String suffix) => '${key}_$suffix';
  
  @override
  String toString() => key;
}
