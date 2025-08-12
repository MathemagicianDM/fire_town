// reactive_search_provider.dart
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

import '../models/person_model.dart';
import '../models/town_extension/town_locations.dart';

// This will track the search initialization state
class SearchState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;

  SearchState({
    this.isInitialized = false, 
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider to track search initialization state
final searchStateProvider = StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  return SearchStateNotifier();
});

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier() : super(SearchState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setInitialized(bool initialized) {
    state = state.copyWith(isInitialized: initialized, isLoading: false);
  }

  void setError(String errorMessage) {
    state = state.copyWith(error: errorMessage, isLoading: false);
  }
}

// Trie implementation for in-memory search
@immutable
class InMemoryTrieNode {
  final Map<String, InMemoryTrieNode> children;
  final Set<String> ids;

  const InMemoryTrieNode({
    Map<String, InMemoryTrieNode>? children,
    Set<String>? ids,
  })  : children = children ?? const {},
        ids = ids ?? const {};

  InMemoryTrieNode copyWith({
    Map<String, InMemoryTrieNode>? children,
    Set<String>? ids,
  }) {
    return InMemoryTrieNode(
      children: children ?? this.children,
      ids: ids ?? this.ids,
    );
  }

  // Helper to add a child node
  InMemoryTrieNode withChild(String char, InMemoryTrieNode child) {
    final newChildren = Map<String, InMemoryTrieNode>.from(children);
    newChildren[char] = child;
    return copyWith(children: newChildren);
  }

  // Helper to add an ID
  InMemoryTrieNode withId(String id) {
    final newIds = Set<String>.from(ids);
    newIds.add(id);
    return copyWith(ids: newIds);
  }

  // Helper to remove an ID
  InMemoryTrieNode withoutId(String id) {
    final newIds = Set<String>.from(ids);
    newIds.remove(id);
    return copyWith(ids: newIds);
  }
}

class ReactiveSearchNotifier extends StateNotifier<InMemoryTrieNode> {
  ReactiveSearchNotifier() : super(const InMemoryTrieNode());

  // Insert a word and associate it with an ID
  void insert(String word, String id) {
    if (word.isEmpty) return;
    
    word = word.toLowerCase().trim();
    
    // For each word part, also add to the index
    final parts = word.split(' ');
    for (final part in parts) {
      if (part.length > 2) { // Skip very short parts
        _insertWord(part, id);
      }
    }
    
    // Also insert the complete phrase
    _insertWord(word, id);
  }
  
  // Internal helper to insert a single word
  void _insertWord(String word, String id) {
    if (word.isEmpty) return;
    
    final chars = word.split('');
    
    // Create a new root with the ID inserted at the right place
    final newRoot = _insertAtPath(state, chars, 0, id);
    
    // Update the state with the new root
    state = newRoot;
  }

InMemoryTrieNode _insertAtPath(
    InMemoryTrieNode node,
    List<String> path,
    int index,
    String id
  ) {
    // If we've reached the end of the path, add the ID to this node
    if (index >= path.length) {
      final newIds = Set<String>.from(node.ids)..add(id);
      return node.copyWith(ids: newIds);
    }
    
    // Get current character and check if child exists
    final char = path[index];
    final existingChild = node.children[char];
    
    // Create or update the child node
    final updatedChild = _insertAtPath(
      existingChild ?? const InMemoryTrieNode(),
      path,
      index + 1,
      id
    );
    
    // Create a new children map with the updated child
    final newChildren = Map<String, InMemoryTrieNode>.from(node.children);
    newChildren[char] = updatedChild;
    
    // Return a new node with updated children
    return node.copyWith(children: newChildren);
  }
  void remove(String word, String id) {
    if (word.isEmpty) return;
    
    word = word.toLowerCase().trim();
    
    // For each word part, also remove from the index
    final parts = word.split(' ');
    for (final part in parts) {
      if (part.length > 2) { // Skip very short parts
        _removeWord(part, id);
      }
    }
    
    // Also remove the complete phrase
    _removeWord(word, id);
  }
  
  // Internal helper to remove a word association
  void _removeWord(String word, String id) {
    if (word.isEmpty) return;
    
    final chars = word.split('');
    
    // Create a new root with the ID removed at the right place
    final newRoot = _removeAtPath(state, chars, 0, id);
    
    // Update the state with the new root
    state = newRoot;
  }

