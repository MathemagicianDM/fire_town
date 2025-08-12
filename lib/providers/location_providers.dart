import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/town_extension/town_locations.dart";


// Buffered provider that wraps the base provider
final locationsProvider = StateNotifierProvider<BufferedProviderListFireStore<Location>, List<Location>>((ref) {
  final baseNotifier = ref.watch(_locationsBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Location>(baseNotifier, []);
});





final _locationsBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Location>, List<Location>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Location>(
    firestoreService,
    ListType.location,
    Location.fromJsonMultiplex,
    (location) => location.toJson(),
    ref,
    [], // Start with empty list
  );
});
