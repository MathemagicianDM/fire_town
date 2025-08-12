import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/barrel_of_models.dart";
// import "../town_extension/town_locations.dart";


// Buffered provider that wraps the base provider
final locationRolesProvider = StateNotifierProvider<BufferedProviderListFireStore<LocationRole>, List<LocationRole>>((ref) {
  final baseNotifier = ref.watch(_locationRolesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<LocationRole>(baseNotifier, []);
});





final _locationRolesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<LocationRole>, List<LocationRole>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<LocationRole>(
    firestoreService,
    ListType.locationRole,
    LocationRole.fromJson,
    (lr) => lr.toJson(),
    ref,
    [], // Start with empty list
  );
});