  InMemoryTrieNode _removeAtPath(
    InMemoryTrieNode node,
    List<String> path,
    int index,
    String id
  ) {
    // If we've reached the end of the path, remove the ID from this node
    if (index >= path.length) {
      final newIds = Set<String>.from(node.ids)..remove(id);
      return node.copyWith(ids: newIds);
    }
    
    // Get current character and check if child exists
    final char = path[index];
    final existingChild = node.children[char];
    
    // If no child exists with this character, no need to continue
    if (existingChild == null) {
      return node;
    }
    
    // Update the child node
    final updatedChild = _removeAtPath(
      existingChild,
      path,
      index + 1,
      id
    );
    
    // If the updated child has no IDs and no children, we can remove it
    if (updatedChild.ids.isEmpty && updatedChild.children.isEmpty) {
      final newChildren = Map<String, InMemoryTrieNode>.from(node.children);
      newChildren.remove(char);
      return node.copyWith(children: newChildren);
    }
    
    // Otherwise, create a new children map with the updated child
    final newChildren = Map<String, InMemoryTrieNode>.from(node.children);
    newChildren[char] = updatedChild;
    
    // Return a new node with updated children
    return node.copyWith(children: newChildren);
  }

    void update(String oldWord, String newWord, String id) {
    remove(oldWord, id);
    insert(newWord, id);
  }

  // Search for exact word match
  Set<String> search(String word) {
    if (word.isEmpty) return {};
    
    word = word.toLowerCase().trim();
    return _getNode(word)?.ids ?? {};
  }

  // Get all IDs for words starting with the given prefix
  Set<String> getIdsWithPrefix(String prefix) {
    if (prefix.isEmpty) return {};
    
    prefix = prefix.toLowerCase().trim();
    final node = _getNode(prefix);
    if (node == null) return {};
    
    final ids = <String>{};
    _collectIds(node, ids);
    return ids;
  }

  // Fuzzy search using Levenshtein Distance
  List<String> searchFuzzy(String query, {int maxDistance = 2}) {
    if (query.isEmpty) return [];
    
    query = query.toLowerCase().trim();
    
    // Extract all words from the trie for fuzzy matching
    final allWords = _extractAllWords(state, "");
    
    final results = <MapEntry<String, int>>[];
    
    for (final word in allWords.entries) {
      final distance = _levenshtein(query, word.key);
      final containsQuery = word.key.contains(query);
      
      if (distance <= maxDistance || containsQuery) {
        final score = _calculateRelevance(query, word.key, distance);
        results.add(MapEntry(word.key, score));
      }
    }
    
    // Sort by score (higher is better)
    results.sort((a, b) => b.value.compareTo(a.value));
    
    // Collect IDs from matching words
    final allIds = <String>{};
    for (final result in results) {
      allIds.addAll(allWords[result.key] ?? {});
    }
    
    return allIds.toList();
  }

  // Helper to get node for a word or prefix
  InMemoryTrieNode? _getNode(String prefix) {
    var node = state;
    
    for (final char in prefix.split('')) {
      if (!node.children.containsKey(char)) {
        return null;
      }
      node = node.children[char]!;
    }
    
    return node;
  }

  // Helper to collect IDs from a subtree
  void _collectIds(InMemoryTrieNode node, Set<String> ids) {
    ids.addAll(node.ids);
    for (final child in node.children.values) {
      _collectIds(child, ids);
    }
  }

  // Helper to calculate search relevance score
  int _calculateRelevance(String query, String word, int distance) {
    int score = 0;
    
    // Exact match gets highest score
    if (word == query) {
      return 100000;
    }
    
    // Prefix match is very relevant
    if (word.startsWith(query)) {
      score += 40;
    }
    
    // Substring match is relevant
    if (word.contains(query)) {
      score += 10;
    }
    
    // Penalize for higher Levenshtein distance
    score -= (distance * 3).clamp(0, 40);
    
    return score;
  }

  // Extract all words from the trie for fuzzy matching
  Map<String, Set<String>> _extractAllWords(InMemoryTrieNode node, String prefix) {
    final words = <String, Set<String>>{};
    
    // If this node has IDs, it's the end of a word
    if (node.ids.isNotEmpty) {
      words[prefix] = node.ids;
    }
    
    // Recursively collect words from children
    for (final entry in node.children.entries) {
      final childPrefix = prefix + entry.key;
      words.addAll(_extractAllWords(entry.value, childPrefix));
    }
    
    return words;
  }

