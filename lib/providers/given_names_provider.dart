import "package:firetown/models/names_models.dart";

import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";


// Buffered provider that wraps the base provider
final givenNamesProvider = StateNotifierProvider<BufferedProviderListFireStore<GivenName>, List<GivenName>>((ref) {
  final baseNotifier = ref.watch(_givenNamesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<GivenName>(baseNotifier, []);
});





final _givenNamesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<GivenName>, List<GivenName>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<GivenName>(
    firestoreService,
    ListType.givenName,
    GivenName.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});
