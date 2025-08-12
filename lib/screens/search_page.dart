import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "navrail.dart";
import "../providers/barrel_of_providers.dart";

class SearchPage extends HookConsumerWidget {
  static const routeName = "/search";

  const SearchPage({super.key});
@override
Widget build(BuildContext context, WidgetRef ref) {
  final searchQuery = useState("");  // Holds the current search query
  final peopleLimit = useState(3);  // Initial max people results
  final locationLimit = useState(3);  // Initial max locations results
// Get the town provider
  ref.watch(townProvider);

  // Get search providers
  final peopleSearchTrie = ref.watch(peopleSearchProvider.notifier);
  final locationSearchTrie = ref.watch(locationsSearchProvider.notifier);

  // Ensure valid search results
  final peopleResults = searchQuery.value.isNotEmpty
      ? peopleSearchTrie.searchFuzzy(searchQuery.value)
      : [];

  final locationResults = searchQuery.value.isNotEmpty
      ? locationSearchTrie.searchFuzzy(searchQuery.value)
      : [];

  

  // Ensure valid lists for people and locations
  final peopleList = ref.watch(peopleProvider);
  final locationList = ref.watch(locationsProvider);

final people = peopleList
    .where((p) => peopleResults.contains(p.id)) // Keep only matching people
    .toList()
  ..sort((a, b) => peopleResults.indexOf(a.id).compareTo(peopleResults.indexOf(b.id))); // Preserve original order
  
  final nPeople = people.take(peopleLimit.value).toList();

final locations = locationList
    .where((l) => locationResults.contains(l.id)) // Keep only matching locations
    .toList()
  ..sort((a, b) => locationResults.indexOf(a.id).compareTo(locationResults.indexOf(b.id))); // Preserve original order
  
  final nLocations=locations.take(locationLimit.value).toList();

 return Scaffold(
  appBar: AppBar(title: Text("Search")),
  body: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Navigation Rail
      const Navrail(),
      const VerticalDivider(),

      // Main Content
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 800; // Adjust threshold if needed
            double tileWidth = isWide ? constraints.maxWidth * 0.4 : constraints.maxWidth; // Shorten width in wide mode

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Search",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) => searchQuery.value = query, // Update search state
                  ),
                  const SizedBox(height: 16),

                  // Constrain the Flex so it doesn't break layout
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 200, // Prevents infinite height errors
                    ),
                    child: Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // People Expansion Tile (Always Visible)
                        SizedBox(
                          width: tileWidth,
                          child: Card(
                            child: ExpansionTile(
                              title: Text("People (${people.length})"),
                              initiallyExpanded: isWide, // Expand if side-by-side, collapse if stacked
                              children: people.isNotEmpty
                                  ? [
                                      for (var person in nPeople)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: person.printPersonSummaryTappable(context),
                                        ),
                                      if (peopleResults.length > peopleLimit.value)
                                        TextButton(
                                          onPressed: () => peopleLimit.value += 3,
                                          child: Text("Show More"),
                                        ),
                                    ]
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("No results found", textAlign: TextAlign.center),
                                      ),
                                    ],
                            ),
                          ),
                        ),

                        if (isWide) const SizedBox(width: 12), // Add spacing in wide mode

                        // Locations Expansion Tile (Always Visible)
                        SizedBox(
                          width: tileWidth,
                          child: Card(
                            child: ExpansionTile(
                              title: Text("Locations (${locations.length})"),
                              initiallyExpanded: isWide, // Expand if side-by-side, collapse if stacked
                              children: locations.isNotEmpty
                                  ? [
                                      for (var location in nLocations)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: location.printSummaryTappable(context),
                                        ),
                                      if (locationResults.length > locationLimit.value)
                                        TextButton(
                                          onPressed: () => locationLimit.value += 3,
                                          child: Text("Show More"),
                                        ),
                                    ]
                                  : [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("No results found", textAlign: TextAlign.center),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),
);
}
}