import 'package:flutter/foundation.dart';

@immutable
class RolePlayTask {
  final String id;
  final String scenarioEn;
  final String? scenarioTa;
  final String learnerRoleEn;
  final String partnerRoleEn;
  final List<String> mustUsePhrases;

  const RolePlayTask({
    required this.id,
    required this.scenarioEn,
    this.scenarioTa,
    required this.learnerRoleEn,
    required this.partnerRoleEn,
    required this.mustUsePhrases,
  });

  factory RolePlayTask.fromJson(Map<String, dynamic> json) {
    return RolePlayTask(
      id: json['id'] as String? ?? '',
      scenarioEn: json['scenarioEn'] as String? ?? '',
      scenarioTa: json['scenarioTa'] as String?,
      learnerRoleEn: json['learnerRoleEn'] as String? ?? '',
      partnerRoleEn: json['partnerRoleEn'] as String? ?? '',
      mustUsePhrases: (json['mustUsePhrases'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenarioEn': scenarioEn,
      if (scenarioTa != null) 'scenarioTa': scenarioTa,
      'learnerRoleEn': learnerRoleEn,
      'partnerRoleEn': partnerRoleEn,
      'mustUsePhrases': mustUsePhrases,
    };
  }
}
