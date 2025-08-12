
// Adjust the path to the Person model.
// For Relationship and Node.
import '/enums_and_maps.dart';
import 'package:uuid/uuid.dart';
import '/globals.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import "package:collection/collection.dart";
import "../../providers/barrel_of_providers.dart";
import '../barrel_of_models.dart';

const _uuid = Uuid();
String infoID = "fixed_info";

String doNotCreateString = "_Nobody_Left_";

// extension TownPeople on Town {

//   Future<void> createPeopleFS(
//     int numPeople,
//     WidgetRef ref,
//     List<GovHelper> govRoles,
//   ) async {
//     List<Person> newPeople = [];

//     final locRolePN = ref.read(
//       locationRolesProvider.notifier,
//     );
//     final peoplePN = ref.read(peopleProvider.notifier);

//     final relationshipPN = ref.read(relationshipsProvider.notifier);
//     final pendingRolesPN = ref.read(pendingRolesProvider.notifier);

//     final roleMeta = ref.read(roleMetaProvider);
//     final roleMetaPN = ref.read(roleMetaProvider.notifier);
//     // final allRolesNotifer = ref.read(roleGenProvider2);
//     Trie peopleSearchProvider = ref.read(peopleSearch.notifier);

//     var updateBuffer = List.empty(growable: true);

//     // Informational roleList=Informational(myID: myID,locType: LocationType.info, name:"AllRoles");
//     List<Role> initRoleList = [];
//     Map<Role, int> roleCounts = {};
//     Role newRole;
//     for (int i = 0; i < numPeople; i++) {
//       newRole = roleMetaPN.getRole();
//       initRoleList.add(newRole);
//       roleCounts[newRole] = (roleCounts[newRole] ?? 0) + 1;
//     }

    
//     List<Role> activeRoles = [];

//     roleCounts.forEach((r, howMany) {
//       int maxAllowed = max(1, (howMany * (propActivate[r] ?? 0)).toInt());
//       int numActive = howMany.clamp(1, maxAllowed);

//       int numPending = howMany - numActive;

//       activeRoles.addAll(List.filled(numActive, r));

//       pendingRolesPN.add(PendingRoles(howMany: numPending, role: r));
//     });

//     List<LocationRole> roleList = [];
//     for (int i = 0; i < activeRoles.length; i++) {
//       Role myRole = activeRoles[i];
//       AgeType myAge = roleMetaPN.getAgeOfRole(myRole);

//       String id = _uuid.v4();
//       String myAncestry = randomAncestry();
//       Person p = createRandomPerson(ref,
//         newID: id,
//         newAncestry: myAncestry,
//         newAge: myAge,
//       );
//       newPeople.add(p);

//       peoplePN.add(p);

//       updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(p));

//       final locRole = LocationRole(
//         locationID: infoID,
//         myID: id,
//         myRole: myRole,
//         specialty: "",
//       );
//       roleList.add(locRole);
//       locRolePN.add(locRole);
      
//       relationshipPN.add(Node(id: id, relPairs: {}));
//     }

//     Informational newGov = Informational(
//       myID: governtmentID,
//       locType: LocationType.government,
//       name: "Government",
//     );
//     final locProvider = ref.read(locationsListProvider.notifier);
//     updateBuffer.add(() async => await locProvider.add(addMe: newGov));

//     List<String> govIDs = [];
//     for (final gr in govRoles) {
//       Role myRole =
//           Role.values.firstWhereOrNull(
//             (v) => v.name.split("Government").first == gr.position,
//           ) ??
//           Role.government;
//       AgeType myAge = gr.age;
//       switch (gr.createMethod) {
//         case GovCreateMethod.createRoles:
//           String id = _uuid.v4();
//           String myAncestry = randomAncestry();
//           Person p = createRandomPerson(ref,
//             newID: id,
//             newAncestry: myAncestry,
//             newAge: myAge,
//           );
//           newPeople.add(p);
//           peoplePN.add(p);
          
//           updateBuffer.add(
//             () async => await peopleSearchProvider.addPersonToSearch(p),
//           );

//           final locRole = LocationRole(
//             locationID: governtmentID,
//             myID: id,
//             myRole: myRole,
//             specialty: "",
//           );
//           roleList.add(locRole);
//           locRolePN.add(locRole);
          
//           LocationRole locRoleID;

//           locRoleID = LocationRole(
//             locationID: infoID,
//             myID: id,
//             myRole: myRole,
//             specialty: "",
//           );

//           roleList.add(locRoleID);
//           locRolePN.add(locRoleID);
    
//           relationshipPN.add(Node(id: id, relPairs: {}));
          
//           govIDs.add(id);
//           break;
//         case GovCreateMethod.createAndChoose:
//           String id =
//               randomElement(
//                 newPeople.where((p) => !govIDs.contains(p.id)).toList(),
//               ).id;

//           final locRole = LocationRole(
//             locationID: governtmentID,
//             myID: id,
//             myRole: myRole,
//             specialty: "",
//           );
//           roleList.add(locRole);
//           locRolePN.add(locRole);
//           govIDs.add(id);
//           break;
//         case GovCreateMethod.useExistingRoles:
//           final validRoles =
//               roleList
//                   .where(
//                     (lr) =>
//                         gr.validRoles.contains(lr.myRole) &&
//                         !govIDs.contains(lr.myID),
//                   )
//                   .toList();

//           if (validRoles.isNotEmpty) {
//             final lr = randomElement(validRoles);
//             govIDs.add(lr.myID);
//             final locRole = LocationRole(
//               locationID: governtmentID,
//               myID: lr.myID,
//               myRole: myRole,
//               specialty: "",
//             );
//             roleList.add(locRole);
//             locRolePN.add(locRole);
            
//           } else {
//             String id = _uuid.v4();
//             String myAncestry = randomAncestry();
//             Person p = createRandomPerson(ref,
//               newID: id,
//               newAncestry: myAncestry,
//               newAge: myAge,
//             );
//             newPeople.add(p);
//             peoplePN.add(p);

//             updateBuffer.add(
//               () async => await peopleSearchProvider.addPersonToSearch(p),
//             );

//             myRole = randomElement(gr.validRoles);
//             final locRole = LocationRole(
//               locationID: governtmentID,
//               myID: id,
//               myRole:
//                   Role.values.firstWhereOrNull(
//                     (v) => v.name.split("Government").first == gr.position,
//                   ) ??
//                   Role.government,
//               specialty: "",
//             );
//             roleList.add(locRole);
//             locRolePN.add(locRole);
            
//             LocationRole locRoleID;

//             locRoleID = LocationRole(
//               locationID: infoID,
//               myID: id,
//               myRole: myRole,
//               specialty: "",
//             );

//             roleList.add(locRoleID);
//             locRolePN.add(locRoleID);
            
//             relationshipPN.add(Node(id: id, relPairs: {}));
            
//             govIDs.add(id);
//             break;
//           }
//           break;
//       }
//     }

//     for (final update in updateBuffer) {
//       await update();
//     }
//     await peoplePN.commitChanges();
//     await relationshipPN.commitChanges();
//     await locRolePN.commitChanges();
//     await pendingRolesPN.commitChanges();
//   }

//    Future<void> createSocialNetworkFS(WidgetRef ref) async {
//     // List<Person> people = List.from(ref.read(peopleListProvider));
//     final people = ref.watch(peopleProvider);
//     final peoplePN = ref.read(peopleProvider.notifier);
//     // PeopleList peoplePN = ref.read(peopleListProvider.notifier);
    
//     final relationships = ref.watch(relationshipsProvider);
//     final relationshipsPN = ref.read(relationshipsProvider.notifier);
//     // List<Node> relCache = List.from(ref.read(relationshipsProvider));
    
//     final locRolePN = ref.read(locationRolesProvider.notifier);

//     final locRoles = ref.watch(locationRolesProvider);

//     Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);
//     // List<Person> newPeople=[];

//     List<Function> updateBuffer = [];
//     int countPartner(String p1) {
//       int myIndex = relationships.indexWhere((v) => v.id == p1);
//       if (myIndex == -1) {
//         return 0;
//       }
//       return relationships[myIndex].relPairs
//           .where((v) => v.iAmYour == RelationshipType.partner)
//           .length;
//     }

//     void addRelationship(String p1, String p2, RelationshipType relType) {
//       int index = relationships.indexWhere((n) => n.id == p1);
//       if (index == -1) {
//         relationshipsPN.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
//       } else {
//         relationshipsPN.addRelationship(p1, p2, relType);
//       }
//     }

//     void addSymmetricRelationship(
//       String p1,
//       String p2,
//       RelationshipType relType,
//     ) {
//       addRelationship(p1, p2, relType);
//       addRelationship(p2, p1, relType);
//     }

//     for (Person p in people) {
//       bool canMarry =
//           (allowedToPartner[p.age]!.isNotEmpty) &&
//           (countPartner(p.id) < p.maxSpouse);
//       bool doItAgain = true;
//       int maxIter = 1;
//       if (p.poly == PolyType.poly) {
//         maxIter = maxIter + random.nextInt(p.maxSpouse) + 1;
//       }
//       if (canMarry) {
//         for (int i = 0; i < maxIter; i++) {
//           while (doItAgain) {
//             if (countPartner(p.id) < p.maxSpouse) {
//               PartnerType myPartnerType = randomPartnerType(p.ancestry);
//               Set<String> myPreferredAncestry;
//               switch (myPartnerType) {
//                 case (PartnerType.sameAncestry):
//                   myPreferredAncestry = {p.ancestry};
//                   break;
//                 case (PartnerType.differentAncestry):
//                   myPreferredAncestry = {
//                     randomAncestry(
//                       restrictedAncestries: getOtherAncestries(ref,p.ancestry),
//                     ),
//                   };
//                   break;
//                 case (PartnerType.noPartner):
//                   myPreferredAncestry = {};
//                   doItAgain = false;
//               }
//               if (myPreferredAncestry.isNotEmpty) {
//                 int myIndex = relationships.indexWhere((n) => n.id == p.id);
//                 Set<String> doNotMarry = {};
//                 if (myIndex != -1) {
//                   doNotMarry = relationships[myIndex].doNotMarry;
//                 }
//                 int numPart = countPartner(p.id);

//                 List<Person> preCandidates =
//                     people
//                         .where(
//                           (f) =>
//                               ((myPreferredAncestry.contains(f.ancestry)) &&
//                                   (p.myPreferredPartnersPronouns.contains(
//                                     f.pronouns,
//                                   )) &&
//                                   (f.myPreferredPartnersPronouns.contains(
//                                     p.pronouns,
//                                   )) &&
//                                   (p.myPartnerAges.contains(f.age)) &&
//                                   (p.poly == f.poly) &&
//                                   (!doNotMarry.contains(f.id))),
//                         )
//                         .toList();
//                 List<Person> candidates = [];
//                 for (final c in preCandidates) {
//                   int cPartner = countPartner(c.id);
//                   if (numPart + cPartner < min(p.maxSpouse, c.maxSpouse)) {
//                     candidates.add(c);
//                   }
//                 }
//                 Person luckyOne;
//                 if (candidates.isNotEmpty) {
//                   luckyOne = candidates[random.nextInt(candidates.length)];
//                 } else {
//                   String newID = _uuid.v4();

//                   luckyOne = createRandomPerson(ref,
//                     newID: newID,
//                     newAncestry: myPreferredAncestry.elementAt(
//                       random.nextInt(myPreferredAncestry.length),
//                     ),
//                     newPoly: p.poly,
//                     newAge: p.age,
//                     newPronouns: p.myPreferredPartnersPronouns.elementAt(
//                       random.nextInt(p.myPreferredPartnersPronouns.length),
//                     ),
//                     newOrientation: p.orientation,
//                   );
//                   // people.add(luckyOne);
//                   peoplePN.add(luckyOne);
//                   // updateBuffer.add(() async => peoplePN.add(addMe: luckyOne));
//                   updateBuffer.add(
//                     () async =>
//                         peopleSearchProvider.addPersonToSearch(luckyOne),
//                   );

//                   relationshipsPN.add(Node(id: luckyOne.id, relPairs: {}));
          
//                 }

//                 Node nobody = Node(id: "", relPairs: {});
//                 if (randomBreakUp(p.ancestry)) {
//                   Set<String> pPartners =
//                       relationships
//                           .firstWhere((n) => n.id == p.id, orElse: () => nobody)
//                           .allPartners;
//                   Set<String> luckyOnePartners =
//                       relationships
//                           .firstWhere(
//                             (n) => n.id == luckyOne,
//                             orElse: () => nobody,
//                           )
//                           .allPartners;
//                   addSymmetricRelationship(
//                     luckyOne.id,
//                     p.id,
//                     RelationshipType.ex,
//                   );
//                   for (String q in pPartners) {
//                     addSymmetricRelationship(
//                       luckyOne.id,
//                       q,
//                       RelationshipType.ex,
//                     );
//                   }

//                   for (String q in luckyOnePartners) {
//                     addSymmetricRelationship(p.id, q, RelationshipType.ex);
//                   }
//                   doItAgain = true;
//                 } else {
//                   int index = relationships.indexWhere((n) => n.id == p.id);
//                   Set<String> luckyOneToMarrySet = {};
//                   if (index != -1) {
//                     luckyOneToMarrySet = relationships[index].allPartners;
//                   }

//                   luckyOneToMarrySet.add(p.id);

//                   int index2 = relationships.indexWhere((n) => n.id == luckyOne.id);
//                   Set<String> pToMarrySet = {};
//                   if (index2 != -1) {
//                     pToMarrySet =
//                         relationships
//                             .firstWhere((n) => n.id == luckyOne.id)
//                             .allPartners;
//                   }

//                   pToMarrySet.add(luckyOne.id);

//                   for (String q in luckyOneToMarrySet) {
//                     addSymmetricRelationship(
//                       q,
//                       luckyOne.id,
//                       RelationshipType.partner,
//                     );

//                     if ((locRoles
//                         .where(
//                           (lr) =>
//                               lr.locationID == governtmentID &&
//                               lr.myID == luckyOne.id &&
//                               {
//                                 Role.liegeGovernment,
//                                 Role.nobleGovernment,
//                                 Role.courtierGovernment,
//                               }.contains(lr.myRole),
//                         )
//                         .isNotEmpty)) {
//                       LocationRole locRole = LocationRole(
//                         locationID: governtmentID,
//                         myID: q,
//                         myRole: Role.minorNoble,
//                         specialty: "Minor Noble (via partner)",
//                       );
//                       locRolePN.add(locRole);
                      
//                     }
//                   }
//                   for (String q in pToMarrySet) {
//                     addSymmetricRelationship(q, p.id, RelationshipType.partner);

//                     if ((locRoles
//                         .where(
//                           (lr) =>
//                               lr.locationID == governtmentID &&
//                               lr.myID == p.id &&
//                               {
//                                 Role.liegeGovernment,
//                                 Role.nobleGovernment,
//                                 Role.courtierGovernment,
//                               }.contains(lr.myRole),
//                         )
//                         .isNotEmpty)) {
//                       LocationRole locRole = LocationRole(
//                         locationID: governtmentID,
//                         myID: luckyOne.id,
//                         myRole: Role.minorNoble,
//                         specialty: "Minor Noble (via partner)",
//                       );
//                       locRolePN.add(locRole);
//                     }
//                   }
//                   doItAgain = false;
//                 }
//               }
//             } else {
//               doItAgain = false;
//             }
//           }
//         }
//       }
//     }

//     await peoplePN.commitChanges();
//     await relationshipsPN.commitChanges();
//     await locRolePN.commitChanges();
    

