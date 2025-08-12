import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import 'package:firetown/models/town_extension/town_locations.dart';
import 'bottombar.dart';
import "../globals.dart";
import "shop_detail_view.dart";
import "../providers/barrel_of_providers.dart";

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



