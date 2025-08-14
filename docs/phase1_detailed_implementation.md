# Phase 1 Detailed Implementation Plan - Town Overview Dashboard

## Overview
Create a comprehensive town overview dashboard with templated rumor system that dynamically references actual NPCs in the town.

## 1. Templated Rumor System

### 1.1 Rumor Template Model
**File**: `lib/models/rumor_template_model.dart`

```dart
class RumorTemplate {
  final String id;
  final String template;  // Template with {roleType/roleType2} placeholders
  final List<String> tags;
  final Map<String, List<String>> variables;  // Variable name -> possible values
  final List<String> requiredRoles;  // At least one of these roles must exist
  final List<String> requiredLocations;  // Required location types (optional)
  
  RumorTemplate({
    required this.id,
    required this.template,
    required this.tags,
    this.variables = const {},
    this.requiredRoles = const [],
    this.requiredLocations = const [],
  });
}

class GeneratedRumor {
  final String id;
  final String content;  // Fully resolved template
  final List<String> referencedNPCs;  // NPCs that were used in generation
  final List<String> tags;
  final DateTime generatedAt;
  
  GeneratedRumor({
    required this.id,
    required this.content,
    required this.referencedNPCs,
    required this.tags,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}
```

### 1.2 Templated Rumors Data
**File**: `assets/data/rumor_templates.yaml`

```yaml
role_templates:
  - id: "tax_increase"
    template: "{warMinister/mintMinister/infrastructureMinister/townLeader} wants to raise taxes to fund {townProject}."
    tags: ["politics", "economy"]
    variables:
      townProject: ["repairs to the town walls", "new guard barracks", "road improvements", "bridge construction"]
    required_roles: ["warMinister", "mintMinister", "infrastructureMinister", "townLeader"]
    
  - id: "smith_rivalry" 
    template: "{weaponsmith} and {armorsmith} are feuding over who makes the finest {metalwork}."
    tags: ["conflict", "trade"]
    variables:
      metalwork: ["steel", "weapons", "armor", "tools"]
    required_roles: ["weaponsmith", "armorsmith"]
    
  - id: "merchant_gossip"
    template: "{merchant/trader} claims they saw {strangeEvent} while traveling from {nearbyTown}."
    tags: ["mystery", "travel"]
    variables:
      strangeEvent: ["strange lights", "hooded figures", "abandoned caravans", "odd creatures"]
      nearbyTown: ["the capital", "the northern settlements", "the eastern trading post", "across the border"]
    required_roles: ["merchant", "trader"]
    
  - id: "tavern_drama"
    template: "Patrons at {tavernLocation} whisper that {tavernKeeper/owner} is hiding {secret} in the cellar."
    tags: ["mystery", "tavern"]
    variables:
      secret: ["stolen goods", "old treasures", "smuggled items", "ancient artifacts"]
    required_roles: ["tavernKeeper", "owner"]
    required_locations: ["tavern"]
    
  - id: "guard_concern"
    template: "{guardCaptain/townGuard} has been asking questions about {suspiciousActivity} near {location}."
    tags: ["law", "mystery"]
    variables:
      suspiciousActivity: ["strange noises", "unusual visitors", "missing items", "broken locks"]
      location: ["the old warehouse", "the cemetery", "the abandoned mill", "the town gates"]
    required_roles: ["guardCaptain", "townGuard"]
    
  - id: "healer_warning"
    template: "{herbalist/healer} warns that {ailment} is spreading and recommends avoiding {location}."
    tags: ["health", "warning"]
    variables:
      ailment: ["a strange sickness", "bad humors", "cursed dreams", "weakness of limbs"]
      location: ["the swamp", "old ruins", "certain wells", "the lower district"]
    required_roles: ["herbalist", "healer"]
    
  - id: "religious_concern"
    template: "{priest/hierophant} has declared that {omen} foretells {prediction}."
    tags: ["religion", "prophecy"]
    variables:
      omen: ["birds flying backwards", "flowers blooming out of season", "strange dreams", "cracked temple stones"]
      prediction: ["good fortune", "hard times ahead", "a visitor of importance", "change in leadership"]
    required_roles: ["priest", "hierophant"]
    
  - id: "craft_guild_news"
    template: "The guild of {craftsmen} has announced {guildNews} affecting local {tradeGood} prices."
    tags: ["economy", "guild"]
    variables:
      craftsmen: ["smiths", "carpenters", "weavers", "potters"]
      guildNews: ["new regulations", "a price increase", "quality standards", "apprentice examinations"]
      tradeGood: ["tools", "furniture", "cloth", "pottery"]
    required_roles: ["owner", "journeyman"]
    
  - id: "mysterious_stranger"
    template: "A {strangerType} visited {shopkeeper/merchant} asking strange questions about {mysteryTopic}."
    tags: ["mystery", "strangers"]
    variables:
      strangerType: ["hooded figure", "well-dressed noble", "foreign merchant", "weathered traveler"]
      mysteryTopic: ["the old bloodlines", "ancient artifacts", "missing persons", "forgotten histories"]
    required_roles: ["shopkeeper", "merchant", "owner"]
    
  - id: "seasonal_concern"
    template: "{farmer/gatherer} reports that {seasonalProblem} might affect this year's {harvest}."
    tags: ["agriculture", "economy"]
    variables:
      seasonalProblem: ["strange weather", "pest infestations", "soil problems", "water shortages"]
      harvest: ["grain harvest", "fruit crop", "vegetable yield", "herb gathering"]
    required_roles: ["farmer", "gatherer"]

# Fallback rumors (no role requirements - always available)
fallback_templates:
  - id: "weather_talk"
    template: "Folks say the weather has been {weatherType} lately, {weatherEffect}."
    tags: ["weather", "general"]
    variables:
      weatherType: ["unusually mild", "strangely cold", "surprisingly wet", "oddly dry"]
      weatherEffect: ["making travel easier", "causing problems for farmers", "keeping people indoors", "bringing good omens"]
      
  - id: "road_conditions"
    template: "Travelers report that the {roadType} is {roadCondition}, {travelAdvice}."
    tags: ["travel", "roads"]
    variables:
      roadType: ["northern road", "eastern path", "main trade route", "mountain pass"]
      roadCondition: ["in good repair", "badly damaged", "blocked by fallen trees", "muddy from recent rains"]
      travelAdvice: ["making for easy travel", "requiring caution", "best avoided for now", "passable with care"]
      
  - id: "merchant_tales"
    template: "A traveling merchant brought news that {distantEvent} in {farPlace}."
    tags: ["news", "travel"]
    variables:
      distantEvent: ["a great fire broke out", "bandits are active", "a new mine was discovered", "strange creatures were sighted"]
      farPlace: ["the eastern kingdoms", "beyond the mountains", "the coastal cities", "the border towns"]
```

