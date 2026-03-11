import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CEFR progression is non-decreasing from phase1 to phase5', () {
    const levelRank = {'A1': 1, 'A2': 2, 'B1': 3, 'B2': 4, 'C1': 5};

    final phases = ['phase1', 'phase2', 'phase3', 'phase4', 'phase5'];
    var previousMin = 0;

    for (final phase in phases) {
      final dir = Directory('assets/lessons/$phase');
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Missing $phase lessons directory',
      );

      final levels = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => jsonDecode(f.readAsStringSync()) as Map<String, dynamic>)
          .map((json) => (json['level'] as String?) ?? '')
          .toList();

      expect(levels.isNotEmpty, isTrue, reason: '$phase has no lesson levels');
      final ranks = levels.map((level) => levelRank[level] ?? 0).toList();
      final minRank = ranks.reduce((a, b) => a < b ? a : b);

      expect(
        minRank >= previousMin,
        isTrue,
        reason: '$phase level progression regressed',
      );

      previousMin = minRank;
    }

    final phase5Levels = Directory('assets/lessons/phase5')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => jsonDecode(f.readAsStringSync()) as Map<String, dynamic>)
        .map((json) => json['level'] as String)
        .toSet();

    expect(
      phase5Levels.contains('C1'),
      isTrue,
      reason: 'Phase 5 must target C1 outcomes',
    );
  });
}
