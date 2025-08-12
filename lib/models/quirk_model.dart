import "package:uuid/uuid.dart";
import 'package:firetown/models/json_serializable_abstract_class.dart';

final Uuid _uuid = const Uuid();



class Quirk implements JsonSerializable{
  final String quirk;
  final String id;

  Quirk({
    required this.quirk,
    required this.id,
  });

  @override
  factory Quirk.fromJson(Map<String, dynamic> json) {
    return Quirk(
      quirk: json['quirk'] as String,
      id: (json['id'] ?? _uuid.v4()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'quirk': quirk,
      'id': id,
    };
  }

  @override
  String compositeKey() {
    return id;
  }
}

