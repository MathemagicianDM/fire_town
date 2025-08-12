import "buffered_provider.dart";
import "../models/person_model.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";


// Buffered provider that wraps the base provider
final peopleProvider = StateNotifierProvider<BufferedProviderListFireStore<Person>, List<Person>>((ref) {
  final baseNotifier = ref.watch(_peopleBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Person>(baseNotifier, []);
});





final _peopleBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Person>, List<Person>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Person>(
    firestoreService,
    ListType.people,
    Person.fromJson2,
    (person) => person.toJson(),
    ref,
    [], // Start with empty list
  );
});
