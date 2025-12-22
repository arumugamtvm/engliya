import 'package:flutter/foundation.dart';

@immutable
class LessonExplain {
  final String ta;
  final String en;
  final List<ExplainTableRow>? table;
  final String? videoUrl;
  final List<String>? images;
  final List<String>? gifs;

  const LessonExplain({
    required this.ta,
    required this.en,
    this.table,
    this.videoUrl,
    this.images,
    this.gifs,
  });

  bool get hasTable => table != null && table!.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasImages => images != null && images!.isNotEmpty;
  bool get hasGifs => gifs != null && gifs!.isNotEmpty;
  bool get hasMultimedia => hasVideo || hasImages || hasGifs;

  factory LessonExplain.fromJson(Map<String, dynamic> json) {
    return LessonExplain(
      ta: json['ta'] as String? ?? '',
      en: json['en'] as String? ?? '',
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

  Map<String, dynamic> toJson() => {
    'ta': ta,
    'en': en,
    if (table != null) 'table': table!.map((row) => row.toJson()).toList(),
    if (videoUrl != null) 'videoUrl': videoUrl,
    if (images != null) 'images': images,
    if (gifs != null) 'gifs': gifs,
  };

  LessonExplain copyWith({
    String? ta,
    String? en,
    List<ExplainTableRow>? table,
    String? videoUrl,
    List<String>? images,
    List<String>? gifs,
  }) {
    return LessonExplain(
      ta: ta ?? this.ta,
      en: en ?? this.en,
      table: table ?? this.table,
      videoUrl: videoUrl ?? this.videoUrl,
      images: images ?? this.images,
      gifs: gifs ?? this.gifs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonExplain && other.ta == ta && other.en == en;
  }

  @override
  int get hashCode => Object.hash(ta, en);

  @override
  String toString() => 'LessonExplain(en: ${en.substring(0, en.length > 50 ? 50 : en.length)}...)';
}

@immutable
class ExplainTableRow {
  final String? pronoun;
  final String? descriptionEn;
  final String? descriptionTa;
  final String? key;
  final List<String>? examples;

  const ExplainTableRow({
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

  Map<String, dynamic> toJson() => {
    if (pronoun != null) 'pronoun': pronoun,
    if (descriptionEn != null) 'descriptionEn': descriptionEn,
    if (descriptionTa != null) 'descriptionTa': descriptionTa,
    if (key != null) 'key': key,
    if (examples != null) 'examples': examples,
  };

  ExplainTableRow copyWith({
    String? pronoun,
    String? descriptionEn,
    String? descriptionTa,
    String? key,
    List<String>? examples,
  }) {
    return ExplainTableRow(
      pronoun: pronoun ?? this.pronoun,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionTa: descriptionTa ?? this.descriptionTa,
      key: key ?? this.key,
      examples: examples ?? this.examples,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExplainTableRow &&
        other.pronoun == pronoun &&
        other.key == key;
  }

  @override
  int get hashCode => Object.hash(pronoun, key);
}
