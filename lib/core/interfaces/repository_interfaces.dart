import '../utils/result.dart';

abstract interface class ILessonRepository {
  Future<Result<T>> getLesson<T>(String lessonId);
  Future<Result<List<T>>> getLessonsForUnit<T>(String unitId);
  Future<Result<List<T>>> getLessonsForPhase<T>(int phaseNumber);
  Future<Result<List<String>>> getLessonIds(int phaseNumber);
  Future<Result<List<String>>> getLessonIdsForUnit(String unitId);
  void clearCache();
}

abstract interface class IProgressRepository {
  Future<Result<Map<String, dynamic>>> getLessonProgress(String lessonId);
  Future<Result<void>> saveLessonProgress(String lessonId, Map<String, dynamic> progress);
  Future<Result<Map<String, Map<String, dynamic>>>> getAllProgress();
  Future<Result<void>> clearProgress();
  Future<Result<bool>> isLessonCompleted(String lessonId);
  Future<Result<bool>> isLessonMastered(String lessonId);
  Future<Result<double>> getLessonScore(String lessonId);
}

abstract interface class ITestRepository {
  Future<Result<List<T>>> generateTest<T>(int phaseNumber, {int? questionCount});
  Future<Result<void>> saveTestResult<T>(int phaseNumber, T result);
  Future<Result<T?>> getLastTestResult<T>(int phaseNumber);
  Future<Result<bool>> hasPassedTest(int phaseNumber);
}

abstract interface class IStorageService {
  Future<Result<void>> init();
  Future<Result<String?>> getString(String key);
  Future<Result<void>> setString(String key, String value);
  Future<Result<int?>> getInt(String key);
  Future<Result<void>> setInt(String key, int value);
  Future<Result<bool?>> getBool(String key);
  Future<Result<void>> setBool(String key, bool value);
  Future<Result<double?>> getDouble(String key);
  Future<Result<void>> setDouble(String key, double value);
  Future<Result<List<String>?>> getStringList(String key);
  Future<Result<void>> setStringList(String key, List<String> value);
  Future<Result<void>> remove(String key);
  Future<Result<void>> clear();
  Future<Result<bool>> containsKey(String key);
  Future<Result<Set<String>>> getKeys();
}

abstract interface class IAudioService {
  Future<Result<void>> init();
  Future<Result<void>> speak(String text, {String? languageCode});
  Future<Result<void>> stop();
  Future<Result<void>> setRate(double rate);
  Future<Result<void>> setPitch(double pitch);
  Future<Result<void>> setVolume(double volume);
  bool get isPlaying;
  bool get isInitialized;
}

abstract interface class ISpeechService {
  Future<Result<void>> init();
  Future<Result<void>> startListening({
    required void Function(String text) onResult,
    void Function(String error)? onError,
  });
  Future<Result<void>> stopListening();
  bool get isListening;
  bool get isAvailable;
}

abstract interface class IGatingService {
  Future<Result<bool>> isPhaseUnlocked(int phaseNumber);
  Future<Result<bool>> isUnitUnlocked(String unitId);
  Future<Result<bool>> isLessonUnlocked(String lessonId);
  Future<Result<void>> unlockPhase(int phaseNumber);
  Future<Result<void>> unlockUnit(String unitId);
  Future<Result<void>> unlockLesson(String lessonId);
}

abstract interface class ITestService<TQuestion, TResult> {
  Future<Result<List<TQuestion>>> generateTest({int? questionCount});
  Future<Result<TResult>> calculateResult(List<TQuestion> questions, List<String> answers);
  Future<Result<void>> saveResult(TResult result);
  Future<Result<TResult?>> getLastResult();
  Future<Result<bool>> hasPassed();
  bool validateAnswer(TQuestion question, String answer);
}
