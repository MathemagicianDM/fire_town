
import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/town_model.dart";


// Buffered provider that wraps the base provider
final townsProvider = StateNotifierProvider<BufferedProviderListFireStore<TownOnFire>, List<TownOnFire>>((ref) {
  final baseNotifier = ref.watch(_townsBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<TownOnFire>(baseNotifier, []);
});


final _townsBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<TownOnFire>, List<TownOnFire>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<TownOnFire>(
    firestoreService,
    ListType.town,
    TownOnFire.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


