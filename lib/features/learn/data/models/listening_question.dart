class ListeningQuestion {
  final String audioText;
  final List<String> options;
  final int correctIndex;

  ListeningQuestion({
    required this.audioText,
    required this.options,
    required this.correctIndex,
  });

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) {
    return ListeningQuestion(
      audioText: json['audioText'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioText': audioText,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}
