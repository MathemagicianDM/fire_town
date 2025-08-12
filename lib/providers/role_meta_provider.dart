import "buffered_provider.dart";  
import "../models/roles_models.dart";
import "../services/firestore_service.dart";
import "../globals.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:firetown/enums_and_maps.dart";

final _rolesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<RoleGeneration>, List<RoleGeneration>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<RoleGeneration>(
    firestoreService,
    ListType.roleMeta,
    RoleGeneration.fromJson,
    (role) => role.toJson(),
    ref,
    [],
  );
});

// Buffered provider (public)
final roleMetaProvider = StateNotifierProvider<RolesBufferedProvider, List<RoleGeneration>>((ref) {
  final baseNotifier = ref.watch(_rolesBaseProvider.notifier);
  return RolesBufferedProvider(baseNotifier, []);
});

// Service provider
final roleServiceProvider = Provider<RoleService>((ref) {
  final roles = ref.watch(roleMetaProvider);
  return RoleService(roles);
});



// Extended buffered provider with role-specific functionality
class RolesBufferedProvider extends BufferedProviderListFireStore<RoleGeneration> {
  static double priorityTavernChance = 0.5;
  static double priorityCustomerChance = 0.5;

  // Cache values for performance
  int? _cachedAll;
  int? _cachedAllTavern;
  int? _cachedAllPriorityTavern;
  int? _cachedAllPriorityCustomer;
  
  RolesBufferedProvider(
    super.baseNotifier, 
    super.initialState
  );
  
  @override
  set state(List<RoleGeneration> newState) {
    // Invalidate the cache whenever the state changes
    _invalidateCache();
    super.state = newState;
  }
  
  void _invalidateCache() {
    _cachedAll = null;
    _cachedAllTavern = null;
    _cachedAllPriorityTavern = null;
    _cachedAllPriorityCustomer = null;
  }
  
  // Add or update a role
  void addOrUpdateRole(RoleGeneration role) {
    final index = state.indexWhere((r) => r.thisRole == role.thisRole);
    
    if (index == -1) {
      add(role);
    } else {
      replace(state[index], role);
    }
    
    _invalidateCache();
  }
  
  // Get the summed onePerHowMany values for all roles
  int get all {
    return _cachedAll ??= state.fold<int>(0, (v, r) => v + r.onePerHowMany);
  }

  // Get the summed onePerHowMany values for tavern roles
  int get allTavern {
    return _cachedAllTavern ??= state
        .where((tr) => tr.promoteInTaverns)
        .fold<int>(0, (v, r) => v + r.onePerHowMany);
  }

  // Get the summed onePerHowMany values for priority tavern roles
  int get allPriorityTavern {
    return _cachedAllPriorityTavern ??= state
        .where((tr) => tr.promoteInTaverns && tr.priorityInTaverns)
        .fold<int>(0, (v, r) => v + r.onePerHowMany);
  }

  // Get the summed onePerHowMany values for priority customer roles
  int get allPriorityCustomer {
    return _cachedAllPriorityCustomer ??= state
        .where((tr) => tr.prioritizeCustomer)
        .fold<int>(0, (v, r) => v + r.onePerHowMany);
  }
  
  // Get display string for a role
  String getString(Role myRole, {bool? plural, WidgetRef? ref}) {
    // Handle special cases
    if (myRole.name.contains("Government")) {
      if (ref != null) {
        return stringForHeaders(ref, myRole);
      } else {
        return "Government Official";
      }
    }

    if (myRole == Role.owner) {
      return plural == true ? "Owners" : "Owner";
    }

    if (myRole == Role.customer) {
      return plural == true ? "Customers" : "Customer";
    }
    
    if (myRole == Role.regular) {
      return plural == true ? "Regulars" : "Regular";
    }

    if (myRole == Role.minorNoble) {
      return plural == true ? "Minor Nobles" : "Minor Noble";
    }
    
    // Find the role in the state
    int i = state.indexWhere((s) => s.thisRole == myRole);
    
    if (i == -1) {
      return "Role not found";
    } else {
      return plural == true ? state[i].plural : state[i].singular;
    }
  }
  
  // Randomly select a tavern regular role based on distribution
  Role getTavernRegularRole() {
    double pt = random.nextDouble();
    double r;
    
    // Check if we should use priority roles
    if (pt < priorityTavernChance) {
      final subRoles = state.where((tr) => tr.priorityInTaverns).toList();
      
      r = random.nextDouble();
      for (int i = 0; i < subRoles.length; i++) {
        r -= 1 / subRoles[i].onePerHowMany;
        if (r < 0) {
          return subRoles[i].thisRole;
        }
      }
    }
    
    // If not priority or no priority role selected, use all tavern roles
    final subRoles = state.where((tr) => tr.promoteInTaverns).toList();
    r = random.nextDouble();
    
    for (int i = 0; i < subRoles.length; i++) {
      r -= 1 / subRoles[i].onePerHowMany;
      if (r < 0) {
        return subRoles[i].thisRole;
      }
    }
    
    // print("Tav");
    // Fallback to a random selection if no role was selected by distribution
    return _randomElement(subRoles.map((s) => s.thisRole).toList());
  }
  
  // Randomly select a customer role based on distribution
  Role getCustomerRole() {
    double pt = random.nextDouble();
    double r;
    
    // Check if we should use priority roles
    if (pt < priorityCustomerChance) {
      final subRoles = state.where((tr) => tr.prioritizeCustomer).toList();
      
      r = random.nextDouble();
      for (int i = 0; i < subRoles.length; i++) {
        r -= 1 / subRoles[i].onePerHowMany;
        if (r < 0) {
          return subRoles[i].thisRole;
        }
      }
    }
    
    // If not priority or no priority role selected, use all roles
    r = random.nextDouble();
    
    for (int i = 0; i < state.length; i++) {
      r -= 1 / state[i].onePerHowMany;
      if (r < 0) {
        return state[i].thisRole;
      }
    }
    
    // print("Cus");
    // Fallback to a random selection if no role was selected by distribution
    return _randomElement(state.map((s) => s.thisRole).toList());
  }
  
  // Randomly select any role based on distribution
  Role getRole() {
    double r = random.nextDouble();
    
    for (int i = 0; i < state.length; i++) {
      r -= 1 / state[i].onePerHowMany;
      if (r < 0) {
        return state[i].thisRole;
      }
    }
    
    // print("Role");
    // Fallback to a random selection if no role was selected by distribution
    return _randomElement(state.map((s) => s.thisRole).toList());
  }
  

  // Get a random valid age for a role
  AgeType getAgeOfRole(Role r) {
    // print("Age");
    List<AgeType> myAges = state
        .firstWhere((s) => s.thisRole == r)
        .validAges
        .toList();
    return _randomElement(myAges);
  }
  
  // Get all valid ages for a role
  Set<AgeType> getAllAgesOfRole(Role r) {
    return state
        .firstWhere((s) => s.thisRole == r)
        .validAges
        .toSet();
  }
  
  // Utility function to select a random element from a list
  T _randomElement<T>(List<T> list) {
    return list[random.nextInt(list.length)];
  }
  
  // Bulk replace all roles
  void replaceAllRoles(List<RoleGeneration> roles) {
    state = [];
    for (final role in roles) {
      add(role);
    }
    _invalidateCache();
  }
}