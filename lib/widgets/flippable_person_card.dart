import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/person_model.dart';
import '../models/character_trait_model.dart';
import '../services/description_service.dart';
import '../providers/barrel_of_providers.dart';
import '../enums_and_maps.dart';
import '../globals.dart';
import '../screens/person_detail_view.dart';

class FlippablePersonCard extends ConsumerStatefulWidget {
  final Person person;
  final List<String>? additionalInfo;
  final bool startFlipped;

  const FlippablePersonCard({
    super.key,
    required this.person,
    this.additionalInfo,
    this.startFlipped = false,
  });

  @override
  ConsumerState<FlippablePersonCard> createState() => _FlippablePersonCardState();
}

class _FlippablePersonCardState extends ConsumerState<FlippablePersonCard>
    with TickerProviderStateMixin {
  late bool isFlipped; // false = description view, true = stats view
  bool isExpanded = false; // only applies to description view
  late AnimationController _flipController;
  late AnimationController _expandController;
  late Animation<double> _flipAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    isFlipped = widget.startFlipped;
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    
    // Set initial flip state
    if (widget.startFlipped) {
      _flipController.value = 1.0;
    }
    
    // Generate traits if they don't exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureTraitsExist();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped) {
        _flipController.forward();
        // Collapse when flipping to stats view
        isExpanded = false;
        _expandController.reset();
      } else {
        _flipController.reverse();
      }
    });
  }

  void _toggleExpand() {
    if (!isFlipped) { // Only allow expansion on description view
      setState(() {
        isExpanded = !isExpanded;
        if (isExpanded) {
          _expandController.forward();
        } else {
          _expandController.reverse();
        }
      });
    }
  }

  void _navigateToDetail() {
    navigatorKey.currentState!.restorablePushNamed(
      PersonDetailView.routeName,
      arguments: {'myID': widget.person.id},
    );
  }

  String _truncateText(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    
    // Find the last space before maxLength to avoid cutting words
    int cutoff = text.lastIndexOf(' ', maxLength);
    if (cutoff == -1) cutoff = maxLength;
    
    return '${text.substring(0, cutoff)}...';
  }

  void _ensureTraitsExist() async {
    final person = widget.person;
    
    // Check if traits are missing
    if (person.physicalTraits.isEmpty || person.clothingTraits.isEmpty) {
      
      try {
        final descriptionService = DescriptionService();
        final physicalTemplates = ref.read(physicalTemplatesProvider);
        final clothingTemplates = ref.read(clothingTemplatesProvider);
        final ancestries = ref.read(ancestriesProvider);
        final allAncestryNames = ancestries.map((a) => a.name).toList();
        
        if (physicalTemplates.isEmpty || clothingTemplates.isEmpty) {
          // Templates not available, skip generation
          return;
        }
        
        List<CharacterTrait> newPhysicalTraits = person.physicalTraits;
        List<CharacterTrait> newClothingTraits = person.clothingTraits;
        
        // Generate missing traits
        if (newPhysicalTraits.isEmpty) {
          newPhysicalTraits = descriptionService.generatePhysicalTraits(
            person: person,
            templates: physicalTemplates,
            allAncestries: allAncestryNames,
            maxTraits: 1,
          );
        }
        
        if (newClothingTraits.isEmpty) {
          newClothingTraits = descriptionService.generateClothingTraits(
            person: person,
            templates: clothingTemplates,
            allAncestries: allAncestryNames,
            maxTraits: 1,
          );
        }
        
        // Update person if any traits were generated
        if (newPhysicalTraits.isNotEmpty || newClothingTraits.isNotEmpty) {
          
          final peopleNotifier = ref.read(peopleProvider.notifier);
          final updatedPerson = person.copyWith(
            physicalTraits: newPhysicalTraits.isNotEmpty ? newPhysicalTraits : person.physicalTraits,
            clothingTraits: newClothingTraits.isNotEmpty ? newClothingTraits : person.clothingTraits,
          );
          
          peopleNotifier.replace(person, updatedPerson);
          await peopleNotifier.commitChanges();
        }
      } catch (e) {
        // Silently fail - descriptions will show as "No description available"
        debugPrint('Failed to generate descriptions for ${person.firstName}: $e');
      }
    }
  }

  Widget _buildDescriptionView() {
    final person = widget.person;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with name, ancestry, pronouns and flip button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.firstName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${enum2String(myEnum: person.age)} ${person.ancestry} (${enum2String(myEnum: person.pronouns)})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _toggleFlip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: const Text(
                  'flip card',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Description content
        if (!isExpanded) ...[
          // Collapsed view - show first trait of each type
          if (person.physicalTraits.isNotEmpty) ...[
            Text(
              _truncateText(person.physicalTraits.first.description, 80),
              style: const TextStyle(fontSize: 13),
            ),
          ],
          
          if (person.clothingTraits.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _truncateText(person.clothingTraits.first.description, 60),
              style: const TextStyle(fontSize: 13),
            ),
          ],
          
          // Expand button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _toggleExpand,
              icon: const Icon(Icons.expand_more, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
          ),
        ] else ...[
          // Expanded view - full descriptions with reroll options
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapse button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _toggleExpand,
                    icon: const Icon(Icons.expand_less, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ),
                
                // Physical traits section
                Row(
                  children: [
                    const Text(
                      'PHYSICAL:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _addNewTrait('physical'),
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Add physical trait',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (person.physicalTraits.isNotEmpty) ...[
                  ...person.physicalTraits.map((trait) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            trait.description,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _rerollIndividualTrait(trait),
                          icon: const Icon(Icons.casino, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 8),
                
                // Clothing traits section
                Row(
                  children: [
                    const Text(
                      'CLOTHING:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _addNewTrait('clothing'),
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Add clothing trait',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (person.clothingTraits.isNotEmpty) ...[
                  ...person.clothingTraits.map((trait) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            trait.description,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _rerollIndividualTrait(trait),
                          icon: const Icon(Icons.casino, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 8),
                
                
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsView() {
    final person = widget.person;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with full name and flip button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${person.firstName} ${person.surname}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${enum2String(myEnum: person.age)} ${person.ancestry} (${enum2String(myEnum: person.pronouns)})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _toggleFlip,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Text(
                  'flip card',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Quirks
        Text(
          '${person.quirk1} & ${person.quirk2}',
          style: const TextStyle(fontSize: 13),
        ),
        
        const SizedBox(height: 4),
        
        // Resonant Argument
        Text(
          'Resonant Argument: ${person.resonantArgument}',
          style: const TextStyle(fontSize: 13),
        ),
        
        // Additional info if provided
        if (widget.additionalInfo != null) ...[
          const SizedBox(height: 8),
          ...widget.additionalInfo!.map(
            (info) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(info, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // More info button
        Center(
          child: ElevatedButton.icon(
            onPressed: _navigateToDetail,
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('More Info', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 0),
            ),
          ),
        ),
      ],
    );
  }


  void _rerollIndividualTrait(CharacterTrait trait) async {
    try {
      final descriptionService = DescriptionService();
      final physicalTemplates = ref.read(physicalTemplatesProvider);
      final clothingTemplates = ref.read(clothingTemplatesProvider);
      final ancestries = ref.read(ancestriesProvider);
      final allAncestryNames = ancestries.map((a) => a.name).toList();
      
      if ((trait.type == 'physical' && physicalTemplates.isEmpty) ||
          (trait.type == 'clothing' && clothingTemplates.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No ${trait.type} templates available. Please import templates first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Get existing tags EXCLUDING the trait we're rerolling
      final existingTags = trait.type == 'physical'
          ? widget.person.physicalTraits
              .where((t) => t.id != trait.id)
              .map((t) => t.tag)
              .toSet()
          : widget.person.clothingTraits
              .where((t) => t.id != trait.id)
              .map((t) => t.tag)
              .toSet();
      
      // Generate a completely new trait (any tag, not locked to current tag)
      List<CharacterTrait> newTraits;
      if (trait.type == 'physical') {
        newTraits = descriptionService.generatePhysicalTraits(
          person: widget.person,
          templates: physicalTemplates,
          allAncestries: allAncestryNames,
          maxTraits: 1,
        );
        // Filter out traits with tags we already have
        newTraits = newTraits.where((newTrait) => !existingTags.contains(newTrait.tag)).toList();
      } else {
        newTraits = descriptionService.generateClothingTraits(
          person: widget.person,
          templates: clothingTemplates,
          allAncestries: allAncestryNames,
          maxTraits: 1,
        );
        // Filter out traits with tags we already have
        newTraits = newTraits.where((newTrait) => !existingTags.contains(newTrait.tag)).toList();
      }
      
      if (newTraits.isNotEmpty) {
        final peopleNotifier = ref.read(peopleProvider.notifier);
        final newTrait = newTraits.first;
        
        // Replace the old trait with the new one
        final updatedTraits = trait.type == 'physical'
            ? widget.person.physicalTraits.map((t) => 
                t.id == trait.id ? newTrait : t
              ).toList()
            : widget.person.clothingTraits.map((t) => 
                t.id == trait.id ? newTrait : t
              ).toList();
        
        final updatedPerson = trait.type == 'physical'
            ? widget.person.copyWith(physicalTraits: updatedTraits)
            : widget.person.copyWith(clothingTraits: updatedTraits);
        
        peopleNotifier.replace(widget.person, updatedPerson);
        await peopleNotifier.commitChanges();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${trait.type} trait rerolled'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No new ${trait.type} traits available for this character'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rerolling trait: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNewTrait(String type) async {
    try {
      final descriptionService = DescriptionService();
      final physicalTemplates = ref.read(physicalTemplatesProvider);
      final clothingTemplates = ref.read(clothingTemplatesProvider);
      final ancestries = ref.read(ancestriesProvider);
      final allAncestryNames = ancestries.map((a) => a.name).toList();
      
      if ((type == 'physical' && physicalTemplates.isEmpty) ||
          (type == 'clothing' && clothingTemplates.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No $type templates available. Please import templates first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Generate a new trait, excluding existing ones
      final existingTags = type == 'physical'
          ? widget.person.physicalTraits.map((t) => t.tag).toList()
          : widget.person.clothingTraits.map((t) => t.tag).toList();
      
      List<CharacterTrait> newTraits;
      if (type == 'physical') {
        newTraits = descriptionService.generatePhysicalTraits(
          person: widget.person,
          templates: physicalTemplates,
          allAncestries: allAncestryNames,
          maxTraits: 1,
        );
        // Filter out any traits with tags we already have
        newTraits = newTraits.where((trait) => !existingTags.contains(trait.tag)).toList();
      } else {
        newTraits = descriptionService.generateClothingTraits(
          person: widget.person,
          templates: clothingTemplates,
          allAncestries: allAncestryNames,
          maxTraits: 1,
        );
        // Filter out any traits with tags we already have
        newTraits = newTraits.where((trait) => !existingTags.contains(trait.tag)).toList();
      }
      
      if (newTraits.isNotEmpty) {
        final peopleNotifier = ref.read(peopleProvider.notifier);
        final newTrait = newTraits.first;
        
        final updatedPerson = type == 'physical'
            ? widget.person.copyWith(
                physicalTraits: [...widget.person.physicalTraits, newTrait],
              )
            : widget.person.copyWith(
                clothingTraits: [...widget.person.clothingTraits, newTrait],
              );
        
        peopleNotifier.replace(widget.person, updatedPerson);
        await peopleNotifier.commitChanges();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added new $type trait'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No new $type traits available for this character'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding trait: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 600,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            if (_flipAnimation.value < 0.5) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * math.pi),
                child: _buildDescriptionView(),
              );
            } else {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((_flipAnimation.value - 1) * math.pi),
                child: _buildStatsView(),
              );
            }
          },
        ),
      ),
    );
  }
}