### 1.3 Rumor Template Engine
**File**: `lib/services/rumor_template_engine.dart`

```dart
class RumorTemplateEngine {
  static List<GeneratedRumor> generateRumors(
    List<RumorTemplate> templates,
    List<Person> people,
    List<LocationRole> roles,
    List<Location> locations,
    {int maxRumors = 6}
  ) {
    final generatedRumors = <GeneratedRumor>[];
    final random = Random();
    
    // Get viable templates (those with required roles available)
    final viableTemplates = templates.where((template) => 
      _hasRequiredRoles(template, people, roles)
    ).toList();
    
    // Add fallback templates (always available)
    final fallbackTemplates = templates.where((t) => 
      t.requiredRoles.isEmpty
    ).toList();
    
    final allViableTemplates = [...viableTemplates, ...fallbackTemplates];
    allViableTemplates.shuffle(random);
    
    for (int i = 0; i < maxRumors && i < allViableTemplates.length; i++) {
      final template = allViableTemplates[i];
      final generatedRumor = _generateFromTemplate(template, people, roles, locations);
      
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
    List<Location> locations
  ) {
    String content = template.template;
    final referencedNPCs = <String>[];
    final random = Random();
    
    // Find all role placeholders {role1/role2/role3}
    final rolePattern = RegExp(r'\{([^}]+)\}');
    final roleMatches = rolePattern.allMatches(content);
    
    for (final match in roleMatches) {
      final placeholder = match.group(0)!; // Full {role1/role2}
      final roleOptions = match.group(1)!; // role1/role2
      
      if (roleOptions.contains('/')) {
        // Multiple role options - pick one that exists
        final roleList = roleOptions.split('/');
        final availablePerson = _findPersonWithAnyRole(roleList, people, roles);
        
        if (availablePerson != null) {
          content = content.replaceFirst(placeholder, availablePerson.firstName);
          referencedNPCs.add(availablePerson.id);
        } else {
          return null; // Can't fulfill this template
        }
      } else if (roleOptions.endsWith('Location')) {
        // Location placeholder
        final locationName = _findLocationOfType(roleOptions, locations);
        if (locationName != null) {
          content = content.replaceFirst(placeholder, locationName);
        }
      } else if (template.variables.containsKey(roleOptions)) {
        // Variable placeholder
        final options = template.variables[roleOptions]!;
        final chosen = options[random.nextInt(options.length)];
        content = content.replaceFirst(placeholder, chosen);
      }
    }
    
    return GeneratedRumor(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      referencedNPCs: referencedNPCs,
      tags: template.tags,
    );
  }
  
  static Person? _findPersonWithAnyRole(
    List<String> roleNames, 
    List<Person> people, 
    List<LocationRole> roles
  ) {
    final targetRoles = roleNames.map(_stringToRole).where((r) => r != null).toList();
    
    for (final targetRole in targetRoles) {
      final personRole = roles.firstWhereOrNull((lr) => lr.myRole == targetRole);
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
      default:
        return null;
    }
  }
  
  static bool _hasRequiredRoles(
    RumorTemplate template, 
    List<Person> people, 
    List<LocationRole> roles
  ) {
    if (template.requiredRoles.isEmpty) return true;
    
    return template.requiredRoles.any((roleName) {
      final role = _stringToRole(roleName);
      if (role == null) return false;
      
      return roles.any((lr) => lr.myRole == role &&
        people.any((p) => p.id == lr.myID));
    });
  }
  
  static String? _findLocationOfType(String locationType, List<Location> locations) {
    Location? targetLocation;
    
    switch (locationType.toLowerCase()) {
      case 'tavernlocation':
        targetLocation = locations.firstWhereOrNull((loc) => 
          loc is Shop && loc.type == ShopType.tavern);
        break;
      // Add other location types as needed
    }
    
    return targetLocation?.name;
  }
}
```

