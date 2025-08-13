import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class LocationTrait implements JsonSerializable {
  final String id;
  final String tag; // e.g., "lighting", "sounds", "smells", "architecture", "crowds", "cleanliness"
  final String description; // The actual trait description
  final String type; // "atmosphere", "physical", "history"
  
  const LocationTrait({
    required this.id,
    required this.tag,
    required this.description,
    required this.type,
  });
  
  LocationTrait.generate({
    required this.tag,
    required this.description,
    required this.type,
  }) : id = _uuid.v4();
  
  LocationTrait copyWith({
    String? id,
    String? tag,
    String? description,
    String? type,
  }) {
    return LocationTrait(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag': tag,
      'description': description,
      'type': type,
    };
  }
  
  @override
  factory LocationTrait.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return LocationTrait(
      id: data['id'],
      tag: data['tag'],
      description: data['description'],
      type: data['type'],
    );
  }
  
  @override
  factory LocationTrait.fromJson2(Map<String, dynamic> data) {
    return LocationTrait(
      id: data['id'],
      tag: data['tag'],
      description: data['description'],
      type: data['type'],
    );
  }
  
  @override
  String compositeKey() {
    return id;
  }
}