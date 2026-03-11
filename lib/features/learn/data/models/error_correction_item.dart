import 'package:flutter/foundation.dart';

@immutable
class ErrorCorrectionItem {
  final String id;
  final String incorrectEn;
  final String? hintTa;
  final String correctedEn;
  final String category;

  const ErrorCorrectionItem({
    required this.id,
    required this.incorrectEn,
    this.hintTa,
    required this.correctedEn,
    required this.category,
  });

  factory ErrorCorrectionItem.fromJson(Map<String, dynamic> json) {
    return ErrorCorrectionItem(
      id: json['id'] as String? ?? '',
      incorrectEn: json['incorrectEn'] as String? ?? '',
      hintTa: json['hintTa'] as String?,
      correctedEn: json['correctedEn'] as String? ?? '',
      category: json['category'] as String? ?? 'grammar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incorrectEn': incorrectEn,
      if (hintTa != null) 'hintTa': hintTa,
      'correctedEn': correctedEn,
      'category': category,
    };
  }
}
