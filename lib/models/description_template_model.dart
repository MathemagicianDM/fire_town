import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:uuid/uuid.dart';
import '../enums_and_maps.dart';

const _uuid = Uuid();

@immutable
class PhysicalTemplate implements JsonSerializable {
  final String id;
  final String name;
  final String tag; // e.g., "hair", "eyes", "build" - prevents conflicts
  final List<String> applicableAncestryGroups; // e.g., ["has_hair", "humanoid"]
  final List<String> excludeAncestryGroups; // e.g., ["feathered", "scaled"]
  final List<Role> applicableRoles; // Optional role filtering
  final List<String> templates; // Template strings with {placeholders}
  final Map<String, List<String>> variables; // Variable name -> possible values

  const PhysicalTemplate({
    required this.id,
    required this.name,
    required this.tag,
    this.applicableAncestryGroups = const ["all"],
    this.excludeAncestryGroups = const [],
    this.applicableRoles = const [],
    required this.templates,
    required this.variables,
  });

  PhysicalTemplate copyWith({
    String? id,
    String? name,
    String? tag,
    List<String>? applicableAncestryGroups,
    List<String>? excludeAncestryGroups,
    List<Role>? applicableRoles,
    List<String>? templates,
    Map<String, List<String>>? variables,
  }) {
    return PhysicalTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      applicableAncestryGroups: applicableAncestryGroups ?? this.applicableAncestryGroups,
      excludeAncestryGroups: excludeAncestryGroups ?? this.excludeAncestryGroups,
      applicableRoles: applicableRoles ?? this.applicableRoles,
      templates: templates ?? this.templates,
      variables: variables ?? this.variables,
    );
  }

  @override
  String compositeKey() {
    return id;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'applicableAncestryGroups': applicableAncestryGroups,
      'excludeAncestryGroups': excludeAncestryGroups,
      'applicableRoles': applicableRoles.map((role) => role.toString().split('.').last).toList(),
      'templates': templates,
      'variables': variables,
    };
  }

  @override
  factory PhysicalTemplate.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return PhysicalTemplate(
      id: data['id'] ?? _uuid.v4(),
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      applicableAncestryGroups: List<String>.from(data['applicableAncestryGroups'] ?? ["all"]),
      excludeAncestryGroups: List<String>.from(data['excludeAncestryGroups'] ?? []),
      applicableRoles: (data['applicableRoles'] as List<dynamic>? ?? [])
          .map((roleStr) => Role.values.firstWhere(
                (r) => r.toString().split('.').last == roleStr,
                orElse: () => Role.customer,
              ))
          .toList(),
      templates: List<String>.from(data['templates'] ?? []),
      variables: Map<String, List<String>>.from(
        (data['variables'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }
}

@immutable
class ClothingTemplate implements JsonSerializable {
  final String id;
  final String name;
  final String tag; // e.g., "torso", "feet", "jewelry" - prevents conflicts
  final List<String> applicableAncestryGroups; // e.g., ["has_hair", "humanoid"]
  final List<String> excludeAncestryGroups; // e.g., ["feathered", "scaled"]
  final List<Role> applicableRoles; // Role-specific clothing
  final List<String> templates; // Template strings with {placeholders}
  final Map<String, List<String>> variables; // Variable name -> possible values

  const ClothingTemplate({
    required this.id,
    required this.name,
    required this.tag,
    this.applicableAncestryGroups = const ["all"],
    this.excludeAncestryGroups = const [],
    this.applicableRoles = const [], // Empty means universal
    required this.templates,
    required this.variables,
  });

  ClothingTemplate copyWith({
    String? id,
    String? name,
    String? tag,
    List<String>? applicableAncestryGroups,
    List<String>? excludeAncestryGroups,
    List<Role>? applicableRoles,
    List<String>? templates,
    Map<String, List<String>>? variables,
  }) {
    return ClothingTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      applicableAncestryGroups: applicableAncestryGroups ?? this.applicableAncestryGroups,
      excludeAncestryGroups: excludeAncestryGroups ?? this.excludeAncestryGroups,
      applicableRoles: applicableRoles ?? this.applicableRoles,
      templates: templates ?? this.templates,
      variables: variables ?? this.variables,
    );
  }

  @override
  String compositeKey() {
    return id;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'applicableAncestryGroups': applicableAncestryGroups,
      'excludeAncestryGroups': excludeAncestryGroups,
      'applicableRoles': applicableRoles.map((role) => role.toString().split('.').last).toList(),
      'templates': templates,
      'variables': variables,
    };
  }

  @override
  factory ClothingTemplate.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return ClothingTemplate(
      id: data['id'] ?? _uuid.v4(),
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      applicableAncestryGroups: List<String>.from(data['applicableAncestryGroups'] ?? ["all"]),
      excludeAncestryGroups: List<String>.from(data['excludeAncestryGroups'] ?? []),
      applicableRoles: (data['applicableRoles'] as List<dynamic>? ?? [])
          .map((roleStr) => Role.values.firstWhere(
                (r) => r.toString().split('.').last == roleStr,
                orElse: () => Role.customer,
              ))
          .toList(),
      templates: List<String>.from(data['templates'] ?? []),
      variables: Map<String, List<String>>.from(
        (data['variables'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }
}

@immutable
class ShopTemplate implements JsonSerializable {
  final String id;
  final String name;
  final String tag; // e.g., "atmosphere", "clientele", "interior" - prevents conflicts
  final List<ShopType> applicableShopTypes; // e.g., [ShopType.tavern, ShopType.herbalist]
  final List<String> templates; // Template strings with {placeholders}
  final Map<String, List<String>> variables; // Variable name -> possible values

  const ShopTemplate({
    required this.id,
    required this.name,
    required this.tag,
    this.applicableShopTypes = const [], // Empty means universal
    required this.templates,
    required this.variables,
  });

  ShopTemplate copyWith({
    String? id,
    String? name,
    String? tag,
    List<ShopType>? applicableShopTypes,
    List<String>? templates,
    Map<String, List<String>>? variables,
  }) {
    return ShopTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      applicableShopTypes: applicableShopTypes ?? this.applicableShopTypes,
      templates: templates ?? this.templates,
      variables: variables ?? this.variables,
    );
  }

  @override
  String compositeKey() {
    return id;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'applicableShopTypes': applicableShopTypes.map((type) => type.toString().split('.').last).toList(),
      'templates': templates,
      'variables': variables,
    };
  }

  @override
  factory ShopTemplate.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return ShopTemplate(
      id: data['id'] ?? _uuid.v4(),
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      applicableShopTypes: (data['applicableShopTypes'] as List<dynamic>? ?? [])
          .map((typeStr) => ShopType.values.firstWhere(
                (t) => t.toString().split('.').last == typeStr,
                orElse: () => ShopType.tavern,
              ))
          .toList(),
      templates: List<String>.from(data['templates'] ?? []),
      variables: Map<String, List<String>>.from(
        (data['variables'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }
}