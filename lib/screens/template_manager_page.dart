import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/description_template_model.dart';
import '../models/description_constants.dart';
import '../providers/physical_template_provider.dart';
import '../providers/clothing_template_provider.dart';
import '../providers/shop_template_provider.dart';
import '../providers/location_template_provider.dart';
import '../providers/anecestries_provider.dart';
import '../providers/rumor_provider.dart';
import '../models/rumor_template_model.dart';
import '../enums_and_maps.dart';

class TemplateManagerPage extends ConsumerStatefulWidget {
  static const routeName = '/template-manager';
  
  const TemplateManagerPage({super.key});

  @override
  ConsumerState<TemplateManagerPage> createState() => _TemplateManagerPageState();
}

class _TemplateManagerPageState extends ConsumerState<TemplateManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _physicalYamlController = TextEditingController();
  final _clothingYamlController = TextEditingController();
  final _shopYamlController = TextEditingController();
  final _locationYamlController = TextEditingController();
  final _rumorYamlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _physicalYamlController.dispose();
    _clothingYamlController.dispose();
    _shopYamlController.dispose();
    _locationYamlController.dispose();
    _rumorYamlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Physical Templates'),
            Tab(text: 'Clothing Templates'),
            Tab(text: 'Shop Templates'),
            Tab(text: 'Location Templates'),
            Tab(text: 'Import/Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhysicalTemplatesTab(),
          _buildClothingTemplatesTab(),
          _buildShopTemplatesTab(),
          _buildLocationTemplatesTab(),
          _buildImportExportTab(),
        ],
      ),
    );
  }

  Widget _buildPhysicalTemplatesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final physicalTemplates = ref.watch(physicalTemplatesProvider);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Physical Templates (${physicalTemplates.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddTemplateDialog(isPhysical: true),
                    child: const Text('Add Template'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: physicalTemplates.length,
                itemBuilder: (context, index) {
                  final template = physicalTemplates[index];
                  return _buildTemplateCard(template, isPhysical: true);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClothingTemplatesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final clothingTemplates = ref.watch(clothingTemplatesProvider);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Clothing Templates (${clothingTemplates.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddTemplateDialog(isPhysical: false),
                    child: const Text('Add Template'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: clothingTemplates.length,
                itemBuilder: (context, index) {
                  final template = clothingTemplates[index];
                  return _buildTemplateCard(template, isPhysical: false);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImportExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Import Templates from YAML',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // File Upload Buttons Row 1
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickYamlFile(isPhysical: true),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Physical Templates'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickYamlFile(isPhysical: false),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Clothing Templates'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // File Upload Buttons Row 2
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickShopYamlFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Shop Templates'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickLocationYamlFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Location Templates'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rumor Template Upload Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickRumorYamlFile,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Upload Rumor Templates'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Import Button (centered)
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _importTemplates,
                icon: const Icon(Icons.file_download),
                label: const Text('Import All Templates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(dynamic template, {required bool isPhysical}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                    if (value == 'edit') {
                      _showEditTemplateDialog(template, isPhysical: isPhysical);
                    } else if (value == 'delete') {
                      _deleteTemplate(template, isPhysical: isPhysical);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (template.applicableAncestryGroups.isNotEmpty) ...[
                  const Text('Ancestry: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...template.applicableAncestryGroups.map((group) => 
                    Chip(
                      label: Text(group),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                if (template.applicableRoles.isNotEmpty) ...[
                  const Text('Roles: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...template.applicableRoles.map((role) => 
                    Chip(
                      label: Text(enum2String(myEnum: role)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                const Text('Tag: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(template.tag),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTemplateDialog({required bool isPhysical}) {
    final nameController = TextEditingController();
    final tagController = TextEditingController();
    final templateController = TextEditingController();
    final ancestryGroupsController = TextEditingController();
    final rolesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${isPhysical ? "Physical" : "Clothing"} Template'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g., "Flowing ancestry hair"',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    labelText: 'Tag',
                    hintText: isPhysical ? 'e.g., hair, eyes, build' : 'e.g., torso, feet, jewelry',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: templateController,
                  decoration: const InputDecoration(
                    labelText: 'Template String',
                    hintText: 'e.g., "has {ancestry} eyes with piercing gaze"',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ancestryGroupsController,
                  decoration: const InputDecoration(
                    labelText: 'Ancestry Groups (comma-separated)',
                    hintText: 'e.g., has_hair, humanoid (leave empty for all)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rolesController,
                  decoration: const InputDecoration(
                    labelText: 'Roles (comma-separated)',
                    hintText: 'e.g., owner, journeyman (leave empty for all)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || 
                  tagController.text.trim().isEmpty ||
                  templateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name, tag, and template are required')),
                );
                return;
              }

              try {
                final ancestryGroups = ancestryGroupsController.text.trim().isEmpty 
                    ? <String>['all']
                    : ancestryGroupsController.text.split(',').map((s) => s.trim()).toList();

                final roles = rolesController.text.trim().isEmpty 
                    ? <Role>[]
                    : rolesController.text.split(',').map((s) => s.trim()).map((roleName) {
                        return Role.values.firstWhere(
                          (r) => r.toString().split('.').last.toLowerCase() == roleName.toLowerCase(),
                          orElse: () => Role.customer,
                        );
                      }).toList();

                if (isPhysical) {
                  final template = PhysicalTemplate(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableAncestryGroups: ancestryGroups,
                    applicableRoles: roles,
                    templates: [templateController.text.trim()],
                    variables: {},
                  );
                  ref.read(physicalTemplatesProvider.notifier).add(template);
                  await ref.read(physicalTemplatesProvider.notifier).commitChanges();
                } else {
                  final template = ClothingTemplate(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableAncestryGroups: ancestryGroups,
                    applicableRoles: roles,
                    templates: [templateController.text.trim()],
                    variables: {},
                  );
                  ref.read(clothingTemplatesProvider.notifier).add(template);
                  await ref.read(clothingTemplatesProvider.notifier).commitChanges();
                }

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${isPhysical ? "Physical" : "Clothing"} template added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding template: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTemplateDialog(dynamic template, {required bool isPhysical}) {
    final nameController = TextEditingController(text: template.name);
    final tagController = TextEditingController(text: template.tag);
    final templateController = TextEditingController(text: template.templates.first);
    final ancestryGroupsController = TextEditingController(text: template.applicableAncestryGroups.join(', '));
    final rolesController = TextEditingController(text: template.applicableRoles.map((r) => r.toString().split('.').last).join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isPhysical ? "Physical" : "Clothing"} Template'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(
                    labelText: 'Tag',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: templateController,
                  decoration: const InputDecoration(
                    labelText: 'Template String',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ancestryGroupsController,
                  decoration: const InputDecoration(
                    labelText: 'Ancestry Groups (comma-separated)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rolesController,
                  decoration: const InputDecoration(
                    labelText: 'Roles (comma-separated)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || 
                  tagController.text.trim().isEmpty ||
                  templateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name, tag, and template are required')),
                );
                return;
              }

              try {
                final ancestryGroups = ancestryGroupsController.text.trim().isEmpty 
                    ? <String>['all']
                    : ancestryGroupsController.text.split(',').map((s) => s.trim()).toList();

                final roles = rolesController.text.trim().isEmpty 
                    ? <Role>[]
                    : rolesController.text.split(',').map((s) => s.trim()).map((roleName) {
                        return Role.values.firstWhere(
                          (r) => r.toString().split('.').last.toLowerCase() == roleName.toLowerCase(),
                          orElse: () => Role.customer,
                        );
                      }).toList();

                if (isPhysical) {
                  final updatedTemplate = PhysicalTemplate(
                    id: template.id,
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableAncestryGroups: ancestryGroups,
                    applicableRoles: roles,
                    templates: [templateController.text.trim()],
                    variables: template.variables,
                  );
                  ref.read(physicalTemplatesProvider.notifier).replace(template, updatedTemplate);
                  await ref.read(physicalTemplatesProvider.notifier).commitChanges();
                } else {
                  final updatedTemplate = ClothingTemplate(
                    id: template.id,
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableAncestryGroups: ancestryGroups,
                    applicableRoles: roles,
                    templates: [templateController.text.trim()],
                    variables: template.variables,
                  );
                  ref.read(clothingTemplatesProvider.notifier).replace(template, updatedTemplate);
                  await ref.read(clothingTemplatesProvider.notifier).commitChanges();
                }

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${isPhysical ? "Physical" : "Clothing"} template updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating template: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteTemplate(dynamic template, {required bool isPhysical}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (isPhysical) {
          ref.read(physicalTemplatesProvider.notifier).remove(template);
          await ref.read(physicalTemplatesProvider.notifier).commitChanges();
        } else {
          ref.read(clothingTemplatesProvider.notifier).remove(template);
          await ref.read(clothingTemplatesProvider.notifier).commitChanges();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${template.name}"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting template: $e')),
          );
        }
      }
    }
  }


  Future<void> _importTemplates() async {
    print('DEBUG: Import button clicked');
    print('DEBUG: Physical YAML length: ${_physicalYamlController.text.length}');
    print('DEBUG: Clothing YAML length: ${_clothingYamlController.text.length}');
    print('DEBUG: Shop YAML length: ${_shopYamlController.text.length}');
    
    try {
      int totalImported = 0;
      
      // Import physical templates (from file upload)
      if (_physicalYamlController.text.isNotEmpty) {
        final physicalTemplates = await _parsePhysicalTemplates(_physicalYamlController.text);
        if (physicalTemplates.isNotEmpty) {
          print('DEBUG: Adding ${physicalTemplates.length} physical templates');
          for (final template in physicalTemplates) {
            ref.read(physicalTemplatesProvider.notifier).add(template);
          }
          print('DEBUG: Committing physical templates changes');
          await ref.read(physicalTemplatesProvider.notifier).commitChanges();
          print('DEBUG: Physical templates committed successfully');
          totalImported += physicalTemplates.length;
        }
      }

      // Import clothing templates (from file upload)
      if (_clothingYamlController.text.isNotEmpty) {
        final clothingTemplates = await _parseClothingTemplates(_clothingYamlController.text);
        if (clothingTemplates.isNotEmpty) {
          print('DEBUG: Adding ${clothingTemplates.length} clothing templates');
          for (final template in clothingTemplates) {
            ref.read(clothingTemplatesProvider.notifier).add(template);
          }
          print('DEBUG: Committing clothing templates changes');
          await ref.read(clothingTemplatesProvider.notifier).commitChanges();
          print('DEBUG: Clothing templates committed successfully');
          totalImported += clothingTemplates.length;
        }
      }
      
      // Import shop templates (from file upload)
      if (_shopYamlController.text.isNotEmpty) {
        final shopTemplates = await _parseShopTemplates(_shopYamlController.text);
        if (shopTemplates.isNotEmpty) {
          print('DEBUG: Adding ${shopTemplates.length} shop templates');
          for (final template in shopTemplates) {
            await ref.read(shopTemplateProvider.notifier).addTemplate(template);
          }
          print('DEBUG: Shop templates added successfully');
          totalImported += shopTemplates.length;
        }
      }

      // Import location templates (from file upload)
      if (_locationYamlController.text.isNotEmpty) {
        final locationTemplates = await _parseLocationTemplates(_locationYamlController.text);
        if (locationTemplates.isNotEmpty) {
          print('DEBUG: Adding ${locationTemplates.length} location templates');
          for (final template in locationTemplates) {
            ref.read(locationTemplatesProvider.notifier).add(template);
          }
          print('DEBUG: Committing location templates changes');
          await ref.read(locationTemplatesProvider.notifier).commitChanges();
          print('DEBUG: Location templates committed successfully');
          totalImported += locationTemplates.length;
        }
      }
      
      // Import rumor templates (from file upload)
      if (_rumorYamlController.text.isNotEmpty) {
        final rumorTemplates = await _parseRumorTemplates(_rumorYamlController.text);
        if (rumorTemplates.isNotEmpty) {
          print('DEBUG: Adding ${rumorTemplates.length} rumor templates');
          for (final template in rumorTemplates) {
            ref.read(rumorTemplatesProvider.notifier).add(template);
          }
          print('DEBUG: Committing rumor templates changes');
          await ref.read(rumorTemplatesProvider.notifier).commitChanges();
          print('DEBUG: Rumor templates committed successfully');
          totalImported += rumorTemplates.length;
        }
      }
      
      print('DEBUG: Total imported: $totalImported templates');
      
      if (totalImported > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $totalImported templates'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear the text controllers after successful import
        _physicalYamlController.clear();
        _clothingYamlController.clear();
        _shopYamlController.clear();
        _locationYamlController.clear();
        _rumorYamlController.clear();
        
        // Debug: Check provider states after import
        print('DEBUG: Physical templates in provider: ${ref.read(physicalTemplatesProvider).length}');
        print('DEBUG: Clothing templates in provider: ${ref.read(clothingTemplatesProvider).length}');
        print('DEBUG: Shop templates in provider: ${ref.read(shopTemplateProvider).length}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No templates found to import')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import error: $e')),
      );
    }
  }

  Future<List<PhysicalTemplate>> _parsePhysicalTemplates(String yamlContent) async {
    final yamlDoc = loadYaml(yamlContent);
    final templates = <PhysicalTemplate>[];
    
    // Handle both direct list and templates: key structure
    final templateList = yamlDoc is Map && yamlDoc.containsKey('templates') 
        ? yamlDoc['templates'] as List
        : yamlDoc as List;
    
    for (final template in templateList) {
      templates.add(PhysicalTemplate(
        id: const Uuid().v4(),
        name: template['name'] ?? 'Unnamed Template',
        tag: template['tag'] ?? 'general',
        applicableAncestryGroups: List<String>.from(template['applicableAncestryGroups'] ?? ['all']),
        applicableRoles: (template['applicableRoles'] as List?)?.map((roleStr) => 
          Role.values.firstWhere(
            (r) => r.toString().split('.').last == roleStr,
            orElse: () => Role.customer,
          )
        ).toList() ?? [],
        templates: List<String>.from(template['templates'] ?? []),
        variables: Map<String, List<String>>.from(
          (template['variables'] ?? {}).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        ),
      ));
    }
    
    return templates;
  }

  Future<List<ClothingTemplate>> _parseClothingTemplates(String yamlContent) async {
    final yamlDoc = loadYaml(yamlContent);
    final templates = <ClothingTemplate>[];
    
    // Handle both direct list and templates: key structure
    final templateList = yamlDoc is Map && yamlDoc.containsKey('templates') 
        ? yamlDoc['templates'] as List
        : yamlDoc as List;
    
    for (final template in templateList) {
      templates.add(ClothingTemplate(
        id: const Uuid().v4(),
        name: template['name'] ?? 'Unnamed Template',
        tag: template['tag'] ?? 'general',
        applicableAncestryGroups: List<String>.from(template['applicableAncestryGroups'] ?? ['all']),
        applicableRoles: (template['applicableRoles'] as List?)?.map((roleStr) => 
          Role.values.firstWhere(
            (r) => r.toString().split('.').last == roleStr,
            orElse: () => Role.customer,
          )
        ).toList() ?? [],
        templates: List<String>.from(template['templates'] ?? []),
        variables: Map<String, List<String>>.from(
          (template['variables'] ?? {}).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        ),
      ));
    }
    
    return templates;
  }

  Future<List<ShopTemplate>> _parseShopTemplates(String yamlContent) async {
    final yamlDoc = loadYaml(yamlContent);
    final templates = <ShopTemplate>[];
    
    // Handle both direct list and templates: key structure
    final templateList = yamlDoc is Map && yamlDoc.containsKey('templates') 
        ? yamlDoc['templates'] as List
        : yamlDoc as List;
    
    for (final template in templateList) {
      // Parse shop types from strings to enum
      final shopTypes = <ShopType>[];
      if (template['applicableShopTypes'] != null) {
        for (final typeStr in template['applicableShopTypes']) {
          final shopType = ShopType.values.firstWhere(
            (t) => t.toString().split('.').last == typeStr,
            orElse: () => ShopType.tavern, // Default fallback
          );
          shopTypes.add(shopType);
        }
      }
      
      templates.add(ShopTemplate(
        id: const Uuid().v4(),
        name: template['name'] ?? template['templates'].first,
        tag: template['tag'] ?? 'general',
        applicableShopTypes: shopTypes,
        descriptionType: template['descriptionType'] ?? 'inside', // Default to inside if not specified
        templates: List<String>.from(template['templates'] ?? []),
        variables: Map<String, List<String>>.from(
          (template['variables'] ?? {}).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        ),
        promoteIf: List<String>.from(template['promoteIf'] ?? template['promote_if'] ?? []),
        excludeIf: List<String>.from(template['excludeIf'] ?? template['exclude_if'] ?? []),
      ));
    }
    
    return templates;
  }

  Future<List<LocationTemplate>> _parseLocationTemplates(String yamlContent) async {
    final yamlDoc = loadYaml(yamlContent);
    final templates = <LocationTemplate>[];
    
    // Handle both direct list and templates: key structure
    final templateList = yamlDoc is Map && yamlDoc.containsKey('templates') 
        ? yamlDoc['templates'] as List
        : yamlDoc as List;
    
    for (final template in templateList) {
      // Parse location types from strings to enum
      final locationTypes = <LocationType>[];
      if (template['applicableLocationTypes'] != null) {
        for (final typeStr in template['applicableLocationTypes']) {
          final locationType = LocationType.values.firstWhere(
            (t) => t.toString().split('.').last == typeStr,
            orElse: () => LocationType.district, // Default fallback
          );
          locationTypes.add(locationType);
        }
      }
      
      templates.add(LocationTemplate(
        id: const Uuid().v4(),
        name: template['name'] ?? template['templates'].first,
        tag: template['tag'] ?? 'general',
        applicableLocationTypes: locationTypes,
        templates: List<String>.from(template['templates'] ?? []),
        variables: Map<String, List<String>>.from(
          (template['variables'] ?? {}).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        ),
        promoteIf: List<String>.from(template['promoteIf'] ?? template['promote_if'] ?? []),
        excludeIf: List<String>.from(template['excludeIf'] ?? template['exclude_if'] ?? []),
      ));
    }
    
    return templates;
  }

  // File picker methods
  Future<void> _pickYamlFile({required bool isPhysical}) async {
    print('DEBUG: File picker started for ${isPhysical ? "Physical" : "Clothing"} templates');
    
    try {
      // Use withData: true to force reading file content as bytes
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        allowMultiple: false,
        withData: true, // This forces file content to be loaded as bytes
      );

      print('DEBUG: FilePicker result: ${result?.files.length ?? 0} files');
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('DEBUG: File selected: ${file.name}');
        print('DEBUG: File size: ${file.size} bytes');
        print('DEBUG: Has bytes: ${file.bytes != null}');
        print('DEBUG: Has path: ${file.path != null}');
        
        if (file.bytes != null) {
          try {
            final yamlContent = String.fromCharCodes(file.bytes!);
            print('DEBUG: Content length: ${yamlContent.length} characters');
            print('DEBUG: First 100 chars: ${yamlContent.length > 100 ? yamlContent.substring(0, 100) : yamlContent}');
            
            if (isPhysical) {
              _physicalYamlController.text = yamlContent;
            } else {
              _clothingYamlController.text = yamlContent;
            }
            
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isPhysical ? "Physical" : "Clothing"} templates YAML loaded from ${file.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('DEBUG: Error converting bytes to string: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading file content: $e')),
              );
            }
          }
        } else {
          print('DEBUG: No file bytes available - this might be a web browser limitation');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File content not available. Try using the manual YAML input below, or try a different browser.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        print('DEBUG: User cancelled file selection or no files selected');
      }
    } catch (e) {
      print('DEBUG: File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker error: $e')),
        );
      }
    }
  }

  Future<void> _pickShopYamlFile() async {
    print('DEBUG: Shop file picker started');
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        allowMultiple: false,
        withData: true, // Force loading file content as bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('DEBUG: Shop file selected: ${file.name}');
        
        if (file.bytes != null) {
          try {
            final yamlContent = String.fromCharCodes(file.bytes!);
            _shopYamlController.text = yamlContent;
            
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shop templates YAML loaded from ${file.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('DEBUG: Error processing shop file: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading shop file: $e')),
              );
            }
          }
        } else {
          print('DEBUG: No shop file bytes available');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Shop file content not available. Try using manual input below.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('DEBUG: Shop file picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shop file picker error: $e')),
        );
      }
    }
  }


  Widget _buildShopTemplatesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final shopTemplates = ref.watch(shopTemplateProvider);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shop Templates (${shopTemplates.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddShopTemplateDialog(),
                    child: const Text('Add Template'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: shopTemplates.length,
                itemBuilder: (context, index) {
                  final template = shopTemplates[index];
                  return _buildShopTemplateCard(template);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShopTemplateCard(ShopTemplate template) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editShopTemplate(template);
                    } else if (value == 'delete') {
                      _deleteShopTemplate(template);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tag: ${template.tag}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (template.templates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                template.templates.first,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (template.applicableShopTypes.isNotEmpty) ...[
                  const Text('Shop Types: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...template.applicableShopTypes.map((type) => 
                    Chip(
                      label: Text(type.toString().split('.').last),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ] else ...[
                  const Chip(
                    label: Text('All Shop Types'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddShopTemplateDialog() {
    final nameController = TextEditingController();
    final tagController = TextEditingController();
    final templateController = TextEditingController();
    List<ShopType> selectedShopTypes = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Shop Template'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                      hintText: 'e.g., "Lively tavern atmosphere"',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      hintText: 'e.g., atmosphere, clientele, interior',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: templateController,
                    decoration: const InputDecoration(
                      labelText: 'Template String',
                      hintText: 'e.g., "The air fills with hearty laughter and music"',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Shop Types (leave empty for all):'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ShopType.values.map((shopType) {
                      final typeName = shopType.toString().split('.').last;
                      final isSelected = selectedShopTypes.contains(shopType);
                      
                      return FilterChip(
                        label: Text(typeName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedShopTypes.add(shopType);
                            } else {
                              selectedShopTypes.remove(shopType);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || 
                    tagController.text.trim().isEmpty ||
                    templateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name, tag, and template are required')),
                  );
                  return;
                }

                try {
                  final template = ShopTemplate(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableShopTypes: selectedShopTypes,
                    templates: [templateController.text.trim()],
                    variables: {},
                  );
                  await ref.read(shopTemplateProvider.notifier).addTemplate(template);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shop template added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding template: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editShopTemplate(ShopTemplate template) {
    final nameController = TextEditingController(text: template.name);
    final tagController = TextEditingController(text: template.tag);
    final templateController = TextEditingController(text: template.templates.first);
    List<ShopType> selectedShopTypes = List.from(template.applicableShopTypes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Shop Template'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: templateController,
                    decoration: const InputDecoration(
                      labelText: 'Template String',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Shop Types (leave empty for all):'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ShopType.values.map((shopType) {
                      final typeName = shopType.toString().split('.').last;
                      final isSelected = selectedShopTypes.contains(shopType);
                      
                      return FilterChip(
                        label: Text(typeName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedShopTypes.add(shopType);
                            } else {
                              selectedShopTypes.remove(shopType);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || 
                    tagController.text.trim().isEmpty ||
                    templateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name, tag, and template are required')),
                  );
                  return;
                }

                try {
                  final updatedTemplate = ShopTemplate(
                    id: template.id,
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableShopTypes: selectedShopTypes,
                    templates: [templateController.text.trim()],
                    variables: template.variables,
                  );
                  await ref.read(shopTemplateProvider.notifier).updateTemplate(updatedTemplate);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shop template updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating template: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteShopTemplate(ShopTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(shopTemplateProvider.notifier).removeTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${template.name}"')),
        );
      }
    }
  }

  Widget _buildLocationTemplatesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final locationTemplates = ref.watch(locationTemplatesProvider);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location Templates (${locationTemplates.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddLocationTemplateDialog(),
                    child: const Text('Add Template'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: locationTemplates.length,
                itemBuilder: (context, index) {
                  final template = locationTemplates[index];
                  return _buildLocationTemplateCard(template);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationTemplateCard(LocationTemplate template) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editLocationTemplate(template);
                    } else if (value == 'delete') {
                      _deleteLocationTemplate(template);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tag: ${template.tag}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (template.templates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                template.templates.first,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (template.applicableLocationTypes.isNotEmpty) ...[
                  const Text('Location Types: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...template.applicableLocationTypes.map((type) => 
                    Chip(
                      label: Text(type.toString().split('.').last),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ] else ...[
                  const Chip(
                    label: Text('All Location Types'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationTemplateDialog() {
    final nameController = TextEditingController();
    final tagController = TextEditingController();
    final templateController = TextEditingController();
    List<LocationType> selectedLocationTypes = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Location Template'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                      hintText: 'e.g., "Bustling marketplace atmosphere"',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      hintText: 'e.g., atmosphere, architecture, history',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: templateController,
                    decoration: const InputDecoration(
                      labelText: 'Template String',
                      hintText: 'e.g., "The air fills with {activity} and {ambiance}"',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Location Types (leave empty for all):'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: LocationType.values.map((locationType) {
                      final typeName = locationType.toString().split('.').last;
                      final isSelected = selectedLocationTypes.contains(locationType);
                      
                      return FilterChip(
                        label: Text(typeName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedLocationTypes.add(locationType);
                            } else {
                              selectedLocationTypes.remove(locationType);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || 
                    tagController.text.trim().isEmpty ||
                    templateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name, tag, and template are required')),
                  );
                  return;
                }

                try {
                  final template = LocationTemplate(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableLocationTypes: selectedLocationTypes,
                    templates: [templateController.text.trim()],
                    variables: {},
                  );
                  ref.read(locationTemplatesProvider.notifier).add(template);
                  await ref.read(locationTemplatesProvider.notifier).commitChanges();

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location template added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding template: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editLocationTemplate(LocationTemplate template) {
    final nameController = TextEditingController(text: template.name);
    final tagController = TextEditingController(text: template.tag);
    final templateController = TextEditingController(text: template.templates.first);
    List<LocationType> selectedLocationTypes = List.from(template.applicableLocationTypes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Location Template'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: templateController,
                    decoration: const InputDecoration(
                      labelText: 'Template String',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Location Types (leave empty for all):'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: LocationType.values.map((locationType) {
                      final typeName = locationType.toString().split('.').last;
                      final isSelected = selectedLocationTypes.contains(locationType);
                      
                      return FilterChip(
                        label: Text(typeName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedLocationTypes.add(locationType);
                            } else {
                              selectedLocationTypes.remove(locationType);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || 
                    tagController.text.trim().isEmpty ||
                    templateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name, tag, and template are required')),
                  );
                  return;
                }

                try {
                  final updatedTemplate = LocationTemplate(
                    id: template.id,
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    applicableLocationTypes: selectedLocationTypes,
                    templates: [templateController.text.trim()],
                    variables: template.variables,
                  );
                  ref.read(locationTemplatesProvider.notifier).replace(template, updatedTemplate);
                  await ref.read(locationTemplatesProvider.notifier).commitChanges();

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location template updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating template: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLocationTemplate(LocationTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        ref.read(locationTemplatesProvider.notifier).remove(template);
        await ref.read(locationTemplatesProvider.notifier).commitChanges();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${template.name}"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting template: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickLocationYamlFile() async {
    print('DEBUG: Location file picker started');
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('DEBUG: Location file selected: ${file.name}');
        
        if (file.bytes != null) {
          try {
            final yamlContent = String.fromCharCodes(file.bytes!);
            _locationYamlController.text = yamlContent;
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location templates YAML loaded from ${file.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('DEBUG: Error processing location file: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading location file: $e')),
              );
            }
          }
        } else {
          print('DEBUG: No location file bytes available');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location file content not available. Try using manual input.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('DEBUG: Location file picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location file picker error: $e')),
        );
      }
    }
  }

  Future<void> _pickRumorYamlFile() async {
    print('DEBUG: Rumor template file picker started');
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('DEBUG: Rumor template file selected: ${file.name}');
        
        if (file.bytes != null) {
          try {
            final yamlContent = String.fromCharCodes(file.bytes!);
            _rumorYamlController.text = yamlContent;
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rumor templates YAML loaded from ${file.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('DEBUG: Error processing rumor template file: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error reading rumor template file: $e')),
              );
            }
          }
        } else {
          print('DEBUG: No rumor template file bytes available');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rumor template file content not available.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('DEBUG: Rumor template file picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rumor template file picker error: $e')),
        );
      }
    }
  }

  Future<List<RumorTemplate>> _parseRumorTemplates(String yamlContent) async {
    try {
      final dynamic yamlData = loadYaml(yamlContent);
      final List<RumorTemplate> templates = [];

      if (yamlData is List) {
        for (final item in yamlData) {
          if (item is Map) {
            templates.add(RumorTemplate(
              id: item['id'] ?? '',
              template: item['template'] ?? '',
              tags: List<String>.from(item['tags'] ?? []),
              variables: Map<String, List<String>>.from(
                (item['variables'] as Map?)?.map(
                  (key, value) => MapEntry(key.toString(), List<String>.from(value)),
                ) ?? {},
              ),
              requiredRoles: List<String>.from(item['required_roles'] ?? []),
              requiredLocations: List<String>.from(item['required_locations'] ?? []),
            ));
          }
        }
      }

      return templates;
    } catch (e) {
      print('Error parsing rumor templates: $e');
      return [];
    }
  }
}