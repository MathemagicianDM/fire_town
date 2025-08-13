import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class CharacterTrait implements JsonSerializable {
  final String id;
  final String tag; // e.g., "hair", "eyes", "build", "shirt", "boots"
  final String description; // The actual trait description
  final String type; // "physical" or "clothing"
  
  const CharacterTrait({
    required this.id,
    required this.tag,
    required this.description,
    required this.type,
  });
  
  CharacterTrait.generate({
    required this.tag,
    required this.description,
    required this.type,
  }) : id = _uuid.v4();
  
  CharacterTrait copyWith({
    String? id,
    String? tag,
    String? description,
    String? type,
  }) {
    return CharacterTrait(
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
  factory CharacterTrait.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return CharacterTrait(
      id: data['id'],
      tag: data['tag'],
      description: data['description'],
      type: data['type'],
    );
  }
  
  @override
  factory CharacterTrait.fromJson2(Map<String, dynamic> data) {
    return CharacterTrait(
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