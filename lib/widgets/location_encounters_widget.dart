import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import '../models/random_encounter_model.dart';
import '../providers/barrel_of_providers.dart';
import '../enums_and_maps.dart';
import '../models/barrel_of_models.dart';
import '../globals.dart';
import '../screens/person_detail_view.dart';

class LocationEncountersWidget extends ConsumerStatefulWidget {
  final LocationType locationType;
  final String locationId; // For filtering roles specific to this location
  final ShopType? shopType; // For filtering encounters by specific shop type
  
  const LocationEncountersWidget({
    super.key,
    required this.locationType,
    required this.locationId,
    this.shopType,
  });

  @override
  ConsumerState<LocationEncountersWidget> createState() => _LocationEncountersWidgetState();
}

class _LocationEncountersWidgetState extends ConsumerState<LocationEncountersWidget> {
  List<RandomEncounter> _displayedEncounters = [];
  List<Map<int, Person>> _encounterPersonMappings = []; // Store the selected people for each encounter by sentence part index
  final Random _random = Random();
  bool _showRoles = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize the provider first
      try {
        await ref.read(randomEncountersProvider.notifier).initialize();
      } catch (e) {
        debugPrint("Error initializing random encounters provider: $e");
      }
      _generateEncounters();
    });
  }

  void _generateEncounters() {
    final allEncounters = ref.read(randomEncountersProvider);
    final locationRoles = ref.read(locationRolesProvider);
    final people = ref.read(peopleProvider);

    // Get all roles available at this specific location from the separate role model
    final availableRoles = locationRoles
        .where((lr) => lr.locationID == widget.locationId)
        .where((lr) => people.any((person) => person.id == lr.myID)) // Make sure person exists
        .map((lr) => lr.myRole)
        .toSet();

    // Filter encounters applicable to this location type
    List<RandomEncounter> applicableEncounters;
    
    if (widget.locationType == LocationType.shop && widget.shopType != null) {
      // For shops, filter by both general shop encounters and shop-type specific encounters
      applicableEncounters = allEncounters.where((encounter) => 
          encounter.applicableLocations.contains(LocationType.shop) ||
          // encounter.applicableLocations.contains(LocationType.street) || // Street encounters work everywhere
          encounter.tags.contains('shop_${widget.shopType!.name}') // Shop type specific encounters
      ).toList();
    } else {
      // For non-shop locations, use the standard filtering
      applicableEncounters = allEncounters.where((encounter) => 
          encounter.applicableLocations.contains(widget.locationType) ||
          encounter.applicableLocations.contains(LocationType.street) // Street encounters work everywhere
      ).toList();
    }

    // Filter encounters that have all required roles available and required quirks
    final viableEncounters = applicableEncounters.where((encounter) {
      return _encounterHasAvailableRoles(encounter, availableRoles) &&
             _encounterHasRequiredQuirks(encounter);
    }).toList();

    // Debug output removed - encounters working!

    // Randomly select up to 6 encounters and generate person mappings
    final selectedEncounters = <RandomEncounter>[];
    final personMappings = <Map<int, Person>>[];
    final encountersToChooseFrom = List<RandomEncounter>.from(viableEncounters);
    final globallyAssignedPeople = <Person>{}; // Track people assigned across all encounters
    
    for (int i = 0; i < 6 && encountersToChooseFrom.isNotEmpty; i++) {
      final randomIndex = _random.nextInt(encountersToChooseFrom.length);
      final encounter = encountersToChooseFrom[randomIndex];
      selectedEncounters.add(encounter);
      
      // Generate person mapping for this encounter, avoiding globally assigned people
      final mapping = _generatePersonMappingForEncounter(encounter, availableRoles, globallyAssignedPeople);
      personMappings.add(mapping);
      
      // Add newly assigned people to the global set
      globallyAssignedPeople.addAll(mapping.values);
      
      encountersToChooseFrom.removeAt(randomIndex); // Avoid duplicates
    }

    setState(() {
      _displayedEncounters = selectedEncounters;
      _encounterPersonMappings = personMappings;
    });
  }

  bool _encounterHasAvailableRoles(RandomEncounter encounter, Set<Role> availableRoles) {
    // Check if all role parts in the encounter have available roles
    for (final part in encounter.sentenceParts) {
      if (part.type == EncounterPartType.role && part.role != null) {
        // Street encounters (LocationType.street) bypass role filtering
        if (encounter.applicableLocations.contains(LocationType.street) && 
            !encounter.applicableLocations.any((loc) => loc != LocationType.street)) {
          continue; // Skip role checking for pure street encounters
        }
        
        if (!_roleIsAvailable(part.role!, availableRoles)) {
          return false; // Required role not available at this location
        }
      }
    }
    return true;
  }

  bool _roleIsAvailable(Role requiredRole, Set<Role> availableRoles) {
    // Direct role match
    if (availableRoles.contains(requiredRole)) {
      return true;
    }
    
    // Role equivalencies based on shop type
    if (widget.shopType != null) {
      switch (widget.shopType!) {
        case ShopType.tavern:
          // In taverns, tavern keepers and owners are interchangeable
          if (requiredRole == Role.tavernKeeper && availableRoles.contains(Role.owner)) {
            return true;
          }
          if (requiredRole == Role.owner && availableRoles.contains(Role.tavernKeeper)) {
            return true;
          }
          break;
          
        case ShopType.temple:
          // In temples, hierophants and owners are interchangeable  
          if (requiredRole == Role.hierophant && availableRoles.contains(Role.owner)) {
            return true;
          }
          if (requiredRole == Role.owner && availableRoles.contains(Role.hierophant)) {
            return true;
          }
          break;
          
        default:
          // No special equivalencies for other shop types
          break;
      }
    }
    
    return false;
  }

  bool _encounterHasRequiredQuirks(RandomEncounter encounter) {
    // If no quirks are required, encounter is viable
    if (encounter.requiredQuirks.isEmpty) {
      return true;
    }

    final people = ref.read(peopleProvider);
    final locationRoles = ref.read(locationRolesProvider);

    // Build role-to-person map for this location using existing logic
    final Map<Role, List<Person>> roleToPersonMap = {};
    
    for (final locationRole in locationRoles) {
      if (locationRole.locationID == widget.locationId) {
        final person = people.firstWhere(
          (p) => p.id == locationRole.myID,
          orElse: () => throw StateError('Person not found for role'),
        );
        
        if (!roleToPersonMap.containsKey(locationRole.myRole)) {
          roleToPersonMap[locationRole.myRole] = [];
        }
        roleToPersonMap[locationRole.myRole]!.add(person);
      }
    }

    // For each role that has required quirks, check if there are people with those quirks
    for (final entry in encounter.requiredQuirks.entries) {
      final requiredRole = entry.key;
      final requiredQuirksList = entry.value;

      // Use the existing helper method to get people with this role (includes equivalencies)
      final peopleWithRole = _getRolePersons(requiredRole, roleToPersonMap);

      // Check if any of these people have ANY of the required quirks for this role
      bool foundPersonWithAnyQuirk = false;
      for (final person in peopleWithRole) {
        final personQuirks = [person.quirk1, person.quirk2];
        
        // Check if this person has any of the required quirks for this role
        final hasAnyQuirk = requiredQuirksList.any((requiredQuirk) => 
          personQuirks.contains(requiredQuirk));
          
        if (hasAnyQuirk) {
          foundPersonWithAnyQuirk = true;
          break;
        }
      }

      // If no person with this role has any required quirks, encounter is not viable
      if (!foundPersonWithAnyQuirk) {
        return false;
      }
    }

    return true;
  }

  void _rerollEncounter(int index) {
    final allEncounters = ref.read(randomEncountersProvider);
    final people = ref.read(peopleProvider);

    // Get available roles (same logic as _generateEncounters) 
    final locationRoles = ref.read(locationRolesProvider);
    final availableRoles = locationRoles
        .where((lr) => lr.locationID == widget.locationId)
        .where((lr) => people.any((person) => person.id == lr.myID)) // Make sure person exists
        .map((lr) => lr.myRole)
        .toSet();

    // Get viable encounters (same logic as _generateEncounters)
    List<RandomEncounter> applicableEncounters;
    
    if (widget.locationType == LocationType.shop && widget.shopType != null) {
      // For shops, filter by both general shop encounters and shop-type specific encounters
      applicableEncounters = allEncounters.where((encounter) => 
          encounter.applicableLocations.contains(LocationType.shop) ||
          // encounter.applicableLocations.contains(LocationType.street) || // Street encounters work everywhere
          encounter.tags.contains('shop_${widget.shopType!.name}') // Shop type specific encounters
      ).toList();
    } else {
      // For non-shop locations, use the standard filtering
      applicableEncounters = allEncounters.where((encounter) => 
          encounter.applicableLocations.contains(widget.locationType) ||
          encounter.applicableLocations.contains(LocationType.street) // Street encounters work everywhere
      ).toList();
    }

    final viableEncounters = applicableEncounters.where((encounter) {
      return _encounterHasAvailableRoles(encounter, availableRoles) &&
             _encounterHasRequiredQuirks(encounter);
    }).toList();

    if (viableEncounters.isNotEmpty) {
      // Simply pick a new random encounter (allow duplicates, they represent different instances)
      final newEncounter = viableEncounters[_random.nextInt(viableEncounters.length)];
      
      setState(() {
        _displayedEncounters[index] = newEncounter;
        // Generate new person mapping for this rerolled encounter
        // Collect people assigned to other encounters to avoid duplicates
        final globallyAssignedPeople = <Person>{};
        for (int i = 0; i < _encounterPersonMappings.length; i++) {
          if (i != index) { // Exclude the encounter we're rerolling
            globallyAssignedPeople.addAll(_encounterPersonMappings[i].values);
          }
        }
        _encounterPersonMappings[index] = _generatePersonMappingForEncounter(newEncounter, availableRoles, globallyAssignedPeople);
      });
    }
  }

  Map<int, Person> _generatePersonMappingForEncounter(RandomEncounter encounter, Set<Role> availableRoles, [Set<Person>? globallyAssignedPeople]) {
    final people = ref.read(peopleProvider);
    final locationRoles = ref.read(locationRolesProvider);
    final Map<int, Person> personMapping = {}; // Map by part index instead of role
    
    // Get people available at this location by role using the separate role model
    final Map<Role, List<Person>> roleToPersonMap = {};
    
    // Find all people who have roles at this location
    for (final locationRole in locationRoles) {
      if (locationRole.locationID == widget.locationId) {
        // Find the person with this role
        final person = people.firstWhere(
          (p) => p.id == locationRole.myID,
          orElse: () => throw StateError('Person not found for role'),
        );
        
        if (!roleToPersonMap.containsKey(locationRole.myRole)) {
          roleToPersonMap[locationRole.myRole] = [];
        }
        roleToPersonMap[locationRole.myRole]!.add(person);
      }
    }
    
    // Generate person mappings for each role needed in this encounter
    for (int partIndex = 0; partIndex < encounter.sentenceParts.length; partIndex++) {
      final part = encounter.sentenceParts[partIndex];
      if (part.type == EncounterPartType.role && part.role != null) {
        // Skip if it's a street encounter with no specific people
        if (encounter.applicableLocations.contains(LocationType.street) && 
            !encounter.applicableLocations.any((loc) => loc != LocationType.street)) {
          continue;
        }
        
        // Allow the same role to appear multiple times with different people
        // Do not skip if the role already exists - assign different people for each occurrence
        
        final availablePeople = _getRolePersons(part.role!, roleToPersonMap);
        if (availablePeople.isNotEmpty) {
          // Filter out people already assigned to other roles in this encounter
          final locallyAssigned = personMapping.values.toSet();
          
          // Filter out people assigned globally across all encounters
          final globallyAssigned = globallyAssignedPeople ?? <Person>{};
          
          // Always prioritize people not already assigned locally within this encounter
          var unassignedPeople = availablePeople.where((person) => !locallyAssigned.contains(person)).toList();
          
          // If no one is unassigned locally, then consider globally assigned people
          if (unassignedPeople.isNotEmpty) {
            // Further filter to avoid globally assigned people if possible
            final globallyUnassigned = unassignedPeople.where((person) => !globallyAssigned.contains(person)).toList();
            if (globallyUnassigned.isNotEmpty) {
              unassignedPeople = globallyUnassigned;
            }
          }
          
          // Filter for people with required quirks if any are specified for this role
          final requiredQuirks = encounter.requiredQuirks[part.role!];
          if (requiredQuirks != null && requiredQuirks.isNotEmpty) {
            final peopleWithRequiredQuirks = unassignedPeople.where((person) {
              final personQuirks = [person.quirk1, person.quirk2];
              return requiredQuirks.any((requiredQuirk) => 
                personQuirks.contains(requiredQuirk));
            }).toList();
            
            // If we found people with required quirks, prefer them
            if (peopleWithRequiredQuirks.isNotEmpty) {
              unassignedPeople = peopleWithRequiredQuirks;
            }
          }
          
          // Final fallback: any available person (only if absolutely no alternatives)
          final peopleToChooseFrom = unassignedPeople.isNotEmpty ? unassignedPeople : availablePeople;
          
          // Select a random person for this role in this encounter
          final selectedPerson = peopleToChooseFrom[_random.nextInt(peopleToChooseFrom.length)];
          
          // Final safety check: if this person is already assigned to another role in this encounter,
          // try to find a different person (this should never happen with the logic above, but just in case)
          if (locallyAssigned.contains(selectedPerson) && peopleToChooseFrom.length > 1) {
            final alternativePeople = peopleToChooseFrom.where((person) => !locallyAssigned.contains(person)).toList();
            if (alternativePeople.isNotEmpty) {
              final alternativePerson = alternativePeople[_random.nextInt(alternativePeople.length)];
              personMapping[partIndex] = alternativePerson;
            } else {
              personMapping[partIndex] = selectedPerson; // Fallback
            }
          } else {
            personMapping[partIndex] = selectedPerson;
          }
        }
      }
    }
    
    return personMapping;
  }

  Widget _buildEncounterWidget(RandomEncounter encounter, int encounterIndex) {
    final personMapping = encounterIndex < _encounterPersonMappings.length 
        ? _encounterPersonMappings[encounterIndex]
        : <int, Person>{};

    // Build text spans with clickable person names
    List<InlineSpan> textSpans = [];
    
    for (int partIndex = 0; partIndex < encounter.sentenceParts.length; partIndex++) {
      final part = encounter.sentenceParts[partIndex];
      if (part.type == EncounterPartType.role && part.role != null) {
        // For street encounters, we might not have specific people, so use generic terms
        if (encounter.applicableLocations.contains(LocationType.street) && 
            !encounter.applicableLocations.any((loc) => loc != LocationType.street)) {
          textSpans.add(TextSpan(text: part.toString()));
        } else if (personMapping.containsKey(partIndex)) {
          // Use the pre-selected person for this part index in this encounter
          final selectedPerson = personMapping[partIndex]!;
          
          // Add the clickable person name with optional role and proper spacing
          final displayText = _showRoles 
              ? ' ${selectedPerson.firstName} ${selectedPerson.surname} (${part.role!.name}) '
              : ' ${selectedPerson.firstName} ${selectedPerson.surname} ';
              
          textSpans.add(
            TextSpan(
              text: displayText,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  navigatorKey.currentState!.restorablePushNamed(
                    PersonDetailView.routeName,
                    arguments: {'myID': selectedPerson.id},
                  );
                },
            ),
          );
        } else {
          textSpans.add(TextSpan(text: part.toString()));
        }
      } else {
        textSpans.add(TextSpan(text: part.content));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: textSpans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedEncounters.isEmpty) {
      // Show a helpful message instead of hiding completely
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Random Encounters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.shopType != null 
                    ? "No encounters available for ${_shopTypeDisplayName(widget.shopType!)} shops yet. Create some in the Encounter Builder!"
                    : "No encounters available for this location type yet. Create some in the Encounter Builder!",
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              // Debug information
              const SizedBox(height: 8),
              Text(
                "Debug: Looking for shop_${widget.shopType?.name ?? 'unknown'} encounters at ${widget.locationId}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final allEncounters = ref.read(randomEncountersProvider);
                  final people = ref.read(peopleProvider);
                  
                  final availableRoles = <Role>{};
                  
                  // Find people who have roles at this specific location
                  for (final person in people) {
                    for (final locationRole in person.myRoles) {
                      if (locationRole.locationID == widget.locationId) {
                        availableRoles.add(locationRole.myRole);
                      }
                    }
                  }
                  
                  final shopTagEncounters = allEncounters.where((e) => e.tags.contains('shop_${widget.shopType?.name ?? ''}')).length;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total encounters: ${allEncounters.length}",
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                      Text(
                        "Shop ${widget.shopType?.name} encounters: $shopTagEncounters",
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                      Text(
                        "Available roles: ${availableRoles.map((r) => r.name).join(', ')}",
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories, size: 18),
                const SizedBox(width: 8),
                const Text(
                  "Random Encounters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Role toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Show roles",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: _showRoles,
                      onChanged: (value) {
                        setState(() {
                          _showRoles = value;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._displayedEncounters.asMap().entries.map((entry) {
              final index = entry.key;
              final encounter = entry.value;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dice with dots for rerolling
                    GestureDetector(
                      onTap: () => _rerollEncounter(index),
                      child: _buildDiceIcon(index + 1),
                    ),
                    const SizedBox(width: 8),
                    
                    // Encounter text with clickable names
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEncounterWidget(encounter, index),
                          // Show rarity indicator for rare encounters
                          if (encounter.rarity != EncounterRarity.common)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: encounter.rarity.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                encounter.rarity.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: encounter.rarity.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Person> _getRolePersons(Role role, Map<Role, List<Person>> roleToPersonMap) {
    // Direct role match
    if (roleToPersonMap.containsKey(role) && roleToPersonMap[role]!.isNotEmpty) {
      return roleToPersonMap[role]!;
    }
    
    // Role equivalencies - combine people from equivalent roles
    List<Person> equivalentPeople = [];
    
    if (widget.shopType != null) {
      switch (widget.shopType!) {
        case ShopType.tavern:
          if (role == Role.tavernKeeper) {
            // Include owners as potential tavern keepers
            if (roleToPersonMap.containsKey(Role.owner)) {
              equivalentPeople.addAll(roleToPersonMap[Role.owner]!);
            }
          } else if (role == Role.owner) {
            // Include tavern keepers as potential owners
            if (roleToPersonMap.containsKey(Role.tavernKeeper)) {
              equivalentPeople.addAll(roleToPersonMap[Role.tavernKeeper]!);
            }
          }
          break;
          
        case ShopType.temple:
          if (role == Role.hierophant) {
            // Include owners as potential hierophants
            if (roleToPersonMap.containsKey(Role.owner)) {
              equivalentPeople.addAll(roleToPersonMap[Role.owner]!);
            }
          } else if (role == Role.owner) {
            // Include hierophants as potential owners
            if (roleToPersonMap.containsKey(Role.hierophant)) {
              equivalentPeople.addAll(roleToPersonMap[Role.hierophant]!);
            }
          }
          break;
          
        default:
          // No equivalencies for other shop types
          break;
      }
    }
    
    return equivalentPeople;
  }

  String _shopTypeDisplayName(ShopType shopType) {
    switch (shopType) {
      case ShopType.tavern:
        return 'Tavern';
      case ShopType.clothier:
        return 'Clothier';
      case ShopType.smith:
        return 'Smith';
      case ShopType.jeweler:
        return 'Jeweler';
      case ShopType.herbalist:
        return 'Herbalist';
      case ShopType.temple:
        return 'Temple';
      case ShopType.generalStore:
        return 'General Store';
      case ShopType.magic:
        return 'Magic Shop';
    }
  }

  Widget _buildDiceIcon(int number) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.shade700, width: 1),
      ),
      child: CustomPaint(
        painter: DicePainter(number),
      ),
    );
  }
}

class DicePainter extends CustomPainter {
  final int number;
  
  DicePainter(this.number);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final double dotRadius = size.width * 0.08;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double quarterX = size.width / 4;
    final double quarterY = size.height / 4;
    final double threeQuarterX = size.width * 0.75;
    final double threeQuarterY = size.height * 0.75;
    
    switch (number) {
      case 1:
        // Single center dot
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, dotPaint);
        break;
        
      case 2:
        // Two diagonal dots
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, threeQuarterY), dotRadius, dotPaint);
        break;
        
      case 3:
        // Three diagonal dots
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, threeQuarterY), dotRadius, dotPaint);
        break;
        
      case 4:
        // Four corner dots
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(quarterX, threeQuarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, threeQuarterY), dotRadius, dotPaint);
        break;
        
      case 5:
        // Four corners plus center
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(centerX, centerY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(quarterX, threeQuarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, threeQuarterY), dotRadius, dotPaint);
        break;
        
      case 6:
        // Six dots in two columns
        canvas.drawCircle(Offset(quarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(quarterX, centerY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(quarterX, threeQuarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, quarterY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, centerY), dotRadius, dotPaint);
        canvas.drawCircle(Offset(threeQuarterX, threeQuarterY), dotRadius, dotPaint);
        break;
        
      default:
        // Fallback - just show the number
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas, 
          Offset(
            (size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2,
          ),
        );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is DicePainter && oldDelegate.number != number;
  }
}