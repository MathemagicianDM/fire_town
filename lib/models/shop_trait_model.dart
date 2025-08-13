import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@immutable
class ShopTrait implements JsonSerializable {
  final String id;
  final String tag; // Outside: "facade", "signage", "exterior_condition", "street_presence"
                   // Inside: "layout", "decor", "lighting", "atmosphere", "clientele", "cleanliness"
  final String description; // The actual trait description
  final String type; // "outside" or "inside"
  
  const ShopTrait({
    required this.id,
    required this.tag,
    required this.description,
    required this.type,
  });
  
  ShopTrait.generate({
    required this.tag,
    required this.description,
    required this.type,
  }) : id = _uuid.v4();
  
  ShopTrait copyWith({
    String? id,
    String? tag,
    String? description,
    String? type,
  }) {
    return ShopTrait(
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
  factory ShopTrait.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return ShopTrait(
      id: data['id'],
      tag: data['tag'],
      description: data['description'],
      type: data['type'],
    );
  }
  
  @override
  factory ShopTrait.fromJson2(Map<String, dynamic> data) {
    return ShopTrait(
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