abstract class HybridFinalTestProvider<Q, S, R> {
  List<Q> get questions;
  Q? get currentQuestion;
  int get currentQuestionIndex;
  int get totalQuestions;
  double get progress;
  bool get isLastQuestion;
  bool get canProceed;
  bool get isLoading;
  String? get error;
  R? get testResult;

  int? get selectedMcqAnswer;
  S? get currentSpeakingResult;
  bool get isCurrentQuestionMcq;
  bool get isCurrentQuestionSpeaking;

  Future<void> startTest({int retryCount});
  Future<void> retryStartTest();
  void selectMcqAnswer(int index);
  void recordSpeakingResult(S result);
  void skipQuestion();
  void nextQuestion();
  Future<void> submitTest();
  Future<void> retrySubmitTest();
  Future<bool> canTakeTest();
}
