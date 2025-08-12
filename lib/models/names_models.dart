// import 'package:flutter/foundation.dart' show immutable;
// import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/models/json_serializable_abstract_class.dart';
// import 'package:firetown/given_names.dart';
// import 'package:firetown/resonant_argument.dart';
// import 'package:firetown/surnames.dart';
// import 'package:firetown/providers.dart';
// import "personEdit.dart";
// import "quirks.dart";
// import "dart:math";

import "../enums_and_maps.dart";
import "package:uuid/uuid.dart";
// part "person.g.dart";

const _uuid = Uuid();





// final givenNameProvider = Provider<ProviderList<GivenName>>((ref) {
//   return ProviderList<GivenName>(
//     myBox: Hive.box<String>("givenNames"),
//     fromJson: (json) => GivenName.fromJson(json),
//   );
// });

// final governmentsProvider = FutureProvider<List<Government>>((ref) {
//   final repository = ref.watch(governmentRepositoryProvider);
//   return repository.loadGovernments('./lib/demofiles/government.json');
// });

// final governmentTypeNamesProvider = Provider<List<MapEntry<String, String>>>((ref) {
//   final asyncGovernments = ref.watch(governmentsProvider);

//   return asyncGovernments.when(
//     data: (governments) => governments
//         .map((g) => MapEntry(g.type, g.printName)) // ✅ Create tuple-like structure
//         .toList(),
//     loading: () => [],
//     error: (err, stack) => [],
//   );
// });

// // Provider for a specific government by type
// final governmentByTypeProvider = 
//     FutureProvider.family<Government?, String>((ref, governmentType) async {
//   final governments = await ref.watch(governmentsProvider.future);
//   try {
//     return governments.firstWhere((gov) => gov.type == governmentType);
//   } catch (e) {
//     debugPrint('Government type not found: $governmentType');
//     return null;
//   }
// });

// // Provider for roles based on government type and city size
// final governmentRolesProvider = 
//     FutureProvider.family<List<RoleResult>, GovernmentQuery>((ref, query) async {
//   final government = await ref.watch(
//       governmentByTypeProvider(query.governmentType).future);
  
//   if (government == null) {
//     return [];
//   }
  
//   final repository = ref.watch(governmentRepositoryProvider);
//   return repository.getRolesForGovernment(government, query.citySize);
// });







@immutable
class GivenName implements JsonSerializable
{
  
  final String name;
  
  final List<String> ancestry;
  
  final List<PronounType> pronouns;
  
  final String id;

  @override
  String compositeKey() {
    return "$id.$name.${ancestry.join("-")}${pronouns.map((p)=>p.name).join("-")}";
  }
  
  
  const GivenName
  (
    {
      required this.name,
      required this.ancestry,
      required this.pronouns,
      required this.id
    }
  );
  @override
  Map<String,dynamic> toJson() {
    return {
      'name': name,
      'pronouns': pronouns.map((p)=>p.toString().split('.').last).toList(), // Serialize enum as a string
      'ancestry': ancestry,
      'id': id,
    };
  }

  @override
  factory GivenName.fromJson(dynamic json) {
    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return GivenName(
      pronouns: (data["pronouns"] as List<dynamic>).map((p)=>PronounType.values.firstWhere((v)=>v.toString().split('.').last==p)).toList(),
      name: data["name"],
      ancestry: List<String>.from(data["ancestry"] as List),
      id: data["id"] ?? _uuid.v4(),
    );
  }
}

@immutable
class Surname implements JsonSerializable
{
  
  final String name;
  
  final List<String> ancestry;
  
  final String id;
  
  
  const Surname
  (
    {
      required this.name,
      required this.ancestry,
      required this.id
    }
  );
  @override
  Map<String,dynamic> toJson() {
    return {
      'name': name,
      'ancestry': ancestry,
      'id': id,
    };
  }
  @override
  factory Surname.fromJson(dynamic json) {

    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return Surname(
      name: data["name"],
      ancestry: List<String>.from(data["ancestry"] as List),
      id: data["id"] ?? _uuid.v4(),
    );
  }
  @override
  String compositeKey() {
    return id;
  }

}