### 1.4 Updated Rumor Provider
**File**: `lib/providers/rumor_provider.dart`

```dart
final rumorTemplatesProvider = FutureProvider<List<RumorTemplate>>((ref) async {
  // Load YAML templates from assets
  final yamlString = await rootBundle.loadString('assets/data/rumor_templates.yaml');
  final yamlMap = loadYaml(yamlString);
  
  final templates = <RumorTemplate>[];
  
  // Load role-based templates
  if (yamlMap['role_templates'] != null) {
    for (final templateData in yamlMap['role_templates']) {
      templates.add(_parseRumorTemplate(templateData));
    }
  }
  
  // Load fallback templates  
  if (yamlMap['fallback_templates'] != null) {
    for (final templateData in yamlMap['fallback_templates']) {
      templates.add(_parseRumorTemplate(templateData));
    }
  }
  
  return templates;
});

final generatedRumorsProvider = Provider<List<GeneratedRumor>>((ref) {
  final templates = ref.watch(rumorTemplatesProvider).asData?.value ?? [];
  final people = ref.watch(peopleProvider);
  final roles = ref.watch(locationRolesProvider);
  final locations = ref.watch(locationsProvider);
  
  return RumorTemplateEngine.generateRumors(
    templates, 
    people, 
    roles, 
    locations,
    maxRumors: 8
  );
});
```

## 2. Updated Dashboard Components

### 2.1 Talk of the Town Card (Updated)
**File**: `lib/widgets/talk_of_town_card.dart`

```dart
class TalkOfTownCard extends ConsumerStatefulWidget {
  const TalkOfTownCard({super.key});

  @override
  ConsumerState<TalkOfTownCard> createState() => _TalkOfTownCardState();
}

class _TalkOfTownCardState extends ConsumerState<TalkOfTownCard> {
  List<GeneratedRumor> _displayedRumors = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRumors());
  }
  
  void _refreshRumors() {
    final allRumors = ref.read(generatedRumorsProvider);
    allRumors.shuffle();
    setState(() {
      _displayedRumors = allRumors.take(4).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Talk of the Town',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _navigateToRumorManagement(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Manage'),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshRumors,
                  tooltip: 'Refresh rumors',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_displayedRumors.isEmpty)
              const Text(
                'No rumors are circulating at the moment...',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )
            else
              ..._displayedRumors.map((rumor) => _RumorItem(rumor: rumor)),
          ],
        ),
      ),
    );
  }
}

class _RumorItem extends ConsumerWidget {
  final GeneratedRumor rumor;
  
  const _RumorItem({required this.rumor});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: _buildRumorTextSpans(rumor, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<InlineSpan> _buildRumorTextSpans(GeneratedRumor rumor, WidgetRef ref) {
    final people = ref.read(peopleProvider);
    final spans = <InlineSpan>[];
    
    String content = rumor.content;
    
    // Make referenced NPC names clickable
    for (final npcId in rumor.referencedNPCs) {
      final person = people.firstWhereOrNull((p) => p.id == npcId);
      if (person != null) {
        final nameIndex = content.indexOf(person.firstName);
        if (nameIndex != -1) {
          // Add text before name
          if (nameIndex > 0) {
            spans.add(TextSpan(text: content.substring(0, nameIndex)));
          }
          
          // Add clickable name
          spans.add(TextSpan(
            text: person.firstName,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _navigateToPersonDetail(person.id),
          ));
          
          // Update content to remaining text
          content = content.substring(nameIndex + person.firstName.length);
        }
      }
    }
    
    // Add any remaining text
    if (content.isNotEmpty) {
      spans.add(TextSpan(text: content));
    }
    
    return spans;
  }
}
```

This templated rumor system provides:

1. **Dynamic Content**: Rumors reference actual NPCs in the town
2. **Role-Based Filtering**: Only shows rumors for roles that exist
3. **Variable Substitution**: Random variables make rumors feel fresh
4. **Clickable NPCs**: Referenced NPCs are clickable links to their detail pages
5. **Fallback Content**: Always has some rumors available even in small towns
6. **Extensible**: Easy to add new rumor templates via YAML

The system automatically adapts to the town's composition - a town with no weaponsmith won't show smith rivalry rumors, but a town with multiple government officials will have political intrigue rumors.