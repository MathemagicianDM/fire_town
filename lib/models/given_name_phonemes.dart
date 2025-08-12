import 'package:flutter/foundation.dart';
import 'json_serializable_abstract_class.dart'; // Import for JsonSerializable



// Define the SyllableType enum
enum SyllableType {
  first,
  middle,
  last
}

class GivenNameElement implements JsonSerializable {
  final String id;
  final String phoneme;
  final List<String> applicableAncestries;
  final List<String> applicablePronouns;
  final List<SyllableType> applicableSyllableTypes;
  final bool isLocked;

  const GivenNameElement({
    required this.id,
    required this.phoneme,
    required this.applicableAncestries,
    required this.applicablePronouns,
    required this.applicableSyllableTypes,
    this.isLocked = false,
  });

  // Required for JsonSerializable interface
  @override
  String compositeKey() => id;

  // Convert GivenNameElement to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneme': phoneme,
      'applicableAncestries': applicableAncestries,
      'applicablePronouns': applicablePronouns,
      'applicableSyllableTypes': applicableSyllableTypes.map((type) => type.name).toList(),
      'isLocked': isLocked,
    };
  }

  // Create GivenNameElement from JSON
  factory GivenNameElement.fromJson(Map<String, dynamic> json) {
    return GivenNameElement(
      id: json['id'],
      phoneme: json['phoneme'] ?? json['syllable'] ?? "***",
      applicableAncestries: List<String>.from(json['applicableAncestries']),
      applicablePronouns: List<String>.from(json['applicablePronouns']),
      applicableSyllableTypes: (json['applicableSyllableTypes'] as List)
          .map((type) => SyllableType.values.firstWhere((e) => e.name == type))
          .toList(),
      isLocked: json['isLocked'] ?? false,
    );
  }

  // Create a copy with updated properties
  GivenNameElement copyWith({
    String? id,
    String? phoneme,
    List<String>? applicableAncestries,
    List<String>? applicablePronouns,
    List<SyllableType>? applicableSyllableTypes,
    bool? isLocked,
  }) {
    return GivenNameElement(
      id: id ?? this.id,
      phoneme: phoneme ?? this.phoneme,
      applicableAncestries: applicableAncestries ?? List.from(this.applicableAncestries),
      applicablePronouns: applicablePronouns ?? List.from(this.applicablePronouns),
      applicableSyllableTypes: applicableSyllableTypes ?? List.from(this.applicableSyllableTypes),
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GivenNameElement &&
        other.id == id &&
        other.phoneme == phoneme &&
        listEquals(other.applicableAncestries, applicableAncestries) &&
        listEquals(other.applicablePronouns, applicablePronouns) &&
        listEquals(other.applicableSyllableTypes, applicableSyllableTypes) && 
        other.isLocked == isLocked;
        
  }

  @override
  int get hashCode => Object.hash(
        id,
        phoneme,
        Object.hashAll(applicableAncestries),
        Object.hashAll(applicablePronouns),
        Object.hashAll(applicableSyllableTypes),
        isLocked,
      );
}