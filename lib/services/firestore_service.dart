// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/barrel_of_providers.dart';
import '../models/todo.dart';

enum ListType {
  people,
  location,
  locationRole,
  relationship,
  town,
  govPosition,
  govRolesBySize,
  pendingRoles,
  roleMeta,
  shopName,
  shopQuality,
  genericService,
  specialtyService,
  ancestry,
  givenName,
  surname,
  resonantArgument,
  quirk,
  givenNamePhonemes,
  randomEncounter,
  physicalTemplate,
  clothingTemplate,
  shopTemplate,
  locationTemplate,
  rumorTemplate,
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _townPathLists(
    String userUuid,
    Ref ref,
  ) => _firestore
      .collection("users")
      .doc(userUuid)
      .collection("user_towns")
      .doc(ref.read(townProvider).id)
      .collection("my_lists");

  DocumentReference<Map<String, dynamic>>? _docPath(
    ListType whereGet,
    Ref? ref,
  ) {
    switch (whereGet) {
      case ListType.people:
        return _peoplePath(ref!);
      case ListType.location:
        return _locationPath(ref!);
      case ListType.locationRole:
        return _locRolePath(ref!);
      case ListType.pendingRoles:
        return _pendingRolePath(ref!);
      case ListType.relationship: // Add this case
        return _relationshipPath(ref!);
      case ListType.roleMeta:
        return _roleMetaPath();
      case ListType.govPosition:
        return govPositionPath();
      case ListType.govRolesBySize:
        return govPositionRolesBySize();
      case ListType.shopName:
        return _shopNamePath();
      case ListType.shopQuality:
        return _shopQualityPath();
        case ListType.genericService:
        return _shopGenericServicePath();
        case ListType.specialtyService:
        return _shopSpecialtyServicePath();
        case ListType.ancestry:
        return _ancestryPath();
        case ListType.givenName:
        return _givenNamePath();
        case ListType.surname:
        return _surnamePath();
        case ListType.resonantArgument:
        return _resonantArgumentPath();
        case ListType.quirk:
        return _quirkPath();
        case ListType.town:
        
          
        return _townsListPath();
        case ListType.givenNamePhonemes:
        return _givenNamePhonemePath();
        case ListType.randomEncounter:
        return _randomEncounterPath();
        case ListType.physicalTemplate:
        return _physicalTemplatePath();
        case ListType.clothingTemplate:
        return _clothingTemplatePath();
        case ListType.shopTemplate:
        return _shopTemplatePath();
        case ListType.locationTemplate:
        return _locationTemplatePath();
        case ListType.rumorTemplate:
        return _rumorTemplatePath();
      // ignore: unreachable_switch_default
      default:
        return null;
    }
  }

