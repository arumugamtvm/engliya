/// Bilingual (simple English + Tamil) UI strings for Engliya.
///
/// Tamil Nadu learners using this app often have weak English, so every
/// critical UI instruction or feedback message is shown in BOTH very simple
/// English (A1 level) and natural written Tamil (polite register).
///
/// Conventions:
/// - Each user-facing string has a `xxxEn` (English) and `xxxTa` (Tamil) pair.
/// - Pre-combined strings (e.g. [welcomeTitle]) put Tamil on a second line
///   using [bilingual], or inline using a separator where space is tight.
/// - Widgets that need different styling for the Tamil line should use the
///   separate `En` / `Ta` constants directly.
///
/// This is intentionally a plain constants class (no i18n framework) to keep
/// the app lightweight. Lesson CONTENT already carries its own Tamil; this
/// file only covers UI chrome (buttons, instructions, feedback, dialogs).
class AppStrings {
  AppStrings._(); // No instances; static access only.

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Combines English + Tamil on two lines (most readable for paragraphs,
  /// banners and dialog bodies).
  static String bilingual(String en, String ta) => '$en\n$ta';

  /// Combines English + Tamil on one line (for short labels / buttons
  /// where a line break looks odd).
  static String inline(String en, String ta) => '$en / $ta';

  // ---------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------

  static const String welcomeTitleEn = 'Welcome to Engliya';
  static const String welcomeTitleTa = 'எங்கிலியாவிற்கு வரவேற்கிறோம்';

  static const String welcomeSubtitleEn = 'Learn English step by step';
  static const String welcomeSubtitleTa =
      'படிப்படியாக ஆங்கிலம் கற்றுக்கொள்ளுங்கள்';

  static const String chooseLevelEn = 'Choose your level';
  static const String chooseLevelTa = 'உங்கள் நிலையைத் தேர்ந்தெடுக்கவும்';

  static const String continueEn = 'Continue';
  static const String continueTa = 'தொடரவும்';
  static const String continueLabel = '$continueEn / $continueTa';

  // User levels (display only — stored ids/names stay in English).
  static const String levelBeginnerEn = 'Beginner';
  static const String levelBeginnerTa = 'தொடக்கநிலை';
  static const String levelBeginnerDescEn = 'Start from the basics';
  static const String levelBeginnerDescTa =
      'அடிப்படையிலிருந்து தொடங்குங்கள்';

  static const String levelSchoolStudentEn = 'School Student';
  static const String levelSchoolStudentTa = 'பள்ளி மாணவர்';
  static const String levelSchoolStudentDescEn = 'Learn English for school';
  static const String levelSchoolStudentDescTa =
      'பள்ளிக்காக ஆங்கிலம் கற்றுக்கொள்ளுங்கள்';

  // ---------------------------------------------------------------------
  // Home / Progress
  // ---------------------------------------------------------------------

  static const String yourProgressEn = 'Your Progress';
  static const String yourProgressTa = 'உங்கள் முன்னேற்றம்';

  // Phase subtitle glosses (kept very short — shown inside small badges).
  static const String phaseFoundationEn = 'Foundation';
  static const String phaseFoundationTa = 'அடித்தளம்';
  static const String phaseFoundationLabel =
      '$phaseFoundationEn · $phaseFoundationTa';

  static const String phaseIntermediateEn = 'Intermediate';
  static const String phaseIntermediateTa = 'இடைநிலை';
  static const String phaseIntermediateLabel =
      '$phaseIntermediateEn · $phaseIntermediateTa';

  static const String phaseRealLifeEn = 'Real-Life';
  static const String phaseRealLifeTa = 'அன்றாட உரையாடல்';
  static const String phaseRealLifeLabel =
      '$phaseRealLifeEn · $phaseRealLifeTa';

  static const String phaseFluencyEn = 'Fluency';
  static const String phaseFluencyTa = 'சரளம்';
  static const String phaseFluencyLabel = '$phaseFluencyEn · $phaseFluencyTa';

  static const String phaseProfessionalEn = 'Professional';
  static const String phaseProfessionalTa = 'தொழில்முறை';
  static const String phaseProfessionalLabel =
      '$phaseProfessionalEn · $phaseProfessionalTa';

  // Locked phase / lesson messages.
  static const String lockedPhaseEn = 'Complete previous phase to unlock';
  static const String lockedPhaseTa =
      'முந்தைய நிலையை முடித்து இதைத் திறக்கவும்';
  static const String lockedPhase = '$lockedPhaseEn\n$lockedPhaseTa';

  static const String masterPreviousLessonEn =
      'Please master the previous lesson first';
  static const String masterPreviousLessonTa =
      'முதலில் முந்தைய பாடத்தில் தேர்ச்சி பெறுங்கள்';
  static const String masterPreviousLesson =
      '$masterPreviousLessonEn\n$masterPreviousLessonTa';

  /// Dialog title: "Phase N Locked" + Tamil.
  static String phaseLockedTitle(int phase) =>
      bilingual('Phase $phase Locked', 'நிலை $phase பூட்டப்பட்டுள்ளது');

  /// Dialog title: "Phase N Test Locked" + Tamil.
  static String phaseTestLockedTitle(int phase) => bilingual(
        'Phase $phase Test Locked',
        'நிலை $phase தேர்வு பூட்டப்பட்டுள்ளது',
      );

  /// Dialog body: master all lessons of a phase before its final test.
  static String masterAllPhaseLessonsFirst(int phase) => bilingual(
        'Master all Phase $phase lessons first.',
        'முதலில் நிலை $phase பாடங்கள் அனைத்திலும் தேர்ச்சி பெறுங்கள்.',
      );

  /// Dialog body: finish the previous phase's final test to unlock the next.
  static String completeFinalTestToUnlock(int donePhase, int nextPhase) =>
      bilingual(
        'Complete Phase $donePhase Final Test to unlock Phase $nextPhase.',
        'நிலை $nextPhase-ஐத் திறக்க நிலை $donePhase இறுதித் தேர்வை முடிக்கவும்.',
      );

  // ---------------------------------------------------------------------
  // Lesson screen (loading / error / empty states)
  // ---------------------------------------------------------------------

  static const String loadingEn = 'Loading...';
  static const String loadingTa = 'ஏற்றுகிறது...';
  static const String loading = '$loadingEn / $loadingTa';

  static const String loadingLessonEn = 'Loading lesson...';
  static const String loadingLessonTa = 'பாடம் ஏற்றுகிறது...';
  static const String loadingLesson = '$loadingLessonEn\n$loadingLessonTa';

  static const String errorEn = 'Error';
  static const String errorTa = 'பிழை';
  static const String errorTitle = '$errorEn / $errorTa';

  static const String noLessonDataEn = 'No lesson data available';
  static const String noLessonDataTa = 'பாடத் தகவல் இல்லை';
  static const String noLessonData = '$noLessonDataEn\n$noLessonDataTa';

  static const String goBackTryAgainEn = 'Please go back and try again';
  static const String goBackTryAgainTa =
      'திரும்பிச் சென்று மீண்டும் முயற்சிக்கவும்';
  static const String goBackTryAgain =
      '$goBackTryAgainEn\n$goBackTryAgainTa';

  static const String tryAgainEn = 'Try Again';
  static const String tryAgainTa = 'மீண்டும் முயற்சி';
  static const String tryAgain = '$tryAgainEn / $tryAgainTa';

  static const String errorLoadingLessonsEn = 'Error loading lessons';
  static const String errorLoadingLessonsTa = 'பாடங்களை ஏற்ற முடியவில்லை';
  static const String errorLoadingLessons =
      '$errorLoadingLessonsEn\n$errorLoadingLessonsTa';

  static const String errorLoadingUnitsEn = 'Error loading units';
  static const String errorLoadingUnitsTa = 'பகுதிகளை ஏற்ற முடியவில்லை';
  static const String errorLoadingUnits =
      '$errorLoadingUnitsEn\n$errorLoadingUnitsTa';

  static const String noLessonsAvailableEn = 'No lessons available';
  static const String noLessonsAvailableTa = 'பாடங்கள் எதுவும் இல்லை';
  static const String noLessonsAvailable =
      '$noLessonsAvailableEn\n$noLessonsAvailableTa';

  static const String noUnitsAvailableEn = 'No units available';
  static const String noUnitsAvailableTa = 'பகுதிகள் எதுவும் இல்லை';
  static const String noUnitsAvailable =
      '$noUnitsAvailableEn\n$noUnitsAvailableTa';

  // ---------------------------------------------------------------------
  // Lesson tabs — shared feedback
  // ---------------------------------------------------------------------

  static const String correctEn = 'Correct!';
  static const String correctTa = 'சரி!';
  static const String correct = '$correctEn / $correctTa';

  static const String incorrectEn = 'Incorrect';
  static const String incorrectTa = 'தவறு';
  static const String incorrect = '$incorrectEn / $incorrectTa';

  static const String completedEn = 'Completed!';
  static const String completedTa = 'முடிந்தது!';
  static const String completed = '$completedEn / $completedTa';

  // ---------------------------------------------------------------------
  // Explain tab
  // ---------------------------------------------------------------------

  static const String scrollToCompleteEn = 'Scroll to bottom to complete';
  static const String scrollToCompleteTa = 'முடிக்க கீழே உருட்டவும்';

  // ---------------------------------------------------------------------
  // Examples tab
  // ---------------------------------------------------------------------

  static const String listenToExamplesEn = 'Listen to at least 3 examples';
  static const String listenToExamplesTa =
      'குறைந்தது 3 எடுத்துக்காட்டுகளைக் கேளுங்கள்';

  // ---------------------------------------------------------------------
  // Listen tab
  // ---------------------------------------------------------------------

  static const String listenRuleEn =
      'Answer at least 3 questions with 70%+ accuracy';
  static const String listenRuleTa =
      'குறைந்தது 3 கேள்விகளுக்கு 70% சரியாக பதிலளிக்கவும்';

  static const String listenRetryMessageEn =
      'You answered all questions, but you need 70% to continue. '
      'Do not worry — try again, you can do it!';
  static const String listenRetryMessageTa =
      'எல்லா கேள்விகளுக்கும் பதிலளித்தீர்கள், ஆனால் தொடர 70% தேவை. '
      'கவலை வேண்டாம் — மீண்டும் முயற்சிக்கவும், உங்களால் முடியும்!';

  // ---------------------------------------------------------------------
  // Speak tab
  // ---------------------------------------------------------------------

  static const String speakRuleEn =
      'Practice at least 3 sentences with 70%+ average';
  static const String speakRuleTa =
      'குறைந்தது 3 வாக்கியங்களை 70% சராசரியுடன் பயிற்சி செய்யுங்கள்';

  static const String sayThisEn = 'Say this';
  static const String sayThisTa = 'இதைச் சொல்லுங்கள்';
  static const String sayThis = '$sayThisEn / $sayThisTa';

  static const String tapToSpeakEn = 'Tap to Speak';
  static const String tapToSpeakTa = 'பேசத் தட்டவும்';
  static const String tapToSpeak = '$tapToSpeakEn\n$tapToSpeakTa';

  static const String listeningEn = 'Listening...';
  static const String listeningTa = 'கேட்கிறது...';
  static const String listening = '$listeningEn\n$listeningTa';

  // Speaking score feedback (pass / fail bands).
  static const String excellentEn = 'Excellent!';
  static const String excellentTa = 'அருமை!';
  static const String excellent = '$excellentEn / $excellentTa';

  static const String greatJobEn = 'Great job!';
  static const String greatJobTa = 'மிகச் சிறப்பு!';
  static const String greatJob = '$greatJobEn / $greatJobTa';

  static const String goodTryEn = 'Good try! Keep practicing';
  static const String goodTryTa =
      'நல்ல முயற்சி! தொடர்ந்து பயிற்சி செய்யுங்கள்';
  static const String goodTry = '$goodTryEn\n$goodTryTa';

  static const String tryAgainListenEn = 'Try again! Listen carefully';
  static const String tryAgainListenTa =
      'மீண்டும் முயற்சிக்கவும்! கவனமாகக் கேளுங்கள்';
  static const String tryAgainListen =
      '$tryAgainListenEn\n$tryAgainListenTa';

  // ---------------------------------------------------------------------
  // Practice tab
  // ---------------------------------------------------------------------

  static const String practiceRuleEn = 'Answer all questions to complete';
  static const String practiceRuleTa =
      'எல்லா கேள்விகளுக்கும் பதிலளியுங்கள்';

  static const String practicePassedEn = 'Great job! You passed!';
  static const String practicePassedTa =
      'மிகச் சிறப்பு! தேர்ச்சி பெற்றீர்கள்!';
  static const String practicePassed =
      '$practicePassedEn\n$practicePassedTa';

  static const String practiceFailedEn = 'Keep practicing to improve!';
  static const String practiceFailedTa =
      'மேம்படத் தொடர்ந்து பயிற்சி செய்யுங்கள்!';
  static const String practiceFailed =
      '$practiceFailedEn\n$practiceFailedTa';

  // ---------------------------------------------------------------------
  // Mastery tab
  // ---------------------------------------------------------------------

  static const String masteryRuleEn =
      'Complete this test with 80% or higher to master this lesson';
  static const String masteryRuleTa =
      'இந்தப் பாடத்தில் தேர்ச்சி பெற 80% அல்லது அதற்கு மேல் மதிப்பெண் பெறுங்கள்';

  static const String lessonMasteredEn = 'Lesson Mastered!';
  static const String lessonMasteredTa = 'பாடம் கற்றுக்கொண்டீர்கள்!';
  static const String lessonMastered =
      '$lessonMasteredEn / $lessonMasteredTa';

  static const String keepPracticingEn = 'Keep Practicing';
  static const String keepPracticingTa =
      'தொடர்ந்து பயிற்சி செய்யுங்கள்';
  static const String keepPracticing =
      '$keepPracticingEn / $keepPracticingTa';

  static const String masteryPassedDetailEn =
      'Congratulations! You mastered this lesson.';
  static const String masteryPassedDetailTa =
      'வாழ்த்துகள்! இந்தப் பாடத்தைக் கற்றுக்கொண்டீர்கள்.';
  static const String masteryPassedDetail =
      '$masteryPassedDetailEn\n$masteryPassedDetailTa';

  static const String masteryFailedDetailEn =
      'You need 80% or higher to master this lesson.';
  static const String masteryFailedDetailTa =
      'இந்தப் பாடத்தில் தேர்ச்சி பெற 80% அல்லது அதற்கு மேல் தேவை.';
  static const String masteryFailedDetail =
      '$masteryFailedDetailEn\n$masteryFailedDetailTa';

  // ---------------------------------------------------------------------
  // Lesson tabs — empty states
  // ---------------------------------------------------------------------

  static const String noExamplesEn = 'No examples available';
  static const String noExamplesTa = 'எடுத்துக்காட்டுகள் இல்லை';
  static const String noExamples = '$noExamplesEn\n$noExamplesTa';

  static const String noListeningQuestionsEn =
      'No listening questions available';
  static const String noListeningQuestionsTa = 'கேட்கும் கேள்விகள் இல்லை';
  static const String noListeningQuestions =
      '$noListeningQuestionsEn\n$noListeningQuestionsTa';

  static const String noPracticeQuestionsEn =
      'No practice questions available';
  static const String noPracticeQuestionsTa = 'பயிற்சி கேள்விகள் இல்லை';
  static const String noPracticeQuestions =
      '$noPracticeQuestionsEn\n$noPracticeQuestionsTa';

  static const String noSpeakingExercisesEn =
      'No speaking exercises available';
  static const String noSpeakingExercisesTa = 'பேச்சுப் பயிற்சிகள் இல்லை';
  static const String noSpeakingExercises =
      '$noSpeakingExercisesEn\n$noSpeakingExercisesTa';

  // ---------------------------------------------------------------------
  // Final tests — locked / loading / error states
  // ---------------------------------------------------------------------

  static const String testLockedEn = 'Test Locked';
  static const String testLockedTa = 'தேர்வு பூட்டப்பட்டுள்ளது';
  static const String testLocked = '$testLockedEn\n$testLockedTa';

  /// Locked-state body: master all lessons of a phase before its final test.
  static String finalTestLockedDescription(int phase) => bilingual(
        'Please master all Phase $phase lessons before taking the final test',
        'இறுதித் தேர்வு எழுத முதலில் Phase $phase-இன் எல்லா பாடங்களையும் '
            'கற்றுக்கொள்ளுங்கள்',
      );

  static const String goBackEn = 'Go Back';
  static const String goBackTa = 'திரும்பிச் செல்லவும்';
  static const String goBack = '$goBackEn / $goBackTa';

  static const String noQuestionsEn = 'No questions available';
  static const String noQuestionsTa = 'கேள்விகள் எதுவும் இல்லை';
  static const String noQuestions = '$noQuestionsEn\n$noQuestionsTa';

  static const String tryAgainMomentEn = 'Please try again in a moment.';
  static const String tryAgainMomentTa =
      'சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.';
  static const String tryAgainMoment = '$tryAgainMomentEn\n$tryAgainMomentTa';

  static const String unableToLoadTestEn = 'Unable to load test';
  static const String unableToLoadTestTa = 'தேர்வை ஏற்ற முடியவில்லை';
  static const String unableToLoadTest =
      '$unableToLoadTestEn\n$unableToLoadTestTa';

  static const String retryEn = 'Retry';
  static const String retryTa = 'மீண்டும் முயற்சி';
  static const String retry = '$retryEn / $retryTa';

  static const String retryingEn = 'Retrying...';
  static const String retryingTa = 'முயற்சிக்கிறது...';
  static const String retrying = '$retryingEn / $retryingTa';

  // Final test navigation buttons (short Tamil for compact buttons).
  static const String nextEn = 'Next';
  static const String nextTa = 'அடுத்து';
  static const String next = '$nextEn / $nextTa';

  static const String skipEn = 'Skip';
  static const String skipTa = 'தவிர்க்கவும்';
  static const String skip = '$skipEn / $skipTa';

  static const String submitTestEn = 'Submit Test';
  static const String submitTestTa = 'சமர்ப்பிக்கவும்';
  static const String submitTest = '$submitTestEn / $submitTestTa';

  // ---------------------------------------------------------------------
  // Final test results
  // ---------------------------------------------------------------------

  static const String testResultsEn = 'Test Results';
  static const String testResultsTa = 'தேர்வு முடிவுகள்';
  static const String testResults = '$testResultsEn / $testResultsTa';

  /// Title: "Phase N Final Test Completed!" + Tamil.
  static String finalTestCompletedTitle(int phase) => bilingual(
        'Phase $phase Final Test Completed!',
        'Phase $phase இறுதித் தேர்வு முடிந்தது!',
      );

  static const String congratulationsEn = 'Congratulations!';
  static const String congratulationsTa = 'வாழ்த்துகள்!';
  static const String congratulations =
      '$congratulationsEn / $congratulationsTa';

  static const String notPassedEn = 'Not Passed';
  static const String notPassedTa = 'தேர்ச்சி இல்லை';
  static const String notPassed = '$notPassedEn / $notPassedTa';

  // Compact pass/fail status banners (kept short — shown at large font size).
  static const String testPassedStatus = 'PASSED ✅ · தேர்ச்சி';
  static const String testNotPassedStatus = 'NOT PASSED ❌ · தேர்ச்சி இல்லை';

  /// Pass message: "You have mastered Phase N" + Tamil.
  static String phaseMasteredMessage(int phase) => bilingual(
        'You have mastered Phase $phase',
        'Phase $phase-ஐ வெற்றிகரமாக முடித்துவிட்டீர்கள்!',
      );

  static const String phase1FoundationMasteredEn =
      'You have mastered the entire Phase 1 foundation';
  static const String phase1FoundationMasteredTa =
      'Phase 1 அடித்தளம் முழுவதையும் கற்றுக்கொண்டீர்கள்';
  static const String phase1FoundationMastered =
      '$phase1FoundationMasteredEn\n$phase1FoundationMasteredTa';

  /// Fail message: keep practicing to master a phase.
  static String keepPracticingPhase(int phase) => bilingual(
        'Keep practicing to master Phase $phase content',
        'Phase $phase-இல் தேர்ச்சி பெற தொடர்ந்து பயிற்சி செய்யுங்கள்',
      );

  /// Fail message with score: "You scored N%. Try again to pass Phase N".
  static String scoredTryAgainMessage(String percent, int phase) => bilingual(
        'You scored $percent%. Try again to pass Phase $phase',
        'நீங்கள் $percent% மதிப்பெண் பெற்றீர்கள். '
            'Phase $phase-இல் தேர்ச்சி பெற மீண்டும் முயற்சிக்கவும்',
      );

  /// Fail message: "You are close! Review Phase N lessons and try again".
  static String reviewPhaseTryAgain(int phase) => bilingual(
        'You are close! Review Phase $phase lessons and try again',
        'நெருக்கமாக உள்ளீர்கள்! Phase $phase பாடங்களை மீண்டும் படித்து '
            'மீண்டும் முயற்சிக்கவும்',
      );

  // Phase 4 final test status messages (English line + Tamil line pairs).
  static const String phase4PassedMessage =
      'Congratulations! You have mastered Phase 4.\n'
      'வாழ்த்துகள்! Phase 4-ஐ வெற்றிகரமாக முடித்துவிட்டீர்கள்!\n'
      'Phase 5 - Professional English is now unlocked!\n'
      'Phase 5 இப்போது திறக்கப்பட்டுள்ளது!';
  static const String phase4FailedMessage =
      'You are close! Review Phase 4 lessons and try again.\n'
      'நெருக்கமாக உள்ளீர்கள்! பாடங்களை மீண்டும் படித்து '
      'மீண்டும் முயற்சிக்கவும்.\n'
      'You need 18 points (75%) to pass.\n'
      'தேர்ச்சி பெற 18 மதிப்பெண்கள் (75%) தேவை.';

  // Phase 5 final test status messages.
  static const String programCompletedEn =
      'You have completed the English Communication Mastery Program!';
  static const String programCompletedTa =
      'ஆங்கிலத் தொடர்புத் திறன் முழுமைத் திட்டத்தை '
      'வெற்றிகரமாக முடித்துவிட்டீர்கள்!';
  static const String programCompleted =
      '$programCompletedEn\n$programCompletedTa';

  static const String phase5FailedEn =
      'You are very close. Review Phase 5 lessons and try again.';
  static const String phase5FailedTa =
      'மிக நெருக்கமாக உள்ளீர்கள். Phase 5 பாடங்களை மீண்டும் படித்து '
      'மீண்டும் முயற்சிக்கவும்.';
  static const String phase5FailedMessage =
      '$phase5FailedEn\n$phase5FailedTa';

  /// Badge: "Phase N Unlocked!" + Tamil inline.
  static String phaseUnlockedBadge(int phase) =>
      inline('Phase $phase Unlocked!', 'Phase $phase திறக்கப்பட்டது!');

  static const String certifiedBadge = 'CERTIFIED ✔️ · சான்றிதழ் பெற்றீர்கள்';

  /// Snackbar: "Phase N is now unlocked!" + Tamil.
  static String phaseNowUnlocked(int phase) => bilingual(
        'Phase $phase is now unlocked!',
        'Phase $phase இப்போது திறக்கப்பட்டது!',
      );

  /// Snackbar: "Phase N will be unlocked soon!" + Tamil.
  static String phaseUnlockedSoon(int phase) => bilingual(
        'Phase $phase will be unlocked soon!',
        'Phase $phase விரைவில் திறக்கப்படும்!',
      );

  static const String startingNewTestEn = 'Starting a new test...';
  static const String startingNewTestTa = 'புதிய தேர்வு தொடங்குகிறது...';
  static const String startingNewTest =
      '$startingNewTestEn\n$startingNewTestTa';

  static const String certificateSoonEn = 'Certificate download coming soon!';
  static const String certificateSoonTa =
      'சான்றிதழ் பதிவிறக்கம் விரைவில் வரும்!';
  static const String certificateSoon =
      '$certificateSoonEn\n$certificateSoonTa';

  static const String passingScoreEn = 'Passing Score';
  static const String passingScoreTa = 'தேர்ச்சி மதிப்பெண்';
  static const String passingScoreLabel = '$passingScoreEn / $passingScoreTa';

  // Result section labels.
  static const String scoreBreakdownEn = 'Score Breakdown';
  static const String scoreBreakdownTa = 'மதிப்பெண் விவரம்';
  static const String scoreBreakdown = '$scoreBreakdownEn / $scoreBreakdownTa';

  static const String summaryEn = 'Summary';
  static const String summaryTa = 'சுருக்கம்';
  static const String summary = '$summaryEn / $summaryTa';

  static const String breakdownEn = 'Breakdown';
  static const String breakdownTa = 'விவரம்';
  static const String breakdown = '$breakdownEn / $breakdownTa';

  static const String mcqQuestionsEn = 'MCQ Questions';
  static const String mcqQuestionsTa = 'MCQ கேள்விகள்';
  static const String mcqQuestions = '$mcqQuestionsEn / $mcqQuestionsTa';

  static const String speakingTasksEn = 'Speaking Tasks';
  static const String speakingTasksTa = 'பேச்சுப் பணிகள்';
  static const String speakingTasks = '$speakingTasksEn / $speakingTasksTa';

  static const String totalScoreEn = 'Total Score';
  static const String totalScoreTa = 'மொத்த மதிப்பெண்';
  static const String totalScore = '$totalScoreEn / $totalScoreTa';

  // Result action buttons.
  static const String reviewMistakesEn = 'Review Mistakes';
  static const String reviewMistakesTa = 'தவறுகளைப் பாருங்கள்';
  static const String reviewMistakes = '$reviewMistakesEn / $reviewMistakesTa';

  static const String downloadCertificateEn = 'Download Certificate';
  static const String downloadCertificateTa = 'சான்றிதழைப் பதிவிறக்கவும்';
  static const String downloadCertificate =
      '$downloadCertificateEn / $downloadCertificateTa';

  static const String returnToHomeEn = 'Return to Home';
  static const String returnToHomeTa = 'முகப்புக்குத் திரும்பவும்';
  static const String returnToHome = '$returnToHomeEn / $returnToHomeTa';

  /// Button: "Continue to Phase N" + Tamil inline.
  static String continueToPhase(int phase) =>
      inline('Continue to Phase $phase', 'Phase $phase-க்குத் தொடரவும்');

  // ---------------------------------------------------------------------
  // Final test review screens
  // ---------------------------------------------------------------------

  static const String reviewEn = 'Review';
  static const String reviewTa = 'மீள்பார்வை';
  static const String review = '$reviewEn / $reviewTa';

  static const String yourAnswerEn = 'Your answer';
  static const String yourAnswerTa = 'உங்கள் பதில்';
  static const String yourAnswer = '$yourAnswerEn / $yourAnswerTa';

  static const String correctAnswerEn = 'Correct answer';
  static const String correctAnswerTa = 'சரியான பதில்';
  static const String correctAnswer = '$correctAnswerEn / $correctAnswerTa';

  static const String perfectScoreEn = 'Perfect Score!';
  static const String perfectScoreTa = 'முழு மதிப்பெண்!';
  static const String perfectScore = '$perfectScoreEn / $perfectScoreTa';

  static const String noMistakesEn = 'No mistakes to review';
  static const String noMistakesTa = 'தவறுகள் எதுவும் இல்லை';
  static const String noMistakes = '$noMistakesEn\n$noMistakesTa';

  static const String allMcqCorrectEn =
      'You answered all MCQ questions correctly.';
  static const String allMcqCorrectTa =
      'எல்லா MCQ கேள்விகளுக்கும் சரியாகப் பதிலளித்துள்ளீர்கள்.';
  static const String allMcqCorrect = '$allMcqCorrectEn\n$allMcqCorrectTa';

  static const String backToResultsEn = 'Back to Results';
  static const String backToResultsTa = 'முடிவுகளுக்குத் திரும்பவும்';
  static const String backToResults = '$backToResultsEn / $backToResultsTa';

  static const String doneEn = 'Done';
  static const String doneTa = 'முடிந்தது';
  static const String done = '$doneEn / $doneTa';

  /// Card header: "Question N" + Tamil inline (numbers stay numeric).
  static String questionNumberLabel(int number) =>
      inline('Question $number', 'கேள்வி $number');

  /// Review header: "You made N mistake(s)" + Tamil.
  static String youMadeMistakes(int count) => bilingual(
        'You made $count mistake${count == 1 ? '' : 's'}',
        'நீங்கள் $count தவறு${count == 1 ? '' : 'கள்'} செய்துள்ளீர்கள்',
      );

  /// Review header: "You got N question(s) wrong. Review them below:" + Tamil.
  static String questionsWrongReview(int count) => bilingual(
        'You got $count question${count == 1 ? '' : 's'} wrong. '
            'Review them below:',
        '$count கேள்வி${count == 1 ? 'க்கு' : 'களுக்கு'} தவறாகப் '
            'பதிலளித்தீர்கள். கீழே மீண்டும் பாருங்கள்:',
      );

  /// Info banner: "N incorrect answer(s) to review" + Tamil.
  static String incorrectAnswersToReview(int count) => bilingual(
        '$count incorrect answer${count == 1 ? '' : 's'} to review',
        '$count தவறான பதில்${count == 1 ? ' உள்ளது' : 'கள் உள்ளன'}',
      );
}
