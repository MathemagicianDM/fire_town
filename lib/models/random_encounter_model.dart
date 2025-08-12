import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import '../enums_and_maps.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Represents a single part of an encounter sentence
/// Can be either static text or a dynamic role placeholder
@immutable
class EncounterSentencePart {
  final String id;
  final EncounterPartType type;
  final String content; // For text parts: the actual text. For role parts: display text like "a patron"
  final Role? role; // Only used for role parts
  final String? articleType; // "a", "an", "the", or custom article

  const EncounterSentencePart({
    required this.id,
    required this.type,
    required this.content,
    this.role,
    this.articleType,
  });

  EncounterSentencePart copyWith({
    String? id,
    EncounterPartType? type,
    String? content,
    Role? role,
    String? articleType,
  }) {
    return EncounterSentencePart(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      role: role ?? this.role,
      articleType: articleType ?? this.articleType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'role': role?.toString().split('.').last,
      'articleType': articleType,
    };
  }

  factory EncounterSentencePart.fromJson(Map<String, dynamic> json) {
    return EncounterSentencePart(
      id: json['id'] ?? _uuid.v4(),
      type: EncounterPartType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EncounterPartType.text,
      ),
      content: json['content'] ?? '',
      role: json['role'] != null 
          ? Role.values.firstWhere(
              (r) => r.toString().split('.').last == json['role'],
              orElse: () => Role.customer,
            )
          : null,
      articleType: json['articleType'],
    );
  }

  @override
  String toString() {
    if (type == EncounterPartType.role && role != null) {
      String article = articleType ?? 'a';
      String roleName = _roleToDisplayName(role!);
      return '<$article $roleName>';
    }
    return content;
  }

  String _roleToDisplayName(Role role) {
    switch (role) {
      case Role.tavernKeeper:
        return 'tavern keeper';
      case Role.generalStoreOwner:
        return 'store owner';
      case Role.streetRat:
        return 'street rat';
      case Role.magicShopOwner:
        return 'magic shop owner';
      case Role.minorNoble:
        return 'minor noble';
      case Role.townGuard:
        return 'town guard';
      case Role.streetFoodVendor:
        return 'street food vendor';
      case Role.spiceMerchant:
        return 'spice merchant';
      default:
        return role.toString().split('.').last;
    }
  }
}

enum EncounterPartType {
  text,
  role,
  item, // For future expansion - items, weather, etc.
}

/// Represents a complete random encounter
@immutable
class RandomEncounter implements JsonSerializable {
  final String id;
  final String name; // Short identifier for the encounter
  final List<EncounterSentencePart> sentenceParts;
  final List<LocationType> applicableLocations; // Where this encounter can happen
  final EncounterRarity rarity;
  final List<String> tags; // Optional categorization (e.g., "conflict", "commerce", "social")
  final Map<Role, List<String>> requiredQuirks; // Optional quirks required for specific roles

  const RandomEncounter({
    required this.id,
    required this.name,
    required this.sentenceParts,
    required this.applicableLocations,
    this.rarity = EncounterRarity.common,
    this.tags = const [],
    this.requiredQuirks = const {},
  });

  RandomEncounter copyWith({
    String? id,
    String? name,
    List<EncounterSentencePart>? sentenceParts,
    List<LocationType>? applicableLocations,
    EncounterRarity? rarity,
    List<String>? tags,
    Map<Role, List<String>>? requiredQuirks,
  }) {
    return RandomEncounter(
      id: id ?? this.id,
      name: name ?? this.name,
      sentenceParts: sentenceParts ?? this.sentenceParts,
      applicableLocations: applicableLocations ?? this.applicableLocations,
      rarity: rarity ?? this.rarity,
      tags: tags ?? this.tags,
      requiredQuirks: requiredQuirks ?? this.requiredQuirks,
    );
  }

  /// Generate the encounter text as a complete sentence
  String get displayText {
    return sentenceParts.map((part) => part.toString()).join('');
  }

