import 'package:flutter/foundation.dart';

@immutable
class SpeakSentence {
  final String en;
  final String? ta;

  const SpeakSentence({
    required this.en,
    this.ta,
  });

  factory SpeakSentence.fromJson(Map<String, dynamic> json) {
    return SpeakSentence(
      en: json['en'] as String? ?? '',
      ta: json['ta'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'en': en,
    if (ta != null) 'ta': ta,
  };

  SpeakSentence copyWith({
    String? en,
    String? ta,
  }) {
    return SpeakSentence(
      en: en ?? this.en,
      ta: ta ?? this.ta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeakSentence && other.en == en && other.ta == ta;
  }

  @override
  int get hashCode => Object.hash(en, ta);

  @override
  String toString() => 'SpeakSentence(en: $en)';
}
