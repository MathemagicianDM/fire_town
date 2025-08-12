import "package:firetown/models/location_services_model.dart";

import "buffered_provider.dart";
import "package:riverpod/riverpod.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "../services/firestore_service.dart";
import "../models/new_shops_models.dart";



// Buffered provider that wraps the base provider
final shopNamesProvider = StateNotifierProvider<BufferedProviderListFireStore<ShopName>, List<ShopName>>((ref) {
  final baseNotifier = ref.watch(_shopNamesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<ShopName>(baseNotifier, []);
});


final _shopNamesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<ShopName>, List<ShopName>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<ShopName>(
    firestoreService,
    ListType.shopName,
    ShopName.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


final shopQualitiesProvider = StateNotifierProvider<BufferedProviderListFireStore<ShopQuality>, List<ShopQuality>>((ref) {
  final baseNotifier = ref.watch(_shopQualitiesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<ShopQuality>(baseNotifier, []);
});





final _shopQualitiesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<ShopQuality>, List<ShopQuality>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<ShopQuality>(
    firestoreService,
    ListType.shopQuality,
    ShopQuality.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


final genericServicesProvider = StateNotifierProvider<BufferedProviderListFireStore<GenericService>, List<GenericService>>((ref) {
  final baseNotifier = ref.watch(_genericServicesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<GenericService>(baseNotifier, []);
});


final _genericServicesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<GenericService>, List<GenericService>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<GenericService>(
    firestoreService,
    ListType.genericService,
    GenericService.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});


final specialtyServicesProvider = StateNotifierProvider<BufferedProviderListFireStore<Specialty>, List<Specialty>>((ref) {
  final baseNotifier = ref.watch(_specialtyServicesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<Specialty>(baseNotifier, []);
});


final _specialtyServicesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<Specialty>, List<Specialty>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Specialty>(
    firestoreService,
    ListType.specialtyService,
    Specialty.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});

