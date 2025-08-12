import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:firetown/enums_and_maps.dart";
import "../globals.dart";


// Government and Title Models
class Government {
  final String type;
  final String printName;
  final Map<String, List<GovRole>> govRoles;
  final Rule rule;

  Government({
    required this.type,
    required this.printName,
    required this.govRoles,
    required this.rule,
  });

  factory Government.fromJson(Map<String, dynamic> json) {
    // Parse roleGeneration map
    Map<String, List<GovRole>> roleGen = {};
    
    if (json['roleGeneration'] != null) {
      json['roleGeneration'].forEach((key, value) {
        if (value is List) {
          roleGen[key] = value.map((e) => GovRole.fromJson(e)).toList();
        }
      });
    }

    return Government(
      type: json['type'] ?? '',
      printName: json['printName'] ?? '',
      govRoles: roleGen,
      rule: Rule.fromJson(json['rule'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'Government(type: $type, printName: $printName)';
  }
}

class GovRole {
  final double? proportion;
  final List<Title>? list;
  final String? title;
  final int? quantityMin;
  final int? quantityMax;
  final String? role;

  GovRole({
    this.proportion,
    this.list,
    this.title,
    this.quantityMin,
    this.quantityMax,
    this.role,
  });

  factory GovRole.fromJson(Map<String, dynamic> json) {
    List<Title>? titleList;
    
    if (json['list'] != null) {
      titleList = (json['list'] as List).map((item) => Title.fromJson(item)).toList();
    }

    return GovRole(
      proportion: json['proportion'] != null ? double.tryParse(json['proportion'].toString()) : null,
      list: titleList,
      title: json['title'],
      quantityMin: json['quantityMin'],
      quantityMax: json['quantityMax'],
      role: json['role'],
    );
  }
}

class Title {
  final String title;
  final int? quantityMin;
  final int? quantityMax;
  final String? role;
  final double? proportion;

  Title({
    required this.title,
    this.quantityMin,
    this.quantityMax,
    this.role,
    this.proportion,
  });

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      title: json['title'] ?? '',
      quantityMin: json['quantityMin'],
      quantityMax: json['quantityMax'],
      role: json['role'],
      proportion: json['proportion'] != null ? double.tryParse(json['proportion'].toString()) : null,
    );
  }

  @override
  String toString() {
    if (quantityMin != null && quantityMax != null) {
      return 'Title(title: $title, quantity: $quantityMin-$quantityMax)';
    } else if (proportion != null) {
      return 'Title(title: $title, proportion: $proportion)';
    } else {
      return 'Title(title: $title)';
    }
  }
}

class Rule {
  final String method;
  final String proportional;
  final String enforceFamily;
  final String universalType;

  Rule({
    required this.method,
    required this.proportional,
    required this.enforceFamily,
    required this.universalType,
  });

  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      method: json['method'] ?? '',
      proportional: json['proportional'] ?? 'false',
      enforceFamily: json['enforceFamily'] ?? 'false',
      universalType: json['universalType'] ?? 'parseError',
    );
  }
}




// Provider for the GovernmentRepository
final governmentRepositoryProvider = Provider<GovernmentRepository>((ref) {
  return GovernmentRepository();
});

// Provider for all governments
final governmentsProvider = FutureProvider<List<Government>>((ref) {
  final repository = ref.watch(governmentRepositoryProvider);
  return repository.loadGovernments('./lib/demofiles/government.json');
});

final governmentTypeNamesProvider = Provider<List<MapEntry<String, String>>>((ref) {
  final asyncGovernments = ref.watch(governmentsProvider);

  return asyncGovernments.when(
    data: (governments) => governments
        .map((g) => MapEntry(g.type, g.printName)) // ✅ Create tuple-like structure
        .toList(),
    loading: () => [],
    error: (err, stack) => [],
  );
});

// Provider for a specific government by type
final governmentByTypeProvider = 
    FutureProvider.family<Government?, String>((ref, governmentType) async {
  final governments = await ref.watch(governmentsProvider.future);
  try {
    return governments.firstWhere((gov) => gov.type == governmentType);
  } catch (e) {
    debugPrint('Government type not found: $governmentType');
    return null;
  }
});

// Provider for roles based on government type and city size
final governmentRolesProvider = 
    FutureProvider.family<List<RoleResult>, GovernmentQuery>((ref, query) async {
  final government = await ref.watch(
      governmentByTypeProvider(query.governmentType).future);
  
  if (government == null) {
    return [];
  }
  
  final repository = ref.watch(governmentRepositoryProvider);
  return repository.getRolesForGovernment(government, query.citySize);
});

