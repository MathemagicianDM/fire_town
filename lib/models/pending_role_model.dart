import "package:flutter/material.dart";
import "package:firetown/models/json_serializable_abstract_class.dart";
import "../enums_and_maps.dart";

@immutable
class PendingRoles implements JsonSerializable {
  final int howMany;
  final Role role;
  const PendingRoles({required this.howMany, required this.role});

  @override
  Map<String, dynamic> toJson() {
    return {
      "howMany": howMany,
      "role": role.name,
    };
  }

  @override
  factory PendingRoles.fromJson(json) {
    return PendingRoles(
        howMany: json["howMany"],
        role: Role.values.firstWhere((v) => v.name == json["role"]));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingRoles &&
          role.name == other.role.name &&
          howMany == other.howMany;

  @override
  int get hashCode => Object.hash(role.name, howMany);

  @override
  String compositeKey() {
    return "${role.name}$howMany";
  }
}