//     for (final b in updateBuffer) {
//       await b();
//     }
//   }


//   // Future<void> createPeople2(
//   //   int numPeople,
//   //   WidgetRef ref,
//   //   List<GovHelper> govRoles,
//   // ) async {
//   //   List<Person> newPeople = [];

//   //   ProviderList<LocationRole> locRoleProvider = ref.read(
//   //     locationRoleListProvider.notifier,
//   //   );
//   //   PeopleList peopleProvider = ref.read(peopleListProvider.notifier);
//   //   RelationshipProvider relProvider = ref.read(relationshipsProvider.notifier);
//   //   ProviderList<PendingRoles> prProvider = ref.read(
//   //     pendingRoleListProvider.notifier,
//   //   );

//   //   World theWorld = ref.read(myWorldProvider);

//   //   final allRolesNotifer = ref.read(theWorld.allRoles.notifier);
//   //   // final allRolesNotifer = ref.read(roleGenProvider2);
//   //   Trie peopleSearchProvider = ref.read(peopleSearch.notifier);

//   //   var updateBuffer = List.empty(growable: true);

//   //   // Informational roleList=Informational(myID: myID,locType: LocationType.info, name:"AllRoles");
//   //   List<Role> initRoleList = [];
//   //   Role newRole;
//   //   for (int i = 0; i < numPeople; i++) {
//   //     newRole = allRolesNotifer.getRole();
//   //     initRoleList.add(newRole);
//   //   }

//   //   // Count all roles in a single pass
//   //   Map<Role, int> roleCounts = {};
//   //   for (final role in initRoleList) {
//   //     roleCounts[role] = (roleCounts[role] ?? 0) + 1;
//   //   }

//   //   List<Role> activeRoles = [];

//   //   roleCounts.forEach((r, howMany) {
//   //     int maxAllowed = max(1, (howMany * (propActivate[r] ?? 0)).toInt());
//   //     int numActive = howMany.clamp(1, maxAllowed);

//   //     int numPending = howMany - numActive;

//   //     activeRoles.addAll(List.filled(numActive, r));
//   //     updateBuffer.add(
//   //       () => prProvider.add(addMe: PendingRoles(howMany: numPending, role: r)),
//   //     );
//   //   });

//   //   List<LocationRole> roleList = [];
//   //   for (int i = 0; i < activeRoles.length; i++) {
//   //     Role myRole = activeRoles[i];
//   //     AgeType myAge = allRolesNotifer.getAgeOfRole(myRole);

//   //     String id = _uuid.v4();
//   //     String myAncestry = randomAncestry();
//   //     Person p = createRandomPerson(
//   //       newID: id,
//   //       newAncestry: myAncestry,
//   //       newAge: myAge,
//   //     );
//   //     newPeople.add(p);

//   //     updateBuffer.add(() async => peopleProvider.add(addMe: p));
//   //     updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(p));

//   //     final locRole = LocationRole(
//   //       locationID: infoID,
//   //       myID: id,
//   //       myRole: myRole,
//   //       specialty: "",
//   //     );
//   //     roleList.add(locRole);
//   //     updateBuffer.add(() async => locRoleProvider.add(addMe: locRole));
//   //     final n = Node(id: id, relPairs: {});
//   //     updateBuffer.add(() async => relProvider.bulkAddNodes([n]));
//   //   }

//   //   Informational newGov = Informational(
//   //     myID: governtmentID,
//   //     locType: LocationType.government,
//   //     name: "Government",
//   //   );
//   //   final locProvider = ref.read(locationsListProvider.notifier);
//   //   updateBuffer.add(() async => await locProvider.add(addMe: newGov));

//   //   List<String> govIDs = [];
//   //   for (final gr in govRoles) {
//   //     Role myRole =
//   //         Role.values.firstWhereOrNull(
//   //           (v) => v.name.split("Government").first == gr.position,
//   //         ) ??
//   //         Role.government;
//   //     AgeType myAge = gr.age;
//   //     print("you are the government");
//   //     switch (gr.createMethod) {
//   //       case GovCreateMethod.createRoles:
//   //         String id = _uuid.v4();
//   //         String myAncestry = randomAncestry();
//   //         Person p = createRandomPerson(
//   //           newID: id,
//   //           newAncestry: myAncestry,
//   //           newAge: myAge,
//   //         );
//   //         newPeople.add(p);

//   //         updateBuffer.add(() async => await peopleProvider.add(addMe: p));
//   //         updateBuffer.add(
//   //           () async => await peopleSearchProvider.addPersonToSearch(p),
//   //         );

//   //         final locRole = LocationRole(
//   //           locationID: governtmentID,
//   //           myID: id,
//   //           myRole: myRole,
//   //           specialty: "",
//   //         );
//   //         roleList.add(locRole);
//   //         updateBuffer.add(
//   //           () async => await locRoleProvider.add(addMe: locRole),
//   //         );
//   //         LocationRole locRoleID;

//   //         locRoleID = LocationRole(
//   //           locationID: infoID,
//   //           myID: id,
//   //           myRole: myRole,
//   //           specialty: "",
//   //         );

//   //         roleList.add(locRoleID);
//   //         updateBuffer.add(
//   //           () async => await locRoleProvider.add(addMe: locRoleID),
//   //         );

//   //         final n = Node(id: id, relPairs: {});
//   //         updateBuffer.add(() async => await relProvider.bulkAddNodes([n]));
//   //         govIDs.add(id);
//   //         break;
//   //       case GovCreateMethod.createAndChoose:
//   //         String id =
//   //             randomElement(
//   //               newPeople.where((p) => !govIDs.contains(p.id)).toList(),
//   //             ).id;

//   //         final locRole = LocationRole(
//   //           locationID: governtmentID,
//   //           myID: id,
//   //           myRole: myRole,
//   //           specialty: "",
//   //         );
//   //         roleList.add(locRole);
//   //         updateBuffer.add(
//   //           () async => await locRoleProvider.add(addMe: locRole),
//   //         );
//   //         govIDs.add(id);
//   //         break;
//   //       case GovCreateMethod.useExistingRoles:
//   //         final validRoles =
//   //             roleList
//   //                 .where(
//   //                   (lr) =>
//   //                       gr.validRoles.contains(lr.myRole) &&
//   //                       !govIDs.contains(lr.myID),
//   //                 )
//   //                 .toList();

//   //         if (validRoles.isNotEmpty) {
//   //           final lr = randomElement(validRoles);
//   //           govIDs.add(lr.myID);
//   //           final locRole = LocationRole(
//   //             locationID: governtmentID,
//   //             myID: lr.myID,
//   //             myRole: myRole,
//   //             specialty: "",
//   //           );
//   //           roleList.add(locRole);
//   //           updateBuffer.add(
//   //             () async => await locRoleProvider.add(addMe: locRole),
//   //           );
//   //         } else {
//   //           String id = _uuid.v4();
//   //           String myAncestry = randomAncestry();
//   //           Person p = createRandomPerson(
//   //             newID: id,
//   //             newAncestry: myAncestry,
//   //             newAge: myAge,
//   //           );
//   //           newPeople.add(p);

//   //           updateBuffer.add(() async => await peopleProvider.add(addMe: p));
//   //           updateBuffer.add(
//   //             () async => await peopleSearchProvider.addPersonToSearch(p),
//   //           );

//   //           myRole = randomElement(gr.validRoles);
//   //           final locRole = LocationRole(
//   //             locationID: governtmentID,
//   //             myID: id,
//   //             myRole:
//   //                 Role.values.firstWhereOrNull(
//   //                   (v) => v.name.split("Government").first == gr.position,
//   //                 ) ??
//   //                 Role.government,
//   //             specialty: "",
//   //           );
//   //           roleList.add(locRole);
//   //           updateBuffer.add(
//   //             () async => await locRoleProvider.add(addMe: locRole),
//   //           );
//   //           LocationRole locRoleID;

//   //           locRoleID = LocationRole(
//   //             locationID: infoID,
//   //             myID: id,
//   //             myRole: myRole,
//   //             specialty: "",
//   //           );

//   //           roleList.add(locRoleID);
//   //           updateBuffer.add(
//   //             () async => await locRoleProvider.add(addMe: locRoleID),
//   //           );

//   //           final n = Node(id: id, relPairs: {});
//   //           updateBuffer.add(() async => await relProvider.bulkAddNodes([n]));
//   //           govIDs.add(id);
//   //           break;
//   //         }
//   //         break;
//   //     }
//   //   }

//   //   for (final update in updateBuffer) {
//   //     await update();
//   //   }
//   // }

//   // Future<void> createSocialNetwork(ref) async {
//   //   List<Person> people = List.from(ref.read(peopleListProvider));
//   //   PeopleList pList = ref.read(peopleListProvider.notifier);
//   //   RelationshipProvider relationshipsGraph = ref.read(
//   //     relationshipsProvider.notifier,
//   //   );
//   //   List<Node> relCache = List.from(ref.read(relationshipsProvider));
//   //   ProviderList<LocationRole> locRoleProvider = ref.read(
//   //     locationRoleListProvider.notifier,
//   //   );
//   //   List<LocationRole> locRoleList = ref.read(locationRoleListProvider);

//   //   Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);
//   //   // List<Person> newPeople=[];

//   //   List<Function> updateBuffer = [];
//   //   int countPartner(String p1) {
//   //     int myIndex = relCache.indexWhere((v) => v.id == p1);
//   //     if (myIndex == -1) {
//   //       return 0;
//   //     }
//   //     return relCache[myIndex].relPairs
//   //         .where((v) => v.iAmYour == RelationshipType.partner)
//   //         .length;
//   //   }

//   //   void addRelationship(String p1, String p2, RelationshipType relType) {
//   //     int index = relCache.indexWhere((n) => n.id == p1);
//   //     if (index == -1) {
//   //       relCache.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
//   //       updateBuffer.add(
//   //         () async => relationshipsGraph.addRelationship(p1, p2, relType),
//   //       );
//   //     } else {
//   //       relCache[index] = relCache[index].addRelationship(p2, relType);
//   //       updateBuffer.add(
//   //         () async => relationshipsGraph.addRelationship(p1, p2, relType),
//   //       );
//   //     }
//   //   }

//   //   void addSymmetricRelationship(
//   //     String p1,
//   //     String p2,
//   //     RelationshipType relType,
//   //   ) {
//   //     addRelationship(p1, p2, relType);
//   //     addRelationship(p2, p1, relType);
//   //   }

//   //   for (Person p in people) {
//   //     bool canMarry =
//   //         (allowedToPartner[p.age]!.isNotEmpty) &&
//   //         (countPartner(p.id) < p.maxSpouse);
//   //     bool doItAgain = true;
//   //     int maxIter = 1;
//   //     if (p.poly == PolyType.poly) {
//   //       maxIter = maxIter + random.nextInt(p.maxSpouse) + 1;
//   //     }
//   //     if (canMarry) {
//   //       for (int i = 0; i < maxIter; i++) {
//   //         while (doItAgain) {
//   //           if (countPartner(p.id) < p.maxSpouse) {
//   //             PartnerType myPartnerType = randomPartnerType(p.ancestry);
//   //             Set<String> myPreferredAncestry;
//   //             switch (myPartnerType) {
//   //               case (PartnerType.sameAncestry):
//   //                 myPreferredAncestry = {p.ancestry};
//   //                 break;
//   //               case (PartnerType.differentAncestry):
//   //                 myPreferredAncestry = {
//   //                   randomAncestry(
//   //                     restrictedAncestries: getOtherAncestries(p.ancestry),
//   //                   ),
//   //                 };
//   //                 break;
//   //               case (PartnerType.noPartner):
//   //                 myPreferredAncestry = {};
//   //                 doItAgain = false;
//   //             }
//   //             if (myPreferredAncestry.isNotEmpty) {
//   //               int myIndex = relCache.indexWhere((n) => n.id == p.id);
//   //               Set<String> doNotMarry = {};
//   //               if (myIndex != -1) {
//   //                 doNotMarry = relCache[myIndex].doNotMarry;
//   //               }
//   //               int numPart = countPartner(p.id);

//   //               List<Person> preCandidates =
//   //                   people
//   //                       .where(
//   //                         (f) =>
//   //                             ((myPreferredAncestry.contains(f.ancestry)) &&
//   //                                 (p.myPreferredPartnersPronouns.contains(
//   //                                   f.pronouns,
//   //                                 )) &&
//   //                                 (f.myPreferredPartnersPronouns.contains(
//   //                                   p.pronouns,
//   //                                 )) &&
//   //                                 (p.myPartnerAges.contains(f.age)) &&
//   //                                 (p.poly == f.poly) &&
//   //                                 (!doNotMarry.contains(f.id))),
//   //                       )
//   //                       .toList();
//   //               List<Person> candidates = [];
//   //               for (final c in preCandidates) {
//   //                 int cPartner = countPartner(c.id);
//   //                 if (numPart + cPartner < min(p.maxSpouse, c.maxSpouse)) {
//   //                   candidates.add(c);
//   //                 }
//   //               }
//   //               Person luckyOne;
//   //               if (candidates.isNotEmpty) {
//   //                 luckyOne = candidates[random.nextInt(candidates.length)];
//   //               } else {
//   //                 String newID = _uuid.v4();

//   //                 luckyOne = createRandomPerson(
//   //                   newID: newID,
//   //                   newAncestry: myPreferredAncestry.elementAt(
//   //                     random.nextInt(myPreferredAncestry.length),
//   //                   ),
//   //                   newPoly: p.poly,
//   //                   newAge: p.age,
//   //                   newPronouns: p.myPreferredPartnersPronouns.elementAt(
//   //                     random.nextInt(p.myPreferredPartnersPronouns.length),
//   //                   ),
//   //                   newOrientation: p.orientation,
//   //                 );
//   //                 // people.add(luckyOne);
//   //                 updateBuffer.add(() async => pList.add(addMe: luckyOne));
//   //                 updateBuffer.add(
//   //                   () async =>
//   //                       peopleSearchProvider.addPersonToSearch(luckyOne),
//   //                 );

//   //                 relCache.add(Node(id: luckyOne.id, relPairs: {}));
//   //                 updateBuffer.add(
//   //                   () async => relationshipsGraph.bulkAddNodes([
//   //                     Node(id: luckyOne.id, relPairs: {}),
//   //                   ]),
//   //                 );
//   //               }

//   //               Node nobody = Node(id: "", relPairs: {});
//   //               if (randomBreakUp(p.ancestry)) {
//   //                 Set<String> pPartners =
//   //                     relCache
//   //                         .firstWhere((n) => n.id == p.id, orElse: () => nobody)
//   //                         .allPartners;
//   //                 Set<String> luckyOnePartners =
//   //                     relCache
//   //                         .firstWhere(
//   //                           (n) => n.id == luckyOne,
//   //                           orElse: () => nobody,
//   //                         )
//   //                         .allPartners;
//   //                 addSymmetricRelationship(
//   //                   luckyOne.id,
//   //                   p.id,
//   //                   RelationshipType.ex,
//   //                 );
//   //                 for (String q in pPartners) {
//   //                   addSymmetricRelationship(
//   //                     luckyOne.id,
//   //                     q,
//   //                     RelationshipType.ex,
//   //                   );
//   //                 }

//   //                 for (String q in luckyOnePartners) {
//   //                   addSymmetricRelationship(p.id, q, RelationshipType.ex);
//   //                 }
//   //                 doItAgain = true;
//   //               } else {
//   //                 int index = relCache.indexWhere((n) => n.id == p.id);
//   //                 Set<String> luckyOneToMarrySet = {};
//   //                 if (index != -1) {
//   //                   luckyOneToMarrySet = relCache[index].allPartners;
//   //                 }

