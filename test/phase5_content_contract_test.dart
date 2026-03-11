import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 5 Content Contract', () {
    final dir = Directory('assets/lessons/phase5');

    test('contains 16 lesson files and every file parses', () {
      final files =
          dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      expect(files.length, 16);
      for (final file in files) {
        final jsonData = jsonDecode(file.readAsStringSync());
        expect(jsonData, isA<Map<String, dynamic>>());
      }
    });

    test('every phase5 lesson has productive schema and type diversity', () {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      for (final file in files) {
        final data =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        expect(
          (data['examples'] as List).length,
          greaterThanOrEqualTo(6),
          reason: file.path,
        );
        expect(
          (data['listeningQuestions'] as List).length,
          greaterThanOrEqualTo(4),
          reason: file.path,
        );
        expect(
          (data['speakSentences'] as List).length,
          greaterThanOrEqualTo(4),
          reason: file.path,
        );
        expect(
          (data['practiceQuestions'] as List).length,
          greaterThanOrEqualTo(6),
          reason: file.path,
        );
        expect(
          (data['masteryQuestions'] as List).length,
          greaterThanOrEqualTo(6),
          reason: file.path,
        );

        expect(
          (data['writingTasks'] as List).length,
          greaterThanOrEqualTo(2),
          reason: file.path,
        );
        expect(
          (data['rolePlayTasks'] as List).length,
          greaterThanOrEqualTo(2),
          reason: file.path,
        );
        expect(
          (data['errorCorrectionItems'] as List).length,
          greaterThanOrEqualTo(2),
          reason: file.path,
        );
        expect(
          (data['targetVocabulary'] as List).length,
          greaterThanOrEqualTo(6),
          reason: file.path,
        );
        expect(
          (data['canDoOutcomes'] as List).isNotEmpty,
          isTrue,
          reason: file.path,
        );

        final practiceTypes = (data['practiceQuestions'] as List)
            .map((item) => (item as Map<String, dynamic>)['type'] as String)
            .toSet();
        final masteryTypes = (data['masteryQuestions'] as List)
            .map((item) => (item as Map<String, dynamic>)['type'] as String)
            .toSet();
        final allTypes = {...practiceTypes, ...masteryTypes};

        expect(allTypes.length, greaterThanOrEqualTo(3), reason: file.path);
      }
    });
  });
}
