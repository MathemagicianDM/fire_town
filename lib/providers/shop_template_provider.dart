import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/description_template_model.dart';
import '../services/firestore_service.dart';
import 'dart:convert';

final shopTemplateProvider = StateNotifierProvider<ShopTemplateNotifier, List<ShopTemplate>>((ref) {
  return ShopTemplateNotifier(ref);
});

class ShopTemplateNotifier extends StateNotifier<List<ShopTemplate>> {
  final Ref _ref;
  
  ShopTemplateNotifier(this._ref) : super([]);

  Future<void> initialize() async {
    try {
      final firestoreService = FirestoreService();
      
      // Listen to the document stream - get the first value
      await for (String? jsonString in firestoreService.getDocString(ListType.shopTemplate, _ref)) {
        // Check if the provider is still mounted before updating state
        if (!mounted) return;
        
        if (jsonString != null && jsonString.isNotEmpty) {
          final decoded = jsonDecode(jsonString);
          List<dynamic> templatesData;
          
          if (decoded is Map && decoded.containsKey('templates')) {
            templatesData = decoded['templates'] as List<dynamic>;
          } else if (decoded is List) {
            templatesData = decoded;
          } else {
            if (mounted) state = [];
            break;
          }

          if (mounted) {
            state = templatesData
                .map((templateJson) => ShopTemplate.fromJson(templateJson))
                .toList();
          }
        } else {
          if (mounted) state = [];
        }
        break; // Get first value and exit
      }
    } catch (e) {
      // Handle error - could log or set error state
      debugPrint('Error loading shop templates: $e');
      if (mounted) state = [];
    }
  }

  Future<void> addTemplate(ShopTemplate template) async {
    state = [...state, template];
    await _saveToFirestore();
  }

  Future<void> updateTemplate(ShopTemplate template) async {
    state = [
      for (final t in state)
        if (t.id == template.id) template else t,
    ];
    await _saveToFirestore();
  }

  Future<void> removeTemplate(ShopTemplate template) async {
    state = state.where((t) => t.id != template.id).toList();
    await _saveToFirestore();
  }

  Future<void> loadFromJsonAndCommit(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      List<dynamic> templatesData;
      
      if (decoded is Map && decoded.containsKey('templates')) {
        templatesData = decoded['templates'] as List<dynamic>;
      } else if (decoded is List) {
        templatesData = decoded;
      } else {
        throw FormatException('Invalid JSON format');
      }

      state = templatesData
          .map((templateJson) => ShopTemplate.fromJson(templateJson))
          .toList();
      
      await _saveToFirestore();
    } catch (e) {
      throw Exception('Failed to load shop templates: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    if (!mounted) return;
    
    try {
      final firestoreService = FirestoreService();
      final templatesJson = {
        'templates': state.map((template) => template.toJson()).toList(),
      };
      
      await firestoreService.putDocString(
        ListType.shopTemplate,
        jsonEncode(templatesJson),
        _ref,
      );
    } catch (e) {
      debugPrint('Error saving shop templates to Firestore: $e');
      if (mounted) throw Exception('Failed to save shop templates');
    }
  }

  String exportToJson() {
    final export = {
      'templates': state.map((template) => template.toJson()).toList(),
    };
    return jsonEncode(export);
  }
}