//   //                 luckyOneToMarrySet.add(p.id);

//   //                 int index2 = relCache.indexWhere((n) => n.id == luckyOne.id);
//   //                 Set<String> pToMarrySet = {};
//   //                 if (index2 != -1) {
//   //                   pToMarrySet =
//   //                       relCache
//   //                           .firstWhere((n) => n.id == luckyOne.id)
//   //                           .allPartners;
//   //                 }

//   //                 pToMarrySet.add(luckyOne.id);

//   //                 for (String q in luckyOneToMarrySet) {
//   //                   addSymmetricRelationship(
//   //                     q,
//   //                     luckyOne.id,
//   //                     RelationshipType.partner,
//   //                   );

//   //                   if ((locRoleList
//   //                       .where(
//   //                         (lr) =>
//   //                             lr.locationID == governtmentID &&
//   //                             lr.myID == luckyOne.id &&
//   //                             {
//   //                               Role.liegeGovernment,
//   //                               Role.nobleGovernment,
//   //                               Role.courtierGovernment,
//   //                             }.contains(lr.myRole),
//   //                       )
//   //                       .isNotEmpty)) {
//   //                     LocationRole locRole = LocationRole(
//   //                       locationID: governtmentID,
//   //                       myID: q,
//   //                       myRole: Role.minorNoble,
//   //                       specialty: "Minor Noble (via partner)",
//   //                     );

//   //                     updateBuffer.add(
//   //                       () async => await locRoleProvider.add(addMe: locRole),
//   //                     );
//   //                   }
//   //                 }
//   //                 for (String q in pToMarrySet) {
//   //                   addSymmetricRelationship(q, p.id, RelationshipType.partner);

//   //                   if ((locRoleList
//   //                       .where(
//   //                         (lr) =>
//   //                             lr.locationID == governtmentID &&
//   //                             lr.myID == p.id &&
//   //                             {
//   //                               Role.liegeGovernment,
//   //                               Role.nobleGovernment,
//   //                               Role.courtierGovernment,
//   //                             }.contains(lr.myRole),
//   //                       )
//   //                       .isNotEmpty)) {
//   //                     LocationRole locRole = LocationRole(
//   //                       locationID: governtmentID,
//   //                       myID: luckyOne.id,
//   //                       myRole: Role.minorNoble,
//   //                       specialty: "Minor Noble (via partner)",
//   //                     );

//   //                     updateBuffer.add(
//   //                       () async => await locRoleProvider.add(addMe: locRole),
//   //                     );
//   //                   }
//   //                 }
//   //                 doItAgain = false;
//   //               }
//   //             }
//   //           } else {
//   //             doItAgain = false;
//   //           }
//   //         }
//   //       }
//   //     }
//   //   }

//   //   for (final b in updateBuffer) {
//   //     await b();
//   //   }
//   // }




//   // Future<void> makeChildren(List<Person> whichPeople, ref) async {
//   //   // List<Person> people = List. from(ref.read(peopleListProvider));

//   //   PeopleList pList = ref.read(peopleListProvider.notifier);
//   //   RelationshipProvider relationshipsGraph = ref.read(
//   //     relationshipsProvider.notifier,
//   //   );
//   //   List<Node> relCache = List.from(ref.read(relationshipsProvider));
//   //   ProviderList<PendingRoles> pendingRoleProvider = ref.watch(
//   //     pendingRoleListProvider.notifier,
//   //   );
//   //   List<PendingRoles> prCache = List.from(ref.read(pendingRoleListProvider));
//   //   List<Person> allPeople = ref.read(peopleListProvider);
//   //   ProviderList<LocationRole> locRoleProvider = ref.read(
//   //     locationRoleListProvider.notifier,
//   //   );
//   //   List<LocationRole> locRoleList = ref.read(locationRoleListProvider);

//   //   List<RoleGeneration> allRoles = ref.read(
//   //     ref.read(myWorldProvider).allRoles,
//   //   );

//   //   List<LocationRole> locRoleAddQueue = [];

//   //   List<Role> hirelingRoles =
//   //       allRoles.where((r) => r.hireling).map((r) => r.thisRole).toList();
//   //   List<Role> marketRoles =
//   //       allRoles.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
//   //   List<Role> infoRoles =
//   //       allRoles.where((r) => r.informational).map((r) => r.thisRole).toList();

//   //   List<Person> newPeople = [];
//   //   List<Function> updateBuffer = [];
//   //   Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);

//   //   Map<Role, int> roleRemovalCounts = {};

//   //   Role? randomRoleFromAges(Set ages) {
//   //     Set<Role> firstPass =
//   //         allRoles
//   //             .where((ar) => ar.validAges.toSet().intersection(ages).isNotEmpty)
//   //             .map((ar) => ar.thisRole)
//   //             .toSet();
//   //     Set<Role> pendingPositive =
//   //         prCache.where((pr) => pr.howMany > 0).map((pr) => pr.role).toSet();

//   //     List<Role> validRoles = firstPass.intersection(pendingPositive).toList();
//   //     if (validRoles.isNotEmpty) {
//   //       return randomElement(validRoles);
//   //     }
//   //     return null;
//   //   }

//   //   void updateLocRoleQueue(String id, Role myRole) {
//   //     if (hirelingRoles.contains(myRole)) {
//   //       final locRole = LocationRole(
//   //         locationID: hirelingID,
//   //         myID: id,
//   //         myRole: myRole,
//   //         specialty: "",
//   //       );
//   //       locRoleAddQueue.add(locRole);
//   //     }
//   //     if (marketRoles.contains(myRole)) {
//   //       final locRole = LocationRole(
//   //         locationID: marketID,
//   //         myID: id,
//   //         myRole: myRole,
//   //         specialty: "",
//   //       );
//   //       locRoleAddQueue.add(locRole);
//   //     }
//   //     if (infoRoles.contains(myRole)) {
//   //       final locRole = LocationRole(
//   //         locationID: informationalID,
//   //         myID: id,
//   //         myRole: myRole,
//   //         specialty: "",
//   //       );
//   //       locRoleAddQueue.add(locRole);
//   //     }

//   //     final locRole = LocationRole(
//   //       locationID: infoID,
//   //       myID: id,
//   //       myRole: myRole,
//   //       specialty: "",
//   //     );

//   //     // updateBuffer.add(() async => await locRoleProvider.add(addMe: locRole));
//   //     locRoleAddQueue.add(locRole);
//   //   }

//   //   void addRelationship(String p1, String p2, RelationshipType relType) {
//   //     int index = relCache.indexWhere((n) => n.id == p1);
//   //     if (index == -1) {
//   //       relCache.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
//   //       updateBuffer.add(
//   //         () async => relationshipsGraph.addRelationship(p1, p2, relType),
//   //       );
//   //     } else {
//   //       relCache[index] = relCache[index].addRelationship(p2, relType);
//   //       updateBuffer.add(
//   //         () async => relationshipsGraph.addRelationship(p1, p2, relType),
//   //       );
//   //     }
//   //   }

//   //   List<Map<String, dynamic>> identifyChildren(Person p1) {
//   //     List<Map<String, dynamic>> output = [];
//   //     List<AgeType> childBearingAges =
//   //         AgeType.values.where((v) => v.index >= AgeType.adult.index).toList();

//   //     if (!childBearingAges.contains(p1.age)) return [];

//   //     Ancestry a = ancestries.firstWhere((an) => an.name == p1.ancestry);
//   //     int index = relCache.indexWhere((n) => n.id == p1.id);
//   //     if (index == -1) {
//   //       relCache.add(Node(id: p1.id, relPairs: {}));
//   //       updateBuffer.add(
//   //         () async =>
//   //             relationshipsGraph.bulkAddNodes([Node(id: p1.id, relPairs: {})]),
//   //       );
//   //     }
//   //     Node myNode = relCache.singleWhere((n) => n.id == p1.id);
//   //     Set<RelationshipType> parentTypes = {
//   //       RelationshipType.partner,
//   //       RelationshipType.ex,
//   //     };

//   //     List<String> possibleParents =
//   //         myNode.relPairs
//   //             .where((e) => parentTypes.contains(e.iAmYour))
//   //             .map((rp) => rp.you)
//   //             .toList();

//   //     int preExistingChildren =
//   //         myNode.relPairs
//   //             .where((e) => e.iAmYour == RelationshipType.parent)
//   //             .length;

//   //     if (random.nextDouble() < a.childrenProb) {
//   //       bool funToMakeFunToEat = preExistingChildren < a.maxChildren;
//   //       while (funToMakeFunToEat) {
//   //         double r = random.nextDouble();
//   //         AdoptionType myType = AdoptionType.noAdoption;
//   //         if (r < a.adoptionWithinProb) {
//   //           myType = AdoptionType.sameAncestry;
//   //         }
//   //         r -= a.adoptionWithinProb;
//   //         if (r < a.adoptionOutsideProb) {
//   //           myType = AdoptionType.differentAncestry;
//   //         }
//   //         Person parent = p1;

//   //         if (possibleParents.isNotEmpty) {
//   //           String parentID =
//   //               possibleParents[random.nextInt(possibleParents.length)];
//   //           parent = [
//   //             ...allPeople,
//   //             ...newPeople,
//   //           ].firstWhere((p) => p.id == parentID);
//   //         }
//   //         output.add({"parent": parent, "childType": myType});
//   //         funToMakeFunToEat =
//   //             (random.nextDouble() < a.childrenProb) &&
//   //             (output.length + preExistingChildren < a.maxChildren);
//   //       }
//   //     }
//   //     return output;
//   //   }

//   //   bool hasNoParent(String c) {
//   //     int index = relCache.indexWhere((n) => n.id == c);
//   //     if (index == -1) {
//   //       return true;
//   //     } else {
//   //       return relCache[index].relPairs
//   //           .where((rp) => rp.iAmYour == RelationshipType.parent)
//   //           .isEmpty;
//   //     }
//   //   }

//   //   Person findAdoption(Person parent, Set<String> adoptionAncestries) {
//   //     List<AgeType> adoptableAges =
//   //         AgeType.values.where((v) => v.index + 2 <= parent.age.index).toList();
//   //     List<Person> candidates =
//   //         whichPeople
//   //             .where(
//   //               (p) =>
//   //                   adoptableAges.contains(p.age) &&
//   //                   adoptionAncestries.contains(p.ancestry) &&
//   //                   hasNoParent(p.id),
//   //             )
//   //             .toList();
//   //     if (candidates.isEmpty) {
//   //       String newAncestry = randomElement(adoptionAncestries.toList());
//   //       AgeType newAge = randomElement(adoptableAges);
//   //       String id = _uuid.v4();
//   //       Role? childRole = randomRoleFromAges(adoptableAges.toSet());
//   //       Person c;
//   //       if (childRole == null) {
//   //         c = createRandomPerson(
//   //           newAge: newAge,
//   //           newAncestry: newAncestry,
//   //           newID: id,
//   //         );
//   //       } else {
//   //         Set<AgeType> roleAges =
//   //             allRoles
//   //                 .firstWhere((ar) => ar.thisRole == childRole)
//   //                 .validAges
//   //                 .toSet();
//   //         newAge = randomElement(
//   //           (adoptableAges.toSet().intersection(roleAges).toList()),
//   //         );
//   //         c = createRandomPerson(
//   //           newAge: newAge,
//   //           newAncestry: newAncestry,
//   //           newID: id,
//   //         );
//   //         updateBuffer.add(
//   //           () async => await peopleSearchProvider.addPersonToSearch(c),
//   //         );

//   //         int myInd = prCache.indexWhere((pr) => pr.role == childRole);
//   //         PendingRoles newPR = PendingRoles(
//   //           howMany: prCache[myInd].howMany - 1,
//   //           role: prCache[myInd].role,
//   //         );
//   //         prCache[myInd] = newPR;
//   //         roleRemovalCounts[childRole] =
//   //             (roleRemovalCounts[childRole] ?? 0) + 1;

//   //         updateLocRoleQueue(id, childRole);
//   //         final n = Node(id: id, relPairs: {});
//   //         updateBuffer.add(
//   //           () async => await ref
//   //               .read(relationshipsProvider.notifier)
//   //               .bulkAddNodes([n]),
//   //         );
//   //       }

//   //       newPeople.add(c);
//   //       updateBuffer.add(() async => pList.add(addMe: c));
//   //       updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(c));
//   //       return c;
//   //     } else {
//   //       return randomElement(candidates);
//   //     }
//   //   }

//   //   for (final p in whichPeople) {
//   //     List<Map<String, dynamic>> childrenMap = identifyChildren(p);

//   //     for (Map<String, dynamic> m in childrenMap) {
//   //       Person parent = m["parent"];
//   //       AdoptionType childType = m["childType"];
//   //       Person c;
//   //       switch (childType) {
//   //         case AdoptionType.differentAncestry:
//   //           c = findAdoption(p, {
//   //             randomAncestry(
//   //               restrictedAncestries: getOtherAncestries(p.ancestry),
//   //             ),
//   //           });
//   //           break;
//   //         case AdoptionType.sameAncestry:
//   //           c = findAdoption(p, {p.ancestry});
//   //           break;
//   //         case AdoptionType.noAdoption:
//   //           List<AgeType> childAges =
//   //               AgeType.values
//   //                   .where(
//   //                     (v) => v.index + 2 <= min(p.age.index, parent.age.index),
//   //                   )
//   //                   .toList();

//   //           final newAncestry = randomElement([p.ancestry, parent.ancestry]);

//   //           AgeType newAge = randomElement(childAges);
//   //           String id = _uuid.v4();
//   //           Role? childRole = randomRoleFromAges(childAges.toSet());
//   //           if (childRole == null) {
//   //             c = createRandomPerson(
//   //               newAge: newAge,
//   //               newAncestry: newAncestry,
//   //               newID: id,
//   //               newSurname: p.surname,
//   //             );
//   //           } else {
//   //             Set<AgeType> roleAges =
//   //                 allRoles
//   //                     .firstWhere((ar) => ar.thisRole == childRole)
//   //                     .validAges
//   //                     .toSet();
//   //             newAge = randomElement(
//   //               (childAges.toSet().intersection(roleAges).toList()),
//   //             );
//   //             c = createRandomPerson(
//   //               newAge: newAge,
//   //               newAncestry: newAncestry,
//   //               newID: id,
//   //             );
//   //             updateBuffer.add(
//   //               () async => await peopleSearchProvider.addPersonToSearch(c),
//   //             );

//   //             int myInd = prCache.indexWhere((pr) => pr.role == childRole);
//   //             PendingRoles newPR = PendingRoles(
//   //               howMany: prCache[myInd].howMany - 1,
//   //               role: prCache[myInd].role,
//   //             );
//   //             prCache[myInd] = newPR;
//   //             roleRemovalCounts[childRole] =
//   //                 (roleRemovalCounts[childRole] ?? 0) + 1;

//   //             updateLocRoleQueue(id, childRole);
//   //             final n = Node(id: id, relPairs: {});
//   //             updateBuffer.add(
//   //               () async => await ref
//   //                   .read(relationshipsProvider.notifier)
//   //                   .bulkAddNodes([n]),
//   //             );
//   //           }

//   //           newPeople.add(c);
//   //           updateBuffer.add(() async => await pList.add(addMe: c));
//   //           updateBuffer.add(
//   //             () async => await peopleSearchProvider.addPersonToSearch(c),
//   //           );

