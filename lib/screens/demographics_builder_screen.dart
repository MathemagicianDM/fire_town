import "package:firetown/providers/government_extension2.dart";
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "../globals.dart";
import "../enums_and_maps.dart";
import "../helpers_functions.dart";
import "generate_town_screen.dart";
import "../providers/barrel_of_providers.dart";

final selectedGovernmentTypeProvider =
    StateProvider<String>((ref) => 'nobility');

class DemoDetermineStateful extends StatefulHookConsumerWidget{
  static const routeName = "/demo_determineStatefule";

  const DemoDetermineStateful({super.key});
  @override
  ConsumerState<DemoDetermineStateful> createState() => DemoDetermine();
}

class DemoDetermine extends ConsumerState<DemoDetermineStateful>{
  static const int defaultValue = 5;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initData();
  }


  Future<void> _initData() async {
    try {
      await initializeGovernmentData(ref);
    final ancestriesPN = ref.read(ancestriesProvider.notifier);
    await ancestriesPN.initialize();

    // final json = await rootBundle.loadString("./lib/demofiles/Demotown.demographics");
    // await ancestriesPN.loadFromJsonAndCommit(json);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

    } catch (e) {
      debugPrint("Error initializing: $e");
    }
  }

  static const routeName = "/demo_determine";

  // DemoDetermine({super.key});

  @override
  Widget build(BuildContext context) {

  // Access the data
  final positions = ref.watch(positionsProvider);
  // final roleBySize = ref.watch(roleBySizeProvider);

  final ancestries = ref.watch(ancestriesProvider);

  // Show loading indicator if data is not ready
  if (positions.isEmpty || ancestries.isEmpty || !_isInitialized) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

//  final roleGenList = ref.watch(roleGenProvider2);
//   final firstElement = roleGenList.when(
//     data: (list) {
//       if (list.isNotEmpty) {
//         return list.first.thisRole.name; // Get the first element
//       } else {
//         print("Null :(");
//         return null; // Or handle empty list case
//       }
//     },
//     error: (error, stackTrace) {
//       // Handle error state
//       print('Error: $error');
//       return null; // Or return a placeholder/default value
//     },
//     loading: () {
//       // Handle loading state
//       return null; // Or return a loading placeholder
//     },
//   );

// // Then you can use firstElement, but check if it's null first
// if (firstElement != null) {
//   print('First element: $firstElement');
// }
    List<String> govTypes = positions[0].titles.keys.map((k)=>k).toList();
    govTypes.sort((a,b)=>a.compareTo(b));
    
    // final ancestries = ref.watch(ancestriesProvider);
    // final ancestries = [Ancestry("Birdfolk"),Ancestry("Elf"),Ancestry("Halfling"),Ancestry("Human")];
    final int maxPoints = 5 * ancestries.length;

    final townName = useState<String>("Town Name");

    final currentSize = useState<CitySize?>(null); // Declare the state

    final nameFocusNode = useFocusNode();
    final nameIsFocused = useIsFocused(nameFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    // Watch the current selections
    final selectedGovType = ref.watch(selectedGovernmentTypeProvider);

    // Manage slider values and locked states with hooks
    final sliderValues = useState<Map<String, int>>({
      for (var ancestry in ancestries) ancestry.name: defaultValue,
    });

    var lockedSliders = useState<Set<String>>({});

    void adjustSliders(String changedAncestry, int newValue) {
      // Calculate the total points before the update

      // Update the changed slider value
      final newSlider = {
        ...sliderValues.value,
        changedAncestry: newValue,
      };

      int totalPoints = newSlider.values.reduce((a, b) => a + b);

      // If total points exceed the maxPoints, redistribute excess points
      if (totalPoints != maxPoints) {
        int excess = totalPoints - maxPoints;

        // Get a list of unlocked sliders excluding the one being changed
        final unlocked = sliderValues.value.keys
            .where((key) =>
                !lockedSliders.value.contains(key) && key != changedAncestry)
            .toList();

        bool canRedistributeExcess = false;
        switch (excess.compareTo(0)) {
          case 1:
            final availablePoints = unlocked.fold<int>(0, (acc, ele) {
              final value = sliderValues.value[ele];
              if (value != null) {
                return acc + value;
              } else {
                return acc;
              }
            });
            canRedistributeExcess = availablePoints >= excess;
            break;
          case -1:
            final availablePoints = unlocked.fold<int>(0, (acc, ele) {
              final value = sliderValues.value[ele];
              if (value != null) {
                return acc + maxPoints - value;
              } else {
                return acc;
              }
            });

            canRedistributeExcess = availablePoints >= -1 * excess;
            break;
          case 0:
            canRedistributeExcess = false;
        }
        if (canRedistributeExcess) {
          sliderValues.value = {
            ...sliderValues.value,
            changedAncestry: newValue,
          };

          while (excess != 0) {
            final randomAncestry = unlocked[random.nextInt(unlocked.length)];

            // Only adjust if the value is greater than 0
            switch (excess.compareTo(0)) {
              case 1:
                if (sliderValues.value[randomAncestry]! > 0) {
                  sliderValues.value = {
                    ...sliderValues.value,
                    randomAncestry: sliderValues.value[randomAncestry]! -
                        1 * excess.compareTo(0),
                  };
                  excess =
                      excess - 1 * excess.compareTo(0); // Reduce excess points
                }
                break;
              case -1:
                if (sliderValues.value[randomAncestry]! < maxPoints) {
                  sliderValues.value = {
                    ...sliderValues.value,
                    randomAncestry: sliderValues.value[randomAncestry]! -
                        1 * excess.compareTo(0),
                  };
                  excess =
                      excess - 1 * excess.compareTo(0); // Reduce excess points
                }
                break;
            }
          }
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please unlock another slider.")),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create a Town")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Size Dropdown
            DropdownButton<CitySize?>(
              value: currentSize.value, // Bind the value to the state
              items: [
                // Allowing a null option
                const DropdownMenuItem<CitySize?>(
                  value: null,
                  child: Text("No Size Selected"),
                ),
                ...CitySize.values.map((s) {
                  return DropdownMenuItem<CitySize?>(
                    value: s, // Ensure the value is unique
                    child: Text(s.name), // Display the town size
                  );
                }),
              ],
              onChanged: (CitySize? newValue) {
                currentSize.value = newValue; // Update the state
              },
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Government Type',
                border: OutlineInputBorder(),
              ),
              value: selectedGovType,
              items: govTypes.map((k) {
                return DropdownMenuItem<String>(
                  value: k,
                  child: Text(govTypeForPrint(k)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedGovernmentTypeProvider.notifier).state =
                      newValue;
                }
              },
            ),
            //Text Field
            Focus(
              focusNode: nameFocusNode,
              onFocusChange: (focused) {
                if (focused) {
                  textEditingController.text = townName.value;
                } else {
                  // Commit changes only when the textfield is unfocused, for performance
                  townName.value = textEditingController.text.trim();
                  //                                          newName: textEditingController.text,
                  //                                          );
                }
              },
              child: ListTile(
                onTap: () {
                  nameFocusNode.requestFocus();
                  textFieldFocusNode.requestFocus();
                },
                title: nameIsFocused
                    ? TextField(
                        autofocus: true,
                        focusNode: textFieldFocusNode,
                        controller: textEditingController,
                      )
                    : Text("Your Town's Name: ${townName.value}"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Almost None"),
                Text("Almost all"),
              ],
            ),
            //Sliders
            Expanded(
              child: ListView.builder(
                itemCount: ancestries.length,
                itemBuilder: (context, index) {
                  final ancestry = ancestries[index];
                  final name = ancestry.name;
                  final value = sliderValues.value[name] ?? defaultValue;

                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Slider(
                          value: value.toDouble(),
                          min: 0,
                          max: maxPoints.toDouble(),
                          divisions: maxPoints,
                          label: value.toString(),
                          onChanged: lockedSliders.value.contains(name)
                              ? null
                              : (newValue) {
                                  adjustSliders(name, newValue.toInt());
                                },
                        ),
                      ],
                    ),
                    trailing: IconButton(
                        icon: Icon(
                          lockedSliders.value.contains(name)
                              ? Icons.lock
                              : Icons.lock_open,
                          color: lockedSliders.value.contains(name)
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: () {
                          // Toggle the lock state for the current ancestry
                          lockedSliders.value =
                              lockedSliders.value.contains(name)
                                  ? lockedSliders.value.difference(
                                      {name}) // Remove name from lockedSliders
                                  : {
                                      ...lockedSliders.value,
                                      name
                                    }; // Add name to lockedSliders
                        }),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Almost None"),
                Text("Almost all"),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final name = townName.value;
                bool canIgoOn = true;
                if (name.isEmpty) {
                  canIgoOn = false;
                  ScaffoldMessenger.of(context).clearSnackBars();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a town name.")),
                  );
                }
                if (currentSize.value == null) {
                  canIgoOn = false;
                  ScaffoldMessenger.of(context).clearSnackBars();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please choose a size.")),
                  );
                }

                if (canIgoOn) {
                  navigatorKey.currentState
                      ?.pushNamed(TownGeneratorPage.routeName, arguments: {
                    "citySize": currentSize.value,
                    "name": name,
                    "demographic": sliderValues.value,
                    "government": selectedGovType
                  });
                }
              },
              child: const Text("Create!"),
            ),
          ],
        ),
      ),
    );
  }
}
