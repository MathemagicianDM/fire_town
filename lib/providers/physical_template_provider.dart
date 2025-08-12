import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/description_template_model.dart";

// Buffered provider that wraps the base provider
final physicalTemplatesProvider = StateNotifierProvider<BufferedProviderListFireStore<PhysicalTemplate>, List<PhysicalTemplate>>((ref) {
  final baseNotifier = ref.watch(_physicalTemplatesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<PhysicalTemplate>(baseNotifier, []);
});

final _physicalTemplatesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<PhysicalTemplate>, List<PhysicalTemplate>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<PhysicalTemplate>(
    firestoreService,
    ListType.physicalTemplate,
    PhysicalTemplate.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});