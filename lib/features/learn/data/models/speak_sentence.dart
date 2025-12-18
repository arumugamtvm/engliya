class SpeakSentence {
  final String en;
  final String? ta;

  SpeakSentence({
    required this.en,
    this.ta,
  });

  factory SpeakSentence.fromJson(Map<String, dynamic> json) {
    return SpeakSentence(
      en: json['en'] as String,
      ta: json['ta'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      if (ta != null) 'ta': ta,
    };
  }
}
