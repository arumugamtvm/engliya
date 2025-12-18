class UnitPerformance {
  final String unitId;
  final String unitName;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;

  UnitPerformance({
    required this.unitId,
    required this.unitName,
    required this.totalQuestions,
    required this.correctAnswers,
  }) : accuracy = totalQuestions > 0 
           ? (correctAnswers / totalQuestions) * 100 
           : 0.0;

  factory UnitPerformance.fromJson(Map<String, dynamic> json) {
    return UnitPerformance(
      unitId: json['unitId'] as String,
      unitName: json['unitName'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'unitName': unitName,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
    };
  }
}
