import "package:uuid/uuid.dart";
import 'package:firetown/models/json_serializable_abstract_class.dart';

final Uuid _uuid = const Uuid();



class ResonantArgument implements JsonSerializable{
  final String argument;
  final String id;

  ResonantArgument({
    required this.argument,
    required this.id,
  });

  @override
  factory ResonantArgument.fromJson(Map<String, dynamic> json) {
    return ResonantArgument(
      argument: json['argument'] as String,
      id: (json['id'] ?? _uuid.v4()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'argument': argument,
      'id': id,
    };
  }

  @override
  String compositeKey() {
    return id;
  }
}

