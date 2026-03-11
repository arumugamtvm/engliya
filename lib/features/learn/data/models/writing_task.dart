import 'package:flutter/foundation.dart';

@immutable
class WritingTask {
  final String id;
  final String promptEn;
  final String? promptTa;
  final List<String> rubricKeys;
  final List<String> modelAnswerAnchors;
  final List<String> errorCategories;

  const WritingTask({
    required this.id,
    required this.promptEn,
    this.promptTa,
    required this.rubricKeys,
    required this.modelAnswerAnchors,
    required this.errorCategories,
  });

  factory WritingTask.fromJson(Map<String, dynamic> json) {
    return WritingTask(
      id: json['id'] as String? ?? '',
      promptEn: json['promptEn'] as String? ?? '',
      promptTa: json['promptTa'] as String?,
      rubricKeys: (json['rubricKeys'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(growable: false),
      modelAnswerAnchors:
          (json['modelAnswerAnchors'] as List<dynamic>? ?? const [])
              .map((item) => item as String)
              .toList(growable: false),
      errorCategories: (json['errorCategories'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promptEn': promptEn,
      if (promptTa != null) 'promptTa': promptTa,
      'rubricKeys': rubricKeys,
      'modelAnswerAnchors': modelAnswerAnchors,
      'errorCategories': errorCategories,
    };
  }
}
