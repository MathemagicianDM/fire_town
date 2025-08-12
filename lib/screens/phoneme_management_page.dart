import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import '../models/given_name_phonemes.dart';
import '../providers/phoneme_provider.dart';
import '../providers/barrel_of_providers.dart';
// import "dart:convert";
import "phoneme_form_page.dart"; // Assuming this has your ancestriesProvider
// Add this import at the top of your file
import 'package:yaml_writer/yaml_writer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// YAML export function

class PhonemeManagementPage extends ConsumerStatefulWidget {
  static const routeName = "/phoneme-management";

  const PhonemeManagementPage({super.key});

  @override
  _PhonemeManagementPageState createState() => _PhonemeManagementPageState();
}

class _PhonemeManagementPageState extends ConsumerState<PhonemeManagementPage> {
  bool _isInitialized = false;
  bool _isLoading = false;

  // Filter state
  Set<String> _selectedAncestryFilters = {};
  Set<String> _selectedPronounFilters = {};
  Set<SyllableType> _selectedSyllableTypeFilters = {};
  bool _showFilters = false;

  // Random name generation
  String? _selectedAncestryForName;
  String? _selectedPronounForName;
  List<String> _generatedNames = [];
  bool _useOnlyLockedPhonemes = false;

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
      final givenNameElementsNotifier = ref.read(
        givenNameElementsProvider.notifier,
      );
      await givenNameElementsNotifier.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final givenNameElements = ref.watch(givenNameElementsProvider);
    final ancestries = ref.watch(ancestriesProvider);
    final givenNameElementsNotifier = ref.watch(
      givenNameElementsProvider.notifier,
    );

    // Define pronouns - in a real app, you might get these from a provider
    final pronounTypes = [
      "heHim",
      "sheHer",
      "theyThem",
      "heThey",
      "sheThey",
      "any",
    ];

