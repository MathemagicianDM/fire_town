// import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
// import 'package:firetown/given_names.dart';


import "../enums_and_maps.dart";
// part "person.g.dart";

@immutable
class LocationRole implements JsonSerializable {
  final String myID;

  final Role myRole;

  final String locationID;

  final String specialty;

  @override
  String compositeKey() {
    return "$myID.$locationID.${myRole.name}$specialty";
  }

  const LocationRole({
    required this.myID,
    required this.myRole,
    required this.locationID,
    required this.specialty,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'myID': myID,
      'myRole': myRole.name, // Serialize enum as a string
      'locationID': locationID,
      'specialty': specialty,
    };
  }

  factory LocationRole.fromJson(Map<String, dynamic> data) {
    return LocationRole(
      myID: data["myID"],
      myRole: Role.values.firstWhere((e) => e.name == data['myRole']),
      locationID: data['locationID'],
      specialty: data['specialty'],
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      {return true;} // Check if the objects are the same instance
    if (other is! LocationRole)
      {return false;} // Ensure the other object is of the same type

    // Compare fields
    return myID == other.myID &&
        myRole == other.myRole &&
        locationID == other.locationID &&
        specialty == other.specialty;
  }

  @override
  int get hashCode {
    return Object.hash(myID, myRole, locationID, specialty);
  }
}