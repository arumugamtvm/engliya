abstract class FinalTestStatusProvider {
  Future<bool> canTakeTest();
  Future<bool> hasPassedBefore();
  Future<int?> getLastTestScore();
}
