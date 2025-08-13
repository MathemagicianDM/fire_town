import "../models/json_serializable_abstract_class.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import "dart:convert";
import "package:flutter/foundation.dart";



// Provider for the FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class ServiceProviderAdapter<T extends JsonSerializable> {
  final FirestoreService _firestoreService;
  final ListType _listType;
  final Ref _ref;
  
  ServiceProviderAdapter(this._firestoreService, this._listType, this._ref);
  
  // Load data as a JSON string and convert to a List of objects
  Future<List<T>> loadItems(T Function(Map<String, dynamic>) fromJson) async {
    try {
      // Get the first value from the stream
      final jsonString = await _firestoreService.getDocString(_listType, _ref).first;
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading items: $e');
      return [];
    }
  }
  
  // Save a list of objects as a JSON string
  Future<void> saveItems(List<Map<String, dynamic>> items) async {
    final jsonString = jsonEncode(items);
    await _firestoreService.putDocString(_listType, jsonString, _ref);
  }
}
// Modified ProviderListFireStore that works with FirestoreService
class ServiceProviderListFireStore<T extends JsonSerializable>
    extends StateNotifier<List<T>> {
  final FirestoreService _firestoreService;
  final ListType _listType;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  final Ref _ref;
  
  // Adapter that handles communication with the FirestoreService
  late final ServiceProviderAdapter<T> _adapter;

  ServiceProviderListFireStore(
    this._firestoreService,
    this._listType,
    this._fromJson,
    this._toJson,
    this._ref, [
    List<T>? initialState,
  ]) : super(initialState ?? []) {
    _adapter = ServiceProviderAdapter<T>(_firestoreService, _listType, _ref);
  }

  // Load data from FirestoreService
  Future<void> load() async {
    final items = await _adapter.loadItems(_fromJson);
    state = items;
  }

  // Save entire list via FirestoreService
  Future<void> save() async {
    final items = state.map(_toJson).toList();
    await _adapter.saveItems(items);
  }

  // Get a stream of the data for reactivity
  @override
  Stream<List<T>> get stream => _firestoreService.getDocString(_listType, _ref).map((jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return <T>[];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => _fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
      return <T>[];
    }
  });

  // Methods for manipulating the list
  void add(T item) {
    final newState = List<T>.from(state);
    newState.add(item);
    state = newState;
  }

  void remove(T item) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere(
      (i) => item.compositeKey() == i.compositeKey(),
    );
    if (index != -1) {
      newState.removeAt(index);
      state = newState;
    }
  }

  void update(T oldVersion, T updated) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere(
      (item) => item.compositeKey() == oldVersion.compositeKey(),
    );
    if (index != -1) {
      newState[index] = updated;
    }
    state = newState;
  }

  void updateByKey(String key, T updated) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere((item) => item.compositeKey() == key);
    if (index != -1) {
      newState[index] = updated;
    }
    state = newState;
  }
}

class BufferedProviderListFireStore<T extends JsonSerializable>
    extends StateNotifier<List<T>> {
  final ServiceProviderListFireStore<T> baseNotifier;
  bool _isDirty = false;

  List<T> get items => state;
  bool get isDirty => _isDirty;

  BufferedProviderListFireStore(this.baseNotifier, List<T> initialState)
    : super(initialState);
    
  // Initialize from FirestoreService
  Future<void> initialize() async {
    await baseNotifier.load();
    if (!mounted) return;
    state = baseNotifier.state;
    _isDirty = false;
  }

  // Add item
  void add(T item) {
    final newState = List<T>.from(state);
    newState.add(item);
    state = newState;
    _isDirty = true;
  }

  // Remove item
  void remove(T item) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere(
      (i) => item.compositeKey() == i.compositeKey(),
    );
    if (index != -1) {
      newState.removeAt(index);
      state = newState;
      _isDirty = true;
    }
  }

   void removeByKey(String key) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere(
      (i) => key == i.compositeKey(),
    );
    if (index != -1) {
      newState.removeAt(index);
      state = newState;
      _isDirty = true;
    }
  }

  // Update item
  void replace(T old, T updated) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere(
      (item) => item.compositeKey() == old.compositeKey(),
    );
    if (index != -1) {
      newState[index] = updated;
      state = newState;
      _isDirty = true;
    }
  }
  
  // Update by key
  void updateByKey(String key, T updated) {
    final newState = List<T>.from(state);
    final index = newState.indexWhere((item) => item.compositeKey() == key);
    if (index != -1) {
      newState[index] = updated;
      state = newState;
      _isDirty = true;
    }
  }

  // Commit changes to FirestoreService
  Future<void> commitChanges() async {
    if (!_isDirty) return;
    baseNotifier.state = state;
    await baseNotifier.save();
    _isDirty = false;
  }

  // Discard changes
  void discardChanges() {
    if(!mounted){return;}
    state = baseNotifier.state;
    _isDirty = false;
  }

  Future<void> loadFromJsonAndCommit(String jsonString) async {
  try {
    // Parse the JSON string
    final List<dynamic> jsonList = jsonDecode(jsonString);

    // Clear current state
    state = [];
    
    // Add each item using the baseNotifier's fromJson function
    for (final item in jsonList) {
      add(baseNotifier._fromJson(item as Map<String, dynamic>));
    }
    
    // Commit the changes to Firestore
    await commitChanges();
    
    // debugPrint('Successfully loaded and committed ${jsonList.length} items');
  } catch (e) {
    debugPrint('Error loading items from JSON: $e');
    throw Exception('Failed to load from JSON: $e');
  }
}
}