// Query parameter class for the roles provider
class GovernmentQuery {
  final String governmentType;
  final String citySize;

  GovernmentQuery(this.governmentType, this.citySize);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GovernmentQuery &&
        other.governmentType == governmentType &&
        other.citySize == citySize;
  }

  @override
  int get hashCode => governmentType.hashCode ^ citySize.hashCode;
}

// Repository class for loading government data
class GovernmentRepository {
  // Enum for city sizes
  
  // Convert string to CitySize enum
  CitySize? stringToCitySize(String sizeStr) {
    try {
        int index = CitySize.values.indexWhere((e) => e.name == sizeStr.toLowerCase());
        if(index == -1) {

          return null;
        }
        else {
          return CitySize.values[index];
        }
        
    } catch (e) {
      return null;
    }
  }

  // Load governments from JSON file
  Future<List<Government>> loadGovernments(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      return jsonList.map((json) => Government.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading governments: $e');
      return [];
    }
  }

  // Get roles for a specific government and city size
  List<RoleResult> getRolesForGovernment(Government government, String citySize) {
    final size = stringToCitySize(citySize);
    if (size == null) {
      return [];
    }
    
    final sizeStr = size.toString().split('.').last;
    final roleGenerations = government.govRoles[sizeStr];
    
    if (roleGenerations == null || roleGenerations.isEmpty) {
      return [];
    }
    
    List<RoleResult> results = [];
    
    for (final roleGen in roleGenerations) {
      // Case 1: Direct title with quantities
      if (roleGen.title != null && roleGen.quantityMin != null) {
        results.add(RoleResult(
          title: roleGen.title!,
          quantity: roleGen.quantityMax != null && roleGen.quantityMax! > roleGen.quantityMin! 
              ? '${roleGen.quantityMin}-${roleGen.quantityMax}'
              : roleGen.quantityMin.toString(),
          proportion: null,
          role: null,
        ));
      }
      // Case 2: List of titles with proportion
      else if (roleGen.list != null) {
        for (final title in roleGen.list!) {
          if (title.quantityMin != null) {
            // Direct quantity
            results.add(RoleResult(
              title: title.title,
              quantity: title.quantityMax != null && title.quantityMax! > title.quantityMin! 
                  ? '${title.quantityMin}-${title.quantityMax}'
                  : title.quantityMin.toString(),
              proportion: roleGen.proportion,
              role: title.role,
            ));
          } else if (title.proportion != null) {
            // Proportion-based
            results.add(RoleResult(
              title: title.title,
              quantity: null,
              proportion: title.proportion,
              role: title.role,
            ));
          } else {
            // Just title with no quantity
            results.add(RoleResult(
              title: title.title,
              quantity: null,
              proportion: null,
              role: title.role,
            ));
          }
        }
      }
    }
    
    return results;
  }

  Future<String> getGovernmentMethod(String governmentType) async {
    final government = await loadGovernmentByType(governmentType);
    if (government == null) {
      return '';
    }
    
    return government.rule.method;
  }

    Future<String> getGovernmenUnivesalType(String governmentType) async {
    final government = await loadGovernmentByType(governmentType);
    if (government == null) {
      return '';
    }
    
    return government.rule.universalType;
  }

  Future<List<RoleResult>> getSelectedRolesForGovernment(String governmentType, String citySize) async {
    // Get the government and validate city size
    final government = await loadGovernmentByType(governmentType);
    if (government == null) {
      return [];
    }
    
    final size = stringToCitySize(citySize);
    if (size == null) {
      return [];
    }
    
    final sizeStr = size.toString().split('.').last;
    final roleGenerations = government.govRoles[sizeStr];
    
    if (roleGenerations == null || roleGenerations.isEmpty) {
      return [];
    }
    
    List<RoleResult> selectedRoles = [];
    
    
    // Process each role generation group
    for (final roleGen in roleGenerations) {
      // Case 1: Direct title with quantities
      if (roleGen.title != null && roleGen.quantityMin != null) {
        selectedRoles.add(RoleResult(
          title: roleGen.title!,
          quantity: roleGen.quantityMax != null && roleGen.quantityMax! > roleGen.quantityMin! 
              ? '${roleGen.quantityMin}-${roleGen.quantityMax}'
              : roleGen.quantityMin.toString(),
          proportion: roleGen.proportion,
          role: roleGen.role,
        ));
      }
      // Case 2: List of titles with proportion
      else if (roleGen.list != null) {
        // For each list entry, we need to apply the proportion to select a subset
        if (roleGen.proportion != null && roleGen.proportion! < 1.0) {
          // Calculate how many titles to select based on the proportion
          int totalTitles = roleGen.list!.length;
          int titlesToSelect = (totalTitles * roleGen.proportion!).round();
          titlesToSelect = titlesToSelect.clamp(1, totalTitles); // Ensure at least 1 is selected
          
          // Create a copy of the list to shuffle
          List<Title> titlesCopy = List.from(roleGen.list!);
          titlesCopy.shuffle(random);
          
          // Take the first n elements after shuffling
          List<Title> selectedTitles = titlesCopy.take(titlesToSelect).toList();
          
          // Add the selected titles
          for (final title in selectedTitles) {
            selectedRoles.add(_createRoleResult(title, roleGen.proportion));
          }
        } else {
          // If proportion is 1 or null, include all titles
          for (final title in roleGen.list!) {
            selectedRoles.add(_createRoleResult(title, roleGen.proportion));
          }
        }
      }
    }
    
    return selectedRoles;
  }
  
