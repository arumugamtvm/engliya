import 'package:flutter/foundation.dart';

@immutable
class TargetVocabularyItem {
  final String lemma;
  final String cefr;
  final List<String> collocations;

  const TargetVocabularyItem({
    required this.lemma,
    required this.cefr,
    required this.collocations,
  });

  factory TargetVocabularyItem.fromJson(Map<String, dynamic> json) {
    return TargetVocabularyItem(
      lemma: json['lemma'] as String? ?? '',
      cefr: json['cefr'] as String? ?? '',
      collocations: (json['collocations'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lemma': lemma, 'cefr': cefr, 'collocations': collocations};
  }
}