  // Levenshtein distance calculation
  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final List<List<int>> dp = List.generate(
      a.length + 1, 
      (_) => List.filled(b.length + 1, 0),
    );
    
    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,         // deletion
          dp[i][j - 1] + 1,         // insertion
          dp[i - 1][j - 1] + cost,  // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    
    return dp[a.length][b.length];
  }
  
  // Index a person
  void addPerson(Person person) {
    insert(person.firstName, person.id);
    insert(person.surname, person.id);
    insert(person.quirk1, person.id);
    insert(person.quirk2, person.id);
    insert(person.resonantArgument, person.id);
  }
  
  // Remove a person from the index
  void removePerson(Person person) {
    remove(person.firstName, person.id);
    remove(person.surname, person.id);
    remove(person.quirk1, person.id);
    remove(person.quirk2, person.id);
    remove(person.resonantArgument, person.id);
  }
  
  // Update a person in the index
  void updatePerson(Person oldPerson, Person newPerson) {
    // If it's the same person (same ID)
    if (oldPerson.id == newPerson.id) {
      // Only update changed fields
      if (oldPerson.firstName != newPerson.firstName) {
        update(oldPerson.firstName, newPerson.firstName, newPerson.id);
      }
      
      if (oldPerson.surname != newPerson.surname) {
        update(oldPerson.surname, newPerson.surname, newPerson.id);
      }
      
      if (oldPerson.quirk1 != newPerson.quirk1) {
        update(oldPerson.quirk1, newPerson.quirk1, newPerson.id);
      }
      
      if (oldPerson.quirk2 != newPerson.quirk2) {
        update(oldPerson.quirk2, newPerson.quirk2, newPerson.id);
      }
      
      if (oldPerson.resonantArgument != newPerson.resonantArgument) {
        update(oldPerson.resonantArgument, newPerson.resonantArgument, newPerson.id);
      }
    } else {
      // Different people, so remove old and add new
      removePerson(oldPerson);
      addPerson(newPerson);
    }
  }
  
  // Index a location
  void addLocation(Location location) {
    insert(location.name, location.id);
    insert(location.blurbText, location.id);
  }
  
  // Remove a location from the index
  void removeLocation(Location location) {
    remove(location.name, location.id);
    remove(location.blurbText, location.id);
  }
  
  // Update a location in the index
  void updateLocation(Location oldLocation, Location newLocation) {
    // If it's the same location (same ID)
    if (oldLocation.id == newLocation.id) {
      // Only update changed fields
      if (oldLocation.name != newLocation.name) {
        update(oldLocation.name, newLocation.name, newLocation.id);
      }
      
      if (oldLocation.blurbText != newLocation.blurbText) {
        update(oldLocation.blurbText, newLocation.blurbText, newLocation.id);
      }
    } else {
      // Different locations, so remove old and add new
      removeLocation(oldLocation);
      addLocation(newLocation);
    }
  }
  
  // Index a shop
  void addShop(Shop shop) {
    addLocation(shop); // Add base location data
    
    // Add shop-specific data
    insert(shop.pro1, shop.id);
    insert(shop.pro2, shop.id);
    insert(shop.con, shop.id);
  }
  
  // Remove a shop from the index
  void removeShop(Shop shop) {
    removeLocation(shop); // Remove base location data
    
    // Remove shop-specific data
    remove(shop.pro1, shop.id);
    remove(shop.pro2, shop.id);
    remove(shop.con, shop.id);
  }
  
  // Update a shop in the index
  void updateShop(Shop oldShop, Shop newShop) {
    // Handle base location updates
    updateLocation(oldShop, newShop);
    
    // If it's the same shop (same ID)
    if (oldShop.id == newShop.id) {
      // Only update changed fields
      if (oldShop.pro1 != newShop.pro1) {
        update(oldShop.pro1, newShop.pro1, newShop.id);
      }
      
      if (oldShop.pro2 != newShop.pro2) {
        update(oldShop.pro2, newShop.pro2, newShop.id);
      }
      
      if (oldShop.con != newShop.con) {
        update(oldShop.con, newShop.con, newShop.id);
      }
    } else {
      // Different shops, so remove old and add new for shop-specific fields
      remove(oldShop.pro1, oldShop.id);
      remove(oldShop.pro2, oldShop.id);
      remove(oldShop.con, oldShop.id);
      
      insert(newShop.pro1, newShop.id);
      insert(newShop.pro2, newShop.id);
      insert(newShop.con, newShop.id);
    }
  }
  
  // Generic method to add any indexable entity
  void addEntity(dynamic entity) {
    if (entity is Person) {
      addPerson(entity);
    } else if (entity is Shop) {
      addShop(entity);
    } else if (entity is Location) {
      addLocation(entity);
    }
  }
  
  // Generic method to remove any indexable entity
  void removeEntity(dynamic entity) {
    if (entity is Person) {
      removePerson(entity);
    } else if (entity is Shop) {
      removeShop(entity);
    } else if (entity is Location) {
      removeLocation(entity);
    }
  }
  
  // Generic method to update any indexable entity
  void updateEntity(dynamic oldEntity, dynamic newEntity) {
    if (oldEntity is Person && newEntity is Person) {
      updatePerson(oldEntity, newEntity);
    } else if (oldEntity is Shop && newEntity is Shop) {
      updateShop(oldEntity, newEntity);
    } else if (oldEntity is Location && newEntity is Location) {
      updateLocation(oldEntity, newEntity);
    }
  }
  
  // Batch index multiple entities
  void indexEntities(List<dynamic> entities) {
    for (final entity in entities) {
      addEntity(entity);
    }
  }
}