   DocumentReference<Map<String, dynamic>> _townsListPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;
    return _firestore
      .collection("users")
      .doc(userUid)
      .collection("user_towns").doc("towns_list");
  }

  DocumentReference<Map<String, dynamic>> _peoplePath(Ref ref) {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;

    return _townPathLists(userUid, ref).doc("people_list");
  }

  DocumentReference<Map<String, dynamic>> _locRolePath(Ref ref) {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;
    return _townPathLists(userUid, ref).doc("locRole_list");
  }

  DocumentReference<Map<String, dynamic>> _locationPath(Ref ref) {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;
    return _townPathLists(userUid, ref).doc("location_list");
  }

  DocumentReference<Map<String, dynamic>> _pendingRolePath(Ref ref) {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;
    return _townPathLists(userUid, ref).doc("pendingRole_list");
  }

  DocumentReference<Map<String, dynamic>> _roleMetaPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('roleMetaList');
  }
  DocumentReference<Map<String, dynamic>> _quirkPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('quirkList');
  }

  DocumentReference<Map<String, dynamic>> _givenNamePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('givenNamesList');
  }

  DocumentReference<Map<String, dynamic>> _givenNamePhonemePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('givenNamesPhonemesList');
  }

  DocumentReference<Map<String, dynamic>> _resonantArgumentPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('resonantArgumentList');
  }

  DocumentReference<Map<String, dynamic>> _surnamePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('surnamesList');
  }

    DocumentReference<Map<String, dynamic>> _ancestryPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('defaultAncestries');
  }

  DocumentReference<Map<String, dynamic>> _randomEncounterPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('randomEncounters');
  }

  DocumentReference<Map<String, dynamic>> _physicalTemplatePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('physicalTemplates');
  }

  DocumentReference<Map<String, dynamic>> _clothingTemplatePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('clothingTemplates');
  }
  
  DocumentReference<Map<String, dynamic>> _shopTemplatePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('shopTemplates');
  }

  DocumentReference<Map<String, dynamic>> _locationTemplatePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('locationTemplates');
  }

  DocumentReference<Map<String, dynamic>> _rumorTemplatePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('rumorTemplates');
  }

  DocumentReference<Map<String, dynamic>> govPositionPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('gov_position');
  }

  DocumentReference<Map<String, dynamic>> _shopNamePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('default_shop_name');
  }

    DocumentReference<Map<String, dynamic>> _shopGenericServicePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('default_shop_generic_services');
  }

      DocumentReference<Map<String, dynamic>> _shopSpecialtyServicePath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('default_shop_specialty_services');
  }
  DocumentReference<Map<String, dynamic>> _shopQualityPath() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore
        .collection('default_settings')
        .doc('default_shop_qualities');
  }

  DocumentReference<Map<String, dynamic>> _relationshipPath(Ref ref) {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;
    return _townPathLists(userUid, ref).doc("relationship_list");
  }

  Future<void> updateTownGovernment(
    String townId,
    String governmentType,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;

    return _firestore
        .collection("users")
        .doc(userUid)
        .collection("user_towns")
        .doc(townId)
        .set({"governmentType": governmentType}, SetOptions(merge: true));
  }

  Future<String> getTownGovernment(String townId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    String userUid = user.uid;

    final docSnapshot =
        await _firestore
            .collection("users")
            .doc(userUid)
            .collection("user_towns")
            .doc(townId)
            .get();

    if (docSnapshot.exists &&
        docSnapshot.data()!.containsKey("governmentType")) {
      return docSnapshot.data()!["governmentType"] as String;
    } else {
      return "nobility"; // Return a default value if not found
    }
  }

  DocumentReference<Map<String, dynamic>> govPositionRolesBySize() {
    final user = _auth.currentUser;
    if (user == null) {
      throw ("Please log in");
    }
    return _firestore.collection('default_settings').doc('gov_rolesBySize');
  }

  Stream<String?> getDocString(ListType whereGet, Ref ref) {
    DocumentReference<Map<String, dynamic>>? docRef;
    docRef = _docPath(whereGet, ref);
    if (docRef != null) {
      return docRef.snapshots().map((snapshot) {
        return snapshot.data()?["json"] as String?;
      });
    } else {
      throw ArgumentError(
        "Invalid ListType: $whereGet. No document reference found.",
      );
    }
  }

  Future<void> putDocString(ListType wherePut, String updatedString, Ref ref) {
    DocumentReference<Map<String, dynamic>>? docRef;

    docRef = _docPath(wherePut, ref);

    if (docRef != null) {
      // Use set with merge:true instead of update
      // This will update the document if it exists or create it if it doesn't
      return docRef.set({"json": updatedString}, SetOptions(merge: true));
    } else {
      throw ArgumentError(
        "Invalid ListType: $wherePut. No document reference found.",
      );
    }
  }

  Future<void> deleteTown(String townID) async {
  final user = _auth.currentUser;
  if (user == null) {
    throw ("Please log in");
  }
  
  String userUid = user.uid;
  
  // Define the base path for the town
  final basePath = _firestore
    .collection("users")
    .doc(userUid)
    .collection("user_towns")
    .doc(townID);
  
  // Known subcollections to delete (you'll need to list these explicitly)
  final knownSubcollections = [
    "my_lists",
    // Add other subcollections your town might have
  ];
  
  // Delete each subcollection
  for (final collectionName in knownSubcollections) {
    final collectionRef = basePath.collection(collectionName);
    await _deleteCollection(collectionRef);
  }
  
  // Finally delete the town document itself
  await basePath.delete();
}

// Helper method to delete all documents in a collection
Future<void> _deleteCollection(CollectionReference collection) async {
  final batchSize = 100;
  var query = collection.limit(batchSize);
  
  while (true) {
    final querySnapshot = await query.get();
    
    // If no documents left, we're done
    if (querySnapshot.docs.isEmpty) {
      break;
    }
    
    // Create a batch operation
    WriteBatch batch = _firestore.batch();
    
    // Add delete operations to batch
    for (final doc in querySnapshot.docs) {
      // For known nested subcollections, delete them first
      final nestedSubcollections = [
        "nested_data", // Add nested subcollection names
        // Add more as needed
      ];
      
      for (final nestedCollection in nestedSubcollections) {
        await _deleteCollection(doc.reference.collection(nestedCollection));
      }
      
      // Add document to deletion batch
      batch.delete(doc.reference);
    }
    
    // Commit the batch
    await batch.commit();
    
    // Get a new query for the next batch
    if (querySnapshot.docs.length < batchSize) {
      break;
    }
    
    // Get the last document ID for pagination
    final lastDoc = querySnapshot.docs.last;
    query = collection.startAfterDocument(lastDoc).limit(batchSize);
  }
}
  CollectionReference _todosCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  // Stream<List<RoleGeneration>> getRoleGeneration() {
  //   // Print the collection path to ensure it's correct
  //   print(
  //     "Fetching data from: ${_firestore.collection('default_settings').doc('lists').collection('roles').path}",
  //   );

  //   return (_roleMetaPath()).snapshots().map((snapshot) {
  //     // Print out the number of documents fetched
  //     print("Fetched ${snapshot.docs.length} documents.");

  //     return snapshot.docs.map((doc) {
  //       // Print the document ID and data to verify the content
  //       // print("Document ID: ${doc.id}");
  //       // print("Document data: ${doc.data()}");

  //       return RoleGeneration.fromJson(doc.data());
  //     }).toList();
  //   });
  // }

  // Get todos stream
  Stream<List<Todo>> getTodos() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _todosCollection(
      user.uid,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new todo for current user
  Future<void> addTodo(String title) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to add todos');
    }

    _todosCollection(
      user.uid,
    ).add({'title': title, 'isCompleted': false, 'createdAt': Timestamp.now()});
  }

  // Toggle todo completion status
  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to update todos');
    }

    return _todosCollection(
      user.uid,
    ).doc(id).update({'isCompleted': !currentStatus});
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to delete todos');
    }

    return _todosCollection(user.uid).doc(id).delete();
  }
}
