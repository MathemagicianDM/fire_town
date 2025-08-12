
import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/resonant_argument_model.dart";


// Buffered provider that wraps the base provider
final resonantArgumentsProvider = StateNotifierProvider<BufferedProviderListFireStore<ResonantArgument>, List<ResonantArgument>>((ref) {
  final baseNotifier = ref.watch(_resonantArgumentsBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<ResonantArgument>(baseNotifier, []);
});


final _resonantArgumentsBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<ResonantArgument>, List<ResonantArgument>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<ResonantArgument>(
    firestoreService,
    ListType.resonantArgument,
    ResonantArgument.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


