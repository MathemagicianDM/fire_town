import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetown/enums_and_maps.dart';
import 'package:firetown/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../models/json_serializable_abstract_class.dart";
import 'buffered_provider.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:collection/collection.dart";
import 'dart:convert';
import "../globals.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter/foundation.dart';

final governmentTypeProvider = StateProvider<String>((ref) {
  return "nobility"; // Default government type
});

// Models for the government data
class GovernmentPosition implements JsonSerializable {
  final String positionKey;
  final Map<String, String> titles;
  final List<String> settlementSizes;
  final Map<String, double> ageProbabilities;

  bool  get isGuard => positionKey.startsWith("guard");

  AgeType? getRandomAge(){
    double r = random.nextDouble();
    for(final entry in ageProbabilities.entries){
      r = r-entry.value;
      if(r<=0){
        return AgeType.values.firstWhereOrNull((a)=>a.name==entry.key);
      }
    }
    return null; //Probabilities didn't add up to 1
  }

  GovernmentPosition({
    required this.positionKey,
    required this.titles,
    required this.settlementSizes,
    required this.ageProbabilities,
  });

  factory GovernmentPosition.fromJson(Map<String, dynamic> json) {
    return GovernmentPosition(
      positionKey: json['positionKey'] as String,
      titles: Map<String, String>.from(json['titles'] as Map),
      settlementSizes: List<String>.from(json['settlementSizes'] as List),
      ageProbabilities: Map<String, double>.from(json['ageProbabilities'] as Map),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'positionKey': positionKey,
      'titles': titles,
      'settlementSizes': settlementSizes,
      'ageProbabilities': ageProbabilities
    };
  }

  @override
  String compositeKey() => positionKey;
}

class RolesBySize implements JsonSerializable {
  final String sizeString;
  final Map<String, Map<String, String>> roles;
  final String universalRoles;
  CitySize? get mySize =>
      CitySize.values.firstWhereOrNull((e) => e.name == sizeString);

  RolesBySize({
    required this.sizeString,
    required this.roles,
    required this.universalRoles,
  });

  int getRandomNumRoles(){
    int min = int.parse(universalRoles.split("--").first);
    int max = int.parse(universalRoles.split("--").last);
    return random.nextInt(1+(max-min)) + min; // 1+ because nextInt(1) always returns 0;
  }

  String getTitle(String position,String govType){
    Map<String,String>? positionData = roles[position];
    if(positionData == null){return "Position not found";}

    String? title = positionData[govType];
    if(title == null){return "Title not found";}
    
    return title;
  }

  factory RolesBySize.fromJson(Map<String, dynamic> json) {
    return RolesBySize(
      sizeString: json['name'] as String,
      roles: Map<String, Map<String, String>>.from(
        (json['roles'] as Map).map(
          (key, value) =>
              MapEntry(key as String, Map<String, String>.from(value as Map)),
        ),
      ),
      universalRoles: json['universalRoles'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': sizeString,
      'roles': roles,
      'universalRoles': universalRoles,
    };
  }

  @override
  String compositeKey() => sizeString;
}

// Government data provider class
class GovernmentDataProvider {
  final FirestoreService _firestore;

  GovernmentDataProvider(this._firestore);

  // Get positions provider
  ServiceProviderListFireStore<GovernmentPosition> getPositionsProvider(Ref ref) {
    return ServiceProviderListFireStore<GovernmentPosition>(
      _firestore,
      ListType.govPosition,
      (json) => _convertToPositions(json),
      (position) => position.toJson(),
      ref,
    );
  }

  // Get settlement sizes provider
  ServiceProviderListFireStore<RolesBySize> getSettlementSizesProvider(Ref ref) {
    return ServiceProviderListFireStore<RolesBySize>(
      _firestore,
      ListType.govRolesBySize,
      (json) => _convertToSettlementSizes(json),
      (size) => size.toJson(),
      ref,
    );
  }

  // Helper method to convert the first JSON format to a list of positions
  GovernmentPosition _convertToPositions(Map<String, dynamic> json) {
    if (json.containsKey('positionKey')) {
      return GovernmentPosition.fromJson(json);
    }

    // If we're handling the raw document, we need to process it
    List<GovernmentPosition> positions = [];

    final governmentPositions =
        json['governmentPositions'] as Map<String, dynamic>;
    governmentPositions.forEach((positionKey, data) {
      positions.add(
        GovernmentPosition(
          positionKey: positionKey,
          titles: Map<String, String>.from(
            (data as Map<String, dynamic>)['titles'] as Map,
          ),
          settlementSizes: List<String>.from((data)['settlementSizes'] as List),
          ageProbabilities: Map<String, double>.from(
            (data as Map<String, double>)['ageProbabilities'] as Map,
        ),
        
          ),
      );
    });

    // Return the first one since our API expects a single item
    // This is just for the conversion function signature
    return positions.isNotEmpty
        ? positions.first
        : GovernmentPosition(positionKey: '', titles: {}, settlementSizes: [],ageProbabilities:{});
  }

