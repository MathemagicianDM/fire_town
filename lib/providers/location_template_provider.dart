import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/description_template_model.dart";

// Buffered provider that wraps the base provider
final locationTemplatesProvider = StateNotifierProvider<BufferedProviderListFireStore<LocationTemplate>, List<LocationTemplate>>((ref) {
  final baseNotifier = ref.watch(_locationTemplatesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<LocationTemplate>(baseNotifier, []);
});

final _locationTemplatesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<LocationTemplate>, List<LocationTemplate>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<LocationTemplate>(
    firestoreService,
    ListType.locationTemplate,
    LocationTemplate.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});