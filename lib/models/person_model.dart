// import 'package:flutter/foundation.dart' show immutable;
// import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
// import 'package:firetown/given_names.dart';
// import 'package:firetown/resonant_argument.dart';
// import 'package:firetown/surnames.dart';
// import 'package:firetown/providers.dart';
import "../globals.dart";
// import "personEdit.dart";
import "../screens/person_detail_view.dart";
// import "quirks.dart";
// import "dart:math";

import "../enums_and_maps.dart";
import '../../models/barrel_of_models.dart';


@immutable
class Person implements JsonSerializable {
  final String firstName;

  final String surname;

  final String ancestry;

  final PronounType pronouns;

  final AgeType age;

  final OrientationType orientation;

  final String quirk1;

  final String quirk2;

  final String resonantArgument;

  final String faction;

  final String id;

  final List<String?> partnerID;

  final List<String?> childrenID;

  final List<String?> parents;

  final List<String?> exIDs;

  final List<Relationship> relationships;

  final List<LocationRole> myRoles;

  final PolyType poly;

  final String? physicalDescription;

  final String? clothingDescription;

  final int maxSpouse = 1;

  bool canMarry() {
    return (countPartner() < maxSpouse) && (allowedToPartner[age]!.isNotEmpty);
  }

  Set<AgeType> get myPartnerAges {
    return allowedToPartner[age] ?? {};
  }

  Set<PronounType> get myPreferredPartnersPronouns {
    switch (orientation) {
      case OrientationType.straight:
        return straightCandidatePronouns[pronouns] ?? {PronounType.any};
      case OrientationType.queer:
        return queerCandidatePronouns[pronouns] ?? {PronounType.any};
      // ignore: unreachable_switch_default
      default:
        return {PronounType.any};
    }
  }

  int countPartner() {
    return relationships
        .where((r) => r.myType == RelationshipType.partner)
        .length;
  }

  const Person({ required this.firstName,
    required this.surname,
    required this.ancestry,
    required this.pronouns,
    required this.age,
    required this.orientation,
    required this.quirk1,
    required this.quirk2,
    required this.resonantArgument,
    required this.faction,
    required this.id,
    required this.partnerID,
    required this.childrenID,
    required this.parents,
    required this.exIDs,
    required this.poly,
    required this.myRoles,
    required this.relationships,
    this.physicalDescription,
    this.clothingDescription,
    maxSpouse,
  });

  Person copyWith({
  String? firstName,
  String? surname,
  String? ancestry,
  PronounType? pronouns,
  AgeType? age,
  OrientationType? orientation,
  String? quirk1,
  String? quirk2,
  String? resonantArgument,
  String? faction,
  String? id,
  List<String?>? partnerID,
  List<String?>? childrenID,
  List<String?>? parents,
  List<String?>? exIDs,
  List<Relationship>? relationships,
  List<LocationRole>? myRoles,
  PolyType? poly,
  String? physicalDescription,
  String? clothingDescription,
  int? maxSpouse,
}) {
  return Person(
    firstName: firstName ?? this.firstName,
    surname: surname ?? this.surname,
    ancestry: ancestry ?? this.ancestry,
    pronouns: pronouns ?? this.pronouns,
    age: age ?? this.age,
    orientation: orientation ?? this.orientation,
    quirk1: quirk1 ?? this.quirk1,
    quirk2: quirk2 ?? this.quirk2,
    resonantArgument: resonantArgument ?? this.resonantArgument,
    faction: faction ?? this.faction,
    id: id ?? this.id,
    partnerID: partnerID ?? this.partnerID,
    childrenID: childrenID ?? this.childrenID,
    parents: parents ?? this.parents,
    exIDs: exIDs ?? this.exIDs,
    relationships: relationships ?? this.relationships,
    myRoles: myRoles ?? this.myRoles,
    poly: poly ?? this.poly,
    physicalDescription: physicalDescription ?? this.physicalDescription,
    clothingDescription: clothingDescription ?? this.clothingDescription,
    // If maxSpouse is a constant with a default value, you might want to handle it differently
    // This will use the provided value or fall back to the default
    maxSpouse: maxSpouse ?? this.maxSpouse,
  );
}

  bool isEmployed() {
    Set<Role> nonJobRoles = {Role.regular, Role.customer};
    Set<Role> jobRoles = Role.values.toSet().difference(nonJobRoles);
    return myRoles.where((r) => jobRoles.contains(r.myRole)).isNotEmpty;
  }

  bool isAssignableAsRegular() {
    Set<Role> S = {Role.regular, Role.customer};
    return myRoles.where((r) => !S.contains(r.myRole)).isNotEmpty;
  }

