
import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/quirk_model.dart";


// Buffered provider that wraps the base provider
final quirksProvider = StateNotifierProvider<BufferedProviderListFireStore<Quirk>, List<Quirk>>((ref) {
  final baseNotifier = ref.watch(_quirksBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Quirk>(baseNotifier, []);
});


final _quirksBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Quirk>, List<Quirk>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Quirk>(
    firestoreService,
    ListType.quirk,
    Quirk.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


