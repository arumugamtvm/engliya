class LessonExplain {
  final String ta;
  final String en;
  final List<ExplainTableRow>? table;
  final String? videoUrl;
  final List<String>? images;
  final List<String>? gifs;

  LessonExplain({
    required this.ta,
    required this.en,
    this.table,
    this.videoUrl,
    this.images,
    this.gifs,
  });

  factory LessonExplain.fromJson(Map<String, dynamic> json) {
    return LessonExplain(
      ta: json['ta'] as String,
      en: json['en'] as String,
      table: json['table'] != null
          ? (json['table'] as List)
              .map((item) => ExplainTableRow.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      videoUrl: json['videoUrl'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e as String).toList()
          : null,
      gifs: json['gifs'] != null
          ? (json['gifs'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ta': ta,
      'en': en,
      if (table != null) 'table': table!.map((row) => row.toJson()).toList(),
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (images != null) 'images': images,
      if (gifs != null) 'gifs': gifs,
    };
  }
}

class ExplainTableRow {
  final String? pronoun;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? key;
  final List<String>? examples;

  ExplainTableRow({
    this.pronoun,
    this.descriptionEn,
    this.descriptionTa,
    this.key,
    this.examples,
  });

  factory ExplainTableRow.fromJson(Map<String, dynamic> json) {
    return ExplainTableRow(
      pronoun: json['pronoun'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      descriptionTa: json['descriptionTa'] as String?,
      key: json['key'] as String?,
      examples: json['examples'] != null
          ? (json['examples'] as List).map((e) => e as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pronoun != null) 'pronoun': pronoun,
      if (descriptionEn != null) 'descriptionEn': descriptionEn,
      if (descriptionTa != null) 'descriptionTa': descriptionTa,
      if (key != null) 'key': key,
      if (examples != null) 'examples': examples,
    };
  }
}
