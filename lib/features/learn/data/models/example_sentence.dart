class ExampleSentence {
  final String en;
  final String ta;
  final String audioId;

  ExampleSentence({
    required this.en,
    required this.ta,
    required this.audioId,
  });

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      en: json['en'] as String,
      ta: json['ta'] as String,
      audioId: json['audioId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ta': ta,
      'audioId': audioId,
    };
  }
}