//   //           relCache.add(Node(id: c.id, relPairs: {}));
//   //           updateBuffer.add(
//   //             () async => await relationshipsGraph.bulkAddNodes([
//   //               Node(id: c.id, relPairs: {}),
//   //             ]),
//   //           );
//   //       }
//   //       addRelationship(p.id, c.id, RelationshipType.child);
//   //       addRelationship(parent.id, c.id, RelationshipType.child);
//   //       addRelationship(c.id, p.id, RelationshipType.parent);
//   //       addRelationship(c.id, parent.id, RelationshipType.parent);

//   //       if (locRoleList
//   //           .where(
//   //             (lr) =>
//   //                 lr.locationID == governtmentID &&
//   //                 lr.myID == p.id &&
//   //                 {
//   //                   Role.liegeGovernment,
//   //                   Role.nobleGovernment,
//   //                   Role.courtierGovernment,
//   //                 }.contains(lr.myRole),
//   //           )
//   //           .isNotEmpty) {
//   //         LocationRole locRole = LocationRole(
//   //           locationID: governtmentID,
//   //           myID: c.id,
//   //           myRole: Role.minorNoble,
//   //           specialty: "Minor Noble (via Parent)",
//   //         );

//   //         updateBuffer.add(
//   //           () async => await locRoleProvider.add(addMe: locRole),
//   //         );
//   //       }
//   //     }
//   //   }

//   //   for (final p in [...whichPeople, ...newPeople]) {
//   //     updateBuffer.add(
//   //       () async => await relationshipsGraph.findAndMakeSiblings(p.id),
//   //     );
//   //   }

//   //   updateBuffer.add(
//   //     () async => await locRoleProvider.bulkAdd(items: locRoleAddQueue),
//   //   );

//   //   updateBuffer.add(() async {
//   //     for (final entry in roleRemovalCounts.entries) {
//   //       await pendingRoleProvider.removeFromRole(entry.key, entry.value);
//   //     }
//   //   });
//   //   for (final b in updateBuffer) {
//   //     await b();
//   //   }
//   // }

//   // int numPartners({required PolyType myPoly, required myAncestry}) {
//   //   switch (myPoly) {
//   //     case PolyType.poly:
//   //       int mpp =
//   //           ancestries.singleWhere((a) => a.name == myAncestry).maxPolyPartner;
//   //       return min(random.nextInt(mpp) + 2, mpp);
//   //     case PolyType.notPoly:
//   //       return 1;
//   //   }
//   // }

// Future<void> makeChildren(List<Person> whichPeople, WidgetRef ref) async {
//     // List<Person> people = List. from(ref.read(peopleListProvider));

//     final peoplePN = ref.read(peopleProvider.notifier);
//     final relationshipPN = ref.read(relationshipsProvider.notifier);

//     final relationships = ref.watch(relationshipsProvider);

//     final pendingRolePN = ref.read(pendingRolesProvider.notifier);
//     final pendingRoles = ref.watch(pendingRolesProvider);

//     final allPeople = ref.watch(peopleProvider);
    
//     final locRolePN = ref.read(locationRolesProvider.notifier);
//     final locRoleList = ref.watch(locationRolesProvider);

//     List<RoleGeneration> allRoles = ref.read(roleMetaProvider);

//     List<LocationRole> locRoleAddQueue = [];

//     List<Role> hirelingRoles =
//         allRoles.where((r) => r.hireling).map((r) => r.thisRole).toList();
//     List<Role> marketRoles =
//         allRoles.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
//     List<Role> infoRoles =
//         allRoles.where((r) => r.informational).map((r) => r.thisRole).toList();

//     List<Person> newPeople = [];
//     List<Function> updateBuffer = [];

//     Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);

//     Map<Role, int> roleRemovalCounts = {};

//     Role? randomRoleFromAges(Set ages) {
//       Set<Role> firstPass =
//           allRoles
//               .where((ar) => ar.validAges.toSet().intersection(ages).isNotEmpty)
//               .map((ar) => ar.thisRole)
//               .toSet();
//       Set<Role> pendingPositive =
//           pendingRoles.where((pr) => pr.howMany > 0).map((pr) => pr.role).toSet();

//       List<Role> validRoles = firstPass.intersection(pendingPositive).toList();
//       if (validRoles.isNotEmpty) {
//         return randomElement(validRoles);
//       }
//       return null;
//     }

//     void updateLocRoleQueue(String id, Role myRole) {
//       if (hirelingRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: hirelingID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (marketRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: marketID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (infoRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: informationalID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }

//       final locRole = LocationRole(
//         locationID: infoID,
//         myID: id,
//         myRole: myRole,
//         specialty: "",
//       );

//       // updateBuffer.add(() async => await locRoleProvider.add(addMe: locRole));
//       // locRoleAddQueue.add(locRole);
//       locRolePN.add(locRole);
//     }

//     void addRelationship(String p1, String p2, RelationshipType relType) {
//       int index = relationships.indexWhere((n) => n.id == p1);
//       if (index == -1) {
//         relationshipPN.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
//       } else {        
//           relationshipPN.addRelationship(p1, p2, relType);
//       }
//     }

//     List<Map<String, dynamic>> identifyChildren(Person p1) {
//       List<Map<String, dynamic>> output = [];
//       List<AgeType> childBearingAges =
//           AgeType.values.where((v) => v.index >= AgeType.adult.index).toList();

//       if (!childBearingAges.contains(p1.age)) return [];

//       Ancestry a = ancestries.firstWhere((an) => an.name == p1.ancestry);
//       int index = relationships.indexWhere((n) => n.id == p1.id);
//       if (index == -1) {
//         relationshipPN.add(Node(id: p1.id, relPairs: {}));
//       }
//       Node myNode = index != -1 
//   ? relationships[index] 
//   : Node(id: p1.id, relPairs: {});
  
//       Set<RelationshipType> parentTypes = {
//         RelationshipType.partner,
//         RelationshipType.ex,
//       };

//       List<String> possibleParents =
//           myNode.relPairs
//               .where((e) => parentTypes.contains(e.iAmYour))
//               .map((rp) => rp.you)
//               .toList();

//       int preExistingChildren =
//           myNode.relPairs
//               .where((e) => e.iAmYour == RelationshipType.parent)
//               .length;

//       if (random.nextDouble() < a.childrenProb) {
//         bool funToMakeFunToEat = preExistingChildren < a.maxChildren;
//         while (funToMakeFunToEat) {
//           double r = random.nextDouble();
//           AdoptionType myType = AdoptionType.noAdoption;
//           if (r < a.adoptionWithinProb) {
//             myType = AdoptionType.sameAncestry;
//           }
//           r -= a.adoptionWithinProb;
//           if (r < a.adoptionOutsideProb) {
//             myType = AdoptionType.differentAncestry;
//           }
//           Person parent = p1;

//           if (possibleParents.isNotEmpty) {
//             String parentID =
//                 possibleParents[random.nextInt(possibleParents.length)];
//             parent = [
//               ...allPeople,
//               ...newPeople,
//             ].firstWhere((p) => p.id == parentID);
//           }
//           output.add({"parent": parent, "childType": myType});
//           funToMakeFunToEat =
//               (random.nextDouble() < a.childrenProb) &&
//               (output.length + preExistingChildren < a.maxChildren);
//         }
//       }
//       return output;
//     }

//     bool hasNoParent(String c) {
//       int index = relationships.indexWhere((n) => n.id == c);
//       if (index == -1) {
//         return true;
//       } else {
//         return relationships[index].relPairs
//             .where((rp) => rp.iAmYour == RelationshipType.parent)
//             .isEmpty;
//       }
//     }

//     Person findAdoption(Person parent, Set<String> adoptionAncestries) {
//       List<AgeType> adoptableAges =
//           AgeType.values.where((v) => v.index + 2 <= parent.age.index).toList();
//       List<Person> candidates =
//           whichPeople
//               .where(
//                 (p) =>
//                     adoptableAges.contains(p.age) &&
//                     adoptionAncestries.contains(p.ancestry) &&
//                     hasNoParent(p.id),
//               )
//               .toList();
//       if (candidates.isEmpty) {
//         String newAncestry = randomElement(adoptionAncestries.toList());
//         AgeType newAge = randomElement(adoptableAges);
//         String id = _uuid.v4();
//         Role? childRole = randomRoleFromAges(adoptableAges.toSet());
//         Person c;
//         if (childRole == null) {
//           c = createRandomPerson(ref,
//             newAge: newAge,
//             newAncestry: newAncestry,
//             newID: id,
//           );
//         } else {
//           Set<AgeType> roleAges =
//               allRoles
//                   .firstWhere((ar) => ar.thisRole == childRole)
//                   .validAges
//                   .toSet();
//           newAge = randomElement(
//             (adoptableAges.toSet().intersection(roleAges).toList()),
//           );
//           c = createRandomPerson(ref,
//             newAge: newAge,
//             newAncestry: newAncestry,
//             newID: id,
//           );
//           updateBuffer.add(
//             () async => await peopleSearchProvider.addPersonToSearch(c),
//           );

//           int myInd = pendingRoles.indexWhere((pr) => pr.role == childRole);
//           PendingRoles newPR = PendingRoles(
//             howMany: pendingRoles[myInd].howMany - 1,
//             role: pendingRoles[myInd].role,
//           );
//           pendingRoles[myInd] = newPR;
//           roleRemovalCounts[childRole] =
//               (roleRemovalCounts[childRole] ?? 0) + 1;

//           updateLocRoleQueue(id, childRole);
//           final n = Node(id: id, relPairs: {});
//           relationshipPN.add(n);
//         }

//         newPeople.add(c);
//         peoplePN.add(c);
//         // updateBuffer.add(() async => peoplePN.add(addMe: c));
//         updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(c));
//         return c;
//       } else {
//         return randomElement(candidates);
//       }
//     }

//     for (final p in whichPeople) {
//       List<Map<String, dynamic>> childrenMap = identifyChildren(p);

//       for (Map<String, dynamic> m in childrenMap) {
//         Person parent = m["parent"];
//         AdoptionType childType = m["childType"];
//         Person c;
//         switch (childType) {
//           case AdoptionType.differentAncestry:
//             c = findAdoption(p, {
//               randomAncestry(
//                 restrictedAncestries: getOtherAncestries(ref,p.ancestry),
//               ),
//             });
//             break;
//           case AdoptionType.sameAncestry:
//             c = findAdoption(p, {p.ancestry});
//             break;
//           case AdoptionType.noAdoption:
//             List<AgeType> childAges =
//                 AgeType.values
//                     .where(
//                       (v) => v.index + 2 <= min(p.age.index, parent.age.index),
//                     )
//                     .toList();

//             final newAncestry = randomElement([p.ancestry, parent.ancestry]);

//             AgeType newAge = randomElement(childAges);
//             String id = _uuid.v4();
//             Role? childRole = randomRoleFromAges(childAges.toSet());
//             if (childRole == null) {
//               c = createRandomPerson(ref,
//                 newAge: newAge,
//                 newAncestry: newAncestry,
//                 newID: id,
//                 newSurname: p.surname,
//               );
//             } else {
//               Set<AgeType> roleAges =
//                   allRoles
//                       .firstWhere((ar) => ar.thisRole == childRole)
//                       .validAges
//                       .toSet();
//               newAge = randomElement(
//                 (childAges.toSet().intersection(roleAges).toList()),
//               );
//               c = createRandomPerson(ref,
//                 newAge: newAge,
//                 newAncestry: newAncestry,
//                 newID: id,
//               );
//               updateBuffer.add(
//                 () async => await peopleSearchProvider.addPersonToSearch(c),
//               );

//               int myInd = pendingRoles.indexWhere((pr) => pr.role == childRole);
//               PendingRoles newPR = PendingRoles(
//                 howMany: pendingRoles[myInd].howMany - 1,
//                 role: pendingRoles[myInd].role,
//               );
//               pendingRoles[myInd] = newPR;
//               roleRemovalCounts[childRole] =
//                   (roleRemovalCounts[childRole] ?? 0) + 1;

//               updateLocRoleQueue(id, childRole);
//               final n = Node(id: id, relPairs: {});
//               relationshipPN.add(n);
    
//             }

//             newPeople.add(c);
//             peoplePN.add(c);
            
//             updateBuffer.add(
//               () async => await peopleSearchProvider.addPersonToSearch(c),
//             );

//             relationshipPN.add(Node(id: c.id, relPairs: {}));
//         }
//         addRelationship(p.id, c.id, RelationshipType.child);
//         addRelationship(parent.id, c.id, RelationshipType.child);
//         addRelationship(c.id, p.id, RelationshipType.parent);
//         addRelationship(c.id, parent.id, RelationshipType.parent);

//         if (locRoleList
//             .where(
//               (lr) =>
//                   lr.locationID == governtmentID &&
//                   lr.myID == p.id &&
//                   {
//                     Role.liegeGovernment,
//                     Role.nobleGovernment,
//                     Role.courtierGovernment,
//                   }.contains(lr.myRole),
//             )
//             .isNotEmpty) {
//           LocationRole locRole = LocationRole(
//             locationID: governtmentID,
//             myID: c.id,
//             myRole: Role.minorNoble,
//             specialty: "Minor Noble (via Parent)",
//           );
//           locRolePN.add(locRole);
//         }
//       }
//     }

//     for (final p in [...whichPeople, ...newPeople]) {
//        relationshipPN.findAndMakeSiblings(p.id);
//     }

//     // updateBuffer.add(
//     //   () async => await locRolePN.bulkAdd(items: locRoleAddQueue),
//     // );

//     // updateBuffer.add(() async {
//     //   for (final entry in roleRemovalCounts.entries) {
//     //     await pendingRolePN.removeFromRole(entry.key, entry.value);
//     //   }
//     // });

//     await pendingRolePN.commitChanges();
//     await peoplePN.commitChanges();
//     await relationshipPN.commitChanges();
//     await locRolePN.commitChanges();

//     for (final b in updateBuffer) {
//       await b();
//     }
//   }

//   int numPartners({required PolyType myPoly, required myAncestry}) {
//     switch (myPoly) {
//       case PolyType.poly:
//         int mpp =
//             ancestries.singleWhere((a) => a.name == myAncestry).maxPolyPartner;
//         return min(random.nextInt(mpp) + 2, mpp);
//       case PolyType.notPoly:
//         return 1;
//     }
//   }

//   Person createRandomPerson(WidgetRef ref,
//     {
//     String? newFirstName,
//     String? newSurname,
//     String? newAncestry,
//     String? newQuirk1,
//     String? newQuirk2,
//     String? newResonantArgument,
//     AgeType? newAge,
//     PronounType? newPronouns,
//     OrientationType? newOrientation,
//     String? newFaction,
//     String? newID,
//     List<String?>? newPartnerID,
//     List<String?>? newChildrenID,
//     List<String?>? newParentID,
//     List<String>? newExID,
//     String? newFrequents,
//     PolyType? newPoly,
//     int? newMaxSpouse,
//     List<LocationRole>? newRoles,
//     List<Relationship>? newRelationships,
//   }) {
//     newAncestry = newAncestry ?? randomAncestry();
//     newQuirk1 = newQuirk1 ?? randomQuirks(ref,newQuirk2);
//     newQuirk2 = newQuirk2 ?? randomQuirks(ref,newQuirk1);
//     newPronouns = newPronouns ?? randomPronouns(ref,newAncestry);
//     if (newPoly == PolyType.poly) {
//       newMaxSpouse =
//           newMaxSpouse ??
//           numPartners(myPoly: PolyType.poly, myAncestry: newAncestry);
//     } else {
//       newMaxSpouse = 1;
//     }

