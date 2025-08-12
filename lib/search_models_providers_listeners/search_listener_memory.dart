// search_listeners.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/person_model.dart';
import '../models/town_extension/town_locations.dart';
import 'search_memory.dart';
// import 'providers.dart';
import "../providers/barrel_of_providers.dart";
/// Set up listeners to keep search index in sync with data changes
class SearchSynchronizer {
  final ProviderContainer container;
  List<ProviderSubscription> _subscriptions = [];
  
  SearchSynchronizer(this.container);
  
  /// Initialize all listeners
  void initialize() {
    _setupPeopleListeners();
    _setupLocationListeners();
  }
  
  /// Dispose all listeners
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions = [];
  }
  
  /// Set up listeners for people collection changes
  void _setupPeopleListeners() {
    // Listen to changes in the people list
    final peopleList = container.listen<List<Person>>(
      peopleProvider,
      (previous, next) {
        _handlePeopleListChanges(previous ?? [], next);
      },
    );
    
    _subscriptions.add(peopleList);
  }
  
  /// Set up listeners for location collection changes
  void _setupLocationListeners() {
    // Listen to changes in the locations list
    final locationsList = container.listen<List<Location>>(
      locationsProvider,
      (previous, next) {
        _handleLocationListChanges(previous ?? [], next);
      },
    );
    
    _subscriptions.add(locationsList);
  }
  
  /// Handle changes in the people list by updating the search index
  void _handlePeopleListChanges(List<Person> previous, List<Person> current) {
    final peopleSearch = container.read(peopleSearchProvider.notifier);
    
    // Skip if search isn't initialized yet
    if (!container.read(searchStateProvider).isInitialized) return;
    
    // Find added people (in current but not in previous)
    final previousIds = previous.map((p) => p.id).toSet();
    for (final person in current) {
      if (!previousIds.contains(person.id)) {
        // This is a new person, add to search
        peopleSearch.addPerson(person);
      }
    }
    
    // Find removed people (in previous but not in current)
    final currentIds = current.map((p) => p.id).toSet();
    for (final person in previous) {
      if (!currentIds.contains(person.id)) {
        // This person was removed, remove from search
        peopleSearch.removePerson(person);
      }
    }
    
    // Find and handle updated people
    for (final oldPerson in previous) {
      final newPersonIndex = current.indexWhere((p) => p.id == oldPerson.id);
      if (newPersonIndex >= 0) {
        final newPerson = current[newPersonIndex];
        
        // Check if any indexed fields changed
        if (_isPersonChanged(oldPerson, newPerson)) {
          peopleSearch.updatePerson(oldPerson, newPerson);
        }
      }
    }
  }
  
  /// Check if searchable fields in a person have changed
  bool _isPersonChanged(Person oldPerson, Person newPerson) {
    return oldPerson.firstName != newPerson.firstName ||
           oldPerson.surname != newPerson.surname ||
           oldPerson.quirk1 != newPerson.quirk1 ||
           oldPerson.quirk2 != newPerson.quirk2 ||
           oldPerson.resonantArgument != newPerson.resonantArgument;
  }
  
  /// Handle changes in the locations list by updating the search index
  void _handleLocationListChanges(List<Location> previous, List<Location> current) {
    final locationsSearch = container.read(locationsSearchProvider.notifier);
    
    // Skip if search isn't initialized yet
    if (!container.read(searchStateProvider).isInitialized) return;
    
    // Find added locations (in current but not in previous)
    final previousIds = previous.map((l) => l.id).toSet();
    for (final location in current) {
      if (!previousIds.contains(location.id)) {
        // This is a new location, add to search
        if (location is Shop) {
          locationsSearch.addShop(location);
        } else {
          locationsSearch.addLocation(location);
        }
      }
    }
    
    // Find removed locations (in previous but not in current)
    final currentIds = current.map((l) => l.id).toSet();
    for (final location in previous) {
      if (!currentIds.contains(location.id)) {
        // This location was removed, remove from search
        if (location is Shop) {
          locationsSearch.removeShop(location);
        } else {
          locationsSearch.removeLocation(location);
        }
      }
    }
    
    // Find and handle updated locations
    for (final oldLocation in previous) {
      final newLocationIndex = current.indexWhere((l) => l.id == oldLocation.id);
      if (newLocationIndex >= 0) {
        final newLocation = current[newLocationIndex];
        
        // Handle different location types appropriately
        if (oldLocation is Shop && newLocation is Shop) {
          if (_isShopChanged(oldLocation, newLocation)) {
            locationsSearch.updateShop(oldLocation, newLocation);
          }
        } else if (_isLocationChanged(oldLocation, newLocation)) {
            locationsSearch.updateLocation(oldLocation, newLocation);
          }
      }
    }
  }
  
  /// Check if searchable fields in a location have changed
  bool _isLocationChanged(Location oldLocation, Location newLocation) {
    return oldLocation.name != newLocation.name ||
           oldLocation.blurbText != newLocation.blurbText;
  }
  
  /// Check if searchable fields in a shop have changed
  bool _isShopChanged(Shop oldShop, Shop newShop) {
    return _isLocationChanged(oldShop, newShop) ||
           oldShop.pro1 != newShop.pro1 ||
           oldShop.pro2 != newShop.pro2 ||
           oldShop.con != newShop.con;
  }
}