    // Filter elements based on selected filters
    final filteredElements =
        givenNameElements.where((element) {
          // If no filters are selected, show all elements
          if (_selectedAncestryFilters.isEmpty &&
              _selectedPronounFilters.isEmpty &&
              _selectedSyllableTypeFilters.isEmpty) {
            return true;
          }

          // Check if element matches ancestry filter
          bool matchesAncestry =
              _selectedAncestryFilters.isEmpty ||
              element.applicableAncestries.any(
                (a) => _selectedAncestryFilters.contains(a),
              );

          // Check if element matches pronoun filter
          bool matchesPronoun =
              _selectedPronounFilters.isEmpty ||
              element.applicablePronouns.any(
                (p) => _selectedPronounFilters.contains(p),
              );

          // Check if element matches syllable type filter
          bool matchesSyllableType =
              _selectedSyllableTypeFilters.isEmpty ||
              element.applicableSyllableTypes.any(
                (t) => _selectedSyllableTypeFilters.contains(t),
              );

          return matchesAncestry && matchesPronoun && matchesSyllableType;
        }).toList();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Phoneme Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (givenNameElementsNotifier.isDirty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await givenNameElementsNotifier.commitChanges();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Changes saved successfully!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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
              givenNameElementsNotifier.discardChanges();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Changes discarded")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters and name generator in a scrollable area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Filters section
                  if (_showFilters)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Filter Phonemes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Ancestry filter
                          const Text(
                            "Ancestries:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8.0,
                            children:
                                ancestries.map((ancestry) {
                                  return FilterChip(
                                    label: Text(ancestry.name),
                                    selected: _selectedAncestryFilters.contains(
                                      ancestry.name,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedAncestryFilters.add(
                                            ancestry.name,
                                          );
                                        } else {
                                          _selectedAncestryFilters.remove(
                                            ancestry.name,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),

                          // Pronoun filter
                          const SizedBox(height: 8),
                          const Text(
                            "Pronouns:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8.0,
                            children:
                                pronounTypes.map((pronoun) {
                                  return FilterChip(
                                    label: Text(pronoun),
                                    selected: _selectedPronounFilters.contains(
                                      pronoun,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedPronounFilters.add(pronoun);
                                        } else {
                                          _selectedPronounFilters.remove(
                                            pronoun,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),

                          // Syllable type filter
                          const SizedBox(height: 8),
                          const Text(
                            "Syllable Types:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8.0,
                            children:
                                SyllableType.values.map((type) {
                                  return FilterChip(
                                    label: Text(type.name),
                                    selected: _selectedSyllableTypeFilters
                                        .contains(type),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedSyllableTypeFilters.add(
                                            type,
                                          );
                                        } else {
                                          _selectedSyllableTypeFilters.remove(
                                            type,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),

                          // Clear filters button
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAncestryFilters.clear();
                                _selectedPronounFilters.clear();
                                _selectedSyllableTypeFilters.clear();
                              });
                            },
                            child: const Text("Clear All Filters"),
                          ),
                        ],
                      ),
                    ),

                  // Random name generator section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Random Name Generator",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Lock toggle for phonemes
                            SwitchListTile(
                              title: const Text("Prioritize locked phonemes"),
                              subtitle: const Text(
                                "When enabled, locked phonemes will always be used if available for their position",
                              ),
                              value: _useOnlyLockedPhonemes,
                              secondary: Icon(
                                _useOnlyLockedPhonemes
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color:
                                    _useOnlyLockedPhonemes
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _useOnlyLockedPhonemes = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Ancestry dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Ancestry',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedAncestryForName,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("-- Select Ancestry --"),
                                ),
                                ...ancestries.map((ancestry) {
                                  return DropdownMenuItem<String>(
                                    value: ancestry.name,
                                    child: Text(ancestry.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAncestryForName = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Pronoun dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Pronoun Type',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedPronounForName,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("-- Select Pronoun --"),
                                ),
                                ...pronounTypes.map((pronoun) {
                                  return DropdownMenuItem<String>(
                                    value: pronoun,
                                    child: Text(pronoun),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPronounForName = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Generate button
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      (_selectedAncestryForName != null &&
                                              _selectedPronounForName != null)
                                          ? () {
                                            _generateRandomNames(
                                              givenNameElements,
                                            );
                                          }
                                          : null,
                                  child: const Text("Generate 10 Random Names"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      (_selectedAncestryForName != null &&
                                              _selectedPronounForName != null)
                                          ? () {
                                                      _exportAllPossibleNamesAsYaml(givenNameElements);
(
                                            );
                                          }
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .teal, // Different color to distinguish it
                                  ),
                                  child: const Text("Export All Names"),
                                ),
                                if (_generatedNames.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _generatedNames.clear();
                                        });
                                      },
                                      child: const Text("Clear"),
                                    ),
                                  ),
                              ],
                            ),

                            // Generated names
                            if (_generatedNames.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text(
                                "Generated Names:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(_generatedNames.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    "${index + 1}. ${_generatedNames[index]}",
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Phoneme list section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Phoneme List",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (filteredElements.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No matching phonemes found"),
                            ),
                          )
                        else
                          ...filteredElements
                              .map(
                                (element) => Card(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              element.phoneme,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.headlineMedium,
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    element.isLocked
                                                        ? Icons.lock
                                                        : Icons.lock_open,
                                                    color:
                                                        element.isLocked
                                                            ? Colors.green
                                                            : Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    final updatedElement =
                                                        element.copyWith(
                                                          isLocked:
                                                              !element.isLocked,
                                                        );
                                                    ref
                                                        .read(
                                                          givenNameElementsProvider
                                                              .notifier,
                                                        )
                                                        .replace(
                                                          element,
                                                          updatedElement,
                                                        );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    _showEditDialog(
                                                      context,
                                                      element,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  onPressed: () {
                                                    _showDeleteConfirmation(
                                                      context,
                                                      element,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ExpansionTile(
                                          title: const Text("Details"),
                                          initiallyExpanded: false,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Syllable Types: ${element.applicableSyllableTypes.map((t) => t.name).join(", ")}",
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Ancestries: ${element.applicableAncestries.join(", ")}",
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Pronouns: ${element.applicablePronouns.join(", ")}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _generateRandomNames(List<GivenNameElement> allElements) {
    if (_selectedAncestryForName == null || _selectedPronounForName == null) {
      return;
    }

    final random = Random();
    List<String> names = [];

    // Filter elements by the selected ancestry, pronoun, and lock status
    final firstPhonemes =
        allElements
            .where(
              (element) =>
                  element.applicableSyllableTypes.contains(
                    SyllableType.first,
                  ) &&
                  element.applicableAncestries.contains(
                    _selectedAncestryForName,
                  ) &&
                  element.applicablePronouns.contains(_selectedPronounForName),
            )
            .toList();

    if (_useOnlyLockedPhonemes &&
        firstPhonemes.where((element) => element.isLocked).isNotEmpty) {
      firstPhonemes.retainWhere((element) => element.isLocked);
    }

    final middlePhonemes =
        allElements
            .where(
              (element) =>
                  element.applicableSyllableTypes.contains(
                    SyllableType.middle,
                  ) &&
                  element.applicableAncestries.contains(
                    _selectedAncestryForName,
                  ) &&
                  element.applicablePronouns.contains(_selectedPronounForName),
            )
            .toList();

    if (_useOnlyLockedPhonemes &&
        middlePhonemes.where((element) => element.isLocked).isNotEmpty) {
      middlePhonemes.retainWhere((element) => element.isLocked);
    }

    final lastPhonemes =
        allElements
            .where(
              (element) =>
                  element.applicableSyllableTypes.contains(SyllableType.last) &&
                  element.applicableAncestries.contains(
                    _selectedAncestryForName,
                  ) &&
                  element.applicablePronouns.contains(_selectedPronounForName),
            )
            .toList();

    if (_useOnlyLockedPhonemes &&
        lastPhonemes.where((element) => element.isLocked).isNotEmpty) {
      lastPhonemes.retainWhere((element) => element.isLocked);
    }

    // Generate 10 random names
    for (int i = 0; i < 10; i++) {
      if (firstPhonemes.isEmpty || lastPhonemes.isEmpty) {
        // print(firstPhonemes.isEmpty);
        // print(lastPhonemes.isEmpty);
        setState(() {
          if (_useOnlyLockedPhonemes) {
            _generatedNames = [
              "Not enough locked phonemes to generate names. Try unlocking the filter or locking more phonemes.",
            ];
          } else {
            _generatedNames = ["Not enough phonemes to generate names"];
          }
        });
        return;
      }

      // Randomly decide if we want to include a middle phoneme (70% chance)
      bool includeMiddle =
          middlePhonemes.isNotEmpty && random.nextDouble() < 0.7;

      // Select random phonemes
      String firstName =
          firstPhonemes[random.nextInt(firstPhonemes.length)].phoneme;
      String? middleName =
          includeMiddle
              ? middlePhonemes[random.nextInt(middlePhonemes.length)].phoneme
              : null;
      String lastName =
          lastPhonemes[random.nextInt(lastPhonemes.length)].phoneme;

      // Construct the name
      String fullName =
          middleName != null
              ? "$firstName$middleName$lastName"
              : "$firstName$lastName";

      names.add(fullName);
    }

    setState(() {
      _generatedNames = names;
    });
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => PhonemeFormDialog(
            title: "Add New Phoneme",
            onSave: (element) {
              ref.read(givenNameElementsProvider.notifier).add(element);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _showEditDialog(BuildContext context, GivenNameElement element) {
    showDialog(
      context: context,
      builder:
          (context) => PhonemeFormDialog(
            title: "Edit Phoneme",
            existingElement: element,
            onSave: (updatedElement) {
              ref
                  .read(givenNameElementsProvider.notifier)
                  .replace(element, updatedElement);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GivenNameElement element) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Phoneme"),
            content: Text(
              "Are you sure you want to delete the phoneme '${element.phoneme}'?",
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
                  ref.read(givenNameElementsProvider.notifier).remove(element);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  // Add this method to your PhonemeManagementPage class
  void _exportAllPossibleNames(List<GivenNameElement> allElements) async {
    if (_selectedAncestryForName == null || _selectedPronounForName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an ancestry and pronoun type first"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter elements by the selected ancestry, pronoun, and lock status - same as in _generateRandomNames
      final firstPhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.first,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          firstPhonemes.where((element) => element.isLocked).isNotEmpty) {
        firstPhonemes.retainWhere((element) => element.isLocked);
      }

      final middlePhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.middle,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          middlePhonemes.where((element) => element.isLocked).isNotEmpty) {
        middlePhonemes.retainWhere((element) => element.isLocked);
      }

      final lastPhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.last,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          lastPhonemes.where((element) => element.isLocked).isNotEmpty) {
        lastPhonemes.retainWhere((element) => element.isLocked);
      }

      // Check if we have enough phonemes
      if (firstPhonemes.isEmpty || lastPhonemes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _useOnlyLockedPhonemes
                  ? "Not enough locked phonemes available. Try unlocking the filter or locking more phonemes."
                  : "Not enough phonemes available to generate names.",
            ),
          ),
        );
        return;
      }

      // Generate all possible combinations
      List<Map<String, dynamic>> allNames = [];
      int count = 0;
      final int maxNames =
          10000; // Safety limit to prevent generating too many names

      // Without middle phonemes
      for (final first in firstPhonemes) {
        for (final last in lastPhonemes) {
          if (count >= maxNames) break;

          final name = "${first.phoneme}${last.phoneme}";
          allNames.add({
            "name": name,
            "ancestry": _selectedAncestryForName,
            "pronounType": _selectedPronounForName,
            "components": {"first": first.phoneme, "last": last.phoneme},
            "locked": false,
          });
          count++;
        }
        if (count >= maxNames) break;
      }

      // With middle phonemes (only if we have middle phonemes)
      if (middlePhonemes.isNotEmpty) {
        for (final first in firstPhonemes) {
          for (final middle in middlePhonemes) {
            for (final last in lastPhonemes) {
              if (count >= maxNames) break;

              final name = "${first.phoneme}${middle.phoneme}${last.phoneme}";
              allNames.add({
                "name": name,
                "ancestry": _selectedAncestryForName,
                "pronounType": _selectedPronounForName,
                "components": {
                  "first": first.phoneme,
                  "middle": middle.phoneme,
                  "last": last.phoneme,
                },
                "locked": false,
              });
              count++;
            }
            if (count >= maxNames) break;
          }
          if (count >= maxNames) break;
        }
      }

      // Prepare the final JSON
      // final exportData = {
      //   "metadata": {
      //     "ancestry": _selectedAncestryForName,
      //     "pronounType": _selectedPronounForName,
      //     "generatedAt": DateTime.now().toIso8601String(),
      //     "lockedPhonemesOnly": _useOnlyLockedPhonemes,
      //   },
      //   "names": allNames,
      //   "phonemeData": {
      //     "first":
      //         firstPhonemes
      //             .map((p) => {"phoneme": p.phoneme, "isLocked": p.isLocked})
      //             .toList(),
      //     "middle":
      //         middlePhonemes
      //             .map((p) => {"phoneme": p.phoneme, "isLocked": p.isLocked})
      //             .toList(),
      //     "last":
      //         lastPhonemes
      //             .map((p) => {"phoneme": p.phoneme, "isLocked": p.isLocked})
      //             .toList(),
      //   },
      // };

      // Convert to JSON
      // final jsonString = jsonEncode(exportData);

      // In a real app, you would save this to a file
      // For simplicity in this example, we'll use the FileSaver plugin to download the file
      // Note: You would need to add this plugin to your pubspec.yaml
      // dependencies:
      //   file_saver: ^0.2.5

      // For web:
      // await FileSaver.instance.saveFile(
      //   name: "${_selectedAncestryForName}_${_selectedPronounForName}_names.json",
      //   bytes: Uint8List.fromList(utf8.encode(jsonString)),
      //   ext: 'json',
      //   mimeType: MimeType.json,
      // );

      // For this example, we'll just show a dialog with the JSON count
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Names Generated"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Generated ${allNames.length} possible names."),
                    const SizedBox(height: 8),
                    const Text("In a real app, this would save a file with:"),
                    const SizedBox(height: 8),
                    Text("• All possible name combinations"),
                    Text("• Metadata about the ancestry and pronoun type"),
                    Text("• The phoneme components of each name"),
                    const SizedBox(height: 16),
                    const Text("You could then edit this file to:"),
                    Text("• Mark names as locked/favorites"),
                    Text("• Adjust pronunciation or spelling"),
                    Text("• Add additional metadata"),
                    const SizedBox(height: 16),
                    if (count >= maxNames)
                      Text(
                        "Note: Output was limited to $maxNames names to prevent memory issues.",
                        style: const TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating names: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _exportAllPossibleNamesAsYaml(List<GivenNameElement> allElements) async {
    if (_selectedAncestryForName == null || _selectedPronounForName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an ancestry and pronoun type first"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter elements by the selected ancestry, pronoun, and lock status - same as in _generateRandomNames
      final firstPhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.first,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          firstPhonemes.where((element) => element.isLocked).isNotEmpty) {
        firstPhonemes.retainWhere((element) => element.isLocked);
      }

      final middlePhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.middle,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          middlePhonemes.where((element) => element.isLocked).isNotEmpty) {
        middlePhonemes.retainWhere((element) => element.isLocked);
      }

      final lastPhonemes =
          allElements
              .where(
                (element) =>
                    element.applicableSyllableTypes.contains(
                      SyllableType.last,
                    ) &&
                    element.applicableAncestries.contains(
                      _selectedAncestryForName,
                    ) &&
                    element.applicablePronouns.contains(
                      _selectedPronounForName,
                    ),
              )
              .toList();

      if (_useOnlyLockedPhonemes &&
          lastPhonemes.where((element) => element.isLocked).isNotEmpty) {
        lastPhonemes.retainWhere((element) => element.isLocked);
      }

      // Check if we have enough phonemes
      if (firstPhonemes.isEmpty || lastPhonemes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _useOnlyLockedPhonemes
                  ? "Not enough locked phonemes available. Try unlocking the filter or locking more phonemes."
                  : "Not enough phonemes available to generate names.",
            ),
          ),
        );
        return;
      }

      // Generate all possible combinations
      List<Map<String, dynamic>> allNames = [];
      int count = 0;
      final int maxNames =
          10000; // Safety limit to prevent generating too many names

      // Without middle phonemes
      for (final first in firstPhonemes) {
        for (final last in lastPhonemes) {
          if (count >= maxNames) break;

          final name = "${first.phoneme}${last.phoneme}";
          allNames.add({
            "name": name,
            "ancestry": _selectedAncestryForName,
            "pronounType": _selectedPronounForName,
          });
          count++;
        }
        if (count >= maxNames) break;
      }

      // With middle phonemes (only if we have middle phonemes)
      if (middlePhonemes.isNotEmpty) {
        for (final first in firstPhonemes) {
          for (final middle in middlePhonemes) {
            for (final last in lastPhonemes) {
              if (count >= maxNames) break;

              final name = "${first.phoneme}${middle.phoneme}${last.phoneme}";
              allNames.add({
                "name": name,
                "ancestry": _selectedAncestryForName,
                "pronounType": _selectedPronounForName,
              });
              count++;
            }
            if (count >= maxNames) break;
          }
          if (count >= maxNames) break;
        }
      }

      // Convert to YAML
      final yamlWriter = YAMLWriter();
      final yamlString = yamlWriter.write(allNames);


      await saveYamlFile(yamlString, "names");
      // In a real app, you would save this to a file
      // For simplicity in this example, we'll use the FileSaver plugin to download the file
      // Note: You would need to add these plugins to your pubspec.yaml:
      // dependencies:
      //   file_saver: ^0.2.5
      //   yaml: ^3.1.1
      //   yaml_writer: ^1.0.2

      // For web:
      // await FileSaver.instance.saveFile(
      //   name: "${_selectedAncestryForName}_${_selectedPronounForName}_names.yaml",
      //   bytes: Uint8List.fromList(utf8.encode(yamlString)),
      //   ext: 'yaml',
      //   mimeType: MimeType.text,
      // );

      // For this example, we'll just show a dialog with a YAML preview
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Names Generated as YAML"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Generated ${allNames.length} possible names in YAML format:",
                    ),
                    const SizedBox(height: 16),
                    const Text("Sample format:"),
                    Text("""
- name: ElAth
  ancestry: $_selectedAncestryForName
  pronounType: $_selectedPronounForName
- name: ElDoth
  ancestry: $_selectedAncestryForName
  pronounType: $_selectedPronounForName
...
""", style: const TextStyle(fontFamily: 'monospace')),
                    const SizedBox(height: 16),
                    if (count >= maxNames)
                      Text(
                        "Note: Output was limited to $maxNames names to prevent memory issues.",
                        style: const TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating names: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> saveYamlFile(String yamlString, String defaultFileName) async {
  try {
    // Ask the user where to save the file
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save YAML File',
      fileName: "$defaultFileName.yaml",
      allowedExtensions: ['yaml'],
      type: FileType.custom,
    );
    
    if (outputFile != null) {
      // Write to the user-selected location
      final file = File(outputFile);
      await file.writeAsString(yamlString);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("YAML file saved successfully to: ${file.path}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving file: $e")),
    );
    debugPrint("Error details: $e");
  }
}
}