  // Helper method to convert the second JSON format to settlement sizes
  RolesBySize _convertToSettlementSizes(Map<String, dynamic> json) {
    if (json.containsKey('name')) {
      return RolesBySize.fromJson(json);
    }

    // If we're handling the raw document, we need to process it
    List<RolesBySize> sizes = [];

    final settlementSizes = json['settlementSizes'] as Map<String, dynamic>;
    settlementSizes.forEach((sizeName, data) {
      final roleData =
          (data as Map<String, dynamic>)['roles'] as Map<String, dynamic>;
      Map<String, Map<String, String>> roles = {};

      roleData.forEach((govType, positions) {
        roles[govType] = Map<String, String>.from(
          (positions as Map<String, dynamic>).map(
            (pos, county) => MapEntry(pos, county.toString()),
          ),
        );
      });

      sizes.add(
        RolesBySize(
          sizeString: sizeName,
          roles: roles,
          universalRoles: data['universalRoles'].toString(),
        ),
      );
    });

    // Return the first one since our API expects a single item
    // This is just for the conversion function signature
    return sizes.isNotEmpty
        ? sizes.first
        : RolesBySize(sizeString: '', roles: {}, universalRoles: '0--0');
  }

  // Add this method to your GovernmentDataProvider class in government_extension2.dart

// Add this method to your GovernmentDataProvider class in government_extension2.dart

Future<void> setAndUpload(WidgetRef ref, String jsonType, Map<String, dynamic> jsonData) async {
  if (jsonType == 'positions') {
    // Convert the raw JSON to a list of GovernmentPosition objects
    List<GovernmentPosition> positions = [];
    
    final governmentPositions = jsonData['governmentPositions'] as Map<String, dynamic>;
    governmentPositions.forEach((positionKey, data) {
      // Cast data once as Map<String, dynamic>
      final positionData = data as Map<String, dynamic>;
      
      // Get age probabilities and properly cast it
      final ageProbData = positionData['ageProbabilities'] as Map<String, dynamic>;
      final ageProbabilities = Map<String, double>.from(
        ageProbData.map((key, value) => MapEntry(key, (value as num).toDouble()))
      );
      
      positions.add(GovernmentPosition(
        positionKey: positionKey,
        titles: Map<String, String>.from(positionData['titles'] as Map),
        settlementSizes: List<String>.from(positionData['settlementSizes'] as List),
        ageProbabilities: ageProbabilities,
      ));
    });
    
    // Clear existing data and add new items
    await _firestore.govPositionPath().set({
      'json': jsonEncode(positions.map((p) => p.toJson()).toList()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
try {
  // Reload the providers to reflect the changes
  final notifier = ref.read(positionsProviderBase.notifier);
  
  await notifier.load();
  ref.read(positionsProvider.notifier).discardChanges();
} catch (e, stackTrace) {
  debugPrint("Error: $e");
  debugPrint("Stack trace: $stackTrace");
}
    
  } else if (jsonType == 'settlementSizes') {
    // Convert the raw JSON to a list of SettlementSize objects
    List<RolesBySize> sizes = [];
    
    final settlementSizes = jsonData['settlementSizes'] as Map<String, dynamic>;
    settlementSizes.forEach((sizeName, data) {
      final roleData = (data as Map<String, dynamic>)['roles'] as Map<String, dynamic>;
      Map<String, Map<String, String>> roles = {};
      
      roleData.forEach((govType, positions) {
        roles[govType] = Map<String, String>.from(
          (positions as Map<String, dynamic>).map(
            (pos, numCount) => MapEntry(pos, numCount.toString()),
          ),
        );
      });
      
      sizes.add(RolesBySize(
        sizeString: sizeName,
        roles: roles,
        universalRoles: data['universalRoles'].toString(),
      ));
    });
    
    // Update Firestore directly
    await _firestore.govPositionRolesBySize().set({
      'json': jsonEncode(sizes.map((s) => s.toJson()).toList()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Reload the providers to reflect the changes
    
    try {
  // Reload the providers to reflect the changes
  final notifier = ref.read(roleBySizeProviderBase.notifier);
  await notifier.load();
  ref.read(roleBySizeProvider.notifier).discardChanges();
} catch (e, stackTrace) {
  debugPrint("Error: $e");
  debugPrint("Stack trace: $stackTrace");
}
  } else {
    throw ArgumentError('Invalid jsonType. Must be "positions" or "settlementSizes"');
  }
}
}

// Extension for BufferedProviderListFireStore to handle government data
extension GovernmentProviderExtension<T extends JsonSerializable>
    on BufferedProviderListFireStore<T> {
  // Initialize from Firestore JSON files
  Future<void> initializeFromFirestore() async {
    await baseNotifier.load();
    discardChanges();
  }

  
  // Gets a position by key
  T? getItemByKey(String key) {
    return items.firstWhereOrNull((item) => item.compositeKey() == key);
  }

  // For positions: get all positions valid for a settlement size
  List<GovernmentPosition> getGovPositionsForSettlementSize(String settlementSize) {
    return items.where((item) {
      if (item is GovernmentPosition) {
        return item.settlementSizes.contains(settlementSize);
      }
      return false;
    }).cast<GovernmentPosition>().toList();
  }

  // For positions: get title for a specific government type
  String? getTitleForPosition(String positionKey, String governmentType) {
    final position = getItemByKey(positionKey);
    if (position is GovernmentPosition) {
      return position.titles[governmentType];
    }
    return null;
  }

  // For settlement sizes: get roles for a specific government type
  Map<String, String>? getRolesForGovernmentType(
    String sizeName,
    String governmentType,
  ) {
    final size = getItemByKey(sizeName);
    if (size is RolesBySize) {
      Map<String,String> output = size.roles[governmentType]!;
      output.addAll(size.roles["guards"]!);
      return output;
      
    }
    return null;
  }

  
}

List<String> getListOfRoles(CitySize citySize, String governmentType,WidgetRef ref){
    final positionsNotif=ref.watch(positionsProvider.notifier);
    final rolesBySizeNotif = ref.watch(roleBySizeProvider.notifier);
    Map<String, String>? data = rolesBySizeNotif.getRolesForGovernmentType(citySize.name,governmentType);
    
    if(data == null){return [];} 
    List<String> output=List.empty(growable: true);
    for(final entry in data.entries){
      int min = int.parse(entry.value.split("--").first);
      int max = int.parse(entry.value.split("--").last);
      int n = random.nextInt(1+(max-min))+min;
      // Role? r = Role.values.firstWhereOrNull((role)=>role.name.split("Government").first== entry.key);
      // if(r == null){
      //   debugPrint("Couldn't find ${entry.key} in Roles enum");
      //     return [];
      // }
      for(int i = 0; i < n; i++){
          output.add(entry.key);
      }
    }

    RolesBySize size = rolesBySizeNotif.getItemByKey(citySize.name) as RolesBySize;
    int min = int.parse(size.universalRoles.split("--").first);
    int max = int.parse(size.universalRoles.split("--").last);
    int howMany = random.nextInt(1+(max-min))+min;
    

    List<GovernmentPosition> govP = positionsNotif.getGovPositionsForSettlementSize(citySize.name);
    for(int i = 0; i <howMany; i++){
      GovernmentPosition gp = randomElement(govP);
      // Role? r = Role.values.firstWhereOrNull((role)=> role.name.startsWith(gp.positionKey));
      // if(r == null){debugPrint("Couldn't find role ${gp.positionKey}"); return [];}
      output.add(gp.positionKey);
      govP.removeWhere((g)=>g.compositeKey()==gp.compositeKey());
    }
    return output;
  }

// Provider definitions
final governmentDataProvider = Provider(
  (ref) => GovernmentDataProvider(ref.watch(firestoreServiceProvider)),
);

// Providers for positions
final positionsProviderBase = StateNotifierProvider<
  ServiceProviderListFireStore<GovernmentPosition>,
  List<GovernmentPosition>
>((ref) {
  final dataProvider = ref.watch(governmentDataProvider);
  return dataProvider.getPositionsProvider(ref);
});

final positionsProvider = StateNotifierProvider<
  BufferedProviderListFireStore<GovernmentPosition>,
  List<GovernmentPosition>
>((ref) {
  final baseNotifier = ref.watch(positionsProviderBase.notifier);
  final initialState = ref.watch(positionsProviderBase);
  return BufferedProviderListFireStore<GovernmentPosition>(
    baseNotifier,
    initialState,
  );
});

// Providers for settlement sizes
final roleBySizeProviderBase = StateNotifierProvider<
  ServiceProviderListFireStore<RolesBySize>,
  List<RolesBySize>
>((ref) {
  final dataProvider = ref.watch(governmentDataProvider);
  return dataProvider.getSettlementSizesProvider(ref);
});

final roleBySizeProvider = StateNotifierProvider<
  BufferedProviderListFireStore<RolesBySize>,
  List<RolesBySize>
>((ref) {
  final baseNotifier = ref.watch(roleBySizeProviderBase.notifier);
  final initialState = ref.watch(roleBySizeProviderBase);
  return BufferedProviderListFireStore<RolesBySize>(baseNotifier, initialState);
});

// Helper function to initialize all data providers
Future<void> initializeGovernmentData(WidgetRef ref) async {
  final positions = ref.read(positionsProvider.notifier);
  final settlementSizes = ref.read(roleBySizeProvider.notifier);

  await positions.initializeFromFirestore();
  await settlementSizes.initializeFromFirestore();
}


Future<void> importGovJsonFromAsset(WidgetRef ref) async {
  // Load the positions JSON
  // print("maybe here?");

  final positionsString = await rootBundle.loadString('assets/govJsonTitlesv2.json');
  final positionsJson = jsonDecode(positionsString) as Map<String, dynamic>;
  
  // Load the settlement sizes JSON
  final sizesString = await rootBundle.loadString('assets/govJsonV2.json');
  final sizesJson = jsonDecode(sizesString) as Map<String, dynamic>;
  
  // Get the provider and update Firestore
  final governmentProvider = ref.read(governmentDataProvider);
  // print("I am jhere");
  // Upload both JSON files
  await governmentProvider.setAndUpload(ref, 'positions', positionsJson);
  await governmentProvider.setAndUpload(ref, 'settlementSizes', sizesJson);
}