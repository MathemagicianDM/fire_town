import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/ancestry_model.dart";


// Buffered provider that wraps the base provider
final ancestriesProvider = StateNotifierProvider<BufferedProviderListFireStore<Ancestry>, List<Ancestry>>((ref) {
  final baseNotifier = ref.watch(_ancestriesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Ancestry>(baseNotifier, []);
});





final _ancestriesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Ancestry>, List<Ancestry>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Ancestry>(
    firestoreService,
    ListType.ancestry,
    Ancestry.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});