//     return Person(
//       firstName: newFirstName ?? randomGivenName(ref,newAncestry, newPronouns),
//       surname: newSurname ?? randomSurname(ref,newAncestry),
//       ancestry: newAncestry,
//       quirk1: newQuirk1,
//       quirk2: newQuirk2,
//       resonantArgument: newResonantArgument ?? randomRA(ref),
//       age: newAge ?? randomAge(ref,newAncestry),
//       pronouns: newPronouns,
//       orientation: newOrientation ?? randomOrientation(ref,newAncestry),
//       faction: newFaction ?? "",
//       id: newID ?? _uuid.v4(),
//       partnerID: newPartnerID ?? [],
//       childrenID: newChildrenID ?? [],
//       parents: newParentID ?? [],
//       exIDs: newExID ?? [],
//       poly: newPoly ?? randomPoly(ref,newAncestry),
//       maxSpouse: newMaxSpouse,
//       myRoles: newRoles ?? [],
//       relationships: newRelationships ?? [],
//     );
//   }

//   bool randomBreakUp(String myAncestry) {
//     final Ancestry a = ancestries.singleWhere((s) => s.name == myAncestry);
//     return (a.breakup());
//   }

//   PartnerType randomPartnerType(String myAncestry) {
//     final Ancestry a = ancestries.singleWhere((s) => s.name == myAncestry);
//     return a.randomPartnerType();
//   }

//   Set<String> getOtherAncestries(WidgetRef ref, myAncestry) {
//     final ancestriesList = ref.read(ancestriesProvider);
//     return (ancestriesList.where(
//       (s) => s.name != myAncestry,
//     )).map((a) => a.name).toSet();
//   }

//   PronounType randomPronouns(WidgetRef ref,String myAncestry) {
//     final ancestriesList = ref.read(ancestriesProvider);
//     final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
//     return a.randomPronouns();
//   }

//   AgeType randomAge(WidgetRef ref,String myAncestry) {
//     final ancestriesList = ref.read(ancestriesProvider);
//     final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
//     return a.randomAge();
//   }

//   OrientationType randomOrientation(WidgetRef ref, String myAncestry) {
//     final ancestriesList = ref.read(ancestriesProvider);
//     final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
//     return a.randomOrientationType();
//   }

//   PolyType randomPoly(WidgetRef ref,String myAncestry) {
//     final ancestriesList = ref.read(ancestriesProvider);
//     final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
//     return a.randomPolyType();
//   }

//   String randomRA(WidgetRef ref) {
//     final resonantArgumentsList = ref.read(resonantArgumentsProvider);
//     return resonantArgumentsList[random.nextInt(resonantArguments.length)].argument;
//   }

//   String randomQuirks(WidgetRef ref, String? givenQuirk) {
//     givenQuirk = givenQuirk ?? "";
//     List<String> quirksList = ref.read(quirksProvider).map((q)=>q.quirk).toList();
//     List<String> subList = quirksList.where((q) => (q != givenQuirk)).toList();

//     return subList[random.nextInt(subList.length)];
//   }

//   String randomGivenName(WidgetRef ref, String myAncestry, PronounType pronouns) {
//     List<GivenName> givenNamesList = ref.read(givenNamesProvider);
//     List<GivenName> subList =
//         givenNamesList
//             .where(
//               (n) =>
//                   (n.ancestry.contains(myAncestry) &&
//                       n.pronouns.contains(pronouns)),
//             )
//             .toList();
//     return subList[random.nextInt(subList.length)].name;
//   }

//   String randomSurname(WidgetRef ref,String myAncestry) {
//     List<Surname> surnamesList = ref.read(surnamesProvider);
//     List<Surname> subList =
//         surnamesList.where((n) => (n.ancestry.contains(myAncestry))).toList();
//     return (subList[random.nextInt(subList.length)]).name;
//   }

//   Future<void> handleShowMore(Role myRole, WidgetRef ref) async {
//     final roleMeta = ref.read(roleMetaProvider);
//     final peoplePN = ref.read(peopleProvider.notifier);
//     final locrolePN = ref.read(locationRolesProvider.notifier);
//     final relationshipPN = ref.read(relationshipsProvider.notifier);
//     final peopleSearchProvider = ref.read(peopleSearch.notifier);

//     final pendingRoles = ref.watch(pendingRolesProvider);
//     final pendingRolesPN = ref.read(pendingRolesProvider.notifier);

//     Map<Role, int> roleRemovalCounts = {};

//     int countRemaining =
//         pendingRoles.firstWhere((e) => e.role == myRole).howMany;

//     int maxAllowed = max(
//       1,
//       (countRemaining * (propActivate[myRole] ?? 0)).toInt(),
//     );

//     int numActive = min(maxAllowed, countRemaining);

//     List<Person> newCreations = [];
//     List<Function> updateBuffer = [];
//     List<LocationRole> locRoleAddQueue = [];
//     List<Person> peopleAddQueue = [];

    
//     final roleMetaPN = ref.read(roleMetaProvider.notifier);


//     int x = min(10 * numActive, pendingRoles.fold(0, (a, pr) => a + pr.howMany));

//     List<Role> hirelingRoles =
//         roleMeta.where((r) => r.hireling).map((r) => r.thisRole).toList();
//     List<Role> marketRoles =
//         roleMeta.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
//     List<Role> infoRoles =
//         roleMeta.where((r) => r.informational).map((r) => r.thisRole).toList();

//     for (int i = 0; i < numActive; i++) {
//       AgeType myAge = roleMetaPN.getAgeOfRole(myRole);
//       String id = _uuid.v4();
//       String myAncestry = randomAncestry();
//       Person p = createRandomPerson(ref,
//         newID: id,
//         newAncestry: myAncestry,
//         newAge: myAge,
//       );

//       newCreations.add(p);

//       // updateBuffer.add(() async => await peopleProvider.add(addMe: p));
//       // peopleAddQueue.add(p);
//       peoplePN.add(p);
//       updateBuffer.add(
//         () async => await peopleSearchProvider.addPersonToSearch(p),
//       );

//       if (hirelingRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: hirelingID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locrolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (marketRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: marketID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locrolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (infoRoles.contains(myRole)) {
//         final locRole = LocationRole(
//           locationID: informationalID,
//           myID: id,
//           myRole: myRole,
//           specialty: "",
//         );
//         locrolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }

//       final locRole = LocationRole(
//         locationID: infoID,
//         myID: id,
//         myRole: myRole,
//         specialty: "",
//       );

//       // updateBuffer.add(() async => await locRoleProvider.add(addMe: locRole));
//       locRoleAddQueue.add(locRole);
//       locrolePN.add(locRole);
//       final n = Node(id: id, relPairs: {});
//       relationshipPN.add(n);
//     }

//     int indy = pendingRoles.indexWhere((pr) => pr.role == myRole);
//     PendingRoles newPR = PendingRoles(
//       howMany: pendingRoles[indy].howMany - numActive,
//       role: myRole,
//     );
//     pendingRoles[indy] = newPR;
//     roleRemovalCounts[myRole] = numActive;

//     for (int i = 0; i < x; i++) {
//       final available = pendingRoles.where((pr) => pr.howMany > 0).toList();
//       if (available.isEmpty) {
//         break;
//       }
//       PendingRoles pr = randomElement(available);

//       AgeType myAge = roleMetaPN.getAgeOfRole(pr.role);
//       String id = _uuid.v4();
//       String myAncestry = randomAncestry();

//       Person p = createRandomPerson(ref,
//         newID: id,
//         newAncestry: myAncestry,
//         newAge: myAge,
//       );

//       // print("Wha?");
//       if (hirelingRoles.contains(pr.role)) {
//         final locRole = LocationRole(
//           locationID: hirelingID,
//           myID: id,
//           myRole: pr.role,
//           specialty: "",
//         );

//         locRoleAddQueue.add(locRole);
//       }
//       if (marketRoles.contains(pr.role)) {
//         final locRole = LocationRole(
//           locationID: marketID,
//           myID: id,
//           myRole: pr.role,
//           specialty: "",
//         );

//         locRoleAddQueue.add(locRole);
//       }
//       if (infoRoles.contains(pr.role)) {
//         final locRole = LocationRole(
//           locationID: informationalID,
//           myID: id,
//           myRole: pr.role,
//           specialty: "",
//         );

//         locRoleAddQueue.add(locRole);
//       }

//       final locRole = LocationRole(
//         locationID: infoID,
//         myID: id,
//         myRole: pr.role,
//         specialty: "",
//       );

//       locRoleAddQueue.add(locRole);
      
//       final n = Node(id: id, relPairs: {});
//       relationshipPN.add(n);

//       newCreations.add(p);

//       peoplePN.add(p);

//       updateBuffer.add(
//         () async => await peopleSearchProvider.addPersonToSearch(p),
//       );

//       roleRemovalCounts[pr.role] = (roleRemovalCounts[pr.role] ?? 0) + 1;

//       int indy = pendingRoles.indexWhere((p) => p.role == pr.role);
//       PendingRoles newPR = PendingRoles(
//         howMany: pendingRoles[indy].howMany - 1,
//         role: pr.role,
//       );

//       pendingRolesPN.updateByKey(pr.role.name, newPR);
      
//     }

//     // updateBuffer.add(() async {
//     //   await locrolePN.bulkAdd(items: locRoleAddQueue);
//     // });
//     // updateBuffer.add(() async {
//     //   await peoplePN.bulkAdd(people: peopleAddQueue);
//     // });

//     await locrolePN.commitChanges();
//     await peoplePN.commitChanges();
//     await pendingRolesPN.commitChanges();
//     await relationshipPN.commitChanges();

//     for (final update in updateBuffer) {
//       await update();
//     }
//     await createLazySocialNetwork(ref: ref, newPeople: newCreations);

    
//   }

//   Future<void> createLazySocialNetwork({
//     required WidgetRef ref,
//     required List<Person> newPeople,
//   }) async {

//     final relationshipsPN = ref.read(relationshipsProvider.notifier);
//     final relationships = ref.watch(relationshipsProvider);

//     final peopleSearchProvider = ref.read(peopleSearch.notifier);

//     final pendingRoles = ref.watch(pendingRolesProvider);
//     final pendingRolesPN = ref.read(pendingRolesProvider.notifier);

//     final locRolePN = ref.read(locationRolesProvider.notifier);
    
//     final peoplePN = ref.read(peopleProvider.notifier);
//     // final people = ref.watch(peopleProvider);

//     final List<Function> updateBuffer = [];
//     List<LocationRole> locRoleAddQueue = [];
//     Map<Role, int> roleRemovalCounts = {};

//     final roleMeta = ref.read(roleMetaProvider);

//     List<Role> hirelingRoles =
//         roleMeta.where((r) => r.hireling).map((r) => r.thisRole).toList();
//     List<Role> marketRoles =
//         roleMeta.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
//     List<Role> infoRoles =
//         roleMeta.where((r) => r.informational).map((r) => r.thisRole).toList();

//     final locRoleProvider = ref.read(locationRoleListProvider.notifier);

//     int countPartner(String p1) {
//       int myIndex = relationships.indexWhere((v) => v.id == p1);
//       if (myIndex == -1) return 0;
//       return relationships[myIndex].relPairs
//           .where((v) => v.iAmYour == RelationshipType.partner)
//           .length;
//     }

//     void addRelationship(String p1, String p2, RelationshipType relType) {
//       int index = relationships.indexWhere((n) => n.id == p1);
//       if (index == -1) {
//         relationships.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
//         relationshipsPN.addRelationship(p1, p2, relType);
//       } else {
//         relationships[index] = relationships[index].addRelationship(p2, relType);
//         relationshipsPN.addRelationship(p1, p2, relType);
//       }
//     }

//     void addSymmetricRelationship(
//       String p1,
//       String p2,
//       RelationshipType relType,
//     ) {
//       addRelationship(p1, p2, relType);
//       addRelationship(p2, p1, relType);
//     }

//     Person? createPartnerFromPendingRole(
//       Person originalPerson,
//       Set<String> myPreferredAncestry,
//     ){
//       // Find a suitable pending role
//       final roleMetaPN = ref.read(roleMetaProvider.notifier);
//       Set<AgeType> partnerAges = allowedToPartner[originalPerson.age]!;

//       var availableRoles =
//           pendingRoles
//               .where(
//                 (pr) =>
//                     (pr.howMany > 0) &&
//                     (roleMetaPN
//                         .getAllAgesOfRole(pr.role)
//                         .intersection(partnerAges)
//                         .isNotEmpty),
//               )
//               .toList();
//       if (availableRoles.isEmpty) return null;

//       PendingRoles selectedRole = randomElement(availableRoles);
//       var intersectAges =
//           roleMetaPN
//               .getAllAgesOfRole(selectedRole.role)
//               .intersection(partnerAges)
//               .toList();
//       var ageOfPartner = randomElement(intersectAges);
//       // Create person with matching characteristics
//       var partnerPronouns = randomElement(
//         originalPerson.myPreferredPartnersPronouns.toList(),
//       );
//       String newID = _uuid.v4();
//       Person partner = createRandomPerson(ref,
//         newID: newID,
//         newAncestry: myPreferredAncestry.elementAt(
//           random.nextInt(myPreferredAncestry.length),
//         ),
//         newPoly: originalPerson.poly,
//         newAge: ageOfPartner,
//         newPronouns: partnerPronouns,
//         newOrientation: originalPerson.orientation,
//       );

//       if (hirelingRoles.contains(selectedRole.role)) {
//         final locRole = LocationRole(
//           locationID: hirelingID,
//           myID: newID,
//           myRole: selectedRole.role,
//           specialty: "",
//         );

//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (marketRoles.contains(selectedRole.role)) {
//         final locRole = LocationRole(
//           locationID: marketID,
//           myID: newID,
//           myRole: selectedRole.role,
//           specialty: "",
//         );
//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }
//       if (infoRoles.contains(selectedRole.role)) {
//         final locRole = LocationRole(
//           locationID: informationalID,
//           myID: newID,
//           myRole: selectedRole.role,
//           specialty: "",
//         );
//         locRolePN.add(locRole);
//         // locRoleAddQueue.add(locRole);
//       }

//       final locRole = LocationRole(
//         locationID: infoID,
//         myID: newID,
//         myRole: selectedRole.role,
//         specialty: "",
//       );
//       locRolePN.add(locRole);
//       // locRoleAddQueue.add(locRole);

//       peoplePN.add(partner);
//       locRolePN.add(locRole);

//       updateBuffer.add(
//         () async => await peopleSearchProvider.addPersonToSearch(partner),
//       );

//       // Remove role from pending
//       roleRemovalCounts[selectedRole.role] =
//           (roleRemovalCounts[selectedRole.role] ?? 0) + 1;
//       int indy = pendingRoles.indexWhere((p) => p.role == selectedRole.role);
//       PendingRoles newPR = PendingRoles(
//         howMany: pendingRoles[indy].howMany - 1,
//         role: selectedRole.role,
//       );
//       pendingRolesPN.updateByKey(selectedRole.role.name, newPR);
//       // pendingRoles[indy] = newPR;

//       return partner;
//     }

//     for (Person p in newPeople) {
//       bool canMarry =
//           (allowedToPartner[p.age]!.isNotEmpty) &&
//           (countPartner(p.id) < p.maxSpouse);

//       if (canMarry) {
//         PartnerType myPartnerType = randomPartnerType(p.ancestry);
//         Set<String> myPreferredAncestry;

//         switch (myPartnerType) {
//           case PartnerType.sameAncestry:
//             myPreferredAncestry = {p.ancestry};
//             break;
//           case PartnerType.differentAncestry:
//             myPreferredAncestry = {
//               randomAncestry(
//                 restrictedAncestries: getOtherAncestries(ref,p.ancestry),
//               ),
//             };
//             break;
//           case PartnerType.noPartner:
//             continue;
//         }