  Container printPersonSummary({List<String>? additionalInfo}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Space between sections
      padding: const EdgeInsets.all(12), // Padding inside the box
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Light background color
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(color: Colors.blue.shade200),
      ), // Optional border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure left-alignment
        children: [
          const SizedBox(height: 4),
          Text(
            "$firstName $surname :: ${enum2String(myEnum: age)} $ancestry, (${enum2String(myEnum: pronouns)})",
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            "$quirk1 & $quirk2 :: Resonant Argument: $resonantArgument",
            style: const TextStyle(fontSize: 14),
          ),
          if (additionalInfo != null) ...[
            const SizedBox(height: 8), // Add spacing before the list
            ...additionalInfo.map(
              (info) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 4.0,
                ), // Add spacing between each line
                child: Text(info, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
          FilledButton.tonal(
            onPressed: () {
              navigatorKey.currentState!.restorablePushNamed(
                PersonDetailView.routeName,
                arguments: {'myID': id},
              );
            },
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  Widget printPersonSummaryTappable(
    BuildContext context, {
    List<String>? additionalInfo,
  }) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState!.restorablePushNamed(
          PersonDetailView.routeName,
          arguments: {'myID': id},
        );
      },
      child: Container(
        width: 600,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ), // Space between sections
        padding: const EdgeInsets.all(12), // Padding inside the box
        decoration: BoxDecoration(
          color: Colors.blue.shade50, // Light background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(color: Colors.blue.shade200),
        ), // Optional border
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure left-alignment
          children: [
            const SizedBox(height: 4),
            Text(
              "$firstName $surname :: ${enum2String(myEnum: age)} $ancestry, (${enum2String(myEnum: pronouns)})",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "$quirk1 & $quirk2 :: Resonant Argument: $resonantArgument",
              style: const TextStyle(fontSize: 14),
            ),
            if (additionalInfo != null) ...[
              const SizedBox(height: 8), // Add spacing before the list
              ...additionalInfo.map(
                (info) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4.0,
                  ), // Add spacing between each line
                  child: Text(info, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String roleString(LocationRole myRole) {
    return "${myRole.myRole} @ ${myRole.locationID}";
  }

  List<Widget> printDetail(List<Person> people, Node myNode) {
    List<RelationshipType> displayOrder = [
      RelationshipType.partner,
      RelationshipType.child,
      RelationshipType.ex,
      RelationshipType.sibling,
      RelationshipType.parent,
      RelationshipType.friend,
      RelationshipType.enemy,
      RelationshipType.family,
    ];
    Map<RelationshipType, Map<String, String>> outputString = {
      RelationshipType.partner: {"singular": "Partner", "plural": "Partners"},
      RelationshipType.child: {"singular": "Child", "plural": "Children"},
      RelationshipType.ex: {"singular": "Ex", "plural": "Exes"},
      RelationshipType.sibling: {"singular": "Sibling", "plural": "Siblings"},
      RelationshipType.parent: {"singular": "Parent", "plural": "Parents"},
      RelationshipType.friend: {"singular": "Friend", "plural": "Friends"},
      RelationshipType.enemy: {"singular": "Enemy", "plural": "Enemies"},
      RelationshipType.family: {"singular": "Family", "plural": "Family"},
    };

    List<Widget> outputWidgets = [
      const SizedBox(height: 4),
      Text(
        "$firstName $surname :: ${enum2String(myEnum: age)} $ancestry, (${enum2String(myEnum: pronouns)})",
        style: const TextStyle(fontSize: 14),
      ),
      Text(
        "$quirk1 & $quirk2 :: Resonant Argument: $resonantArgument",
        style: const TextStyle(fontSize: 14),
      ),
      Text("Member of $faction", style: const TextStyle(fontSize: 14)),
    ];

    for (final type in displayOrder) {
      List<String> printIDs =
          myNode.relPairs
              .where((rp) => rp.iAmYour == type)
              .map((rp) => rp.you)
              .toList();
      List<Person> printPeople =
          people.where((p) => printIDs.contains(p.id)).toList();
      Map<String, String> myStrings = outputString[type]!;
      String printString = myStrings["singular"]!;
      if (printIDs.length > 1) {
        printString = myStrings["plural"]!;
      }
      if (printIDs.isNotEmpty) {
        outputWidgets.addAll([
          Text(printString),
          for (int i = 0; i < printPeople.length; i++) ...[
            (printPeople.elementAt(i)).printPersonSummary(),
          ],
        ]);
      }
    }
    List<Widget> roleWidgets = [...myRoles.map((r) => Text(roleString(r)))];
    outputWidgets.addAll([
      Text("Polyamorous Status: ${enum2String(myEnum: poly)}"),
      Text("Orientation Status: ${enum2String(myEnum: orientation)}"),
      ...roleWidgets,
    ]);
    return outputWidgets;
  }

@override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'surname': surname,
      'ancestry': ancestry,
      'pronouns': pronouns.name,
      'age': age.name,
      'orientation': orientation.name,
      'quirk1': quirk1,
      'quirk2': quirk2,
      'resonantArgument': resonantArgument,
      'faction': faction,
      'id': id,
      'partnerID': partnerID,
      'childrenID': childrenID,
      'parents': parents,
      'exIDs': exIDs,
      'myRoles': myRoles.map((r) => r.toJson()).toList(),
      'poly': poly.name,
      'physicalDescription': physicalDescription,
      'clothingDescription': clothingDescription,
      'maxSpouse': maxSpouse.toString(),
      'relationships': relationships.map((r) => r.toJson()).toList(),
    };
  }
@override
  factory Person.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    // print('Deserializing poly: ${data["poly"]}');
    // print(PolyType.values.firstWhere((v)=>v.name==data["poly"]));
    return Person(
      firstName: data["firstName"],
      surname: data["surname"],
      ancestry: data["ancestry"],
      pronouns: PronounType.values.firstWhere(
        (v) => v.name == data["pronouns"],
      ),
      age: AgeType.values.firstWhere((v) => v.name == data["age"]),
      orientation: OrientationType.values.firstWhere(
        (v) => v.name == data["orientation"],
      ),
      quirk1: data["quirk1"],
      quirk2: data["quirk2"],
      resonantArgument: data["resonantArgument"],
      faction: data["faction"],
      id: data["id"],
      partnerID: List<String?>.from(data["partnerID"] as List),
      childrenID: List<String?>.from(data["childrenID"] as List),
      parents: List<String?>.from(data["parents"] as List),
      exIDs: List<String?>.from(data["exIDs"] as List),
      myRoles: List<LocationRole>.from(
        (data["myRoles"] as List)
            .map((r) => LocationRole.fromJson(((r))))
            .toList(),
      ),
      poly: PolyType.values.firstWhere((v) => v.name == data["poly"]),
      physicalDescription: data["physicalDescription"],
      clothingDescription: data["clothingDescription"],
      maxSpouse: int.parse(data["maxSpouse"]),

      relationships: List<Relationship>.from(
        (data["relationships"] ?? [])
            .map((r) => Relationship.fromJson((jsonEncode(r))))
            .toList(),
      ),
    );
  }

  @override
  factory Person.fromJson2(Map<String,dynamic> data) {
    // final Map<String, dynamic> data = jsonDecode(json);
    // print('Deserializing poly: ${data["poly"]}');
    // print(PolyType.values.firstWhere((v)=>v.name==data["poly"]));
    return Person(
      firstName: data["firstName"],
      surname: data["surname"],
      ancestry: data["ancestry"],
      pronouns: PronounType.values.firstWhere(
        (v) => v.name == data["pronouns"],
      ),
      age: AgeType.values.firstWhere((v) => v.name == data["age"]),
      orientation: OrientationType.values.firstWhere(
        (v) => v.name == data["orientation"],
      ),
      quirk1: data["quirk1"],
      quirk2: data["quirk2"],
      resonantArgument: data["resonantArgument"],
      faction: data["faction"],
      id: data["id"],
      partnerID: List<String?>.from(data["partnerID"] as List),
      childrenID: List<String?>.from(data["childrenID"] as List),
      parents: List<String?>.from(data["parents"] as List),
      exIDs: List<String?>.from(data["exIDs"] as List),
      myRoles: List<LocationRole>.from(
        (data["myRoles"] as List)
            .map((r) => LocationRole.fromJson(((r))))
            .toList(),
      ),
      poly: PolyType.values.firstWhere((v) => v.name == data["poly"]),
      physicalDescription: data["physicalDescription"],
      clothingDescription: data["clothingDescription"],
      maxSpouse: int.parse(data["maxSpouse"]),

      relationships: List<Relationship>.from(
        (data["relationships"] ?? [])
            .map((r) => Relationship.fromJson((jsonEncode(r))))
            .toList(),
      ),
    );
  }

  @override
  String compositeKey(){
    return id;
  }
}

class PersonActionHandler {
  final VoidCallback onInfoPressed;

  final VoidCallback onEditPressed;

  PersonActionHandler({
    required this.onInfoPressed,
    required this.onEditPressed,
  });
}

