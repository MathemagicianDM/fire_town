import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../providers/buffered_provider.dart';
import "../enums_and_maps.dart";
import 'package:flutter/foundation.dart';
import 'barrel_of_models.dart';

// Base provider for relationships
final _relationshipsBaseProvider = 
    StateNotifierProvider<ServiceProviderListFireStore<Node>, List<Node>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return ServiceProviderListFireStore<Node>(
    firestoreService,
    ListType.relationship, // Make sure to add this to your ListType enum
    (json) => Node.fromJson2(json),
    (node) => node.toJson(),
    ref,
    [], // Start with empty list
  );
});

// Public buffered provider for relationships
final relationshipsProvider = 
    StateNotifierProvider<RelationshipBufferedProvider, List<Node>>((ref) {
  final baseNotifier = ref.watch(_relationshipsBaseProvider.notifier);
  
  return RelationshipBufferedProvider(baseNotifier, []);
});

// Extended BufferedProviderListFireStore with relationship-specific functionality
class RelationshipBufferedProvider extends BufferedProviderListFireStore<Node> {
  RelationshipBufferedProvider(
    super.baseNotifier, 
    super.initialState
  );

  // Count a person's partners
  int countPartners(String personId) {
    final index = state.indexWhere((node) => node.id == personId);
    if (index == -1) {
      return 0;
    }
    return state[index].allPartners.length;
  }
  
  // Get or create a node for a person (prevents duplicates)
  Node _getOrCreateNode(String personId) {
    final index = state.indexWhere((node) => node.id == personId);
    if (index != -1) {
      return state[index];
    }
    
    // Create new node
    final newNode = Node(id: personId, relPairs: {});
    add(newNode);
    return newNode;
  }

  // Add a one-way relationship
  void addRelationship(String person1, String person2, RelationshipType relationship) {
    final index = state.indexWhere((node) => node.id == person1);
    
    if (index == -1) {
      // Person doesn't exist, create new node
      final newNode = Node(
        id: person1, 
        relPairs: {Edge(you: person2, iAmYour: relationship)}
      );
      add(newNode);
    } else {
      // Person exists, add relationship
      final currentNode = state[index];
      final updatedNode = currentNode.addRelationship(person2, relationship);
      
      // Only update if there's a change
      if (!setEquals(currentNode.relPairs, updatedNode.relPairs)) {
        replace(currentNode, updatedNode);
      }
    }
  }

  // Ensure a node exists for a person (safe way to add nodes)
  void ensureNodeExists(String personId) {
    if (!state.any((node) => node.id == personId)) {
      final newNode = Node(id: personId, relPairs: {});
      add(newNode);
    }
  }
  
  // Add a two-way symmetric relationship
  void addSymmetricRelationship(
    String person1, 
    String person2, 
    RelationshipType symmetricRelationship
  ) {
    addRelationship(person1, person2, symmetricRelationship);
    addRelationship(person2, person1, symmetricRelationship);
  }
  
  // Remove a one-way relationship
  void removeRelationship(String person1, String person2, RelationshipType relationship) {
    final index = state.indexWhere((node) => node.id == person1);
    
    if (index != -1) {
      final currentNode = state[index];
      final updatedNode = currentNode.removeRelationship(person2, relationship);
      
      if (!setEquals(currentNode.relPairs, updatedNode.relPairs)) {
        replace(currentNode, updatedNode);
      }
    }
  }
  
  // Remove a two-way symmetric relationship
  void removeSymmetricRelationship(
    String person1, 
    String person2, 
    RelationshipType symmetricRelationship
  ) {
    removeRelationship(person1, person2, symmetricRelationship);
    removeRelationship(person2, person1, symmetricRelationship);
  }
  
  // Make two people exes (remove partner relationship, add ex relationship)
  void makeExes(String person1, String person2) {
    removeSymmetricRelationship(person1, person2, RelationshipType.partner);
    addSymmetricRelationship(person1, person2, RelationshipType.ex);
  }
  
  // Add parent-child relationship
  void addParentChild(String parent, String child) {
    addRelationship(parent, child, RelationshipType.parent);
    addRelationship(child, parent, RelationshipType.child);
  }
  
  // Find all relationships of specified types for a person
  List<String> findRelationshipsOfType(String personId, Set<RelationshipType> relationshipTypes) {
    final index = state.indexWhere((node) => node.id == personId);
    
    if (index == -1) {
      return [];
    }
    
    final node = state[index];
    return node.relPairs
        .where((edge) => relationshipTypes.contains(edge.iAmYour))
        .map((edge) => edge.you)
        .toList();
  }
  
  // Make siblings based on common parents
  void findAndMakeSiblings(String childId) {
    final childIndex = state.indexWhere((node) => node.id == childId);
    
    if (childIndex == -1) return;
    
    final child = state[childIndex];
    
    // Find parents
    final parents = child.relPairs
        .where((edge) => edge.iAmYour == RelationshipType.parent)
        .map((edge) => edge.you)
        .toList();
    
    // Find all children of those parents
    final siblings = <String>{};
    
    for (final parentId in parents) {
      final parentIndex = state.indexWhere((node) => node.id == parentId);
      
      if (parentIndex != -1) {
        final parent = state[parentIndex];
        
        // Add all children except the original child
        siblings.addAll(
          parent.relPairs
              .where((edge) => edge.iAmYour == RelationshipType.child && edge.you != childId)
              .map((edge) => edge.you)
        );
      }
    }
    
    // Make sibling relationships
    for (final siblingId in siblings) {
      addSymmetricRelationship(childId, siblingId, RelationshipType.sibling);
    }
  }
  
  // Replace all nodes at once (useful for bulk operations)
  void replaceAllNodes(List<Node> newNodes) {
    // First clear the list without committing
    final newState = <Node>[];
    state = newState;
    
    // Then add all the new nodes
    for (final node in newNodes) {
      add(node);
    }
  }
  
  // Remove duplicate nodes (merge their relationships)
  void deduplicateNodes() {
    final Map<String, Node> uniqueNodes = {};
    final List<Node> duplicates = [];
    
    // Find duplicates and collect unique nodes
    for (final node in state) {
      if (uniqueNodes.containsKey(node.id)) {
        // This is a duplicate, merge its relationships with the existing node
        final existingNode = uniqueNodes[node.id]!;
        final mergedRelPairs = <Edge>{}..addAll(existingNode.relPairs)..addAll(node.relPairs);
        uniqueNodes[node.id] = Node(id: node.id, relPairs: mergedRelPairs);
        duplicates.add(node);
      } else {
        uniqueNodes[node.id] = node;
      }
    }
    
    // Remove duplicates and replace with merged nodes if any were found
    if (duplicates.isNotEmpty) {
      // Clear and rebuild with unique nodes only
      final uniqueNodesList = uniqueNodes.values.toList();
      replaceAllNodes(uniqueNodesList);
      
      debugPrint("Removed ${duplicates.length} duplicate relationship nodes");
    }
  }
}