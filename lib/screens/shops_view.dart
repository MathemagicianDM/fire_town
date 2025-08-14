import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import 'package:firetown/models/town_extension/town_locations.dart';
import 'bottombar.dart';
import "../globals.dart";
import "shop_detail_view.dart";
import "../providers/barrel_of_providers.dart";
import '../services/pdf_export_service.dart';
import '../enums_and_maps.dart';

class FilterNotifier extends StateNotifier<Set<String>> {
  FilterNotifier() : super({});

  void toggleTag(String tagKey, bool isChecked) {
    if (isChecked) {
      state = {...state, tagKey}; // Add the tag
    } else {
      state = {...state}..remove(tagKey); // Remove the tag
    }
  }

  // Clear all tags
  void clearTags() {
    state = {};
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, Set<String>>((ref) => FilterNotifier());
    final displayedShopsProvider = Provider<List<Shop>>((ref) {
    final toggledTags = ref.watch(filterProvider);

    

    List<Shop> shops = ref.watch(filteredShops);
    final d = shops.where((shop) {
      return toggledTags.every((tag) => {shop.pro1, shop.pro2, shop.con}.contains(tag));
    }).toList();

    
    return d.isEmpty? shops : d;
    
});

class ShopsView extends HookConsumerWidget {
  const ShopsView({super.key});
  static const routeName="/shopsview";
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(filteredShops, (previous, next) {
    // Clear all tags when filteredShops changes
    ref.read(filterProvider.notifier).clearTags();
    });

    Map<String,int> tagCounter={};
        
        final displayMe = ref.watch(displayedShopsProvider);
        final toggledTags = ref.watch(filterProvider);
    
    Set<String> allTags={...displayMe.map((s)=>s.pro1),...displayMe.map((s)=>s.pro2),...displayMe.map((s)=>s.con)};
    
    for (final t in allTags) {
      tagCounter[t] = displayMe.where((s) => {s.pro1, s.pro2, s.con}.contains(t)).length;
    }
    final sortedTagCounter = tagCounter.entries.toList();

  // Sort the list with a custom comparator
  sortedTagCounter.sort((a, b) {
    // First, sort by the integer value in descending order
    final valueComparison = b.value.compareTo(a.value);
    if (valueComparison != 0) {
      return valueComparison;
    }
    // If the values are equal, sort alphabetically by key
    return a.key.compareTo(b.key);
  });
    
    
    
    return Scaffold(
        body: 
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [const Navrail(),const VerticalDivider(),
          Expanded( child: SingleChildScrollView(
            child:
        Column(
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 42),
            _buildExportSection(context, ref, displayMe),
            if (displayMe.isNotEmpty) const Divider(height: 0),
            for (var i = 0; i < displayMe.length; i++) ...[

              if (i > 0) const Divider(height: 0),
              ProviderScope(
                  overrides: [
                    currentShop.overrideWithValue(displayMe[i]),
                  ],
                  child: const ShopItem(),
              ),
            

            ],
          ]
        )
        )
        ),
        const VerticalDivider(),
        Flexible(child:
            SingleChildScrollView(child:
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tag in sortedTagCounter)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Checkbox(
                            value: toggledTags.contains(tag.key),
                            onChanged: (bool? isChecked) {
                              ref.read(filterProvider.notifier).toggleTag(tag.key, isChecked ?? false);
                            },
                          ),
                          Expanded(
                            child: Text(
                              "${tag.key} (${tag.value})",
                              style: TextStyle(fontSize: 14 + (tag.value * 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          )
        ]
        ),
        
        bottomNavigationBar: const Menu(),
      );
  }

  Widget _buildExportSection(BuildContext context, WidgetRef ref, List<Shop> shops) {
    if (shops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Export Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportAllLocationsToPDF(context, ref),
                icon: const Icon(Icons.location_city),
                label: const Text('Export All Locations to PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _exportAllLocationsToPDF(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Generating all locations PDF... This may take a moment.'),
              ],
            ),
            duration: Duration(seconds: 7),
          ),
        );
      }

      final allLocations = ref.read(locationsProvider);
      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);

      // Filter to get shops, government, and market
      final exportableLocations = allLocations.where((location) => 
        location.locType == LocationType.shop ||
        location.locType == LocationType.government ||
        location.locType == LocationType.market
      ).toList();

      if (exportableLocations.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No exportable locations found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await PDFExportService.exportAllLocationsToPDF(
        locations: exportableLocations,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All locations PDF exported successfully! (${exportableLocations.length} locations)'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting all locations PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ShopItem extends HookConsumerWidget {
  const ShopItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(currentShop);

    return Material(
      color: Colors.white,
      elevation: 6,
        child: GestureDetector(
          onTap: () {
            // ignore: avoid_print
            print(shop.name);
            navigatorKey.currentState!.restorablePushNamed(
                  ShopDetailTabbed.routeName,
                  arguments: {
                    'myID': shop.id,
                  }
                );
          },
          child: shop.printSummary(),
        ),

    );
  }
}