/// Provider for the search synchronizer
final searchSynchronizerProvider = Provider<SearchSynchronizer>((ref) {
  final container = ProviderContainer(parent: ref.container);
  final synchronizer = SearchSynchronizer(container);
  
  // Initialize listeners when the provider is created
  synchronizer.initialize();
  
  // Clean up when the provider is disposed
  ref.onDispose(() {
    synchronizer.dispose();
    container.dispose();
  });
  
  return synchronizer;
});

/// Helper functions to manually update search index when making changes

/// Update search index after adding a person
void updateSearchAfterAddingPerson(WidgetRef ref, Person person) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Add to search index
  final peopleSearch = ref.read(peopleSearchProvider.notifier);
  peopleSearch.addPerson(person);
}

/// Update search index after editing a person
void updateSearchAfterEditingPerson(WidgetRef ref, Person oldPerson, Person newPerson) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Update in search index
  final peopleSearch = ref.read(peopleSearchProvider.notifier);
  peopleSearch.updatePerson(oldPerson, newPerson);
}

/// Update search index after removing a person
void updateSearchAfterRemovingPerson(WidgetRef ref, Person person) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Remove from search index
  final peopleSearch = ref.read(peopleSearchProvider.notifier);
  peopleSearch.removePerson(person);
}

/// Update search index after adding a location
void updateSearchAfterAddingLocation(WidgetRef ref, Location location) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Add to search index
  final locationsSearch = ref.read(locationsSearchProvider.notifier);
  
  if (location is Shop) {
    locationsSearch.addShop(location);
  } else {
    locationsSearch.addLocation(location);
  }
}

/// Update search index after editing a location
void updateSearchAfterEditingLocation(WidgetRef ref, Location oldLocation, Location newLocation) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Update in search index
  final locationsSearch = ref.read(locationsSearchProvider.notifier);
  
  if (oldLocation is Shop && newLocation is Shop) {
    locationsSearch.updateShop(oldLocation, newLocation);
  } else {
    locationsSearch.updateLocation(oldLocation, newLocation);
  }
}

/// Update search index after removing a location
void updateSearchAfterRemovingLocation(WidgetRef ref, Location location) {
  // Skip if search isn't initialized
  if (!ref.read(searchStateProvider).isInitialized) return;
  
  // Remove from search index
  final locationsSearch = ref.read(locationsSearchProvider.notifier);
  
  if (location is Shop) {
    locationsSearch.removeShop(location);
  } else {
    locationsSearch.removeLocation(location);
  }
}


void initializeSearchListeners(WidgetRef ref) {
  // Only initialize if not already done
  if (!ref.exists(searchSynchronizerProvider)) {
    // This read will trigger the creation and initialization
    ref.read(searchSynchronizerProvider);
  }
}