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
import '../providers/anecestries_provider.dart';
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
  final _validationResults = <String>[];
  final _previewResults = <String>[];
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _physicalYamlController.dispose();
    _clothingYamlController.dispose();
    _shopYamlController.dispose();
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
          
          // File Upload Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickYamlFile(isPhysical: true),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Physical Templates YAML'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickYamlFile(isPhysical: false),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Clothing Templates YAML'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickShopYamlFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Shop Templates YAML'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Import Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _previewTemplates,
                  child: _isValidating 
                    ? const CircularProgressIndicator()
                    : const Text('Preview'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _validateTemplates,
                  child: _isValidating 
                    ? const CircularProgressIndicator()
                    : const Text('Validate'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _importTemplates,
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Preview Results
          if (_previewResults.isNotEmpty) ...[
            Text(
              'Template Preview:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _previewResults.map((result) => 
                  Text(result, style: const TextStyle(fontSize: 12))
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Validation Results
          if (_validationResults.isNotEmpty) ...[
            Text(
              'Validation Results:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _validationResults.map((result) => 
                  Text(result, style: const TextStyle(fontSize: 12))
                ).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Export Section
          Text(
            'Export Templates',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _exportPhysicalTemplates,
                  child: const Text('Export Physical Templates'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _exportClothingTemplates,
                  child: const Text('Export Clothing Templates'),
                ),
              ),
            ],
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

  Future<void> _validateTemplates() async {
    setState(() {
      _isValidating = true;
      _validationResults.clear();
    });

    try {
      final ancestries = ref.read(ancestriesProvider).map((a) => a.name).toList();
      
      // Validate physical templates
      if (_physicalYamlController.text.isNotEmpty) {
        final physicalValidation = await _validateYaml(
          _physicalYamlController.text,
          isPhysical: true,
          ancestries: ancestries,
        );
        _validationResults.addAll(physicalValidation);
      }

      // Validate clothing templates
      if (_clothingYamlController.text.isNotEmpty) {
        final clothingValidation = await _validateYaml(
          _clothingYamlController.text,
          isPhysical: false,
          ancestries: ancestries,
        );
        _validationResults.addAll(clothingValidation);
      }
      
      // Validate shop templates
      if (_shopYamlController.text.isNotEmpty) {
        final shopValidation = await _validateShopYaml(_shopYamlController.text);
        _validationResults.addAll(shopValidation);
      }

      if (_validationResults.isEmpty) {
        _validationResults.add('✅ All templates are valid!');
      }
    } catch (e) {
      _validationResults.add('❌ Validation error: $e');
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  Future<List<String>> _validateYaml(
    String yamlContent,
    {required bool isPhysical, required List<String> ancestries}
  ) async {
    final results = <String>[];
    
    try {
      final yamlDoc = loadYaml(yamlContent);
      
      if (yamlDoc is! List) {
        results.add('❌ YAML must contain a list of templates');
        return results;
      }

      for (int i = 0; i < yamlDoc.length; i++) {
        final template = yamlDoc[i];
        final prefix = isPhysical ? 'Physical' : 'Clothing';
        
        if (template is! Map) {
          results.add('❌ $prefix template $i: must be a map/object');
          continue;
        }

        // Validate required fields
        if (!template.containsKey('template') || template['template'] == null) {
          results.add('❌ $prefix template $i: missing required "template" field');
          continue;
        }

        if (!template.containsKey('tags') || template['tags'] is! List) {
          results.add('❌ $prefix template $i: missing or invalid "tags" field (must be a list)');
          continue;
        }

        // Validate ancestry groups
        if (template.containsKey('ancestry_groups') && template['ancestry_groups'] is List) {
          final ancestryGroups = template['ancestry_groups'] as List;
          for (final group in ancestryGroups) {
            if (!AncestryGroups.allGroups.contains(group)) {
              results.add('⚠️  $prefix template $i: unknown ancestry group "$group"');
            }
          }
        }

        // Validate roles
        if (template.containsKey('roles') && template['roles'] is List) {
          final roles = template['roles'] as List;
          for (final role in roles) {
            if (!Role.values.any((r) => r.name == role)) {
              results.add('⚠️  $prefix template $i: unknown role "$role"');
            }
          }
        }

        // Validate tags
        final validTags = isPhysical ? DescriptionTags.physicalTags : DescriptionTags.clothingTags;
        final templateTags = template['tags'] as List;
        for (final tag in templateTags) {
          if (!validTags.contains(tag)) {
            results.add('⚠️  $prefix template $i: unknown tag "$tag"');
          }
        }
      }

      if (results.isEmpty) {
        results.add('✅ ${yamlDoc.length} ${isPhysical ? "Physical" : "Clothing"} templates validated successfully');
      }
    } catch (e) {
      results.add('❌ ${isPhysical ? "Physical" : "Clothing"} YAML parsing error: $e');
    }

    return results;
  }

  Future<List<String>> _validateShopYaml(String yamlContent) async {
    final results = <String>[];
    
    try {
      final yamlDoc = loadYaml(yamlContent);
      
      if (yamlDoc is! List) {
        results.add('❌ YAML must contain a list of templates');
        return results;
      }

      for (int i = 0; i < yamlDoc.length; i++) {
        final template = yamlDoc[i];
        
        if (template is! Map) {
          results.add('❌ Shop template $i: must be a map/object');
          continue;
        }

        // Validate required fields
        if (!template.containsKey('templates') || template['templates'] is! List) {
          results.add('❌ Shop template $i: missing or invalid "templates" field (must be a list)');
          continue;
        }

        if (!template.containsKey('tag') || template['tag'] == null) {
          results.add('❌ Shop template $i: missing required "tag" field');
          continue;
        }

        // Validate shop types
        if (template.containsKey('applicableShopTypes') && template['applicableShopTypes'] is List) {
          final shopTypes = template['applicableShopTypes'] as List;
          for (final type in shopTypes) {
            if (!ShopType.values.any((t) => t.toString().split('.').last == type)) {
              results.add('⚠️  Shop template $i: unknown shop type "$type"');
            }
          }
        }
      }

      if (results.isEmpty) {
        results.add('✅ ${yamlDoc.length} Shop templates validated successfully');
      }
    } catch (e) {
      results.add('❌ Shop YAML parsing error: $e');
    }

    return results;
  }

  Future<void> _previewUploadedFile(String yamlContent, String type) async {
    print('DEBUG: Starting preview for $type templates');
    print('DEBUG: YAML content length: ${yamlContent.length}');
    
    setState(() {
      _previewResults.clear();
    });

    try {
      final yamlDoc = loadYaml(yamlContent);
      print('DEBUG: YAML parsed successfully, type: ${yamlDoc.runtimeType}');
      
      if (yamlDoc is List) {
        print('DEBUG: Found ${yamlDoc.length} templates in list');
        _previewResults.add('📁 $type Templates File Preview:');
        _previewResults.add('📊 Found ${yamlDoc.length} templates');
        _previewResults.add('');
        
        for (int i = 0; i < yamlDoc.length && i < 5; i++) { // Show first 5
          final template = yamlDoc[i];
          if (template is Map) {
            final name = template['name'] ?? 'Unnamed';
            final tag = template['tag'] ?? 'No tag';
            final templateString = template['templates']?.first ?? template['template'] ?? 'No template';
            
            _previewResults.add('${i + 1}. Name: $name');
            _previewResults.add('   Tag: $tag');
            _previewResults.add('   Template: ${templateString.length > 50 ? "${templateString.substring(0, 50)}..." : templateString}');
            
            if (type != 'Shop') {
              final ancestries = template['applicableAncestryGroups'] ?? template['ancestry_groups'] ?? [];
              final roles = template['applicableRoles'] ?? template['roles'] ?? [];
              if (ancestries.isNotEmpty) _previewResults.add('   Ancestries: ${ancestries.join(", ")}');
              if (roles.isNotEmpty) _previewResults.add('   Roles: ${roles.join(", ")}');
            } else {
              final shopTypes = template['applicableShopTypes'] ?? [];
              if (shopTypes.isNotEmpty) _previewResults.add('   Shop Types: ${shopTypes.join(", ")}');
            }
            _previewResults.add('');
          }
        }
        
        if (yamlDoc.length > 5) {
          _previewResults.add('... and ${yamlDoc.length - 5} more templates');
        }
      } else {
        print('DEBUG: YAML doc is not a list, type: ${yamlDoc.runtimeType}');
        print('DEBUG: YAML content: $yamlDoc');
        _previewResults.add('❌ Invalid YAML format - expected a list of templates');
        _previewResults.add('Found: ${yamlDoc.runtimeType}');
      }
    } catch (e) {
      print('DEBUG: YAML parsing error: $e');
      _previewResults.add('❌ Error parsing YAML: $e');
    }

    setState(() {
      print('DEBUG: Preview results: ${_previewResults.length} items');
    });
  }

  Future<void> _previewTemplates() async {
    setState(() {
      _isValidating = true;
      _previewResults.clear();
    });

    try {
      // Preview physical templates
      if (_physicalYamlController.text.isNotEmpty) {
        await _previewUploadedFile(_physicalYamlController.text, 'Physical');
      }

      // Preview clothing templates
      if (_clothingYamlController.text.isNotEmpty) {
        await _previewUploadedFile(_clothingYamlController.text, 'Clothing');
      }
      
      // Preview shop templates
      if (_shopYamlController.text.isNotEmpty) {
        await _previewUploadedFile(_shopYamlController.text, 'Shop');
      }

      if (_previewResults.isEmpty) {
        _previewResults.add('ℹ️ No templates loaded to preview');
      }
    } catch (e) {
      _previewResults.add('❌ Preview error: $e');
    } finally {
      setState(() {
        _isValidating = false;
      });
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
    
    for (final template in yamlDoc) {
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
    
    for (final template in yamlDoc) {
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
    
    for (final template in yamlDoc) {
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

  void _exportPhysicalTemplates() {
    final templates = ref.read(physicalTemplatesProvider);
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export ${templates.length} physical templates - TODO')),
    );
  }

  void _exportClothingTemplates() {
    final templates = ref.read(clothingTemplatesProvider);
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export ${templates.length} clothing templates - TODO')),
    );
  }

  // Debug test method
  Future<void> _testFilePickerDebug() async {
    print('DEBUG: Testing FilePicker...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check console/logs for debug information')),
    );
    
    try {
      print('DEBUG: Platform: ${Theme.of(context).platform}');
      
      // Test with any file type first
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      
      print('DEBUG: Any file result: ${result?.files.length ?? 0}');
      if (result != null) {
        print('DEBUG: File name: ${result.files.single.name}');
        print('DEBUG: File extension: ${result.files.single.extension}');
        print('DEBUG: File size: ${result.files.single.size}');
        print('DEBUG: Has bytes: ${result.files.single.bytes != null}');
        print('DEBUG: Has path: ${result.files.single.path != null}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File selected: ${result.files.single.name}')),
          );
        }
      } else {
        print('DEBUG: No file selected');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
        }
      }
    } catch (e) {
      print('DEBUG: FilePicker test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FilePicker error: $e')),
        );
      }
    }
  }

  static const String _physicalTemplateExample = '''# Physical Template Example
- template: "has {ancestry} eyes with {color} irises"
  ancestry_groups: ["humanoid"]
  roles: []
  tags: ["eyes"]

- template: "sports a magnificent {color} beard decorated with {ancestry} jewelry"
  ancestry_groups: ["has_beard"]
  roles: ["owner", "journeyman"]
  tags: ["facial_hair", "jewelry"]

- template: "has {build} build and calloused hands from years of work"
  ancestry_groups: ["humanoid"]
  roles: ["smith", "journeyman"]
  tags: ["build", "hands"]''';

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
            
            // Auto-preview the uploaded file
            await _previewUploadedFile(yamlContent, isPhysical ? 'Physical' : 'Clothing');
            
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
            
            // Auto-preview the uploaded file
            await _previewUploadedFile(yamlContent, 'Shop');
            
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

  static const String _clothingTemplateExample = '''# Clothing Template Example
- template: "wears a leather apron stained with soot and metal shavings"
  ancestry_groups: ["all"]
  roles: ["smith"]
  tags: ["torso"]

- template: "adorned with {ancestry} ceremonial jewelry"
  ancestry_groups: ["humanoid"]
  roles: ["owner", "noble"]
  tags: ["jewelry"]

- template: "wears practical {color} clothing suitable for {role} work"
  ancestry_groups: ["all"]
  roles: ["journeyman", "apprentice"]
  tags: ["torso", "legs"]''';

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
}