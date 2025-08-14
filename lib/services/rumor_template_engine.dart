import 'dart:math';
import 'package:collection/collection.dart';
import '../models/rumor_template_model.dart';
import '../models/barrel_of_models.dart';
import '../enums_and_maps.dart';

class RumorTemplateEngine {
  static List<GeneratedRumor> generateRumors(
    List<RumorTemplate> templates,
    List<Person> people,
    List<LocationRole> roles,
    List<Location> locations, {
    int maxRumors = 6,
  }) {
    final generatedRumors = <GeneratedRumor>[];
    final random = Random();

    // Get viable templates (those with required roles available)
    final viableTemplates = templates
        .where((template) => _hasRequiredRoles(template, people, roles))
        .toList();

    // Add fallback templates (always available)
    final fallbackTemplates =
        templates.where((t) => t.requiredRoles.isEmpty).toList();

    final allViableTemplates = [...viableTemplates, ...fallbackTemplates];
    allViableTemplates.shuffle(random);

    for (int i = 0; i < maxRumors && i < allViableTemplates.length; i++) {
      final template = allViableTemplates[i];
      final generatedRumor =
          _generateFromTemplate(template, people, roles, locations);

      if (generatedRumor != null) {
        generatedRumors.add(generatedRumor);
      }
    }

    return generatedRumors;
  }

  static GeneratedRumor? _generateFromTemplate(
    RumorTemplate template,
    List<Person> people,
    List<LocationRole> roles,
    List<Location> locations,
  ) {
    String content = template.template;
    final referencedNPCs = <String>[];
    final random = Random();

    // Find all placeholders {role1/role2} or {variable}
    final placeholderPattern = RegExp(r'\{([^}]+)\}');
    final matches = placeholderPattern.allMatches(content).toList();

    for (final match in matches) {
      final placeholder = match.group(0)!; // Full {role1/role2}
      final placeholderContent = match.group(1)!; // role1/role2

      if (placeholderContent.contains('/')) {
        // Multiple role options - pick one that exists
        final roleList = placeholderContent.split('/');
        final availablePerson = _findPersonWithAnyRole(roleList, people, roles);

        if (availablePerson != null) {
          content = content.replaceFirst(placeholder, availablePerson.firstName);
          referencedNPCs.add(availablePerson.id);
        } else {
          return null; // Can't fulfill this template
        }
      } else if (placeholderContent.endsWith('Location')) {
        // Location placeholder
        final locationName = _findLocationOfType(placeholderContent, locations);
        if (locationName != null) {
          content = content.replaceFirst(placeholder, locationName);
        } else {
          content = content.replaceFirst(placeholder, 'the local establishment');
        }
      } else if (template.variables.containsKey(placeholderContent)) {
        // Variable placeholder
        final options = template.variables[placeholderContent]!;
        final chosen = options[random.nextInt(options.length)];
        content = content.replaceFirst(placeholder, chosen);
      } else {
        // Single role placeholder
        final availablePerson = _findPersonWithAnyRole([placeholderContent], people, roles);
        if (availablePerson != null) {
          content = content.replaceFirst(placeholder, availablePerson.firstName);
          referencedNPCs.add(availablePerson.id);
        } else {
          return null; // Can't fulfill this template
        }
      }
    }

    return GeneratedRumor(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
      content: content,
      referencedNPCs: referencedNPCs,
      tags: template.tags,
    );
  }

  static Person? _findPersonWithAnyRole(
    List<String> roleNames,
    List<Person> people,
    List<LocationRole> roles,
  ) {
    final targetRoles = roleNames
        .map(_stringToRole)
        .where((r) => r != null)
        .cast<Role>()
        .toList();

    for (final targetRole in targetRoles) {
      final personRole =
          roles.firstWhereOrNull((lr) => lr.myRole == targetRole);
      if (personRole != null) {
        final person = people.firstWhereOrNull((p) => p.id == personRole.myID);
        if (person != null) return person;
      }
    }
    return null;
  }

  static Role? _stringToRole(String roleName) {
    // Map string role names to Role enum values
    switch (roleName.toLowerCase()) {
      case 'townleader':
      case 'leader':
        return Role.liegeGovernment;
      case 'warminister':
        return Role.warMinisterGovernmentUniversal;
      case 'mintminister':
        return Role.mintMinisterGovernmentUniversal;
      case 'infrastructureminister':
        return Role.infrastructureMinisterGovernmentUniversal;
      case 'weaponsmith':
        return Role.owner; // Weaponsmith would be shop owner
      case 'armorsmith':
        return Role.owner; // Armorsmith would be shop owner
      case 'merchant':
      case 'trader':
        return Role.owner;
      case 'tavernkeeper':
        return Role.tavernKeeper;
      case 'owner':
        return Role.owner;
      case 'guardcaptain':
        return Role.guardCaptainGovernment;
      case 'townguard':
        return Role.townGuard;
      case 'herbalist':
      case 'healer':
        return Role.owner; // Herbalist shop owner
      case 'priest':
        return Role.hierophant;
      case 'hierophant':
        return Role.hierophant;
      case 'shopkeeper':
        return Role.owner;
      case 'journeyman':
        return Role.journeyman;
      case 'farmer':
      case 'gatherer':
        return Role.farmer;
      case 'courier':
        return Role.courier;
      case 'porter':
        return Role.porter;
      case 'mercenary':
        return Role.mercenary;
      case 'scribe':
        return Role.scribe;
      case 'accountant':
        return Role.accountant;
      case 'eldergovernment':
      case 'elder':
        return Role.elderGovernment;
      case 'alchemist':
        return Role.owner; // Alchemist shop owner
      case 'tailor':
        return Role.owner; // Tailor shop owner
      default:
        return null;
    }
  }

  static bool _hasRequiredRoles(
    RumorTemplate template,
    List<Person> people,
    List<LocationRole> roles,
  ) {
    if (template.requiredRoles.isEmpty) return true;

    return template.requiredRoles.any((roleName) {
      final role = _stringToRole(roleName);
      if (role == null) return false;

      return roles.any((lr) =>
          lr.myRole == role && people.any((p) => p.id == lr.myID));
    });
  }

  static String? _findLocationOfType(String locationType, List<Location> locations) {
    Location? targetLocation;

    switch (locationType.toLowerCase()) {
      case 'tavernlocation':
        targetLocation = locations.firstWhereOrNull((loc) =>
            loc is Shop && loc.type == ShopType.tavern);
        break;
      case 'templocation':
        targetLocation = locations.firstWhereOrNull((loc) =>
            loc is Shop && loc.type == ShopType.temple);
        break;
      case 'shoplocation':
        targetLocation = locations.firstWhereOrNull((loc) => loc is Shop);
        break;
      // Add other location types as needed
    }

    return targetLocation?.name;
  }
}