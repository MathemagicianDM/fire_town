import "package:firetown/models/names_models.dart";

import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";


// Buffered provider that wraps the base provider
final surnamesProvider = StateNotifierProvider<BufferedProviderListFireStore<Surname>, List<Surname>>((ref) {
  final baseNotifier = ref.watch(_surnamesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Surname>(baseNotifier, []);
});


final _surnamesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Surname>, List<Surname>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Surname>(
    firestoreService,
    ListType.surname,
    Surname.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


