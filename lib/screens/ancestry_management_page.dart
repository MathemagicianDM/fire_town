import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'dart:io';
import '../models/ancestry_model.dart';
import '../providers/barrel_of_providers.dart';
import '../models/names_models.dart';
import '../enums_and_maps.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class AncestryManagementPage extends ConsumerStatefulWidget {
  static const routeName = "/ancestry-management";

  const AncestryManagementPage({super.key});

  @override
  ConsumerState<AncestryManagementPage> createState() => _AncestryManagementPageState();
}

class _AncestryManagementPageState extends ConsumerState<AncestryManagementPage> {
  bool _isLoading = false;

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
      // Initialize the providers
      final ancestriesNotifier = ref.read(ancestriesProvider.notifier);
      await ancestriesNotifier.initialize();

      final givenNamesNotifier = ref.read(givenNamesProvider.notifier);
      await givenNamesNotifier.initialize();

      final surnamesNotifier = ref.read(surnamesProvider.notifier);
      await surnamesNotifier.initialize();

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
  Widget build(BuildContext context) {
    final ancestries = ref.watch(ancestriesProvider);
    final ancestriesNotifier = ref.watch(ancestriesProvider.notifier);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ancestry Management"),
        actions: [
          if (ancestriesNotifier.isDirty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await ancestriesNotifier.commitChanges();
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
              ancestriesNotifier.discardChanges();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Changes discarded")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Ancestry list section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ancestries",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ancestries.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No ancestries found"),
                        ),
                      )
                    else
                      ...ancestries.map(
                        (ancestry) => Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ExpansionTile(
                            title: Text(
                              ancestry.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            subtitle: Text("ID: ${ancestry.id}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.upload_file),
                                  onPressed: () {
                                    _showNameUploadDialog(context, ancestry);
                                  },
                                  tooltip: "Upload Names",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(context, ancestry);
                                  },
                                  tooltip: "Edit",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, ancestry);
                                  },
                                  tooltip: "Delete",
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Age Probabilities:",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    _buildProbabilityRow("Quite Young", ancestry.quiteYoungProb),
                                    _buildProbabilityRow("Young", ancestry.youngProb),
                                    _buildProbabilityRow("Adult", ancestry.adultProb),
                                    _buildProbabilityRow("Middle Age", ancestry.middleAgeProb),
                                    _buildProbabilityRow("Old", ancestry.oldProb),
                                    _buildProbabilityRow("Quite Old", ancestry.quiteOldProb),
                                    const SizedBox(height: 8),
                                    const Text("Pronoun Probabilities:",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    _buildProbabilityRow("He/Him", ancestry.heHimProb),
                                    _buildProbabilityRow("She/Her", ancestry.sheHerProb),
                                    _buildProbabilityRow("They/Them", ancestry.theyThemProb),
                                    _buildProbabilityRow("He/They", ancestry.heTheyProb),
                                    _buildProbabilityRow("She/They", ancestry.sheTheyProb),
                                    const SizedBox(height: 8),
                                    const Text("Relationship Probabilities:",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    _buildProbabilityRow("Partner Within", ancestry.partnerWithinProb),
                                    _buildProbabilityRow("Partner Outside", ancestry.partnerOutsideProb),
                                    _buildProbabilityRow("Breakup", ancestry.breakupProb),
                                    _buildProbabilityRow("No Children", ancestry.noChildrenProb),
                                    _buildProbabilityRow("Children", ancestry.childrenProb),
                                    _buildIntRow("Max Children", ancestry.maxChildren),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        tooltip: "Add New Ancestry",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProbabilityRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("  $label:"),
          Text("${(value * 100).toStringAsFixed(1)}%"),
        ],
      ),
    );
  }

