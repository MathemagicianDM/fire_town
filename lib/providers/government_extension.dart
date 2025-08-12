// import "../generic_list.dart";
// import "../enums_and_maps.dart";
// import 'dart:convert';
// import 'package:collection/collection.dart';
// import 'buffered_provider.dart';
// import 'package:flutter/material.dart';
// import "package:hooks_riverpod/hooks_riverpod.dart";

// class GovHelper implements JsonSerializable {
//   String position;
//   GovCreateMethod createMethod;
//   String printName;
//   AgeType age;
//   bool isGuard;
//   List<Role> validRoles;
  
//   GovHelper({
//     required this.position,
//     required this.createMethod,
//     required this.printName,
//     required this.age,
//     required this.validRoles,
//     required this.isGuard
//   });

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'position': position,
//       'createMethod': createMethod.name,
//       'printName': printName,
//       'age': age.name,
//       'isGuard': isGuard,
//       'validRoles': validRoles.map((role) => role.name).toList(),
//     };
//   }

//   @override
//   factory GovHelper.fromJson(Map<String, dynamic> json) {
//     return GovHelper(
//       position: json['position'],
//       createMethod: GovCreateMethod.values.firstWhere(
//         (method) => method.name == json['createMethod'],
//       ),
//       printName: json['printName'],
//       age: AgeType.values.firstWhere(
//         (type) => type.name == json['age'],
//       ),
//       isGuard: json['isGuard'],
//       validRoles: (json['validRoles'] as List)
//           .map((roleName) => Role.values.firstWhere(
//                 (role) => role.name == roleName,
//               ))
//           .toList(),
//     );
//   }

//   @override
//   String compositeKey() {
//     // Using position and printName as a composite key
//     // Assuming these together should be unique
//     return '$position:$printName';
//   }
// }


// class GovernmentQuery {
//   final String governmentType;
//   final String citySize;

//   GovernmentQuery(this.governmentType, this.citySize);

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is GovernmentQuery &&
//         other.governmentType == governmentType &&
//         other.citySize == citySize;
//   }

//   @override
//   int get hashCode => governmentType.hashCode ^ citySize.hashCode;
// }

// extension GovernmentHelpers on BufferedProviderListFireStore<GovHelper> {
//   Future<List<GovHelper>> assignGovernmentRoles(WidgetRef ref, GovernmentQuery gq) async {
//     final repository = ref.watch(governmentRepositoryProvider);
//     final service = ref.watch(governmentPositionsServiceProvider);
    
//     // Get roles for different categories
//     final specificRoles = await repository.getSelectedRolesForGovernment(
//         gq.governmentType, gq.citySize.split(".").last);
//     final universalRoles = await repository.getSelectedRolesForGovernment(
//         "universal", gq.citySize.split(".").last);
//     final guardRoles = await repository.getSelectedRolesForGovernment(
//         "guards", gq.citySize.split(".").last);

//     // Get methods and types
//     final specificMethod = await repository.getGovernmentMethod(gq.governmentType);
//     final universalMethod = await repository.getGovernmentMethod(gq.governmentType);
//     final universalType = await repository.getGovernmenUnivesalType(gq.governmentType);

//     // Convert methods to enum values
//     final specificMethodEnum = GovCreateMethod.values.firstWhere(
//         (e) => e.name == specificMethod);
//     final universalMethodEnum = GovCreateMethod.values.firstWhere(
//         (e) => e.name == universalMethod);
    
//     // Process and create government helpers
//     List<GovHelper> output = [];
    
//     // Process specific roles
//     output.addAll(_processRoleList(
//       roleList: specificRoles,
//       createMethod: specificMethodEnum,
//       service: service,
//       governmentType: gq.governmentType,
//       universalType: null,
//       isGuard: false,
//     ));
    
//     // Process universal roles
//     output.addAll(_processRoleList(
//       roleList: universalRoles,
//       createMethod: universalMethodEnum,
//       service: service,
//       governmentType: gq.governmentType,
//       universalType: universalType,
//       isGuard: false,
//     ));
    
//     // Process guard roles
//     output.addAll(_processRoleList(
//       roleList: guardRoles,
//       createMethod: GovCreateMethod.createRoles,
//       service: service,
//       governmentType: gq.governmentType,
//       universalType: universalType,
//       isGuard: true,
//     ));
    
//     return output;
//   }
  
//   List<GovHelper> _processRoleList({
//     required List<GovernmentRole> roleList,
//     required GovCreateMethod createMethod,
//     required GovernmentPositionsService service,
//     required String governmentType,
//     required String? universalType,
//     required bool isGuard,
//   }) {
//     List<GovHelper> result = [];
    
//     for (final role in roleList) {
//       int howMany = 1;
      
//       // Calculate quantity if specified
//       if (role.quantity != null) {
//         final parts = role.quantity!.split("-");
//         int qmin = int.parse(parts.first);
//         int qmax = int.parse(parts.last);
//         howMany = qmin + random.nextInt(qmax - qmin + 1);
//       }
      
//       // Create the specified number of positions
//       for (int j = 0; j < howMany; j++) {
//         // Determine the role type
//         Role myRole = Role.government;
//         if (role.role != null) {
//           myRole = Role.values.firstWhere((e) => e.name == role.role);
//         }
        
//         // Create the helper object
//         result.add(GovHelper(
//           position: role.title,
//           createMethod: createMethod,
//           printName: service.getTitleForPosition(role.title, governmentType),
//           age: service.getRandomAgeForPosition(role.title) ?? AgeType.adult,
//           validRoles: universalType != null 
//               ? rolesFromUniversalType(universalType) 
//               : rolesFromUniversalType(myRole.name),
//           isGuard: isGuard,
//         ));
//       }
//     }
    
//     return result;
//   }
  
//   void bulkAddPositions(List<GovPosition> positions) {
//     positions.forEach(add);
//   }
  
//   List<GovPosition> getPositionsByType(GovPositionType type) {
//     return items.where((position) => position.type == type).toList();
//   }
  
//   void removeAllPositionsOfType(GovPositionType type) {
//     final positionsToRemove = getPositionsByType(type);
//     positionsToRemove.forEach(remove);
//   }
  
//   // Additional extension methods specific to government positions
//   GovPosition? findPositionById(String id) {
//     return items.firstWhereOrNull((position) => position.id == id);
//   }
  
//   List<GovPosition> findPositionsByTitle(String title) {
//     return items.where((position) => position.title == title).toList();
//   }
  
//   // Add government-specific relationships
//   void assignSupervisor(String subordinateId, String supervisorId) {
//     final subordinate = findPositionById(subordinateId);
//     final supervisor = findPositionById(supervisorId);
    
//     if (subordinate != null && supervisor != null) {
//       final updatedSubordinate = subordinate.copyWith(supervisorId: supervisorId);
//       replace(subordinate, updatedSubordinate);
//     }
//   }
// }