import 'package:flutter/foundation.dart';

@immutable
class ExampleSentence {
  final String en;
  final String ta;
  final String audioId;

  const ExampleSentence({
    required this.en,
    required this.ta,
    required this.audioId,
  });

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      en: json['en'] as String? ?? '',
      ta: json['ta'] as String? ?? '',
      audioId: json['audioId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'en': en,
    'ta': ta,
    'audioId': audioId,
  };

  ExampleSentence copyWith({
    String? en,
    String? ta,
    String? audioId,
  }) {
    return ExampleSentence(
      en: en ?? this.en,
      ta: ta ?? this.ta,
      audioId: audioId ?? this.audioId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExampleSentence &&
        other.en == en &&
        other.ta == ta &&
        other.audioId == audioId;
  }

  @override
  int get hashCode => Object.hash(en, ta, audioId);

  @override
  String toString() => 'ExampleSentence(en: $en, ta: $ta)';
}
