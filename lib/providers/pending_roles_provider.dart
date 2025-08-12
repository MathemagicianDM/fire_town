import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import '../models/barrel_of_models.dart';


// Buffered provider that wraps the base provider
final pendingRolesProvider = StateNotifierProvider<BufferedProviderListFireStore<PendingRoles>, List<PendingRoles>>((ref) {
  final baseNotifier = ref.watch(_pendingRoleBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<PendingRoles>(baseNotifier, []);
});





final _pendingRoleBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<PendingRoles>, List<PendingRoles>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<PendingRoles>(
    firestoreService,
    ListType.pendingRoles,
    PendingRoles.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});

