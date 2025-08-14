import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "package:firetown/screens/government_screen.dart";
import "package:firetown/screens/hirelings_screen.dart";
// import 'enums_and_maps.dart';
// import 'package:firetown/demographics_view.dart';
import 'package:firetown/screens/people_view.dart';
// import 'providers.dart';
import "shops_view.dart";
// import "tavern_view.dart";
// import "demographics.dart";
import "../globals.dart";
import "home.dart";
import "sages_view.dart";
import "market_screen.dart";
import "search_page.dart";
import "encounter_builder_page.dart";
import "town_dashboard_view.dart";

final navRailKey = UniqueKey();

enum NavigationDestination {
  dashboard,
  saveLoad,
  // tavernsView,
  shopsView,
  peopleView,
  sagesView,
  hirelingsView,
  marketView,
  // demographicsView,
  searchView,
  encounterBuilder,
  testButton,
}

final Map<NavigationDestination, NavigationRailDestination> destinationMap = {
  NavigationDestination.dashboard: const NavigationRailDestination(
    icon: Icon(Icons.dashboard),
    label: Text('Overview'),
  ),
  NavigationDestination.saveLoad: const NavigationRailDestination(
    icon: Icon(Icons.save),
    label: Text('Save/Load'),
  ),
  // NavigationDestination.tavernsView: const NavigationRailDestination(
  //   icon: Icon(Icons.sports_bar),
  //   label: Text('Taverns'),
  // ),
  NavigationDestination.shopsView: const NavigationRailDestination(
    icon: Icon(Icons.store),
    label: Text('Shops'),
  ),
  NavigationDestination.peopleView: const NavigationRailDestination(
    icon: Icon(Icons.groups),
    label: Text('People'),
  ),
  NavigationDestination.sagesView: const NavigationRailDestination(
    icon: Icon(Icons.quiz),
    label: Text('Sages'),
  ),
  NavigationDestination.hirelingsView: const NavigationRailDestination(icon: Icon(Icons.handshake), label: Text("Hirelings")),
  NavigationDestination.marketView: const NavigationRailDestination(icon: Icon(Icons.forum), label: Text("Market") ),
  // NavigationDestination.demographicsView: const NavigationRailDestination(
  //   icon: Icon(Icons.assignment),
  //   label: Text('Demographics'),
  // ),
  NavigationDestination.searchView: const NavigationRailDestination(icon: Icon(Icons.search),label: Text("Search")),
  NavigationDestination.encounterBuilder: const NavigationRailDestination(
    icon: Icon(Icons.auto_stories),
    label: Text('Encounters'),
  ),
  NavigationDestination.testButton: const NavigationRailDestination(
    icon: Icon(Icons.temple_buddhist_sharp),
    label: Text('Test'),
  ),
};


int _myIndex=0;
class Navrail extends HookConsumerWidget {
  const Navrail({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return NavigationRail(
      key: navRailKey,
      elevation: null,
      onDestinationSelected: (value) {
        final destination = NavigationDestination.values[value];
        switch(destination){
          case NavigationDestination.dashboard: navigatorKey.currentState?.pushNamed(TownDashboardView.routeName);break;
          case NavigationDestination.saveLoad: navigatorKey.currentState?.pushNamed(Home.routeName);break;
          case NavigationDestination.peopleView: navigatorKey.currentState?.pushNamed(PeopleView.routeName);break;
          // case NavigationDestination.demographicsView: navigatorKey.currentState?.pushNamed(DemographicsView.routeName);break;
          case NavigationDestination.sagesView: navigatorKey.currentState?.pushNamed(SagesView.routeName);break;
          case NavigationDestination.hirelingsView: navigatorKey.currentState?.pushNamed(HirelingsView.routeName); break;
          case NavigationDestination.marketView: navigatorKey.currentState?.pushNamed(MarketView.routeName); break;
          case NavigationDestination.shopsView: navigatorKey.currentState?.pushNamed(ShopsView.routeName);break;
          case NavigationDestination.searchView: navigatorKey.currentState?.pushNamed(SearchPage.routeName);break;
          case NavigationDestination.encounterBuilder:
            navigatorKey.currentState?.pushNamed(EncounterBuilderPage.routeName);
            break;
          // case NavigationDestination.tavernsView: navigatorKey.currentState?.pushNamed(TavernsView.routeName);break;
          case NavigationDestination.testButton: 
                   
                    testFeature(ref);
                    break;
          // ignore: unreachable_switch_default
          default: debugPrint("Page not in navrail"); break;
        }
        _myIndex=value;
      },
      destinations: destinationMap.values.toList(),
      selectedIndex: _myIndex,
      // selectedItemColor: Colors.amber[800],
      // unselectedItemColor: Colors.grey,
    );
  }
}

Future<void> testFeature(WidgetRef ref) async
{
      // await makeBoxforRoleGeneration(ref);
      // await makeBoxForShopGeneration(ref);
      // await makeBoxforRoleGeneration(ref);
      // await importGovJsonFromAsset(ref);
      navigatorKey.currentState?.pushNamed(GovernmentView.routeName);

      // final firestoreProvider = ref.read(locRoleFirestoreProvider.notifier);
      // await firestoreProvider.sendToFireBase(ref);
    // await myTown.populateTown(CitySize.city,ref);
       
    // print("hi");

}