//         int myIndex = relationships.indexWhere((n) => n.id == p.id);
//         Set<String> doNotMarry = {p.id};
//         if (myIndex != -1) {
//           doNotMarry.addAll(relationships[myIndex].doNotMarry);
//         }
//         // Look for existing suitable partner
//         List<Person> candidates =
//             newPeople
//                 .where(
//                   (f) =>
//                       (myPreferredAncestry.contains(f.ancestry)) &&
//                       (p.myPreferredPartnersPronouns.contains(f.pronouns)) &&
//                       (f.myPreferredPartnersPronouns.contains(p.pronouns)) &&
//                       (p.myPartnerAges.contains(f.age)) &&
//                       (p.poly == f.poly) &&
//                       (countPartner(f.id) < f.maxSpouse) &&
//                       (!doNotMarry.contains(f.id)),
//                 )
//                 .toList();

//         Person? partner;
//         if (candidates.isNotEmpty) {
//           partner = candidates[random.nextInt(candidates.length)];
//         } else {
//           // Create partner from pending role
//           partner = createPartnerFromPendingRole(p, myPreferredAncestry);
//         }
//         if (partner != null) {
//           if (partner.id != doNotCreateString) {
//             if (randomBreakUp(p.ancestry)) {
//               addSymmetricRelationship(partner.id, p.id, RelationshipType.ex);
//             } else {
//               addSymmetricRelationship(
//                 partner.id,
//                 p.id,
//                 RelationshipType.partner,
//               );
//             }
//           }
//         }
//       }
//     }
//     // updateBuffer.add(() async => );
//     // Execute all updates

//     // updateBuffer.add(() async {
//     //   for (final entry in roleRemovalCounts.entries) {
//     //     await pendingRolesPN.removeFromRole(entry.key, entry.value);
//     //   }
//     // });
//     // updateBuffer.add(() async {
//     //   await locRoleProvider.bulkAdd(items: locRoleAddQueue);
//     // });
//     await pendingRolesPN.commitChanges();
//     await relationshipsPN.commitChanges();
//     await peoplePN.commitChanges();
//     await locRolePN.commitChanges();

//     await makeChildren(newPeople, ref);


    
//     for (final update in updateBuffer) {
//       await update();
//     }
//   }
// }


extension TownOnFirePeople on TownOnFire {

  Future<void> createPeopleFS(
    int numPeople,
    WidgetRef ref,
    List<GovHelper> govRoles,
  ) async {
    List<Person> newPeople = [];

    final locRolePN = ref.read(
      locationRolesProvider.notifier,
    );
    final peoplePN = ref.read(peopleProvider.notifier);

    final relationshipPN = ref.read(relationshipsProvider.notifier);
    final pendingRolesPN = ref.read(pendingRolesProvider.notifier);


    final roleMetaPN = ref.read(roleMetaProvider.notifier);
    // final allRolesNotifer = ref.read(roleGenProvider2);
    // Trie peopleSearchProvider = ref.read(peopleSearch.notifier);

    var updateBuffer = List.empty(growable: true);

    // Informational roleList=Informational(myID: myID,locType: LocationType.info, name:"AllRoles");
    List<Role> initRoleList = [];
    Map<Role, int> roleCounts = {};
    Role newRole;
    for (int i = 0; i < numPeople; i++) {
      newRole = roleMetaPN.getRole();
      initRoleList.add(newRole);
      roleCounts[newRole] = (roleCounts[newRole] ?? 0) + 1;
    }
    
    List<Role> activeRoles = [];

    roleCounts.forEach((r, howMany) {
      int maxAllowed = max(1, (howMany * (propActivate[r] ?? 0)).toInt());
      int numActive = howMany.clamp(1, maxAllowed);

      int numPending = howMany - numActive;

      activeRoles.addAll(List.filled(numActive, r));

      pendingRolesPN.add(PendingRoles(howMany: numPending, role: r));
    });

    List<LocationRole> roleList = [];
    for (int i = 0; i < activeRoles.length; i++) {
      Role myRole = activeRoles[i];
      AgeType myAge = roleMetaPN.getAgeOfRole(myRole);

      String id = _uuid.v4();
      String myAncestry = randomAncestry();
      Person p = createRandomPerson(ref,
        newID: id,
        newAncestry: myAncestry,
        newAge: myAge,
      );
      newPeople.add(p);

      peoplePN.add(p);

      // updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(p));

      final locRole = LocationRole(
        locationID: infoID,
        myID: id,
        myRole: myRole,
        specialty: "",
      );
      roleList.add(locRole);
      locRolePN.add(locRole);
      
      relationshipPN.add(Node(id: id, relPairs: {}));
    }

    Informational newGov = Informational(
      myID: governtmentID,
      locType: LocationType.government,
      name: "Government",
    );
    final locationsPN = ref.watch(locationsProvider.notifier);
    locationsPN.add(newGov);
  

    List<String> govIDs = [];
    for (final gr in govRoles) {
      Role myRole =
          Role.values.firstWhereOrNull(
            (v) => v.name.split("Government").first == gr.position,
          ) ??
          Role.government;
      AgeType myAge = gr.age;
      switch (gr.createMethod) {
        case GovCreateMethod.createRoles:
          String id = _uuid.v4();
          String myAncestry = randomAncestry();
          Person p = createRandomPerson(ref,
            newID: id,
            newAncestry: myAncestry,
            newAge: myAge,
          );
          newPeople.add(p);
          peoplePN.add(p);
          
          // updateBuffer.add(
          //   () async => await peopleSearchProvider.addPersonToSearch(p),
          // );

          final locRole = LocationRole(
            locationID: governtmentID,
            myID: id,
            myRole: myRole,
            specialty: "",
          );
          roleList.add(locRole);
          locRolePN.add(locRole);
          
          LocationRole locRoleID;

          locRoleID = LocationRole(
            locationID: infoID,
            myID: id,
            myRole: myRole,
            specialty: "",
          );

          roleList.add(locRoleID);
          locRolePN.add(locRoleID);
    
          relationshipPN.add(Node(id: id, relPairs: {}));
          
          govIDs.add(id);
          break;
        case GovCreateMethod.createAndChoose:
          String id =
              randomElement(
                newPeople.where((p) => !govIDs.contains(p.id)).toList(),
              ).id;

          final locRole = LocationRole(
            locationID: governtmentID,
            myID: id,
            myRole: myRole,
            specialty: "",
          );
          roleList.add(locRole);
          locRolePN.add(locRole);
          govIDs.add(id);
          break;
        case GovCreateMethod.useExistingRoles:
          final validRoles =
              roleList
                  .where(
                    (lr) =>
                        gr.validRoles.contains(lr.myRole) &&
                        !govIDs.contains(lr.myID),
                  )
                  .toList();

          if (validRoles.isNotEmpty) {
            final lr = randomElement(validRoles);
            govIDs.add(lr.myID);
            final locRole = LocationRole(
              locationID: governtmentID,
              myID: lr.myID,
              myRole: myRole,
              specialty: "",
            );
            roleList.add(locRole);
            locRolePN.add(locRole);
            
          } else {
            String id = _uuid.v4();
            String myAncestry = randomAncestry();
            Person p = createRandomPerson(ref,
              newID: id,
              newAncestry: myAncestry,
              newAge: myAge,
            );
            newPeople.add(p);
            peoplePN.add(p);

            // updateBuffer.add(
            //   () async => await peopleSearchProvider.addPersonToSearch(p),
            // );

            myRole = randomElement(gr.validRoles);
            final locRole = LocationRole(
              locationID: governtmentID,
              myID: id,
              myRole:
                  Role.values.firstWhereOrNull(
                    (v) => v.name.split("Government").first == gr.position,
                  ) ??
                  Role.government,
              specialty: "",
            );
            roleList.add(locRole);
            locRolePN.add(locRole);
            
            LocationRole locRoleID;

            locRoleID = LocationRole(
              locationID: infoID,
              myID: id,
              myRole: myRole,
              specialty: "",
            );

            roleList.add(locRoleID);
            locRolePN.add(locRoleID);
            
            relationshipPN.add(Node(id: id, relPairs: {}));
            
            govIDs.add(id);
            break;
          }
          break;
      }
    }

    for (final update in updateBuffer) {
      await update();
    }
    await peoplePN.commitChanges();
    await relationshipPN.commitChanges();
    await locRolePN.commitChanges();
    await pendingRolesPN.commitChanges();
    await locationsPN.commitChanges();
    
  }

