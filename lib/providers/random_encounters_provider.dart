import "package:firetown/models/random_encounter_model.dart";
import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";

// Buffered provider that wraps the base provider
final randomEncountersProvider = StateNotifierProvider<BufferedProviderListFireStore<RandomEncounter>, List<RandomEncounter>>((ref) {
  final baseNotifier = ref.watch(_randomEncountersBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<RandomEncounter>(baseNotifier, []);
});

final _randomEncountersBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<RandomEncounter>, List<RandomEncounter>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<RandomEncounter>(
    firestoreService,
    ListType.randomEncounter, // We'll need to add this to the enum
    RandomEncounter.fromJson,
    (encounter) => encounter.toJson(),
    ref,
    [], // Start with empty list
  );
});