  // Helper method to create a RoleResult from a Title
  RoleResult _createRoleResult(Title title, double? groupProportion) {
    return RoleResult(
      title: title.title,
      quantity: title.quantityMin != null ? 
        (title.quantityMax != null && title.quantityMax! > title.quantityMin! 
          ? '${title.quantityMin}-${title.quantityMax}' 
          : title.quantityMin.toString()) 
        : null,
      proportion: title.proportion ?? groupProportion,
      role: title.role,
    );
  }
  
  // Helper method to load a specific government by type
  Future<Government?> loadGovernmentByType(String governmentType) async {
    final governments = await loadGovernments('./lib/demofiles/government.json');
    try {
      return governments.firstWhere((gov) => gov.type == governmentType);
    } catch (e) {
      debugPrint('Government type not found: $governmentType');
      return null;
    }
  }
}

// Class to return structured results
class RoleResult {
  final String title;
  final String? quantity;
  final double? proportion;
  final String? role;

  RoleResult({
    required this.title,
    this.quantity,
    this.proportion,
    this.role,
  });

  @override
  String toString() {
    String result = 'Title: $title';
    if (quantity != null) {
      result += ', Quantity: $quantity';
    }
    if (proportion != null) {
      result += ', Proportion: $proportion';
    }
    if (role != null) {
      result += ', Role: $role';
    }
    return result;
  }
}


final selectedGovernmentRolesProvider = 
    FutureProvider.family<List<RoleResult>, GovernmentQuery>((ref, query) async {
  final repository = ref.watch(governmentRepositoryProvider);
  return repository.getSelectedRolesForGovernment(query.governmentType, query.citySize);
});






// Models
class GovernmentPosition {
  final Map<String, String> titles;
  final Map<AgeType, double> ageProbabilities;

  GovernmentPosition({
    required this.titles,
    required this.ageProbabilities,
  });

  factory GovernmentPosition.fromJson(Map<String, dynamic> json) {
    return GovernmentPosition(
      titles: Map.fromEntries(
        (json['titles'] as Map<String, dynamic>).entries.map(
              (entry) => MapEntry(
                entry.key,
                entry.value as String,
              ),
            ),
      ),
      ageProbabilities: Map.fromEntries(
        (json['ageProbabilities'] as Map<String, dynamic>).entries.map(
              (entry) => MapEntry(
                AgeType.values.firstWhere(
                  (age) => age.name == entry.key,
                ),
                (entry.value as num).toDouble(),
              ),
            ),
      ),
    );
  }
}

class GovernmentPositionsData {
  final Map<String, GovernmentPosition> positions;

  GovernmentPositionsData({required this.positions});