   Future<void> createSocialNetworkFS(WidgetRef ref) async {
    // List<Person> people = List.from(ref.read(peopleListProvider));
    final people = ref.watch(peopleProvider);
    final peoplePN = ref.read(peopleProvider.notifier);
    // PeopleList peoplePN = ref.read(peopleListProvider.notifier);
    
    final relationships = ref.watch(relationshipsProvider);
    final relationshipsPN = ref.read(relationshipsProvider.notifier);
    // List<Node> relCache = List.from(ref.read(relationshipsProvider));
    
    final locRolePN = ref.read(locationRolesProvider.notifier);

    final locRoles = ref.watch(locationRolesProvider);

    // Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);
    // List<Person> newPeople=[];

    List<Function> updateBuffer = [];
    int countPartner(String p1) {
      int myIndex = relationships.indexWhere((v) => v.id == p1);
      if (myIndex == -1) {
        return 0;
      }
      return relationships[myIndex].relPairs
          .where((v) => v.iAmYour == RelationshipType.partner)
          .length;
    }

    void addRelationship(String p1, String p2, RelationshipType relType) {
      int index = relationships.indexWhere((n) => n.id == p1);
      if (index == -1) {
        relationshipsPN.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
      } else {
        relationshipsPN.addRelationship(p1, p2, relType);
      }
    }

    void addSymmetricRelationship(
      String p1,
      String p2,
      RelationshipType relType,
    ) {
      addRelationship(p1, p2, relType);
      addRelationship(p2, p1, relType);
    }

    for (Person p in people) {
      bool canMarry =
          (allowedToPartner[p.age]!.isNotEmpty) &&
          (countPartner(p.id) < p.maxSpouse);
      bool doItAgain = true;
      int maxIter = 1;
      if (p.poly == PolyType.poly) {
        maxIter = maxIter + random.nextInt(p.maxSpouse) + 1;
      }
      if (canMarry) {
        for (int i = 0; i < maxIter; i++) {
          while (doItAgain) {
            if (countPartner(p.id) < p.maxSpouse) {
              PartnerType myPartnerType = randomPartnerType(ref, p.ancestry);
              Set<String> myPreferredAncestry;
              switch (myPartnerType) {
                case (PartnerType.sameAncestry):
                  myPreferredAncestry = {p.ancestry};
                  break;
                case (PartnerType.differentAncestry):
                  myPreferredAncestry = {
                    randomAncestry(
                      restrictedAncestries: getOtherAncestries(ref,p.ancestry),
                    ),
                  };
                  break;
                case (PartnerType.noPartner):
                  myPreferredAncestry = {};
                  doItAgain = false;
              }
              if (myPreferredAncestry.isNotEmpty) {
                int myIndex = relationships.indexWhere((n) => n.id == p.id);
                Set<String> doNotMarry = {};
                if (myIndex != -1) {
                  doNotMarry = relationships[myIndex].doNotMarry;
                }
                int numPart = countPartner(p.id);

                List<Person> preCandidates =
                    people
                        .where(
                          (f) =>
                              ((myPreferredAncestry.contains(f.ancestry)) &&
                                  (p.myPreferredPartnersPronouns.contains(
                                    f.pronouns,
                                  )) &&
                                  (f.myPreferredPartnersPronouns.contains(
                                    p.pronouns,
                                  )) &&
                                  (p.myPartnerAges.contains(f.age)) &&
                                  (p.poly == f.poly) &&
                                  (!doNotMarry.contains(f.id))),
                        )
                        .toList();
                List<Person> candidates = [];
                for (final c in preCandidates) {
                  int cPartner = countPartner(c.id);
                  if (numPart + cPartner < min(p.maxSpouse, c.maxSpouse)) {
                    candidates.add(c);
                  }
                }
                Person luckyOne;
                if (candidates.isNotEmpty) {
                  luckyOne = candidates[random.nextInt(candidates.length)];
                } else {
                  String newID = _uuid.v4();

                  luckyOne = createRandomPerson(ref,
                    newID: newID,
                    newAncestry: myPreferredAncestry.elementAt(
                      random.nextInt(myPreferredAncestry.length),
                    ),
                    newPoly: p.poly,
                    newAge: p.age,
                    newPronouns: p.myPreferredPartnersPronouns.elementAt(
                      random.nextInt(p.myPreferredPartnersPronouns.length),
                    ),
                    newOrientation: p.orientation,
                  );
                  // people.add(luckyOne);
                  peoplePN.add(luckyOne);
                  // updateBuffer.add(() async => peoplePN.add(addMe: luckyOne));
                  // updateBuffer.add(
                  //   () async =>
                  //       peopleSearchProvider.addPersonToSearch(luckyOne),
                  // );

                  relationshipsPN.add(Node(id: luckyOne.id, relPairs: {}));
          
                }

                Node nobody = Node(id: "", relPairs: {});
                if (randomBreakUp(ref, p.ancestry)) {
                  Set<String> pPartners =
                      relationships
                          .firstWhere((n) => n.id == p.id, orElse: () => nobody)
                          .allPartners;
                  Set<String> luckyOnePartners =
                      relationships
                          .firstWhere(
                            (n) => n.id == luckyOne.id,
                            orElse: () => nobody,
                          )
                          .allPartners;
                  addSymmetricRelationship(
                    luckyOne.id,
                    p.id,
                    RelationshipType.ex,
                  );
                  for (String q in pPartners) {
                    addSymmetricRelationship(
                      luckyOne.id,
                      q,
                      RelationshipType.ex,
                    );
                  }

                  for (String q in luckyOnePartners) {
                    addSymmetricRelationship(p.id, q, RelationshipType.ex);
                  }
                  doItAgain = true;
                } else {
                  int index = relationships.indexWhere((n) => n.id == p.id);
                  Set<String> luckyOneToMarrySet = {};
                  if (index != -1) {
                    luckyOneToMarrySet = relationships[index].allPartners;
                  }

                  luckyOneToMarrySet.add(p.id);

                  int index2 = relationships.indexWhere((n) => n.id == luckyOne.id);
                  Set<String> pToMarrySet = {};
                  if (index2 != -1) {
                    pToMarrySet =
                        relationships
                            .firstWhere((n) => n.id == luckyOne.id)
                            .allPartners;
                  }

                  pToMarrySet.add(luckyOne.id);

                  for (String q in luckyOneToMarrySet) {
                    addSymmetricRelationship(
                      q,
                      luckyOne.id,
                      RelationshipType.partner,
                    );

                    if ((locRoles
                        .where(
                          (lr) =>
                              lr.locationID == governtmentID &&
                              lr.myID == luckyOne.id &&
                              {
                                Role.liegeGovernment,
                                Role.nobleGovernment,
                                Role.courtierGovernment,
                              }.contains(lr.myRole),
                        )
                        .isNotEmpty)) {
                      LocationRole locRole = LocationRole(
                        locationID: governtmentID,
                        myID: q,
                        myRole: Role.minorNoble,
                        specialty: "Minor Noble (via partner)",
                      );
                      locRolePN.add(locRole);
                      
                    }
                  }
                  for (String q in pToMarrySet) {
                    addSymmetricRelationship(q, p.id, RelationshipType.partner);

                    if ((locRoles
                        .where(
                          (lr) =>
                              lr.locationID == governtmentID &&
                              lr.myID == p.id &&
                              {
                                Role.liegeGovernment,
                                Role.nobleGovernment,
                                Role.courtierGovernment,
                              }.contains(lr.myRole),
                        )
                        .isNotEmpty)) {
                      LocationRole locRole = LocationRole(
                        locationID: governtmentID,
                        myID: luckyOne.id,
                        myRole: Role.minorNoble,
                        specialty: "Minor Noble (via partner)",
                      );
                      locRolePN.add(locRole);
                    }
                  }
                  doItAgain = false;
                }
              }
            } else {
              doItAgain = false;
            }
          }
        }
      }
    }

    await peoplePN.commitChanges();
    await relationshipsPN.commitChanges();
    await locRolePN.commitChanges();
    

    for (final b in updateBuffer) {
      await b();
    }
  }

Future<void> makeChildren(List<Person> whichPeople, WidgetRef ref) async {
    // List<Person> people = List. from(ref.read(peopleListProvider));

    final peoplePN = ref.read(peopleProvider.notifier);
    final relationshipPN = ref.read(relationshipsProvider.notifier);

    final relationships = ref.watch(relationshipsProvider);

    final pendingRolePN = ref.read(pendingRolesProvider.notifier);
    final pendingRoles = ref.watch(pendingRolesProvider);

    final allPeople = ref.watch(peopleProvider);
    
    final locRolePN = ref.read(locationRolesProvider.notifier);
    final locRoleList = ref.watch(locationRolesProvider);

    List<RoleGeneration> allRoles = ref.read(roleMetaProvider);


    List<Role> hirelingRoles =
        allRoles.where((r) => r.hireling).map((r) => r.thisRole).toList();
    List<Role> marketRoles =
        allRoles.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
    List<Role> infoRoles =
        allRoles.where((r) => r.informational).map((r) => r.thisRole).toList();

    List<Person> newPeople = [];
    List<Function> updateBuffer = [];

    // Trie peopleSearchProvider = ref.watch(peopleSearch.notifier);

    Map<Role, int> roleRemovalCounts = {};

    Role? randomRoleFromAges(Set ages) {
      Set<Role> firstPass =
          allRoles
              .where((ar) => ar.validAges.toSet().intersection(ages).isNotEmpty)
              .map((ar) => ar.thisRole)
              .toSet();
      Set<Role> pendingPositive =
          pendingRoles.where((pr) => pr.howMany > 0).map((pr) => pr.role).toSet();

      List<Role> validRoles = firstPass.intersection(pendingPositive).toList();
      if (validRoles.isNotEmpty) {
        return randomElement(validRoles);
      }
      return null;
    }

    void updateLocRoleQueue(String id, Role myRole) {
      if (hirelingRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: hirelingID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (marketRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: marketID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (infoRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: informationalID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }

      final locRole = LocationRole(
        locationID: infoID,
        myID: id,
        myRole: myRole,
        specialty: "",
      );

      // updateBuffer.add(() async => await locRoleProvider.add(addMe: locRole));
      // locRoleAddQueue.add(locRole);
      locRolePN.add(locRole);
    }

    void addRelationship(String p1, String p2, RelationshipType relType) {
      int index = relationships.indexWhere((n) => n.id == p1);
      if (index == -1) {
        relationshipPN.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
      } else {        
          relationshipPN.addRelationship(p1, p2, relType);
      }
    }

    List<Map<String, dynamic>> identifyChildren(Person p1) {
      List<Map<String, dynamic>> output = [];
      List<AgeType> childBearingAges =
          AgeType.values.where((v) => v.index >= AgeType.adult.index).toList();

      if (!childBearingAges.contains(p1.age)) return [];
      final ancestries = ref.read(ancestriesProvider);
      Ancestry a = ancestries.firstWhere((an) => an.name == p1.ancestry);
      int index = relationships.indexWhere((n) => n.id == p1.id);
      if (index == -1) {
        relationshipPN.add(Node(id: p1.id, relPairs: {}));
      }
      Node myNode = index != -1 
  ? relationships[index] 
  : Node(id: p1.id, relPairs: {});
  
      Set<RelationshipType> parentTypes = {
        RelationshipType.partner,
        RelationshipType.ex,
      };

      List<String> possibleParents =
          myNode.relPairs
              .where((e) => parentTypes.contains(e.iAmYour))
              .map((rp) => rp.you)
              .toList();

      int preExistingChildren =
          myNode.relPairs
              .where((e) => e.iAmYour == RelationshipType.parent)
              .length;

      if (random.nextDouble() < a.childrenProb) {
        bool funToMakeFunToEat = preExistingChildren < a.maxChildren;
        while (funToMakeFunToEat) {
          double r = random.nextDouble();
          AdoptionType myType = AdoptionType.noAdoption;
          if (r < a.adoptionWithinProb) {
            myType = AdoptionType.sameAncestry;
          }
          r -= a.adoptionWithinProb;
          if (r < a.adoptionOutsideProb) {
            myType = AdoptionType.differentAncestry;
          }
          Person parent = p1;

          if (possibleParents.isNotEmpty) {
            String parentID =
                possibleParents[random.nextInt(possibleParents.length)];
            parent = [
              ...allPeople,
              ...newPeople,
            ].firstWhere((p) => p.id == parentID);
          }
          output.add({"parent": parent, "childType": myType});
          funToMakeFunToEat =
              (random.nextDouble() < a.childrenProb) &&
              (output.length + preExistingChildren < a.maxChildren);
        }
      }
      return output;
    }

    bool hasNoParent(String c) {
      int index = relationships.indexWhere((n) => n.id == c);
      if (index == -1) {
        return true;
      } else {
        return relationships[index].relPairs
            .where((rp) => rp.iAmYour == RelationshipType.parent)
            .isEmpty;
      }
    }

    Person findAdoption(Person parent, Set<String> adoptionAncestries) {
      List<AgeType> adoptableAges =
          AgeType.values.where((v) => v.index + 2 <= parent.age.index).toList();
      List<Person> candidates =
          whichPeople
              .where(
                (p) =>
                    adoptableAges.contains(p.age) &&
                    adoptionAncestries.contains(p.ancestry) &&
                    hasNoParent(p.id),
              )
              .toList();
      if (candidates.isEmpty) {
        String newAncestry = randomElement(adoptionAncestries.toList());
        AgeType newAge = randomElement(adoptableAges);
        String id = _uuid.v4();
        Role? childRole = randomRoleFromAges(adoptableAges.toSet());
        Person c;
        if (childRole == null) {
          c = createRandomPerson(ref,
            newAge: newAge,
            newAncestry: newAncestry,
            newID: id,
          );
        } else {
          Set<AgeType> roleAges =
              allRoles
                  .firstWhere((ar) => ar.thisRole == childRole)
                  .validAges
                  .toSet();
          newAge = randomElement(
            (adoptableAges.toSet().intersection(roleAges).toList()),
          );
          c = createRandomPerson(ref,
            newAge: newAge,
            newAncestry: newAncestry,
            newID: id,
          );
          // updateBuffer.add(
          //   () async => await peopleSearchProvider.addPersonToSearch(c),
          // );

          int myInd = pendingRoles.indexWhere((pr) => pr.role == childRole);
          PendingRoles newPR = PendingRoles(
            howMany: pendingRoles[myInd].howMany - 1,
            role: pendingRoles[myInd].role,
          );
          pendingRoles[myInd] = newPR;
          roleRemovalCounts[childRole] =
              (roleRemovalCounts[childRole] ?? 0) + 1;

          updateLocRoleQueue(id, childRole);
          final n = Node(id: id, relPairs: {});
          relationshipPN.add(n);
        }

        newPeople.add(c);
        peoplePN.add(c);
        // updateBuffer.add(() async => peoplePN.add(addMe: c));
        // updateBuffer.add(() async => peopleSearchProvider.addPersonToSearch(c));
        return c;
      } else {
        return randomElement(candidates);
      }
    }

    for (final p in whichPeople) {
      List<Map<String, dynamic>> childrenMap = identifyChildren(p);

      for (Map<String, dynamic> m in childrenMap) {
        Person parent = m["parent"];
        AdoptionType childType = m["childType"];
        Person c;
        switch (childType) {
          case AdoptionType.differentAncestry:
            c = findAdoption(p, {
              randomAncestry(
                restrictedAncestries: getOtherAncestries(ref,p.ancestry),
              ),
            });
            break;
          case AdoptionType.sameAncestry:
            c = findAdoption(p, {p.ancestry});
            break;
          case AdoptionType.noAdoption:
            List<AgeType> childAges =
                AgeType.values
                    .where(
                      (v) => v.index + 2 <= min(p.age.index, parent.age.index),
                    )
                    .toList();

            final newAncestry = randomElement([p.ancestry, parent.ancestry]);

            AgeType newAge = randomElement(childAges);
            String id = _uuid.v4();
            Role? childRole = randomRoleFromAges(childAges.toSet());
            if (childRole == null) {
              c = createRandomPerson(ref,
                newAge: newAge,
                newAncestry: newAncestry,
                newID: id,
                newSurname: p.surname,
              );
            } else {
              Set<AgeType> roleAges =
                  allRoles
                      .firstWhere((ar) => ar.thisRole == childRole)
                      .validAges
                      .toSet();
              newAge = randomElement(
                (childAges.toSet().intersection(roleAges).toList()),
              );
              c = createRandomPerson(ref,
                newAge: newAge,
                newAncestry: newAncestry,
                newID: id,
              );
              // updateBuffer.add(
              //   () async => await peopleSearchProvider.addPersonToSearch(c),
              // );

              int myInd = pendingRoles.indexWhere((pr) => pr.role == childRole);
              PendingRoles newPR = PendingRoles(
                howMany: pendingRoles[myInd].howMany - 1,
                role: pendingRoles[myInd].role,
              );
              pendingRoles[myInd] = newPR;
              roleRemovalCounts[childRole] =
                  (roleRemovalCounts[childRole] ?? 0) + 1;

              updateLocRoleQueue(id, childRole);
              final n = Node(id: id, relPairs: {});
              relationshipPN.add(n);
    
            }

            newPeople.add(c);
            peoplePN.add(c);
            
            // updateBuffer.add(
            //   () async => await peopleSearchProvider.addPersonToSearch(c),
            // );

            relationshipPN.add(Node(id: c.id, relPairs: {}));
        }
        addRelationship(p.id, c.id, RelationshipType.child);
        addRelationship(parent.id, c.id, RelationshipType.child);
        addRelationship(c.id, p.id, RelationshipType.parent);
        addRelationship(c.id, parent.id, RelationshipType.parent);

        if (locRoleList
            .where(
              (lr) =>
                  lr.locationID == governtmentID &&
                  lr.myID == p.id &&
                  {
                    Role.liegeGovernment,
                    Role.nobleGovernment,
                    Role.courtierGovernment,
                  }.contains(lr.myRole),
            )
            .isNotEmpty) {
          LocationRole locRole = LocationRole(
            locationID: governtmentID,
            myID: c.id,
            myRole: Role.minorNoble,
            specialty: "Minor Noble (via Parent)",
          );
          locRolePN.add(locRole);
        }
      }
    }

    for (final p in [...whichPeople, ...newPeople]) {
       relationshipPN.findAndMakeSiblings(p.id);
    }

    // updateBuffer.add(
    //   () async => await locRolePN.bulkAdd(items: locRoleAddQueue),
    // );

    // updateBuffer.add(() async {
    //   for (final entry in roleRemovalCounts.entries) {
    //     await pendingRolePN.removeFromRole(entry.key, entry.value);
    //   }
    // });

    await pendingRolePN.commitChanges();
    await peoplePN.commitChanges();
    await relationshipPN.commitChanges();
    await locRolePN.commitChanges();

    for (final b in updateBuffer) {
      await b();
    }
  }

  int numPartners(WidgetRef ref, {required PolyType myPoly, required myAncestry}) {
    final ancestries = ref.read(ancestriesProvider);
    switch (myPoly) {
      case PolyType.poly:
        int mpp =
            ancestries.singleWhere((a) => a.name == myAncestry).maxPolyPartner;
        return min(random.nextInt(mpp) + 2, mpp);
      case PolyType.notPoly:
        return 1;
    }
  }

  Person createRandomPerson(WidgetRef ref,
    {
    String? newFirstName,
    String? newSurname,
    String? newAncestry,
    String? newQuirk1,
    String? newQuirk2,
    String? newResonantArgument,
    AgeType? newAge,
    PronounType? newPronouns,
    OrientationType? newOrientation,
    String? newFaction,
    String? newID,
    List<String?>? newPartnerID,
    List<String?>? newChildrenID,
    List<String?>? newParentID,
    List<String>? newExID,
    String? newFrequents,
    PolyType? newPoly,
    int? newMaxSpouse,
    List<LocationRole>? newRoles,
    List<Relationship>? newRelationships,
  }) {
    newAncestry = newAncestry ?? randomAncestry();
    newQuirk1 = newQuirk1 ?? randomQuirks(ref,newQuirk2);
    newQuirk2 = newQuirk2 ?? randomQuirks(ref,newQuirk1);
    newPronouns = newPronouns ?? randomPronouns(ref,newAncestry);
    if (newPoly == PolyType.poly) {
      newMaxSpouse =
          newMaxSpouse ??
          numPartners(ref,myPoly: PolyType.poly, myAncestry: newAncestry);
    } else {
      newMaxSpouse = 1;
    }

    return Person(
      firstName: newFirstName ?? randomGivenName(ref,newAncestry, newPronouns),
      surname: newSurname ?? randomSurname(ref,newAncestry),
      ancestry: newAncestry,
      quirk1: newQuirk1,
      quirk2: newQuirk2,
      resonantArgument: newResonantArgument ?? randomRA(ref),
      age: newAge ?? randomAge(ref,newAncestry),
      pronouns: newPronouns,
      orientation: newOrientation ?? randomOrientation(ref,newAncestry),
      faction: newFaction ?? "",
      id: newID ?? _uuid.v4(),
      partnerID: newPartnerID ?? [],
      childrenID: newChildrenID ?? [],
      parents: newParentID ?? [],
      exIDs: newExID ?? [],
      poly: newPoly ?? randomPoly(ref,newAncestry),
      maxSpouse: newMaxSpouse,
      myRoles: newRoles ?? [],
      relationships: newRelationships ?? [],
    );
  }

  bool randomBreakUp(WidgetRef ref, String myAncestry) {
    final ancestries = ref.read(ancestriesProvider);
    final Ancestry a = ancestries.singleWhere((s) => s.name == myAncestry);
    return (a.breakup());
  }

  PartnerType randomPartnerType(WidgetRef ref, String myAncestry) {
    final ancestries = ref.read(ancestriesProvider);
    final Ancestry a = ancestries.singleWhere((s) => s.name == myAncestry);
    return a.randomPartnerType();
  }

  Set<String> getOtherAncestries(WidgetRef ref, myAncestry) {
    final ancestriesList = ref.read(ancestriesProvider);
    return (ancestriesList.where(
      (s) => s.name != myAncestry,
    )).map((a) => a.name).toSet();
  }

  PronounType randomPronouns(WidgetRef ref,String myAncestry) {
    final ancestriesList = ref.read(ancestriesProvider);
    final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
    return a.randomPronouns();
  }

  AgeType randomAge(WidgetRef ref,String myAncestry) {
    final ancestriesList = ref.read(ancestriesProvider);
    final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
    return a.randomAge();
  }

  OrientationType randomOrientation(WidgetRef ref, String myAncestry) {
    final ancestriesList = ref.read(ancestriesProvider);
    final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
    return a.randomOrientationType();
  }

  PolyType randomPoly(WidgetRef ref,String myAncestry) {
    final ancestriesList = ref.read(ancestriesProvider);
    final Ancestry a = ancestriesList.singleWhere((s) => s.name == myAncestry);
    return a.randomPolyType();
  }

  String randomRA(WidgetRef ref) {
    final resonantArgumentsList = ref.read(resonantArgumentsProvider);
    return resonantArgumentsList[random.nextInt(resonantArgumentsList.length)].argument;
  }

  String randomQuirks(WidgetRef ref, String? givenQuirk) {
    givenQuirk = givenQuirk ?? "";
    List<String> quirksList = ref.read(quirksProvider).map((q)=>q.quirk).toList();
    List<String> subList = quirksList.where((q) => (q != givenQuirk)).toList();

    return subList[random.nextInt(subList.length)];
  }

  String randomGivenName(WidgetRef ref, String myAncestry, PronounType pronouns) {
    List<GivenName> givenNamesList = ref.read(givenNamesProvider);
    List<GivenName> subList =
        givenNamesList
            .where(
              (n) =>
                  (n.ancestry.contains(myAncestry) &&
                      (n.pronouns.contains(pronouns) || n.pronouns.contains(PronounType.any))),
            )
            .toList();
    
    if (subList.isEmpty) {
      // Fallback: try to find any name with the ancestry (ignore pronouns)
      subList = givenNamesList
          .where((n) => n.ancestry.contains(myAncestry))
          .toList();
      
      if (subList.isEmpty) {
        // Last resort: return a default name or throw a more descriptive error
        return "Unknown"; // or throw Exception("No names found for ancestry: $myAncestry");
      }
    }
    
    return subList[random.nextInt(subList.length)].name;
  }

  String randomSurname(WidgetRef ref,String myAncestry) {
    List<Surname> surnamesList = ref.read(surnamesProvider);
    List<Surname> subList =
        surnamesList.where((n) => (n.ancestry.contains(myAncestry))).toList();
    
    if (subList.isEmpty) {
      // No surnames found for this ancestry, return a default
      return "Unknown"; // or throw Exception("No surnames found for ancestry: $myAncestry");
    }
    
    return (subList[random.nextInt(subList.length)]).name;
  }

  Future<void> handleShowMore(Role myRole, WidgetRef ref) async {
    final roleMeta = ref.read(roleMetaProvider);
    final peoplePN = ref.read(peopleProvider.notifier);
    final locrolePN = ref.read(locationRolesProvider.notifier);
    final relationshipPN = ref.read(relationshipsProvider.notifier);
    // final peopleSearchProvider = ref.read(peopleSearch.notifier);

    final pendingRoles = ref.watch(pendingRolesProvider);
    final pendingRolesPN = ref.read(pendingRolesProvider.notifier);

    Map<Role, int> roleRemovalCounts = {};

    int countRemaining =
        pendingRoles.firstWhere((e) => e.role == myRole).howMany;

    int maxAllowed = max(
      1,
      (countRemaining * (propActivate[myRole] ?? 0)).toInt(),
    );

    int numActive = min(maxAllowed, countRemaining);

    List<Person> newCreations = [];
    List<Function> updateBuffer = [];
    List<LocationRole> locRoleAddQueue = [];

    
    final roleMetaPN = ref.read(roleMetaProvider.notifier);


    int x = min(10 * numActive, pendingRoles.fold(0, (a, pr) => a + pr.howMany));

    List<Role> hirelingRoles =
        roleMeta.where((r) => r.hireling).map((r) => r.thisRole).toList();
    List<Role> marketRoles =
        roleMeta.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
    List<Role> infoRoles =
        roleMeta.where((r) => r.informational).map((r) => r.thisRole).toList();

    for (int i = 0; i < numActive; i++) {
      AgeType myAge = roleMetaPN.getAgeOfRole(myRole);
      String id = _uuid.v4();
      String myAncestry = randomAncestry();
      Person p = createRandomPerson(ref,
        newID: id,
        newAncestry: myAncestry,
        newAge: myAge,
      );

      newCreations.add(p);

      // updateBuffer.add(() async => await peopleProvider.add(addMe: p));
      // peopleAddQueue.add(p);
      peoplePN.add(p);
      // updateBuffer.add(
      //   () async => await peopleSearchProvider.addPersonToSearch(p),
      // );

      if (hirelingRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: hirelingID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locrolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (marketRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: marketID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locrolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (infoRoles.contains(myRole)) {
        final locRole = LocationRole(
          locationID: informationalID,
          myID: id,
          myRole: myRole,
          specialty: "",
        );
        locrolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }

      final locRole = LocationRole(
        locationID: infoID,
        myID: id,
        myRole: myRole,
        specialty: "",
      );

      // updateBuffer.add(() async => await locRoleProvider.add(addMe: locRole));
      locRoleAddQueue.add(locRole);
      locrolePN.add(locRole);
      final n = Node(id: id, relPairs: {});
      relationshipPN.add(n);
    }

    int indy = pendingRoles.indexWhere((pr) => pr.role == myRole);
    PendingRoles newPR = PendingRoles(
      howMany: pendingRoles[indy].howMany - numActive,
      role: myRole,
    );
    pendingRoles[indy] = newPR;
    roleRemovalCounts[myRole] = numActive;

    for (int i = 0; i < x; i++) {
      final available = pendingRoles.where((pr) => pr.howMany > 0).toList();
      if (available.isEmpty) {
        break;
      }
      PendingRoles pr = randomElement(available);

      AgeType myAge = roleMetaPN.getAgeOfRole(pr.role);
      String id = _uuid.v4();
      String myAncestry = randomAncestry();

      Person p = createRandomPerson(ref,
        newID: id,
        newAncestry: myAncestry,
        newAge: myAge,
      );

      // print("Wha?");
      if (hirelingRoles.contains(pr.role)) {
        final locRole = LocationRole(
          locationID: hirelingID,
          myID: id,
          myRole: pr.role,
          specialty: "",
        );

        locRoleAddQueue.add(locRole);
      }
      if (marketRoles.contains(pr.role)) {
        final locRole = LocationRole(
          locationID: marketID,
          myID: id,
          myRole: pr.role,
          specialty: "",
        );

        locRoleAddQueue.add(locRole);
      }
      if (infoRoles.contains(pr.role)) {
        final locRole = LocationRole(
          locationID: informationalID,
          myID: id,
          myRole: pr.role,
          specialty: "",
        );

        locRoleAddQueue.add(locRole);
      }

      final locRole = LocationRole(
        locationID: infoID,
        myID: id,
        myRole: pr.role,
        specialty: "",
      );

      locRoleAddQueue.add(locRole);
      
      final n = Node(id: id, relPairs: {});
      relationshipPN.add(n);

      newCreations.add(p);

      peoplePN.add(p);

      // updateBuffer.add(
      //   () async => await peopleSearchProvider.addPersonToSearch(p),
      // );

      roleRemovalCounts[pr.role] = (roleRemovalCounts[pr.role] ?? 0) + 1;

      int indy = pendingRoles.indexWhere((p) => p.role == pr.role);
      PendingRoles newPR = PendingRoles(
        howMany: pendingRoles[indy].howMany - 1,
        role: pr.role,
      );

      pendingRolesPN.updateByKey(pr.role.name, newPR);
      
    }

    // updateBuffer.add(() async {
    //   await locrolePN.bulkAdd(items: locRoleAddQueue);
    // });
    // updateBuffer.add(() async {
    //   await peoplePN.bulkAdd(people: peopleAddQueue);
    // });

    await locrolePN.commitChanges();
    await peoplePN.commitChanges();
    await pendingRolesPN.commitChanges();
    await relationshipPN.commitChanges();

    for (final update in updateBuffer) {
      await update();
    }
    await createLazySocialNetwork(ref: ref, newPeople: newCreations);

    
  }

  Future<void> createLazySocialNetwork({
    required WidgetRef ref,
    required List<Person> newPeople,
  }) async {

    final relationshipsPN = ref.read(relationshipsProvider.notifier);
    final relationships = ref.watch(relationshipsProvider);

    // final peopleSearchProvider = ref.read(peopleSearch.notifier);

    final pendingRoles = ref.watch(pendingRolesProvider);
    final pendingRolesPN = ref.read(pendingRolesProvider.notifier);

    final locRolePN = ref.read(locationRolesProvider.notifier);
    
    final peoplePN = ref.read(peopleProvider.notifier);
    // final people = ref.watch(peopleProvider);

    final List<Function> updateBuffer = [];
    
    Map<Role, int> roleRemovalCounts = {};

    final roleMeta = ref.read(roleMetaProvider);

    List<Role> hirelingRoles =
        roleMeta.where((r) => r.hireling).map((r) => r.thisRole).toList();
    List<Role> marketRoles =
        roleMeta.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
    List<Role> infoRoles =
        roleMeta.where((r) => r.informational).map((r) => r.thisRole).toList();

    // final locRoleProvider = ref.read(locationRoleListProvider.notifier);

    int countPartner(String p1) {
      int myIndex = relationships.indexWhere((v) => v.id == p1);
      if (myIndex == -1) return 0;
      return relationships[myIndex].relPairs
          .where((v) => v.iAmYour == RelationshipType.partner)
          .length;
    }

    void addRelationship(String p1, String p2, RelationshipType relType) {
      int index = relationships.indexWhere((n) => n.id == p1);
      if (index == -1) {
        relationships.add(Node(id: p1, relPairs: {Edge(you: p2, iAmYour: relType)}));
        relationshipsPN.addRelationship(p1, p2, relType);
      } else {
        relationships[index] = relationships[index].addRelationship(p2, relType);
        relationshipsPN.addRelationship(p1, p2, relType);
      }
    }

    void addSymmetricRelationship(
      String p1,
      String p2,
      RelationshipType relType,
    ) {
      addRelationship(p1, p2, relType);
      addRelationship(p2, p1, relType);
    }

    Person? createPartnerFromPendingRole(
      Person originalPerson,
      Set<String> myPreferredAncestry,
    ){
      // Find a suitable pending role
      final roleMetaPN = ref.read(roleMetaProvider.notifier);
      Set<AgeType> partnerAges = allowedToPartner[originalPerson.age]!;

      var availableRoles =
          pendingRoles
              .where(
                (pr) =>
                    (pr.howMany > 0) &&
                    (roleMetaPN
                        .getAllAgesOfRole(pr.role)
                        .intersection(partnerAges)
                        .isNotEmpty),
              )
              .toList();
      if (availableRoles.isEmpty) return null;

      PendingRoles selectedRole = randomElement(availableRoles);
      var intersectAges =
          roleMetaPN
              .getAllAgesOfRole(selectedRole.role)
              .intersection(partnerAges)
              .toList();
      var ageOfPartner = randomElement(intersectAges);
      // Create person with matching characteristics
      var partnerPronouns = randomElement(
        originalPerson.myPreferredPartnersPronouns.toList(),
      );
      String newID = _uuid.v4();
      Person partner = createRandomPerson(ref,
        newID: newID,
        newAncestry: myPreferredAncestry.elementAt(
          random.nextInt(myPreferredAncestry.length),
        ),
        newPoly: originalPerson.poly,
        newAge: ageOfPartner,
        newPronouns: partnerPronouns,
        newOrientation: originalPerson.orientation,
      );

      if (hirelingRoles.contains(selectedRole.role)) {
        final locRole = LocationRole(
          locationID: hirelingID,
          myID: newID,
          myRole: selectedRole.role,
          specialty: "",
        );

        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (marketRoles.contains(selectedRole.role)) {
        final locRole = LocationRole(
          locationID: marketID,
          myID: newID,
          myRole: selectedRole.role,
          specialty: "",
        );
        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }
      if (infoRoles.contains(selectedRole.role)) {
        final locRole = LocationRole(
          locationID: informationalID,
          myID: newID,
          myRole: selectedRole.role,
          specialty: "",
        );
        locRolePN.add(locRole);
        // locRoleAddQueue.add(locRole);
      }

      final locRole = LocationRole(
        locationID: infoID,
        myID: newID,
        myRole: selectedRole.role,
        specialty: "",
      );
      locRolePN.add(locRole);
      // locRoleAddQueue.add(locRole);

      peoplePN.add(partner);
      locRolePN.add(locRole);

      // updateBuffer.add(
      //   () async => await peopleSearchProvider.addPersonToSearch(partner),
      // );

      // Remove role from pending
      roleRemovalCounts[selectedRole.role] =
          (roleRemovalCounts[selectedRole.role] ?? 0) + 1;
      int indy = pendingRoles.indexWhere((p) => p.role == selectedRole.role);
      PendingRoles newPR = PendingRoles(
        howMany: pendingRoles[indy].howMany - 1,
        role: selectedRole.role,
      );
      pendingRolesPN.updateByKey(selectedRole.role.name, newPR);
      // pendingRoles[indy] = newPR;

      return partner;
    }

    for (Person p in newPeople) {
      bool canMarry =
          (allowedToPartner[p.age]!.isNotEmpty) &&
          (countPartner(p.id) < p.maxSpouse);

      if (canMarry) {
        PartnerType myPartnerType = randomPartnerType(ref,p.ancestry);
        Set<String> myPreferredAncestry;

        switch (myPartnerType) {
          case PartnerType.sameAncestry:
            myPreferredAncestry = {p.ancestry};
            break;
          case PartnerType.differentAncestry:
            myPreferredAncestry = {
              randomAncestry(
                restrictedAncestries: getOtherAncestries(ref,p.ancestry),
              ),
            };
            break;
          case PartnerType.noPartner:
            continue;
        }

        int myIndex = relationships.indexWhere((n) => n.id == p.id);
        Set<String> doNotMarry = {p.id};
        if (myIndex != -1) {
          doNotMarry.addAll(relationships[myIndex].doNotMarry);
        }
        // Look for existing suitable partner
        List<Person> candidates =
            newPeople
                .where(
                  (f) =>
                      (myPreferredAncestry.contains(f.ancestry)) &&
                      (p.myPreferredPartnersPronouns.contains(f.pronouns)) &&
                      (f.myPreferredPartnersPronouns.contains(p.pronouns)) &&
                      (p.myPartnerAges.contains(f.age)) &&
                      (p.poly == f.poly) &&
                      (countPartner(f.id) < f.maxSpouse) &&
                      (!doNotMarry.contains(f.id)),
                )
                .toList();

        Person? partner;
        if (candidates.isNotEmpty) {
          partner = candidates[random.nextInt(candidates.length)];
        } else {
          // Create partner from pending role
          partner = createPartnerFromPendingRole(p, myPreferredAncestry);
        }
        if (partner != null) {
          if (partner.id != doNotCreateString) {
            if (randomBreakUp(ref,p.ancestry)) {
              addSymmetricRelationship(partner.id, p.id, RelationshipType.ex);
            } else {
              addSymmetricRelationship(
                partner.id,
                p.id,
                RelationshipType.partner,
              );
            }
          }
        }
      }
    }
    // updateBuffer.add(() async => );
    // Execute all updates

    // updateBuffer.add(() async {
    //   for (final entry in roleRemovalCounts.entries) {
    //     await pendingRolesPN.removeFromRole(entry.key, entry.value);
    //   }
    // });
    // updateBuffer.add(() async {
    //   await locRoleProvider.bulkAdd(items: locRoleAddQueue);
    // });
    await pendingRolesPN.commitChanges();
    await relationshipsPN.commitChanges();
    await peoplePN.commitChanges();
    await locRolePN.commitChanges();

    await makeChildren(newPeople, ref);


    
    for (final update in updateBuffer) {
      await update();
    }
  }
}