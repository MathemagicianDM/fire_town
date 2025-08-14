import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'json_serializable_abstract_class.dart';

const _uuid = Uuid();

@immutable
class RumorTemplate implements JsonSerializable {
  final String id;
  final String template; // Template with {roleType/roleType2} placeholders
  final List<String> tags;
  final Map<String, List<String>> variables; // Variable name -> possible values
  final List<String> requiredRoles; // At least one of these roles must exist
  final List<String> requiredLocations; // Required location types (optional)

  const RumorTemplate({
    required this.id,
    required this.template,
    required this.tags,
    this.variables = const {},
    this.requiredRoles = const [],
    this.requiredLocations = const [],
  });

  @override
  String compositeKey() => id;

  factory RumorTemplate.fromJson(Map<String, dynamic> json) {
    return RumorTemplate(
      id: json['id'] as String,
      template: json['template'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      variables: (json['variables'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, List<String>.from(value))),
      requiredRoles: List<String>.from(json['required_roles'] ?? []),
      requiredLocations: List<String>.from(json['required_locations'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'template': template,
        'tags': tags,
        'variables': variables,
        'required_roles': requiredRoles,
        'required_locations': requiredLocations,
      };
}

class GeneratedRumor {
  final String id;
  final String content; // Fully resolved template
  final List<String> referencedNPCs; // NPCs that were used in generation
  final List<String> tags;
  final DateTime generatedAt;
  final bool isCustom;

  GeneratedRumor({
    required this.id,
    required this.content,
    required this.referencedNPCs,
    required this.tags,
    DateTime? generatedAt,
    this.isCustom = false,
  }) : generatedAt = generatedAt ?? DateTime.now();

  factory GeneratedRumor.fromJson(Map<String, dynamic> json) {
    return GeneratedRumor(
      id: json['id'] as String,
      content: json['content'] as String,
      referencedNPCs: List<String>.from(json['referencedNPCs'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'referencedNPCs': referencedNPCs,
        'tags': tags,
        'generatedAt': generatedAt.toIso8601String(),
        'isCustom': isCustom,
      };

  // Create a custom rumor (user-added)
  factory GeneratedRumor.custom(String content) {
    return GeneratedRumor(
      id: _uuid.v4(),
      content: content,
      referencedNPCs: [],
      tags: ['custom'],
      isCustom: true,
    );
  }
}