  /// Get a preview of the encounter (first 50 characters)
  String get preview {
    String full = displayText;
    return full.length > 50 ? '${full.substring(0, 47)}...' : full;
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
      'sentenceParts': sentenceParts.map((part) => part.toJson()).toList(),
      'applicableLocations': applicableLocations.map((loc) => loc.toString().split('.').last).toList(),
      'rarity': rarity.toString().split('.').last,
      'tags': tags,
      'requiredQuirks': requiredQuirks.map((role, quirks) => 
          MapEntry(role.toString().split('.').last, quirks)),
    };
  }

  @override
  factory RandomEncounter.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    // Parse required quirks map
    Map<Role, List<String>> requiredQuirks = {};
    if (data['requiredQuirks'] != null) {
      final quirksData = data['requiredQuirks'] as Map<String, dynamic>;
      for (final entry in quirksData.entries) {
        final role = Role.values.firstWhere(
          (r) => r.toString().split('.').last == entry.key,
          orElse: () => Role.customer, // Default fallback
        );
        requiredQuirks[role] = List<String>.from(entry.value);
      }
    }

    return RandomEncounter(
      id: data['id'] ?? _uuid.v4(),
      name: data['name'] ?? '',
      sentenceParts: (data['sentenceParts'] as List<dynamic>? ?? [])
          .map((part) => EncounterSentencePart.fromJson(part as Map<String, dynamic>))
          .toList(),
      applicableLocations: (data['applicableLocations'] as List<dynamic>? ?? [])
          .map((loc) => LocationType.values.firstWhere(
                (e) => e.toString().split('.').last == loc,
                orElse: () => LocationType.street,
              ))
          .toList(),
      rarity: EncounterRarity.values.firstWhere(
        (r) => r.toString().split('.').last == (data['rarity'] ?? 'common'),
        orElse: () => EncounterRarity.common,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      requiredQuirks: requiredQuirks,
    );
  }
}

enum EncounterRarity {
  common,    // Happens frequently
  uncommon,  // Happens occasionally  
  rare,      // Happens rarely
  unique,    // Special one-off encounters
}

/// Helper class for building encounters dynamically
class EncounterBuilder {
  final List<EncounterSentencePart> _parts = [];
  
  EncounterBuilder();

  /// Add a text part to the encounter
  EncounterBuilder addText(String text) {
    _parts.add(EncounterSentencePart(
      id: _uuid.v4(),
      type: EncounterPartType.text,
      content: text,
    ));
    return this;
  }

  /// Add a role-based part to the encounter
  EncounterBuilder addRole(Role role, {String article = 'a'}) {
    String roleName = _roleToDisplayName(role);
    _parts.add(EncounterSentencePart(
      id: _uuid.v4(),
      type: EncounterPartType.role,
      content: '$article $roleName',
      role: role,
      articleType: article,
    ));
    return this;
  }

  /// Build the final encounter
  RandomEncounter build({
    required String name,
    required List<LocationType> locations,
    EncounterRarity rarity = EncounterRarity.common,
    List<String> tags = const [],
    Map<Role, List<String>> requiredQuirks = const {},
  }) {
    return RandomEncounter(
      id: _uuid.v4(),
      name: name,
      sentenceParts: List.from(_parts),
      applicableLocations: locations,
      rarity: rarity,
      tags: tags,
      requiredQuirks: requiredQuirks,
    );
  }

  /// Clear the builder to start a new encounter
  void clear() {
    _parts.clear();
  }

  /// Get current parts (for preview)
  List<EncounterSentencePart> get currentParts => List.from(_parts);

  String _roleToDisplayName(Role role) {
    switch (role) {
      case Role.tavernKeeper:
        return 'tavern keeper';
      case Role.generalStoreOwner:
        return 'store owner';
      case Role.streetRat:
        return 'street rat';
      case Role.magicShopOwner:
        return 'magic shop owner';
      case Role.minorNoble:
        return 'minor noble';
      case Role.townGuard:
        return 'town guard';
      case Role.streetFoodVendor:
        return 'street food vendor';
      case Role.spiceMerchant:
        return 'spice merchant';
      default:
        return role.toString().split('.').last;
    }
  }
}

/// Extensions for better display of enums
extension LocationTypeExtension on LocationType {
  String get displayName {
    switch (this) {
      case LocationType.shop:
        return 'Shop';
      case LocationType.meetingPlace:
        return 'Meeting Place';
      case LocationType.street:
        return 'Street/Public';
      default:
        String name = toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

extension EncounterRarityExtension on EncounterRarity {
  String get displayName {
    String name = toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
  
  Color get color {
    switch (this) {
      case EncounterRarity.common:
        return Colors.green;
      case EncounterRarity.uncommon:
        return Colors.blue;
      case EncounterRarity.rare:
        return Colors.purple;
      case EncounterRarity.unique:
        return Colors.orange;
    }
  }
}