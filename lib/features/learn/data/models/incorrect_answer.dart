import 'final_test_question.dart';
import 'phase2_final_test_question.dart';
import 'phase3_final_test_question.dart';

/// Model representing an incorrectly answered question in a final test.
/// 
/// Supports questions from:
/// - Phase 1 Final Test (FinalTestQuestion)
/// - Phase 2 Final Test (Phase2FinalTestQuestion)
/// - Phase 3 Final Test (Phase3FinalTestQuestion)
class IncorrectAnswer {
  final dynamic question; // Can be FinalTestQuestion, Phase2FinalTestQuestion, or Phase3FinalTestQuestion
  final int selectedIndex;
  final String selectedAnswer;
  final String correctAnswer;

  IncorrectAnswer({
    required this.question,
    required this.selectedIndex,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  factory IncorrectAnswer.fromJson(Map<String, dynamic> json) {
    final questionJson = json['question'] as Map<String, dynamic>;
    
    // Determine which question type based on unitId format
    dynamic question;
    if (questionJson.containsKey('unitId')) {
      final unitId = questionJson['unitId'] as String;
      // Phase 3 units are unit12-unit17, Phase 2 units are unit7-unit11
      if (unitId.startsWith('unit1') && int.tryParse(unitId.substring(4)) != null) {
        final unitNum = int.parse(unitId.substring(4));
        if (unitNum >= 12 && unitNum <= 17) {
          question = Phase3FinalTestQuestion.fromJson(questionJson);
        } else {
          question = Phase2FinalTestQuestion.fromJson(questionJson);
        }
      } else {
        question = Phase2FinalTestQuestion.fromJson(questionJson);
      }
    } else {
      question = FinalTestQuestion.fromJson(questionJson);
    }

    return IncorrectAnswer(
      question: question,
      selectedIndex: json['selectedIndex'] as int,
      selectedAnswer: json['selectedAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'selectedIndex': selectedIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
    };
  }
}
