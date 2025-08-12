import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/description_template_model.dart";

// Buffered provider that wraps the base provider
final clothingTemplatesProvider = StateNotifierProvider<BufferedProviderListFireStore<ClothingTemplate>, List<ClothingTemplate>>((ref) {
  final baseNotifier = ref.watch(_clothingTemplatesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<ClothingTemplate>(baseNotifier, []);
});

final _clothingTemplatesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<ClothingTemplate>, List<ClothingTemplate>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<ClothingTemplate>(
    firestoreService,
    ListType.clothingTemplate,
    ClothingTemplate.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});