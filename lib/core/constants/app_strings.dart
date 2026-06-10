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
}
