import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firetown/person.dart';
// import 'package:firetown/providers.dart';
import '../enums_and_maps.dart';
// import 'dart:math';
// import 'enums_and_maps.dart';
import "json_serializable_abstract_class.dart";
// import '../town_storage.dart';
// import "search.dart";


@immutable
class Node implements JsonSerializable {
  final String id;
  final Set<Edge> relPairs;
  const Node({required this.id, required this.relPairs});

  Set<String> get doNotMarry {
    Set<RelationshipType> noBueno = {
      RelationshipType.child,
      RelationshipType.enemy,
      RelationshipType.ex,
      RelationshipType.family,
      RelationshipType.parent,
      RelationshipType.partner,
      RelationshipType.sibling,
    };

    return relPairs
        .where((e) => noBueno.contains(e.iAmYour))
        .map((e) => e.you)
        .toSet();
  }

  Set<String> get allPartners {
    return relPairs
        .where((e) => e.iAmYour == RelationshipType.partner)
        .map((e) => e.you)
        .toSet();
  }

  Node addRelationship(String you, RelationshipType iAmYour) {
    Set<Edge> newRelPairs = Set.from(relPairs);  // Create a proper copy
    newRelPairs.add(Edge(you: you, iAmYour: iAmYour));
    return Node(id: id, relPairs: newRelPairs);
  }

  Node removeRelationship(String you, RelationshipType iAmYour) {
    Set<Edge> newRelPairs = Set.from(relPairs);
    newRelPairs.removeWhere((e) => e.you == you && e.iAmYour == iAmYour);
    return Node(id: id, relPairs: newRelPairs);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "relPairs": relPairs.map((rp) => (rp.toJson())).toList()};
  }

  @override
  factory Node.fromJson(String s) {
    Map<String, dynamic> data = jsonDecode(s);
    return Node(
      id: data["id"],
      relPairs:
          (data["relPairs"] as List)
              .map((rp) => Edge.fromJson(rp))
              .cast<Edge>()
              .toSet(),
    );
  }
  @override
  factory Node.fromJson2(Map<String, dynamic> data) {
    return Node(
      id: data["id"],
      relPairs:
          (data["relPairs"] as List)
              .map((rp) => Edge.fromJson(rp))
              .cast<Edge>()
              .toSet(),
    );
  }
  @override
  String compositeKey() {
    return id;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && (other.id == id) && (other.relPairs == relPairs);
  }

  @override
  int get hashCode => Object.hash(id, relPairs);
}

@immutable
class Edge {
  final String you;
  final RelationshipType iAmYour;
  const Edge({required this.you, required this.iAmYour});
  Map<String, dynamic> toJson() {
    return {"you": you, "iAmYour": iAmYour.name};
  }

  factory Edge.fromJson(Map<String, dynamic> data) {
    return (Edge(
      you: data["you"],
      iAmYour: RelationshipType.values.firstWhere(
        (v) => v.name == data["iAmYour"],
      ),
    ));
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Edge && (other.you == you) && (other.iAmYour == iAmYour);
  }

  @override
  int get hashCode => Object.hash(you, iAmYour);
}



class Relationship {
  RelationshipType myType;
  String myID;

  Relationship({required this.myType, required this.myID});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Relationship &&
        other.myID == myID &&
        other.myType == myType;
  }

  @override
  int get hashCode => Object.hash(myType, myID);

  Map<String, dynamic> toJson() {
    return {'myType': myType.name, 'myID': myID};
  }

  factory Relationship.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return Relationship(
      myType: RelationshipType.values.firstWhere(
        (v) => v.name == data["myType"],
      ),
      myID: data["myID"],
    );
  }

}

