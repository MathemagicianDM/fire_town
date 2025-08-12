import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/random_encounter_model.dart';
import '../providers/barrel_of_providers.dart';
import '../enums_and_maps.dart';
import '../search_models_providers_listeners/search_memory.dart';
import '../models/barrel_of_models.dart';
class EncounterBuilderPage extends ConsumerStatefulWidget {
  static const routeName = "/encounter-builder";

  const EncounterBuilderPage({super.key});

  @override
  ConsumerState<EncounterBuilderPage> createState() => _EncounterBuilderPageState();
}

class _EncounterBuilderPageState extends ConsumerState<EncounterBuilderPage> {
  bool _isLoading = false;
  final EncounterBuilder _builder = EncounterBuilder();
  final TextEditingController _textController = TextEditingController();
  final Set<ShopType> _selectedShopTypes = {};
  
  // Persistent state for last selections
  List<LocationType> _lastSelectedLocations = [];
  EncounterRarity _lastSelectedRarity = EncounterRarity.common;
  Set<ShopType> _lastSelectedShopTypes = {};
  
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final encountersNotifier = ref.read(randomEncountersProvider.notifier);
      await encountersNotifier.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error initializing: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading data: $e")),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encounters = ref.watch(randomEncountersProvider);
    final encountersNotifier = ref.watch(randomEncountersProvider.notifier);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Random Encounter Builder"),
        actions: [
          if (encountersNotifier.isDirty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await encountersNotifier.commitChanges();
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Changes saved successfully!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving changes: $e")),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              encountersNotifier.discardChanges();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Changes discarded")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Encounter Builder Section
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Build New Encounter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Current sentence preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Text(
                        _builder.currentParts.isEmpty 
                            ? "Your encounter will appear here..."
                            : _builder.currentParts.map((p) => p.toString()).join(''),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Building controls
                    Expanded(
                      child: Row(
                        children: [
                          // Text input section
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Add Text:", 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _textController,
                                    decoration: const InputDecoration(
                                      hintText: "Type text here...",
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: null,
                                    expands: true,
                                    onFieldSubmitted: (text) {
                                      if (text.trim().isNotEmpty) {
                                        setState(() {
                                          _builder.addText(text.trim());
                                          _textController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final text = _textController.text.trim();
                                    if (text.isNotEmpty) {
                                      setState(() {
                                        _builder.addText(text);
                                        _textController.clear();
                                      });
                                    }
                                  },
                                  child: const Text("Add Text"),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Role selection section
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Add Role:", 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildRoleSelectionSection(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _builder.currentParts.isNotEmpty
                              ? () {
                                  setState(() {
                                    _builder.clear();
                                  });
                                }
                              : null,
                          child: const Text("Clear"),
                        ),
                        ElevatedButton(
                          onPressed: _builder.currentParts.isNotEmpty
                              ? () => _showSaveDialog(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save Encounter"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Existing encounters list
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Existing Encounters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: encounters.isEmpty
                          ? const Center(
                              child: Text("No encounters created yet"),
                            )
                          : ListView.builder(
                              itemCount: encounters.length,
                              itemBuilder: (context, index) {
                                final encounter = encounters[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(encounter.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(encounter.preview),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          children: encounter.applicableLocations
                                              .map((loc) => Chip(
                                                    label: Text(
                                                      loc.displayName,
                                                      style: const TextStyle(fontSize: 10),
                                                    ),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize.shrinkWrap,
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: encounter.rarity.color,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            encounter.rarity.displayName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        PopupMenuButton(
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'edit':
                                                _editEncounter(encounter);
                                                break;
                                              case 'delete':
                                                _deleteEncounter(encounter);
                                                break;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionSection() {
    // Group roles by category for better organization
    final Map<String, List<Role>> roleCategories = {
      'Shop/Service': [
        Role.owner,
        Role.smith,
        Role.tailor,
        Role.herbalist,
        Role.jeweler,
        Role.generalStoreOwner,
        Role.magicShopOwner,
      ],
      'Tavern': [
        Role.tavernKeeper,
        Role.waitstaff,
        Role.cook,
        Role.entertainment,
        Role.regular,
        Role.customer,
      ],
      'Common Folk': [
        Role.apprentice,
        Role.journeyman,
        Role.beggar,
        Role.streetRat,
        Role.farmer,
        Role.laborer,
      ],
      'Government': [
        Role.townGuard,
        Role.minorNoble,
        Role.government,
      ],
    };

    return Column(
      children: roleCategories.entries.map((category) {
        return ExpansionTile(
          title: Text(
            category.key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          children: category.value.map((role) {
            return ListTile(
              dense: true,
              title: Text(_roleToDisplayName(role)),
              onTap: () {
                setState(() {
                  _builder.addRole(role, article: ''); // No article needed
                });
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  String _roleToDisplayName(Role role) {
    switch (role) {
      case Role.tavernKeeper:
        return 'tavern keeper';
      case Role.generalStoreOwner:
        return 'store owner';
      case Role.streetRat:
        return 'street rat';
      case Role.magicShopOwner:
        return 'magic shop owner';
      case Role.minorNoble:
        return 'minor noble';
      case Role.townGuard:
        return 'town guard';
      case Role.streetFoodVendor:
        return 'street food vendor';
      case Role.spiceMerchant:
        return 'spice merchant';
      default:
        return role.toString().split('.').last;
    }
  }


  void _showSaveDialog(BuildContext context) {
    final nameController = TextEditingController();
    // Use last selections as defaults
    List<LocationType> selectedLocations = List.from(_lastSelectedLocations);
    EncounterRarity selectedRarity = _lastSelectedRarity;
    Set<ShopType> selectedShopTypes = Set.from(_lastSelectedShopTypes);
    final tagsController = TextEditingController();
    Map<Role, List<String>> requiredQuirks = {};

    // Get the roles used in this encounter for quirk selection
    final usedRoles = <Role>{};
    for (final part in _builder.currentParts) {
      if (part.type == EncounterPartType.role && part.role != null) {
        usedRoles.add(part.role!);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Save Encounter"),
          content: SizedBox(
            width: 400,
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Encounter Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location types
                  const Text("Applicable Locations:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      children: [
                        // Non-shop location types
                        ...LocationType.values
                            .where((locType) => locType != LocationType.shop)
                            .map((locType) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(locType.displayName),
                            value: selectedLocations.contains(locType),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedLocations.add(locType);
                                } else {
                                  selectedLocations.remove(locType);
                                }
                              });
                            },
                          );
                        }),
                        
                        // Shop types (broken down by specific type)
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Shop Types:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...ShopType.values.map((shopType) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text('${_shopTypeDisplayName(shopType)} Shop'),
                            value: selectedShopTypes.contains(shopType),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedShopTypes.add(shopType);
                                } else {
                                  selectedShopTypes.remove(shopType);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rarity
                  DropdownButtonFormField<EncounterRarity>(
                    decoration: const InputDecoration(
                      labelText: "Rarity",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRarity,
                    items: EncounterRarity.values.map((rarity) {
                      return DropdownMenuItem(
                        value: rarity,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: rarity.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(rarity.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRarity = value ?? EncounterRarity.common;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: "Tags (comma separated)",
                      border: OutlineInputBorder(),
                      helperText: "e.g., conflict, commerce, social",
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Required Quirks Section
                  if (usedRoles.isNotEmpty) ...[
                    const Text("Required Quirks (Optional):",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Encounter appears if people have ANY of the selected quirks for each role",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final quirks = ref.watch(quirksProvider);
                            
                            return SingleChildScrollView(
                              child: Column(
                                children: usedRoles.map((role) {
                                  return _buildQuirkSelectionTile(role, quirks, requiredQuirks, setState);
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Combine selected locations with shop locations for selected shop types
                final allLocations = List<LocationType>.from(selectedLocations);
                if (selectedShopTypes.isNotEmpty) {
                  // If any shop types are selected, add the general shop location
                  if (!allLocations.contains(LocationType.shop)) {
                    allLocations.add(LocationType.shop);
                  }
                }
                
                if (nameController.text.trim().isNotEmpty && (selectedLocations.isNotEmpty || selectedShopTypes.isNotEmpty)) {
                  // Persist selections for next time
                  _lastSelectedLocations = List.from(selectedLocations);
                  _lastSelectedRarity = selectedRarity;
                  _lastSelectedShopTypes = Set.from(selectedShopTypes);
                  
                  final encounter = _builder.build(
                    name: nameController.text.trim(),
                    locations: allLocations,
                    rarity: selectedRarity,
                    tags: [
                      ...tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty),
                      // Add shop type tags for filtering
                      ...selectedShopTypes.map((shopType) => 'shop_${shopType.name}'),
                    ],
                    requiredQuirks: requiredQuirks,
                  );
                  
                  ref.read(randomEncountersProvider.notifier).add(encounter);
                  
                  setState(() {
                    _builder.clear();
                    _selectedShopTypes.clear();
                  });
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Encounter saved!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please provide name and select at least one location")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _editEncounter(RandomEncounter encounter) {
    // For now, just show encounter details
    // In the future, could implement full editing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${encounter.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Full text: ${encounter.displayText}"),
            const SizedBox(height: 8),
            Text("Locations: ${encounter.applicableLocations.map((l) => l.displayName).join(', ')}"),
            const SizedBox(height: 8),
            Text("Rarity: ${encounter.rarity.displayName}"),
            if (encounter.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Tags: ${encounter.tags.join(', ')}"),
            ],
            if (encounter.requiredQuirks.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Required Quirks:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...encounter.requiredQuirks.entries.map((entry) => 
                Text("${_roleToDisplayName(entry.key)}: ${entry.value.join(', ')}")),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _deleteEncounter(RandomEncounter encounter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Encounter"),
        content: Text("Are you sure you want to delete '${encounter.name}'?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(randomEncountersProvider.notifier).remove(encounter);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Encounter deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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

  Widget _buildQuirkSelectionTile(Role role, List<Quirk> quirks, Map<Role, List<String>> requiredQuirks, StateSetter setState) {
    // Create a local search notifier for this tile
    final searchNotifier = ReactiveSearchNotifier();
    
    // Index all quirks for searching
    for (final quirk in quirks) {
      searchNotifier.insert(quirk.quirk, quirk.id);
    }
    
    return _QuirkSelectionTile(
      role: role,
      quirks: quirks,
      requiredQuirks: requiredQuirks,
      setState: setState,
      searchNotifier: searchNotifier,
      roleToDisplayName: _roleToDisplayName,
    );
  }
}

class _QuirkSelectionTile extends StatefulWidget {
  final Role role;
  final List<Quirk> quirks;
  final Map<Role, List<String>> requiredQuirks;
  final StateSetter setState;
  final ReactiveSearchNotifier searchNotifier;
  final String Function(Role) roleToDisplayName;
  
  const _QuirkSelectionTile({
    required this.role,
    required this.quirks,
    required this.requiredQuirks,
    required this.setState,
    required this.searchNotifier,
    required this.roleToDisplayName,
  });

  @override
  State<_QuirkSelectionTile> createState() => _QuirkSelectionTileState();
}

class _QuirkSelectionTileState extends State<_QuirkSelectionTile> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Quirk> get _filteredQuirks {
    List<Quirk> filteredQuirks;
    if (_searchQuery.isEmpty) {
      // Show all quirks alphabetically
      filteredQuirks = List.from(widget.quirks)
        ..sort((a, b) => a.quirk.toLowerCase().compareTo(b.quirk.toLowerCase()));
    } else {
      // Perform fuzzy search
      final matchingIds = widget.searchNotifier.searchFuzzy(_searchQuery, maxDistance: 2);
      filteredQuirks = widget.quirks.where((quirk) => matchingIds.contains(quirk.id)).toList()
        ..sort((a, b) => a.quirk.toLowerCase().compareTo(b.quirk.toLowerCase()));
    }
    return filteredQuirks;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.roleToDisplayName(widget.role)),
      subtitle: widget.requiredQuirks[widget.role]?.isNotEmpty == true
          ? Text("${widget.requiredQuirks[widget.role]!.length} quirks selected (ANY required)")
          : const Text("No quirks required"),
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search quirks...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        // Quirks list
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _filteredQuirks.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No quirks available' : 'No quirks found matching "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredQuirks.length,
                  itemBuilder: (context, index) {
                    final quirk = _filteredQuirks[index];
                    final isSelected = widget.requiredQuirks[widget.role]?.contains(quirk.quirk) ?? false;
                    
                    return CheckboxListTile(
                      dense: true,
                      title: Text(quirk.quirk, style: const TextStyle(fontSize: 12)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        widget.setState(() {
                          if (widget.requiredQuirks[widget.role] == null) {
                            widget.requiredQuirks[widget.role] = [];
                          }
                          if (value == true) {
                            widget.requiredQuirks[widget.role]!.add(quirk.quirk);
                          } else {
                            widget.requiredQuirks[widget.role]!.remove(quirk.quirk);
                          }
                          // Clean up empty lists
                          if (widget.requiredQuirks[widget.role]!.isEmpty) {
                            widget.requiredQuirks.remove(widget.role);
                          }
                        });
                        // Also update the local state to reflect changes in subtitle
                        setState(() {});
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}