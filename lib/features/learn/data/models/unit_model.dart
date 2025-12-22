import '../../domain/entities/phase_config.dart';
import '../../domain/entities/unit.dart';

/// Data model for Unit with JSON serialization support
/// Extends the domain entity to add serialization capabilities
class UnitModel extends Unit {
  const UnitModel({
    required super.id,
    required super.order,
    required super.title,
    required super.description,
    required super.lessonCount,
    super.masteredCount = 0,
  });

  /// Create a UnitModel from JSON data
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      lessonCount: json['lessonCount'] as int,
      masteredCount: json['masteredCount'] as int? ?? 0,
    );
  }

  /// Create a UnitModel from PhaseConfig for a specific unit
  /// Calculates lesson count from the config's lessonToUnitMapping
  factory UnitModel.fromConfig(
    String unitId,
    PhaseConfig config,
    int masteredCount,
  ) {
    // Get unit name from config, fallback to unitId
    final unitName = config.unitNames[unitId] ?? unitId;

    // Count lessons for this unit
    final lessonCount = config.lessonToUnitMapping.entries
        .where((entry) => entry.value == unitId)
        .length;

    // Extract order from unitId (e.g., 'unit7' -> 7)
    final orderMatch = RegExp(r'(\d+)').firstMatch(unitId);
    final order = orderMatch != null ? int.parse(orderMatch.group(1)!) : 0;

    return UnitModel(
      id: unitId,
      order: order,
      title: unitName,
      description: 'Unit $order: $unitName',
      lessonCount: lessonCount,
      masteredCount: masteredCount,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'description': description,
      'lessonCount': lessonCount,
      'masteredCount': masteredCount,
    };
  }

  /// Convert to domain entity
  Unit toEntity() {
    return Unit(
      id: id,
      order: order,
      title: title,
      description: description,
      lessonCount: lessonCount,
      masteredCount: masteredCount,
    );
  }

  /// Create a UnitModel from a domain entity
  factory UnitModel.fromEntity(Unit entity) {
    return UnitModel(
      id: entity.id,
      order: entity.order,
      title: entity.title,
      description: entity.description,
      lessonCount: entity.lessonCount,
      masteredCount: entity.masteredCount,
    );
  }

  /// Create a copy with updated mastered count
  @override
  UnitModel withMasteredCount(int newMasteredCount) {
    return UnitModel(
      id: id,
      order: order,
      title: title,
      description: description,
      lessonCount: lessonCount,
      masteredCount: newMasteredCount,
    );
  }
}