  Widget _buildIntRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("  $label:"),
          Text("$value"),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AncestryFormDialog(
        title: "Add New Ancestry",
        onSave: (ancestry) {
          ref.read(ancestriesProvider.notifier).add(ancestry);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Ancestry ancestry) {
    showDialog(
      context: context,
      builder: (context) => AncestryFormDialog(
        title: "Edit Ancestry",
        existingAncestry: ancestry,
        onSave: (updatedAncestry) {
          ref.read(ancestriesProvider.notifier).replace(ancestry, updatedAncestry);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Ancestry ancestry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Ancestry"),
        content: Text(
          "Are you sure you want to delete the ancestry '${ancestry.name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(ancestriesProvider.notifier).remove(ancestry);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showNameUploadDialog(BuildContext context, Ancestry ancestry) {
    showDialog(
      context: context,
      builder: (context) => NameUploadDialog(ancestry: ancestry),
    );
  }
}

class AncestryFormDialog extends HookConsumerWidget {
  final String title;
  final Ancestry? existingAncestry;
  final Function(Ancestry) onSave;

  const AncestryFormDialog({
    super.key,
    required this.title,
    this.existingAncestry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Text controllers for all fields
    final nameController = useTextEditingController(text: existingAncestry?.name ?? "");
    
    // Age probability controllers
    final quiteYoungController = useTextEditingController(
        text: (existingAncestry?.quiteYoungProb ?? 0.1).toString());
    final youngController = useTextEditingController(
        text: (existingAncestry?.youngProb ?? 0.15).toString());
    final adultController = useTextEditingController(
        text: (existingAncestry?.adultProb ?? 0.4).toString());
    final middleAgeController = useTextEditingController(
        text: (existingAncestry?.middleAgeProb ?? 0.25).toString());
    final oldController = useTextEditingController(
        text: (existingAncestry?.oldProb ?? 0.08).toString());
    final quiteOldController = useTextEditingController(
        text: (existingAncestry?.quiteOldProb ?? 0.02).toString());

    // Pronoun probability controllers
    final heHimController = useTextEditingController(
        text: (existingAncestry?.heHimProb ?? 0.45).toString());
    final sheHerController = useTextEditingController(
        text: (existingAncestry?.sheHerProb ?? 0.45).toString());
    final theyThemController = useTextEditingController(
        text: (existingAncestry?.theyThemProb ?? 0.05).toString());
    final heTheyController = useTextEditingController(
        text: (existingAncestry?.heTheyProb ?? 0.025).toString());
    final sheTheyController = useTextEditingController(
        text: (existingAncestry?.sheTheyProb ?? 0.025).toString());

    // Relationship controllers
    final partnerWithinController = useTextEditingController(
        text: (existingAncestry?.partnerWithinProb ?? 0.6).toString());
    final partnerOutsideController = useTextEditingController(
        text: (existingAncestry?.partnerOutsideProb ?? 0.25).toString());
    final breakupController = useTextEditingController(
        text: (existingAncestry?.breakupProb ?? 0.1).toString());
    final noChildrenController = useTextEditingController(
        text: (existingAncestry?.noChildrenProb ?? 0.3).toString());
    final childrenController = useTextEditingController(
        text: (existingAncestry?.childrenProb ?? 0.7).toString());
    final maxChildrenController = useTextEditingController(
        text: (existingAncestry?.maxChildren ?? 4).toString());

    // Adoption controllers
    final adoptionWithinController = useTextEditingController(
        text: (existingAncestry?.adoptionWithinProb ?? 0.05).toString());
    final adoptionOutsideController = useTextEditingController(
        text: (existingAncestry?.adoptionOutsideProb ?? 0.02).toString());

    // Orientation controllers
    final straightController = useTextEditingController(
        text: (existingAncestry?.straightProb ?? 0.85).toString());
    final queerController = useTextEditingController(
        text: (existingAncestry?.queerProb ?? 0.15).toString());
    final polyController = useTextEditingController(
        text: (existingAncestry?.polyProb ?? 0.05).toString());
    final ifPolyFlipToQueerController = useTextEditingController(
        text: (existingAncestry?.ifPolyFliptoQueerProb ?? 0.5).toString());
    final maxPolyPartnerController = useTextEditingController(
        text: (existingAncestry?.maxPolyPartner ?? 3).toString());

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Ancestry Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Age Probabilities", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildProbabilityField("Quite Young", quiteYoungController),
                _buildProbabilityField("Young", youngController),
                _buildProbabilityField("Adult", adultController),
                _buildProbabilityField("Middle Age", middleAgeController),
                _buildProbabilityField("Old", oldController),
                _buildProbabilityField("Quite Old", quiteOldController),
                const SizedBox(height: 16),
                const Text("Pronoun Probabilities",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildProbabilityField("He/Him", heHimController),
                _buildProbabilityField("She/Her", sheHerController),
                _buildProbabilityField("They/Them", theyThemController),
                _buildProbabilityField("He/They", heTheyController),
                _buildProbabilityField("She/They", sheTheyController),
                const SizedBox(height: 16),
                const Text("Relationship Probabilities",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildProbabilityField("Partner Within", partnerWithinController),
                _buildProbabilityField("Partner Outside", partnerOutsideController),
                _buildProbabilityField("Breakup", breakupController),
                _buildProbabilityField("No Children", noChildrenController),
                _buildProbabilityField("Children", childrenController),
                _buildIntField("Max Children", maxChildrenController),
                const SizedBox(height: 8),
                _buildProbabilityField("Adoption Within", adoptionWithinController),
                _buildProbabilityField("Adoption Outside", adoptionOutsideController),
                const SizedBox(height: 16),
                const Text("Orientation Probabilities",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildProbabilityField("Straight", straightController),
                _buildProbabilityField("Queer", queerController),
                _buildProbabilityField("Poly", polyController),
                _buildProbabilityField("If Poly, Flip to Queer", ifPolyFlipToQueerController),
                _buildIntField("Max Poly Partners", maxPolyPartnerController),
              ],
            ),
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
            if (formKey.currentState!.validate()) {
              try {
                final ancestry = Ancestry(
                  name: nameController.text,
                  id: existingAncestry?.id ?? _uuid.v4(),
                  quiteYoungProb: double.parse(quiteYoungController.text),
                  youngProb: double.parse(youngController.text),
                  adultProb: double.parse(adultController.text),
                  middleAgeProb: double.parse(middleAgeController.text),
                  oldProb: double.parse(oldController.text),
                  quiteOldProb: double.parse(quiteOldController.text),
                  heHimProb: double.parse(heHimController.text),
                  sheHerProb: double.parse(sheHerController.text),
                  theyThemProb: double.parse(theyThemController.text),
                  heTheyProb: double.parse(heTheyController.text),
                  sheTheyProb: double.parse(sheTheyController.text),
                  partnerWithinProb: double.parse(partnerWithinController.text),
                  partnerOutsideProb: double.parse(partnerOutsideController.text),
                  breakupProb: double.parse(breakupController.text),
                  noChildrenProb: double.parse(noChildrenController.text),
                  childrenProb: double.parse(childrenController.text),
                  maxChildren: int.parse(maxChildrenController.text),
                  adoptionWithinProb: double.parse(adoptionWithinController.text),
                  adoptionOutsideProb: double.parse(adoptionOutsideController.text),
                  straightProb: double.parse(straightController.text),
                  queerProb: double.parse(queerController.text),
                  polyProb: double.parse(polyController.text),
                  ifPolyFliptoQueerProb: double.parse(ifPolyFlipToQueerController.text),
                  maxPolyPartner: int.parse(maxPolyPartnerController.text),
                );
                onSave(ancestry);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid input: $e")),
                );
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildProbabilityField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a value";
          }
          final parsed = double.tryParse(value);
          if (parsed == null || parsed < 0 || parsed > 1) {
            return "Please enter a value between 0 and 1";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildIntField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a value";
          }
          final parsed = int.tryParse(value);
          if (parsed == null || parsed < 0) {
            return "Please enter a positive integer";
          }
          return null;
        },
      ),
    );
  }
}

class NameUploadDialog extends HookConsumerWidget {
  final Ancestry ancestry;

  const NameUploadDialog({super.key, required this.ancestry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = useState(false);

    return AlertDialog(
      title: Text("Upload Names for ${ancestry.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Upload YAML files containing names for this ancestry. The files should contain lists of name objects with 'name', 'ancestry', and (for given names) 'pronouns' fields.",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUploading.value
                      ? null
                      : () => _uploadNames(context, ref, ancestry, true, isUploading),
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Given Names"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUploading.value
                      ? null
                      : () => _uploadNames(context, ref, ancestry, false, isUploading),
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Surnames"),
                ),
              ),
            ],
          ),
          if (isUploading.value) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text("Uploading..."),
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
    );
  }

  Future<void> _uploadNames(BuildContext context, WidgetRef ref, Ancestry ancestry, 
      bool isGivenNames, ValueNotifier<bool> isUploading) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        isUploading.value = true;

        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final yamlData = loadYaml(content);

        if (yamlData is! List) {
          throw Exception("YAML file must contain a list of names");
        }

        if (isGivenNames) {
          // Process given names
          final givenNames = <GivenName>[];
          for (final item in yamlData) {
            if (item is Map) {
              final name = item['name']?.toString();
              final ancestryList = item['ancestry'];
              // Handle both 'pronouns' and 'pronounType' field names
              final pronounsList = item['pronouns'] ?? item['pronounType'];

              if (name == null) {
                continue; // Skip invalid entries
              }

              final List<String> ancestries;
              if (ancestryList is String) {
                ancestries = [ancestryList];
              } else if (ancestryList is List) {
                ancestries = ancestryList.cast<String>();
              } else {
                ancestries = [ancestry.name]; // Default to current ancestry
              }

              final List<PronounType> pronouns;
              if (pronounsList is List) {
                pronouns = pronounsList
                    .map((p) => PronounType.values.firstWhere(
                        (v) => v.toString().split('.').last == p.toString(),
                        orElse: () => PronounType.any))
                    .toList();
              } else if (pronounsList is String) {
                // Handle single pronoun as string
                final pronoun = PronounType.values.firstWhere(
                    (v) => v.toString().split('.').last == pronounsList.toString(),
                    orElse: () => PronounType.any);
                pronouns = [pronoun];
              } else {
                pronouns = [PronounType.any]; // Default
              }

              givenNames.add(GivenName(
                name: name,
                ancestry: ancestries,
                pronouns: pronouns,
                id: _uuid.v4(),
              ));
            }
          }

          if (givenNames.isNotEmpty) {
            final provider = ref.read(givenNamesProvider.notifier);
            
            // Get existing given names to append to (not overwrite)
            final existingGivenNames = ref.read(givenNamesProvider);
            
            // Combine existing and new names
            final allGivenNames = [...existingGivenNames, ...givenNames];
            
            // Convert combined list to proper JSON string using jsonEncode
            final jsonList = allGivenNames.map((gn) => gn.toJson()).toList();
            final jsonString = jsonEncode(jsonList);
            await provider.loadFromJsonAndCommit(jsonString);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully uploaded ${givenNames.length} given names (${allGivenNames.length} total)")),
              );
            }
          }
        } else {
          // Process surnames
          final surnames = <Surname>[];
          for (final item in yamlData) {
            if (item is Map) {
              final name = item['name']?.toString();
              final ancestryList = item['ancestry'];

              if (name == null) {
                continue; // Skip invalid entries
              }

              final List<String> ancestries;
              if (ancestryList is String) {
                ancestries = [ancestryList];
              } else if (ancestryList is List) {
                ancestries = ancestryList.cast<String>();
              } else {
                ancestries = [ancestry.name]; // Default to current ancestry
              }

              surnames.add(Surname(
                name: name,
                ancestry: ancestries,
                id: _uuid.v4(),
              ));
            }
          }

          if (surnames.isNotEmpty) {
            final provider = ref.read(surnamesProvider.notifier);
            
            // Get existing surnames to append to (not overwrite)
            final existingSurnames = ref.read(surnamesProvider);
            
            // Combine existing and new surnames
            final allSurnames = [...existingSurnames, ...surnames];
            
            // Convert combined list to proper JSON string using jsonEncode
            final jsonList = allSurnames.map((sn) => sn.toJson()).toList();
            final jsonString = jsonEncode(jsonList);
            await provider.loadFromJsonAndCommit(jsonString);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully uploaded ${surnames.length} surnames (${allSurnames.length} total)")),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading names: $e")),
        );
      }
    } finally {
      isUploading.value = false;
    }
  }
}