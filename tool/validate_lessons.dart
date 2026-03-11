import 'dart:convert';
import 'dart:io';

const allowedQuestionTypes = {
  'mcq',
  'short_answer',
  'rewrite',
  'ordering',
  'speaking_rubric_scored',
  'writing_rubric_scored',
};

Future<void> main() async {
  final lessonFiles = await _lessonJsonFiles();
  if (lessonFiles.isEmpty) {
    stderr.writeln('No lesson files found under assets/lessons.');
    exitCode = 1;
    return;
  }

  final issues = <String>[];
  for (final file in lessonFiles) {
    final raw = await file.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final errors = _validateSchema(json);
    final pedagogy = _validatePedagogy(json);
    errors.addAll(pedagogy);

    if (errors.isNotEmpty) {
      issues.add('${file.path}: ${errors.join(' | ')}');
    }
  }

  if (issues.isNotEmpty) {
    stderr.writeln('Lesson validation failed with ${issues.length} issue(s):');
    for (final issue in issues) {
      stderr.writeln('- $issue');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Validated ${lessonFiles.length} lessons successfully.');
}

List<String> _validateSchema(Map<String, dynamic> rawJson) {
  final errors = <String>[];

  _requireString(rawJson, 'id', errors);
  _requireString(rawJson, 'unitId', errors);
  _requireString(rawJson, 'title', errors);
  _requireString(rawJson, 'description', errors);
  _requireString(rawJson, 'level', errors);

  final order = rawJson['order'];
  if (order is! int || order <= 0) {
    errors.add('Field "order" must be a positive integer.');
  }

  final explain = rawJson['explain'];
  if (explain is! Map<String, dynamic>) {
    errors.add('Field "explain" must be an object.');
  } else {
    _requireString(explain, 'en', errors, parent: 'explain');
    _requireString(explain, 'ta', errors, parent: 'explain');
  }

  for (final key in [
    'examples',
    'listeningQuestions',
    'speakSentences',
    'practiceQuestions',
    'masteryQuestions',
  ]) {
    _requireList(rawJson, key, errors);
  }

  final id = rawJson['id'] as String? ?? '';
  if (id.startsWith('phase5_')) {
    for (final key in [
      'writingTasks',
      'rolePlayTasks',
      'errorCorrectionItems',
      'targetVocabulary',
      'canDoOutcomes',
    ]) {
      _requireList(rawJson, key, errors);
    }
  }

  return errors;
}

List<String> _validatePedagogy(Map<String, dynamic> json) {
  final errors = <String>[];

  int len(String key) => (json[key] as List<dynamic>? ?? const []).length;
  final practiceLen = len('practiceQuestions');
  final masteryLen = len('masteryQuestions');

  final id = (json['id'] as String?) ?? '';
  final isPhase5 = id.startsWith('phase5_');
  final minPractice = isPhase5 ? 5 : 1;
  final minMastery = isPhase5 ? 5 : 1;
  if (practiceLen < minPractice) {
    errors.add('At least $minPractice practice questions are required.');
  }
  if (masteryLen < minMastery) {
    errors.add('At least $minMastery mastery questions are required.');
  }

  final practiceTypes =
      (json['practiceQuestions'] as List<dynamic>? ?? const [])
          .map(
            (item) => ((item as Map<String, dynamic>)['type'] as String? ?? '')
                .toLowerCase(),
          )
          .toSet();
  final masteryTypes = (json['masteryQuestions'] as List<dynamic>? ?? const [])
      .map(
        (item) => ((item as Map<String, dynamic>)['type'] as String? ?? '')
            .toLowerCase(),
      )
      .toSet();
  final types = {...practiceTypes, ...masteryTypes};

  if (isPhase5 && types.length < 3) {
    errors.add('Phase 5 lessons require at least 3 question types.');
  }

  final unsupported = types.where(
    (type) => !allowedQuestionTypes.contains(type),
  );
  if (unsupported.isNotEmpty) {
    errors.add('Unsupported question type(s): ${unsupported.join(', ')}');
  }

  return errors;
}

void _requireString(
  Map<String, dynamic> data,
  String key,
  List<String> errors, {
  String? parent,
}) {
  final value = data[key];
  if (value is! String || value.trim().isEmpty) {
    final scopedKey = parent == null ? key : '$parent.$key';
    errors.add('Field "$scopedKey" must be a non-empty string.');
  }
}

void _requireList(Map<String, dynamic> data, String key, List<String> errors) {
  final value = data[key];
  if (value is! List || value.isEmpty) {
    errors.add('Field "$key" must be a non-empty list.');
  }
}

Future<List<File>> _lessonJsonFiles() async {
  final root = Directory('assets/lessons');
  if (!await root.exists()) return [];

  final files = <File>[];
  await for (final entity in root.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.json')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}
