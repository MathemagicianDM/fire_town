// Description template constants and utility functions

/// Predefined ancestry groups for template filtering
/// These groups can be referenced in templates to avoid manually listing every ancestry
class AncestryGroups {
  // Universal group - all ancestries
  static const String all = "all";
  
  // Physical trait groups
  static const String hasHair = "has_hair";
  static const String hasBeard = "has_beard"; 
  static const String feathered = "feathered";
  static const String scaled = "scaled";
  static const String furred = "furred";
  static const String humanoid = "humanoid";
  static const String bestial = "bestial";
  static const String elemental = "elemental";
  
  /// Default ancestry group mappings
  /// You can customize these based on your actual ancestries
  static const Map<String, List<String>> defaultMappings = {
    hasHair: [
      'human', 'dwarf', 'elf', 'halfling', 'gnome', 'orc', 'half-orc', 
      'tiefling', 'aasimar', 'genasi', 'goliath', 'firbolg'
    ],
    hasBeard: [
      'human', 'dwarf', 'orc', 'half-orc', 'goliath', 'firbolg'
      // Note: elves traditionally don't grow beards in most fantasy
    ],
    feathered: [
      'birdfolk', 'aarakocra', 'kenku', 'owlin', 'phoenix-kin'
    ],
    scaled: [
      'dragonborn', 'lizardfolk', 'kobold', 'yuan-ti', 'naga'
    ],
    furred: [
      'tabaxi', 'leonin', 'harengon', 'loxodon', 'minotaur'
    ],
    humanoid: [
      'human', 'dwarf', 'elf', 'halfling', 'gnome', 'orc', 'half-orc',
      'tiefling', 'aasimar', 'genasi', 'goliath', 'firbolg'
    ],
    bestial: [
      'tabaxi', 'leonin', 'harengon', 'loxodon', 'minotaur', 
      'birdfolk', 'aarakocra', 'kenku', 'owlin'
    ],
    elemental: [
      'genasi', 'phoenix-kin', 'triton'
    ],
  };
  
  /// Get all group names
  static List<String> get allGroups => defaultMappings.keys.toList()..add(all);
  
  /// Check if an ancestry belongs to a group
  static bool ancestryInGroup(String ancestry, String group, List<String> allAncestries) {
    if (group == all) return true;
    
    final groupAncestries = defaultMappings[group];
    if (groupAncestries == null) return false;
    
    return groupAncestries.contains(ancestry.toLowerCase());
  }
  
  /// Get all ancestries that belong to specific groups
  static List<String> getAncestriesForGroups(
    List<String> includeGroups, 
    List<String> excludeGroups, 
    List<String> allAncestries
  ) {
    final result = <String>[];
    
    for (final ancestry in allAncestries) {
      // Check if ancestry should be included
      bool shouldInclude = false;
      for (final group in includeGroups) {
        if (ancestryInGroup(ancestry, group, allAncestries)) {
          shouldInclude = true;
          break;
        }
      }
      
      // Check if ancestry should be excluded
      bool shouldExclude = false;
      for (final group in excludeGroups) {
        if (ancestryInGroup(ancestry, group, allAncestries)) {
          shouldExclude = true;
          break;
        }
      }
      
      if (shouldInclude && !shouldExclude) {
        result.add(ancestry);
      }
    }
    
    return result;
  }
}

/// Tag categories for preventing description conflicts
class DescriptionTags {
  // Physical trait tags
  static const String hair = "hair";
  static const String facialHair = "facial_hair";
  static const String eyes = "eyes";
  static const String build = "build";
  static const String hands = "hands";
  static const String voice = "voice";
  static const String movement = "movement";
  static const String ears = "ears";
  static const String scars = "scars";
  
  // Ancestry-specific physical tags
  static const String plumage = "plumage";
  static const String beak = "beak";
  static const String tusks = "tusks";
  static const String scales = "scales";
  static const String fur = "fur";
  static const String tail = "tail";
  static const String wings = "wings";
  static const String horns = "horns";
  
  // Clothing tags
  static const String head = "head";
  static const String torso = "torso";
  static const String arms = "arms";
  static const String hands_clothing = "hands_clothing";
  static const String waist = "waist";
  static const String legs = "legs";
  static const String feet = "feet";
  static const String jewelry = "jewelry";
  static const String accessories = "accessories";
  
  /// Get all physical trait tags
  static List<String> get physicalTags => [
    hair, facialHair, eyes, build, hands, voice, movement, ears, scars,
    plumage, beak, tusks, scales, fur, tail, wings, horns
  ];
  
  /// Get all clothing tags
  static List<String> get clothingTags => [
    head, torso, arms, hands_clothing, waist, legs, feet, jewelry, accessories
  ];
  
  /// Get all tags
  static List<String> get allTags => [...physicalTags, ...clothingTags];
}