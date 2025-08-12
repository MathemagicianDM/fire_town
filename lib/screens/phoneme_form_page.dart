import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/given_name_phonemes.dart';
import '../providers/barrel_of_providers.dart';

class PhonemeFormDialog extends ConsumerStatefulWidget {
  final String title;
  final GivenNameElement? existingElement;
  final Function(GivenNameElement) onSave;

  const PhonemeFormDialog({
    super.key,
    required this.title,
    this.existingElement,
    required this.onSave,
  });

  @override
  _PhonemeFormDialogState createState() => _PhonemeFormDialogState();
}

class _PhonemeFormDialogState extends ConsumerState<PhonemeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phonemeController = TextEditingController();
  final _uuid = Uuid();
  
  Set<String> _selectedAncestries = {};
  Set<String> _selectedPronouns = {};
  Set<SyllableType> _selectedSyllableTypes = {};
  bool _isLocked = false;

  // Static variables to remember the last selected values
  static Set<String> _lastSelectedAncestries = {};
  static Set<String> _lastSelectedPronouns = {};
  static Set<SyllableType> _lastSelectedSyllableTypes = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize form if editing an existing element
    if (widget.existingElement != null) {
      _phonemeController.text = widget.existingElement!.phoneme;
      _selectedAncestries = Set.from(widget.existingElement!.applicableAncestries);
      _selectedPronouns = Set.from(widget.existingElement!.applicablePronouns);
      _selectedSyllableTypes = Set.from(widget.existingElement!.applicableSyllableTypes);
      _isLocked = widget.existingElement!.isLocked;
    } else {
      // For new elements, use the last selected values if available
      if (_lastSelectedAncestries.isNotEmpty) {
        _selectedAncestries = Set.from(_lastSelectedAncestries);
      }
      if (_lastSelectedPronouns.isNotEmpty) {
        _selectedPronouns = Set.from(_lastSelectedPronouns);
      }
      if (_lastSelectedSyllableTypes.isNotEmpty) {
        _selectedSyllableTypes = Set.from(_lastSelectedSyllableTypes);
      }
      // Debug log to see what's being remembered
      print("Using remembered selections: Ancestries: $_selectedAncestries, Pronouns: $_selectedPronouns, SyllableTypes: $_selectedSyllableTypes");
    }
  }

  @override
  void dispose() {
    _phonemeController.dispose();
    super.dispose();
  }
  
  // Save the current selections as the last used values
  void _saveSelectionsAsLast() {
    _lastSelectedAncestries.clear();
    _lastSelectedPronouns.clear();
    _lastSelectedSyllableTypes.clear();
    
    _lastSelectedAncestries.addAll(_selectedAncestries);
    _lastSelectedPronouns.addAll(_selectedPronouns);
    _lastSelectedSyllableTypes.addAll(_selectedSyllableTypes);
    
    // Debug log to verify what's being saved
    print("Saved as last selections: Ancestries: $_lastSelectedAncestries, Pronouns: $_lastSelectedPronouns, SyllableTypes: $_lastSelectedSyllableTypes");
  }

  @override
  Widget build(BuildContext context) {
    final ancestries = ref.watch(ancestriesProvider);
    
    // Define pronouns - in a real app, you might get these from a provider
    final pronounTypes = ["heHim", "sheHer", "theyThem", "heThey", "sheThey", "any"];
    
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _phonemeController,
                decoration: const InputDecoration(labelText: "Phoneme"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a phoneme";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Lock Phoneme"),
                subtitle: const Text("Locked phonemes can be filtered for name generation"),
                value: _isLocked,
                secondary: Icon(
                  _isLocked ? Icons.lock : Icons.lock_open,
                  color: _isLocked ? Colors.green : Colors.grey,
                ),
                onChanged: (bool? value) {
                  setState(() {
                    _isLocked = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text("Syllable Types:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: SyllableType.values.map((type) {
                  return FilterChip(
                    label: Text(type.name),
                    selected: _selectedSyllableTypes.contains(type),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSyllableTypes.add(type);
                        } else {
                          _selectedSyllableTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text("Applicable Ancestries:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _showMultiSelectDialog(
                    context,
                    "Select Ancestries",
                    ancestries.map((a) => a.name).toList(),
                    _selectedAncestries,
                    (newSelection) {
                      setState(() {
                        _selectedAncestries = newSelection;
                      });
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Ancestries: "),
                    _buildSelectionIndicator(_selectedAncestries),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Applicable Pronouns:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _showMultiSelectDialog(
                    context,
                    "Select Pronouns",
                    pronounTypes,
                    _selectedPronouns,
                    (newSelection) {
                      setState(() {
                        _selectedPronouns = newSelection;
                      });
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Pronouns: "),
                    _buildSelectionIndicator(_selectedPronouns),
                  ],
                ),
              ),
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
            if (_formKey.currentState!.validate()) {
              if (_selectedSyllableTypes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select at least one syllable type")),
                );
                return;
              }
              if (_selectedAncestries.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select at least one ancestry")),
                );
                return;
              }
              if (_selectedPronouns.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select at least one pronoun type")),
                );
                return;
              }
              
              final element = GivenNameElement(
                id: widget.existingElement?.id ?? _uuid.v4(),
                phoneme: _phonemeController.text.trim(),
                applicableAncestries: _selectedAncestries.toList(),
                applicablePronouns: _selectedPronouns.toList(),
                applicableSyllableTypes: _selectedSyllableTypes.toList(),
                isLocked: _isLocked,
              );
              
              // Save selections as last used
              _saveSelectionsAsLast();
              
              widget.onSave(element);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  void _showMultiSelectDialog<T>(
    BuildContext context,
    String title,
    List<T> items,
    Set<T> selectedItems,
    Function(Set<T>) onSelectionChanged,
  ) {
    // Create a local copy of the selectedItems for the dialog
    final localSelected = Set<T>.from(selectedItems);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: items.map((item) {
                    return CheckboxListTile(
                      title: Text(item.toString()),
                      value: localSelected.contains(item),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            localSelected.add(item);
                          } else {
                            localSelected.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Select All"),
                  onPressed: () {
                    setState(() {
                      localSelected.addAll(items);
                    });
                  },
                ),
                TextButton(
                  child: const Text("Clear All"),
                  onPressed: () {
                    setState(() {
                      localSelected.clear();
                    });
                  },
                ),
                TextButton(
                  child: const Text("Done"),
                  onPressed: () {
                    // Update the main selection set with the values from the dialog
                    onSelectionChanged(localSelected);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

  Widget _buildSelectionIndicator(Set<dynamic> items) {
    if (items.isEmpty) {
      return const Text("None selected");
    } else if (items.length == 1) {
      return Text("Selected: ${items.first}");
    } else {
      return Text("${items.length} selected");
    }
  }