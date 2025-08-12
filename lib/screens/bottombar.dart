import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/barrel_of_providers.dart';

final bottomNavigationBarKey = UniqueKey();

/// Bottom menu widget
class Menu extends HookConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(shopListFilter);

    int currentIndex() {
      switch (filter) {
        case ShopListFilter.tavern:
          return 1;
        case ShopListFilter.clothier:
          return 5;
        case ShopListFilter.jeweler:
          return 4;
        case ShopListFilter.herbalist:
          return 3;
        case ShopListFilter.smith:
          return 2;
        case ShopListFilter.all:
          return 0;
      }
    }

    return BottomNavigationBar(
      key: bottomNavigationBarKey,
      elevation: 0.0,
      onTap: (value) {
        if (value == 0) ref.read(shopListFilter.notifier).state = ShopListFilter.all;
        if (value == 1) ref.read(shopListFilter.notifier).state = ShopListFilter.tavern;        
        if (value == 2) ref.read(shopListFilter.notifier).state = ShopListFilter.smith;
        if (value == 3) ref.read(shopListFilter.notifier).state = ShopListFilter.herbalist;
        if (value == 4) ref.read(shopListFilter.notifier).state = ShopListFilter.jeweler;
        if (value == 5) ref.read(shopListFilter.notifier).state = ShopListFilter.clothier;
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'All',
          tooltip: 'All'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_bar),
          label: 'Show Taverns',
          tooltip: 'Show Taverns',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.hardware),
          label: 'Smiths',
          tooltip: 'Show Smiths',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grass),
          label: 'Herbalists',
          tooltip: 'Show Herbalists',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.diamond),
          label: 'Jewelers',
          tooltip: 'Show Jewelers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checkroom),
          label: 'Clothiers',
          tooltip: 'Show Clothiers',
        ),
      ],
      currentIndex: currentIndex(),
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
    );
  }
}
