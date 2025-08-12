import "../models/json_serializable_abstract_class.dart";
import "../enums_and_maps.dart";
import 'package:collection/collection.dart';
import 'buffered_provider.dart';
import 'package:flutter/material.dart';

// import 'dart:math';
// import 'enums_and_maps.dart';

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
    // Create a new set with all existing relationships plus the new one
    Set<Edge> newRelPairs = Set.from(relPairs);
    newRelPairs.add(Edge(you: you, iAmYour: iAmYour));
    return Node(id: id, relPairs: newRelPairs);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "relPairs": relPairs.map((rp) => (rp.toJson())).toList()};
  }

  factory Node.fromJson(Map<String, dynamic> data) {
    return Node(
      id: data["id"],
      relPairs:
          (data["relPairs"] as List)
              .map((rp) => Edge.fromJson(rp as Map<String, dynamic>))
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

extension RelationshipList on BufferedProviderListFireStore<Node> {
  int countPartner(String p1) {
    final Node? node = items.firstWhereOrNull((n) => n.id == p1);
    return node?.relPairs
            .where((rp) => rp.iAmYour == RelationshipType.partner)
            .length ??
        0;
  }

  void addRelationship(String p1, String p2, RelationshipType p1isp2s) {
    int nodeIndex = items.indexWhere((n) => n.id == p1);
    if (nodeIndex == -1) {
      Node me = Node(id: p1, relPairs: {Edge(you: p2, iAmYour: p1isp2s)});
      add(me);
    } else {
      Node me = items[nodeIndex];
      if (!me.relPairs.contains(Edge(you: p2, iAmYour: p1isp2s))) {
        final oldMe = me;
        me = me.addRelationship(p2, p1isp2s);
        replace(oldMe, me);
      }
    }
  }

  void addSymmetricRelationship(String p1, String p2, RelationshipType symRel) {
    addRelationship(p1, p2, symRel);
    addRelationship(p2, p1, symRel);
  }

  void removeRelationship(String p1, String p2, RelationshipType p1isp2s) {
    int nodeIndex = items.indexWhere((n) => n.id == p1);
    if (nodeIndex != -1) {
      Node me = items[nodeIndex];
      final oldMe = me;
      // Create a new set without the relationship to remove
      Set<Edge> newRelPairs = Set.from(me.relPairs);
      newRelPairs.removeWhere((e) => (e.you == p2) && (e.iAmYour == p1isp2s));
      // Create a new node with the updated relationships
      Node newMe = Node(id: me.id, relPairs: newRelPairs);
      replace(oldMe, newMe);
    }
  }

  void removeSymmetricRelationship(
    String p1,
    String p2,
    RelationshipType symRel,
  ) {
    removeRelationship(p1, p2, symRel);
    removeRelationship(p2, p1, symRel);
  }

  void addParentChild(String parent, String child) {
    addRelationship(parent, child, RelationshipType.parent);
    addRelationship(child, parent, RelationshipType.child);
  }

  void makeExes(String x, String y) {
    removeSymmetricRelationship(x, y, RelationshipType.partner);
    addSymmetricRelationship(x, y, RelationshipType.ex);
  }

  int getI(String s) {
    return items.indexWhere((e) => e.id == s);
  }

  void findAndMakeSiblings(String c) {
    int meIndex = getI(c);
    if (meIndex == -1) return;
    
    List<String> csParents =
        items[meIndex].relPairs
            .where((e) => e.iAmYour == RelationshipType.parent)
            .map((e) => e.you)
            .toList();
    
    // Find all parents once and cache their indices
    Map<String, int> parentIndices = {};
    for (String p in csParents) {
      int idx = getI(p);
      if (idx != -1) {
        parentIndices[p] = idx;
      }
    }
    
    // Collect children from all parents
    Set<String> parentsChildren = {};
    for (String p in csParents) {
      if (parentIndices.containsKey(p)) {
        parentsChildren.addAll(
          items[parentIndices[p]!].relPairs
              .where((e) => (e.iAmYour == RelationshipType.child))
              .map((q) => q.you)
              .where((i) => i != c),
        );
      }
    }
    
    // Add sibling relationships
    for (String s in parentsChildren) {
      addSymmetricRelationship(s, c, RelationshipType.sibling);
    }
  }

  List<String> findRelationshipOfType(
      String myID, Set<RelationshipType> findTypes)  {
    Node? myNode = items.firstWhereOrNull((n) => n.id == myID);
    if (myNode == null) return [];
    
    return myNode.relPairs
        .where((rp) => findTypes.contains(rp.iAmYour))
        .map((rp) => rp.you)
        .toList();
  }

  void bulkAddNodes(List<Node> nodeList) {
    nodeList.forEach(add);  // Use forEach instead of map to execute the add operation
  }
}