// Providers for the search
final peopleSearchProvider = StateNotifierProvider<ReactiveSearchNotifier, InMemoryTrieNode>((ref) {
  return ReactiveSearchNotifier();
});

final locationsSearchProvider = StateNotifierProvider<ReactiveSearchNotifier, InMemoryTrieNode>((ref) {
  return ReactiveSearchNotifier();
});

// Message class for isolate communication
class SearchBuildMessage {
  final SendPort sendPort;
  final List<Person> people;
  final List<Location> locations;

  SearchBuildMessage({
    required this.sendPort,
    required this.people,
    required this.locations,
  });
}

// Background isolate function to build search index (for initial load)
void _buildSearchIndexIsolate(SearchBuildMessage message) {
  try {
    // Data structures to hold search mappings
    final peopleSearchWords = <String, List<String>>{};
    final locationsSearchWords = <String, List<String>>{};
    
    // Process people
    for (final person in message.people) {
      _addToSearchMap(peopleSearchWords, person.firstName, person.id);
      _addToSearchMap(peopleSearchWords, person.surname, person.id);
      _addToSearchMap(peopleSearchWords, person.quirk1, person.id);
      _addToSearchMap(peopleSearchWords, person.quirk2, person.id);
      _addToSearchMap(peopleSearchWords, person.resonantArgument, person.id);
    }
    
    // Process locations
    for (final location in message.locations) {
      _addToSearchMap(locationsSearchWords, location.name, location.id);
      _addToSearchMap(locationsSearchWords, location.blurbText, location.id);
      
      if (location is Shop) {
        _addToSearchMap(locationsSearchWords, location.pro1, location.id);
        _addToSearchMap(locationsSearchWords, location.pro2, location.id);
        _addToSearchMap(locationsSearchWords, location.con, location.id);
      }
    }
    
    // Send result back to main isolate
    message.sendPort.send({
      'people': peopleSearchWords,
      'locations': locationsSearchWords,
      'success': true,
    });
  } catch (e) {
    // Handle any errors
    message.sendPort.send({
      'people': <String, List<String>>{},
      'locations': <String, List<String>>{},
      'success': false,
      'error': e.toString(),
    });
  }
}

// Helper function to add to search map
void _addToSearchMap(Map<String, List<String>> map, String text, String id) {
  if (text.isEmpty) return;
  
  text = text.toLowerCase().trim();
  map.putIfAbsent(text, () => []).add(id);
  
  // Add word parts for partial matching
  final words = text.split(' ');
  for (final word in words) {
    if (word.length > 2) { // Skip very short words
      map.putIfAbsent(word, () => []).add(id);
    }
  }
}

// Initialize search in background
Future<void> initializeSearch({
  required WidgetRef ref,
  required List<Person> people,
  required List<Location> locations,
}) async {
  final searchState = ref.read(searchStateProvider.notifier);
  
  // Skip if already initialized or loading
  if (ref.read(searchStateProvider).isInitialized || 
      ref.read(searchStateProvider).isLoading) {
    return;
  }
  
  // Set loading state
  searchState.setLoading(true);
  
  try {
    // Create communication channel with isolate
    final receivePort = ReceivePort();
    
    // Create message with data
    final message = SearchBuildMessage(
      sendPort: receivePort.sendPort,
      people: people,
      locations: locations,
    );
    
    // Spawn isolate to process data
    await Isolate.spawn(_buildSearchIndexIsolate, message);
    
    // Wait for result
    final result = await receivePort.first as Map<String, dynamic>;
    
    if (result['success'] == true) {
      // If successful, build the tries in main isolate using the data
      final peopleSearch = ref.read(peopleSearchProvider.notifier);
      final locationsSearch = ref.read(locationsSearchProvider.notifier);
      
      // Build people search trie
      final peopleData = result['people'] as Map<String, List<String>>;
      for (final entry in peopleData.entries) {
        for (final id in entry.value) {
          peopleSearch.insert(entry.key, id);
        }
      }
      
      // Build locations search trie
      final locationsData = result['locations'] as Map<String, List<String>>;
      for (final entry in locationsData.entries) {
        for (final id in entry.value) {
          locationsSearch.insert(entry.key, id);
        }
      }
      
      // Mark initialization as complete
      searchState.setInitialized(true);
    } else {
      // Handle error
      searchState.setError(result['error'] ?? "Unknown error building search index");
    }
  } catch (e) {
    // Handle any errors
    searchState.setError("Error initializing search: $e");
  }
}