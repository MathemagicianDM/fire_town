import 'dart:math';
import '../models/description_template_model.dart';
import '../models/description_constants.dart';
import '../models/person_model.dart';
import '../models/character_trait_model.dart';
import '../models/town_extension/town_locations.dart';
import '../enums_and_maps.dart';

/// Service for generating character and shop descriptions using templates
class DescriptionService {
  final Random _random = Random();
  
  /// Generate a physical description for a person using available templates
  String? generatePhysicalDescription({
    required Person person,
    required List<PhysicalTemplate> templates,
    required List<String> allAncestries,
    List<String>? excludeTags,
  }) {
    // Filter templates that match the person's ancestry and roles
    final applicableTemplates = _filterPhysicalTemplates(
      templates: templates,
      ancestry: person.ancestry,
      roles: person.myRoles.map((lr) => lr.myRole).toList(),
      allAncestries: allAncestries,
    );
    
    if (applicableTemplates.isEmpty) return null;
    
    // Get already used tags from existing traits to prevent conflicts
    final existingTags = person.physicalTraits.map((trait) => trait.tag).toSet();
    
    // Combine existing tags with manually excluded tags
    final allExcludedTags = <String>[...(excludeTags ?? []), ...existingTags];
    
    // Group templates by tags to prevent conflicts
    final availableTemplates = _filterByExcludedTags(applicableTemplates, allExcludedTags);
    
    if (availableTemplates.isEmpty) return null;
    
    // Select a random template and generate description
    final selectedTemplate = availableTemplates[_random.nextInt(availableTemplates.length)];
    
    return _processTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      person: person,
      variables: selectedTemplate.variables,
    );
  }
  
  /// Generate a clothing description for a person using available templates
  String? generateClothingDescription({
    required Person person,
    required List<ClothingTemplate> templates,
    required List<String> allAncestries,
    List<String>? excludeTags,
  }) {
    // Filter templates that match the person's ancestry and roles
    final applicableTemplates = _filterClothingTemplates(
      templates: templates,
      ancestry: person.ancestry,
      roles: person.myRoles.map((lr) => lr.myRole).toList(),
      allAncestries: allAncestries,
    );
    
    if (applicableTemplates.isEmpty) return null;
    
    // Get already used tags from existing traits to prevent conflicts
    final existingTags = person.clothingTraits.map((trait) => trait.tag).toSet();
    
    // Combine existing tags with manually excluded tags
    final allExcludedTags = <String>[...(excludeTags ?? []), ...existingTags];
    
    // Group templates by tags to prevent conflicts
    final availableTemplates = _filterByExcludedTags(applicableTemplates, allExcludedTags);
    
    if (availableTemplates.isEmpty) return null;
    
    // Select a random template and generate description
    final selectedTemplate = availableTemplates[_random.nextInt(availableTemplates.length)];
    
    return _processTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      person: person,
      variables: selectedTemplate.variables,
    );
  }
  
  /// Generate individual physical trait by rerolling a specific tag category
  String? rerollPhysicalTrait({
    required Person person,
    required List<PhysicalTemplate> templates,
    required List<String> allAncestries,
    required String tag,
  }) {
    // Filter templates that only have the specified tag
    final tagTemplates = templates.where((t) => 
      t.tag == tag && 
      _matchesAncestry(t, person.ancestry, allAncestries) &&
      _matchesRole(t, person.myRoles.map((lr) => lr.myRole).toList())
    ).toList();
    
    if (tagTemplates.isEmpty) return null;
    
    final selectedTemplate = tagTemplates[_random.nextInt(tagTemplates.length)];
    
    return _processTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      person: person,
      variables: selectedTemplate.variables,
    );
  }
  
  /// Generate individual clothing trait by rerolling a specific tag category
  String? rerollClothingTrait({
    required Person person,
    required List<ClothingTemplate> templates,
    required List<String> allAncestries,
    required String tag,
  }) {
    // Filter templates that only have the specified tag
    final tagTemplates = templates.where((t) => 
      t.tag == tag && 
      _matchesAncestry(t, person.ancestry, allAncestries) &&
      _matchesRole(t, person.myRoles.map((lr) => lr.myRole).toList())
    ).toList();
    
    if (tagTemplates.isEmpty) return null;
    
    final selectedTemplate = tagTemplates[_random.nextInt(tagTemplates.length)];
    
    return _processTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      person: person,
      variables: selectedTemplate.variables,
    );
  }
  
  /// Generate a list of individual physical traits using available templates
  List<CharacterTrait> generatePhysicalTraits({
    required Person person,
    required List<PhysicalTemplate> templates,
    required List<String> allAncestries,
    int maxTraits = 3,
  }) {
    final List<CharacterTrait> traits = [];
    final Set<String> usedTags = {};
    
    // Filter templates that match the person's ancestry and roles
    final applicableTemplates = _filterPhysicalTemplates(
      templates: templates,
      ancestry: person.ancestry,
      roles: person.myRoles.map((lr) => lr.myRole).toList(),
      allAncestries: allAncestries,
    );
    
    // Group templates by tag to ensure variety
    final Map<String, List<PhysicalTemplate>> templatesByTag = {};
    for (final template in applicableTemplates) {
      if (!templatesByTag.containsKey(template.tag)) {
        templatesByTag[template.tag] = [];
      }
      templatesByTag[template.tag]!.add(template);
    }
    
    // Generate traits, ensuring no duplicate tags
    final availableTags = templatesByTag.keys.toList()..shuffle(_random);
    
    for (final tag in availableTags) {
      if (traits.length >= maxTraits) break;
      if (usedTags.contains(tag)) continue;
      
      final tagTemplates = templatesByTag[tag]!;
      final selectedTemplate = tagTemplates[_random.nextInt(tagTemplates.length)];
      
      final description = _processTemplateString(
        template: selectedTemplate.templates.first,
        person: person,
        variables: selectedTemplate.variables,
      );
      
      if (description != null) {
        traits.add(CharacterTrait.generate(
          tag: tag,
          description: description,
          type: 'physical',
        ));
        usedTags.add(tag);
      }
    }
    
    return traits;
  }
  
  /// Generate a list of individual clothing traits using available templates
  List<CharacterTrait> generateClothingTraits({
    required Person person,
    required List<ClothingTemplate> templates,
    required List<String> allAncestries,
    int maxTraits = 2,
  }) {
    final List<CharacterTrait> traits = [];
    final Set<String> usedTags = {};
    
    // Filter templates that match the person's ancestry and roles
    final applicableTemplates = _filterClothingTemplates(
      templates: templates,
      ancestry: person.ancestry,
      roles: person.myRoles.map((lr) => lr.myRole).toList(),
      allAncestries: allAncestries,
    );
    
    // Group templates by tag to ensure variety
    final Map<String, List<ClothingTemplate>> templatesByTag = {};
    for (final template in applicableTemplates) {
      if (!templatesByTag.containsKey(template.tag)) {
        templatesByTag[template.tag] = [];
      }
      templatesByTag[template.tag]!.add(template);
    }
    
    // Generate traits, ensuring no duplicate tags
    final availableTags = templatesByTag.keys.toList()..shuffle(_random);
    
    for (final tag in availableTags) {
      if (traits.length >= maxTraits) break;
      if (usedTags.contains(tag)) continue;
      
      final tagTemplates = templatesByTag[tag]!;
      final selectedTemplate = tagTemplates[_random.nextInt(tagTemplates.length)];
      
      final description = _processTemplateString(
        template: selectedTemplate.templates.first,
        person: person,
        variables: selectedTemplate.variables,
      );
      
      if (description != null) {
        traits.add(CharacterTrait.generate(
          tag: tag,
          description: description,
          type: 'clothing',
        ));
        usedTags.add(tag);
      }
    }
    
    return traits;
  }
  
  /// Filter physical templates based on ancestry and role constraints
  List<PhysicalTemplate> _filterPhysicalTemplates({
    required List<PhysicalTemplate> templates,
    required String ancestry,
    required List<Role> roles,
    required List<String> allAncestries,
  }) {
    return templates.where((template) => 
      _matchesAncestry(template, ancestry, allAncestries) &&
      _matchesRole(template, roles)
    ).toList();
  }
  
  /// Filter clothing templates based on ancestry and role constraints
  List<ClothingTemplate> _filterClothingTemplates({
    required List<ClothingTemplate> templates,
    required String ancestry,
    required List<Role> roles,
    required List<String> allAncestries,
  }) {
    return templates.where((template) => 
      _matchesAncestry(template, ancestry, allAncestries) &&
      _matchesRole(template, roles)
    ).toList();
  }
  
  /// Check if a template matches the person's ancestry
  bool _matchesAncestry(dynamic template, String ancestry, List<String> allAncestries) {
    // If no ancestry groups specified, template applies to all
    if (template.applicableAncestryGroups.isEmpty) return true;
    
    // Check if ancestry matches any of the specified groups
    for (final group in template.applicableAncestryGroups) {
      if (AncestryGroups.ancestryInGroup(ancestry, group, allAncestries)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Check if a template matches any of the person's roles
  bool _matchesRole(dynamic template, List<Role> roles) {
    // If no roles specified, template applies to all roles
    if (template.applicableRoles.isEmpty) return true;
    
    // Check if any of the person's roles match the template's roles
    return roles.any((role) => template.applicableRoles.contains(role));
  }
  
  /// Filter templates to exclude conflicting tags
  List<T> _filterByExcludedTags<T extends dynamic>(List<T> templates, List<String> excludeTags) {
    if (excludeTags.isEmpty) return templates;
    
    return templates.where((template) {
      // Check if template's tag is in excluded tags
      return !excludeTags.contains(template.tag);
    }).toList();
  }
  
  /// Process template string with variable substitution
  String _processTemplateString({
    required String template,
    required Person person,
    Map<String, List<String>>? variables,
  }) {
    String result = template;
    
    // Enhanced variable substitution from template variables (do this first)
    if (variables != null && variables.isNotEmpty) {
      for (final entry in variables.entries) {
        final variableName = entry.key;
        final options = entry.value;
        
        if (options.isNotEmpty) {
          // Select a random option from the list
          String selectedOption = options[_random.nextInt(options.length)];
          
          // Process built-in variables within the selected option
          selectedOption = _processBuiltInVariables(selectedOption, person);
          
          // Replace {variableName} with the processed option
          result = result.replaceAll('{$variableName}', selectedOption);
        }
      }
    }
    
    // Finally, process any remaining built-in variables in the main template
    result = _processBuiltInVariables(result, person);
    
    return result;
  }
  
  /// Process built-in variables like pronouns, name, etc.
  String _processBuiltInVariables(String text, Person person) {
    String result = text;
    
    // Basic variable substitution
    result = result.replaceAll('{name}', person.firstName);
    result = result.replaceAll('{surname}', person.surname);
    result = result.replaceAll('{ancestry}', person.ancestry);
    result = result.replaceAll('{age}', _ageToString(person.age));
    result = result.replaceAll('{pronoun_subject}', _getPronounSubject(person.pronouns));
    result = result.replaceAll('{pronoun_object}', _getPronounObject(person.pronouns));
    result = result.replaceAll('{pronoun_possessive}', _getPronounPossessive(person.pronouns));
    
    return result;
  }
  
  /// Convert age enum to descriptive string
  String _ageToString(AgeType age) {
    switch (age) {
      case AgeType.quiteYoung:
        return 'very young';
      case AgeType.young:
        return 'young';
      case AgeType.adult:
        return 'adult';
      case AgeType.middleAge:
        return 'middle-aged';
      case AgeType.old:
        return 'elderly';
      case AgeType.quiteOld:
        return 'very elderly';
    }
  }
  
  /// Get subject pronoun (he/she/they)
  String _getPronounSubject(PronounType pronouns) {
    switch (pronouns) {
      case PronounType.heHim:
      case PronounType.heThey:
        return 'he';
      case PronounType.sheHer:
      case PronounType.sheThey:
        return 'she';
      case PronounType.theyThem:
        return 'they';
      default:
        return 'they';
    }
  }
  
  /// Get object pronoun (him/her/them)
  String _getPronounObject(PronounType pronouns) {
    switch (pronouns) {
      case PronounType.heHim:
      case PronounType.heThey:
        return 'him';
      case PronounType.sheHer:
      case PronounType.sheThey:
        return 'her';
      case PronounType.theyThem:
        return 'them';
      default:
        return 'them';
    }
  }
  
  /// Get possessive pronoun (his/her/their)
  String _getPronounPossessive(PronounType pronouns) {
    switch (pronouns) {
      case PronounType.heHim:
      case PronounType.heThey:
        return 'his';
      case PronounType.sheHer:
      case PronounType.sheThey:
        return 'her';
      case PronounType.theyThem:
        return 'their';
      default:
        return 'their';
    }
  }

  
  /// Parse description into individual traits
  List<String> _parseDescriptionTraits(String? description) {
    if (description == null || description.isEmpty) {
      return [];
    }
    
    // Split by sentence-ending punctuation and clean up
    return description
        .split(RegExp(r'[.!?]+'))
        .map((trait) => trait.trim())
        .where((trait) => trait.isNotEmpty)
        .toList();
  }

  /// Get all tags from current descriptions to avoid conflicts
  List<String> extractTagsFromDescription(String? description, List<PhysicalTemplate> physicalTemplates, List<ClothingTemplate> clothingTemplates) {
    if (description == null || description.isEmpty) return [];
    
    final usedTags = <String>[];
    
    // Check physical templates for matches
    for (final template in physicalTemplates) {
      if (description.contains(template.templates.first)) {
        usedTags.add(template.tag);
      }
    }
    
    // Check clothing templates for matches
    for (final template in clothingTemplates) {
      if (description.contains(template.templates.first)) {
        usedTags.add(template.tag);
      }
    }
    
    return usedTags.toSet().toList(); // Remove duplicates
  }
  
  /// Generate a full description combining multiple templates while avoiding conflicts
  String? generateFullDescription({
    required Person person,
    required List<PhysicalTemplate> physicalTemplates,
    required List<ClothingTemplate> clothingTemplates,
    required List<String> allAncestries,
    int maxTraits = 3,
  }) {
    final usedTags = <String>[];
    final descriptionParts = <String>[];
    
    // Generate physical traits
    var attempts = 0;
    while (descriptionParts.length < maxTraits && attempts < maxTraits * 2) {
      attempts++;
      
      final trait = generatePhysicalDescription(
        person: person,
        templates: physicalTemplates,
        allAncestries: allAncestries,
        excludeTags: usedTags,
      );
      
      if (trait != null) {
        descriptionParts.add(trait);
        // Extract tags from this trait to avoid conflicts
        final traitTags = extractTagsFromDescription(trait, physicalTemplates, []);
        usedTags.addAll(traitTags);
      }
    }
    
    // Add clothing description if we have room
    if (descriptionParts.length < maxTraits) {
      final clothingTrait = generateClothingDescription(
        person: person,
        templates: clothingTemplates,
        allAncestries: allAncestries,
        excludeTags: usedTags,
      );
      
      if (clothingTrait != null) {
        descriptionParts.add(clothingTrait);
      }
    }
    
    return descriptionParts.isEmpty ? null : descriptionParts.join(' ');
  }

  /// Generate a shop description using available templates
  String? generateShopDescription({
    required Shop shop,
    required List<ShopTemplate> templates,
    List<String>? excludeTags,
  }) {
    // Filter templates that match the shop's type
    final applicableTemplates = _filterShopTemplates(
      templates: templates,
      shopType: shop.type,
    );
    
    if (applicableTemplates.isEmpty) return null;
    
    // Group templates by tags to prevent conflicts
    final availableTemplates = _filterShopTemplatesByExcludedTags(applicableTemplates, excludeTags ?? []);
    
    if (availableTemplates.isEmpty) return null;
    
    // Select a random template and generate description
    final selectedTemplate = availableTemplates[_random.nextInt(availableTemplates.length)];
    
    return _processShopTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      shop: shop,
      variables: selectedTemplate.variables,
    );
  }

  /// Generate individual shop trait by rerolling a specific tag category
  String? rerollShopTrait({
    required Shop shop,
    required List<ShopTemplate> templates,
    required String tag,
  }) {
    // Filter templates that only have the specified tag
    final tagTemplates = templates.where((t) => 
      t.tag == tag && 
      _matchesShopType(t, shop.type)
    ).toList();
    
    if (tagTemplates.isEmpty) return null;
    
    final selectedTemplate = tagTemplates[_random.nextInt(tagTemplates.length)];
    
    return _processShopTemplateString(
      template: selectedTemplate.templates.first, // Use first template from list
      shop: shop,
      variables: selectedTemplate.variables,
    );
  }

  /// Filter shop templates based on shop type constraints
  List<ShopTemplate> _filterShopTemplates({
    required List<ShopTemplate> templates,
    required ShopType shopType,
  }) {
    return templates.where((template) => 
      _matchesShopType(template, shopType)
    ).toList();
  }

  /// Check if a template matches the shop's type
  bool _matchesShopType(ShopTemplate template, ShopType shopType) {
    // If no shop types specified, template applies to all
    if (template.applicableShopTypes.isEmpty) return true;
    
    // Check if shop type matches any of the specified types
    return template.applicableShopTypes.contains(shopType);
  }

  /// Filter shop templates to exclude conflicting tags
  List<ShopTemplate> _filterShopTemplatesByExcludedTags(List<ShopTemplate> templates, List<String> excludeTags) {
    if (excludeTags.isEmpty) return templates;
    
    return templates.where((template) {
      // Check if template's tag is in excluded tags
      return !excludeTags.contains(template.tag);
    }).toList();
  }

  /// Process shop template string with variable substitution
  String _processShopTemplateString({
    required String template,
    required Shop shop,
    Map<String, List<String>>? variables,
  }) {
    String result = template;
    
    // Enhanced variable substitution from template variables (do this first)
    if (variables != null && variables.isNotEmpty) {
      for (final entry in variables.entries) {
        final variableName = entry.key;
        final options = entry.value;
        
        if (options.isNotEmpty) {
          // Select a random option from the list
          String selectedOption = options[_random.nextInt(options.length)];
          
          // Process built-in shop variables within the selected option
          selectedOption = _processBuiltInShopVariables(selectedOption, shop);
          
          // Replace {variableName} with the processed option
          result = result.replaceAll('{$variableName}', selectedOption);
        }
      }
    }
    
    // Finally, process any remaining built-in variables in the main template
    result = _processBuiltInShopVariables(result, shop);
    
    return result;
  }
  
  /// Process built-in shop variables like name, type, etc.
  String _processBuiltInShopVariables(String text, Shop shop) {
    String result = text;
    
    // Basic variable substitution for shops
    result = result.replaceAll('{name}', shop.name);
    result = result.replaceAll('{type}', _shopTypeToString(shop.type));
    result = result.replaceAll('{pro1}', shop.pro1);
    result = result.replaceAll('{pro2}', shop.pro2);
    result = result.replaceAll('{con}', shop.con);
    
    return result;
  }

  /// Convert shop type enum to descriptive string
  String _shopTypeToString(ShopType type) {
    switch (type) {
      case ShopType.tavern:
        return 'tavern';
      case ShopType.herbalist:
        return 'herbalist';
      case ShopType.temple:
        return 'temple';
      case ShopType.smith:
        return 'smithy';
      case ShopType.generalStore:
        return 'general store';
      case ShopType.jeweler:
        return 'jeweler';
      case ShopType.clothier:
        return 'clothier';
      case ShopType.magic:
        return 'magic shop';
    }
  }

  /// Get all tags from current shop descriptions to avoid conflicts
  List<String> extractTagsFromShopDescription(String? description, List<ShopTemplate> shopTemplates) {
    if (description == null || description.isEmpty) return [];
    
    final usedTags = <String>[];
    
    // Check shop templates for matches
    for (final template in shopTemplates) {
      if (description.contains(template.templates.first)) {
        usedTags.add(template.tag);
      }
    }
    
    return usedTags.toSet().toList(); // Remove duplicates
  }

  /// Generate a full shop description combining multiple templates while avoiding conflicts
  String? generateFullShopDescription({
    required Shop shop,
    required List<ShopTemplate> shopTemplates,
    int maxTraits = 3,
  }) {
    final usedTags = <String>[];
    final descriptionParts = <String>[];
    
    // Generate shop traits
    var attempts = 0;
    while (descriptionParts.length < maxTraits && attempts < maxTraits * 2) {
      attempts++;
      
      final trait = generateShopDescription(
        shop: shop,
        templates: shopTemplates,
        excludeTags: usedTags,
      );
      
      if (trait != null) {
        descriptionParts.add(trait);
        // Extract tags from this trait to avoid conflicts
        final traitTags = extractTagsFromShopDescription(trait, shopTemplates);
        usedTags.addAll(traitTags);
      }
    }
    
    return descriptionParts.isEmpty ? null : descriptionParts.join(' ');
  }
}