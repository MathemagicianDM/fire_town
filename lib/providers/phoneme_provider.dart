import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/given_name_phonemes.dart';
import 'buffered_provider.dart';

// Base provider for given name elements
final _givenNameElementsBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<GivenNameElement>, List<GivenNameElement>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<GivenNameElement>(
    firestoreService,
    ListType.givenNamePhonemes, // Make sure to add this to your ListType enum
    GivenNameElement.fromJson,
    (element) => element.toJson(),
    ref,
    [], // Start with empty list
  );
});

// Buffered provider for given name elements
final givenNameElementsProvider = StateNotifierProvider<BufferedProviderListFireStore<GivenNameElement>, List<GivenNameElement>>((ref) {
  final baseNotifier = ref.watch(_givenNameElementsBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<GivenNameElement>(baseNotifier, []);
});