  factory GovernmentPositionsData.fromJson(Map<String, dynamic> json) {
    final positionsJson = json['governmentPositions'] as Map<String, dynamic>;
    return GovernmentPositionsData(
      positions: Map.fromEntries(
        positionsJson.entries.map(
          (entry) => MapEntry(
            entry.key,
            GovernmentPosition.fromJson(entry.value as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }
}

// Providers
final governmentPositionsJsonProvider = FutureProvider<String>((ref) async {
  // Load the JSON from the specified file path
  return await rootBundle.loadString('lib/demofiles/governmentTitleMap.json');
});

// final governmentPositionsDataProvider = FutureProvider<GovernmentPositionsData>((ref) async {
//   final jsonString = await ref.watch(governmentPositionsJsonProvider.future);
//   final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
//   return GovernmentPositionsData.fromJson(jsonMap);
// });

final isDataLoadedProvider = StateProvider<bool>((ref) => false);

final governmentPositionsDataProvider = FutureProvider<GovernmentPositionsData>((ref) async {
  // print("Loading government positions data...");
  try {
    final jsonString = await ref.watch(governmentPositionsJsonProvider.future);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    // print("Data loaded successfully");
    ref.read(isDataLoadedProvider.notifier).state = true;
    return GovernmentPositionsData.fromJson(jsonMap);
    // Explicitly mark data as loaded
  } catch (e) {
    // print("Error loading data: $e");
    rethrow;
  }
});

// final governmentPositionsDataProvider = FutureProvider<GovernmentPositionsData>((ref) async {
//   print("Loading government positions data...");
//   try {
//     final jsonString = await ref.watch(governmentPositionsJsonProvider.future);
//     final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
//     print("Data loaded successfully");
//     return GovernmentPositionsData.fromJson(jsonMap);
//   } catch (e) {
//     print("Error loading data: $e");
//     throw e;
//   }
// });
final governmentPositionsServiceProvider = Provider<GovernmentPositionsService>((ref) {
  final dataAsyncValue = ref.watch(governmentPositionsDataProvider);
  
  return GovernmentPositionsService(dataAsyncValue);
});

// Selected values providers
final selectedGovernmentTypeProvider = StateProvider<String>((ref) {
  return "nobility"; // Default value
});

final selectedPositionProvider = StateProvider<String?>((ref) {
  return null; // No default position
});

// Service class
class GovernmentPositionsService {
  final AsyncValue<GovernmentPositionsData> dataAsyncValue;

  GovernmentPositionsService(this.dataAsyncValue);
  
    Future<GovernmentPositionsData> getPositionsData() async {
    if (dataAsyncValue is AsyncData<GovernmentPositionsData>) {
      return (dataAsyncValue as AsyncData<GovernmentPositionsData>).value;
    } else if (dataAsyncValue is AsyncError) {
      throw (dataAsyncValue as AsyncError).error;
    } else {
      // We're in loading state, so we need to wait for the data
      // This assumes your provider will eventually complete
      // You might need to add a timeout here
      await Future.delayed(Duration(milliseconds: 100));
      return getPositionsData(); // Try again (recursively)
    }
  }


  /// Returns a list of all available position keys
  List<String> getAllPositions() {
    return dataAsyncValue.maybeWhen(
      data: (data) => data.positions.keys.toList(),
      orElse: () => [],
    );
  }


  /// Returns the title for a given position based on the government type
  String getTitleForPosition(String position, String governmentType) {
  return dataAsyncValue.when(
    data: (data) {
      // Normalize inputs to reduce mismatch issues
      final normalizedPosition = position.trim();
      final normalizedGovType = governmentType.trim();
      
      // Try exact match first
      final positionData = data.positions[normalizedPosition];
      if (positionData != null) {
        final title = positionData.titles[normalizedGovType];
        if (title != null) {
          return title;
        }
        
        // Try case-insensitive match for government type
        for (final entry in positionData.titles.entries) {
          if (entry.key.toLowerCase() == normalizedGovType.toLowerCase()) {
            return entry.value;
          }
        }
      }
      
      // Try case-insensitive match for position
      for (final entry in data.positions.entries) {
        if (entry.key.toLowerCase() == normalizedPosition.toLowerCase()) {
          final title = entry.value.titles[normalizedGovType];
          if (title != null) {
            return title;
          }
          
          // Try case-insensitive match for government type
          for (final titleEntry in entry.value.titles.entries) {
            if (titleEntry.key.toLowerCase() == normalizedGovType.toLowerCase()) {
              return titleEntry.value;
            }
          }
        }
      }
      
      // Fall back to a default value instead of returning null
      return normalizedPosition[0].toUpperCase() + normalizedPosition.substring(1).toLowerCase();
    },
    loading: () => "Loading...",
    error: (error, stack) => "Error: $error",
  );
}

  /// Returns a random age type based on the probabilities for a given position
  AgeType? getRandomAgeForPosition(String position) {
    return dataAsyncValue.maybeWhen(
      data: (data) {
        final positionData = data.positions[position];
        if (positionData == null) {
          return null;
        }

        // Get a random value between 0 and 1
        final randomValue = random.nextDouble();
        
        // Use the probabilities to determine which age to return
        double cumulativeProbability = 0.0;
        
        for (final entry in positionData.ageProbabilities.entries) {
          cumulativeProbability += entry.value;
          if (randomValue <= cumulativeProbability) {
            return entry.key;
          }
        }
        
        // Fallback to adult in case there's an issue with probabilities
        return AgeType.adult;
      },
      orElse: () => null,
    );
  }
}


