import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rumor_template_model.dart';
import '../services/rumor_template_engine.dart';
import 'barrel_of_providers.dart';
import 'buffered_provider.dart';
import '../services/firestore_service.dart';

// Buffered provider that wraps the base provider  
final rumorTemplatesProvider = StateNotifierProvider<BufferedProviderListFireStore<RumorTemplate>, List<RumorTemplate>>((ref) {
  final baseNotifier = ref.watch(_rumorTemplatesBaseProvider.notifier);
  
  // Initialize with empty list
  return BufferedProviderListFireStore<RumorTemplate>(baseNotifier, []);
});

final _rumorTemplatesBaseProvider = StateNotifierProvider<ServiceProviderListFireStore<RumorTemplate>, List<RumorTemplate>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<RumorTemplate>(
    firestoreService,
    ListType.rumorTemplate, // We'll need to add this to the ListType enum
    RumorTemplate.fromJson,
    (pr) => pr.toJson(),
    ref,
    [], // Start with empty list
  );
});

// Provider for generated rumors based on current town
final generatedRumorsProvider = Provider<List<GeneratedRumor>>((ref) {
  final templates = ref.watch(rumorTemplatesProvider);
  final people = ref.watch(peopleProvider);
  final roles = ref.watch(locationRolesProvider);
  final locations = ref.watch(locationsProvider);
  
  if (templates.isEmpty) return [];
  
  return RumorTemplateEngine.generateRumors(
    templates,
    people,
    roles,
    locations,
    maxRumors: 8,
  );
});

// Provider for custom rumors (user-added)
final customRumorsProvider = StateNotifierProvider<CustomRumorsNotifier, List<GeneratedRumor>>((ref) {
  return CustomRumorsNotifier();
});

class CustomRumorsNotifier extends StateNotifier<List<GeneratedRumor>> {
  CustomRumorsNotifier() : super([]);
  
  void addCustomRumor(String content) {
    final rumor = GeneratedRumor.custom(content.trim());
    state = [...state, rumor];
    _saveCustomRumors();
  }
  
  void removeCustomRumor(String rumorId) {
    state = state.where((rumor) => rumor.id != rumorId).toList();
    _saveCustomRumors();
  }
  
  void _saveCustomRumors() {
    // TODO: Implement persistence to SharedPreferences or local storage
    // For now, custom rumors are session-only
  }
}

// Combined provider for all rumors (generated + custom)
final allRumorsProvider = Provider<List<GeneratedRumor>>((ref) {
  final generated = ref.watch(generatedRumorsProvider);
  final custom = ref.watch(customRumorsProvider);
  
  return [...generated, ...custom];
});

