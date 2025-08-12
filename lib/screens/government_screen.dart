import 'package:firetown/providers/location_providers.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import 'package:firetown/models/town_extension/town_locations.dart';
// import 'package:firetown/personEdit.dart';
// import 'load_json.dart';
// import 'shop.dart';
// import 'person.dart';
// import "editHelpers.dart";
// import "personDetailView.dart";
// import "town.dart";
import "../enums_and_maps.dart";
import "package:collection/collection.dart";

// Providers for the selected government type and city size
final selectedGovernmentTypeProvider = StateProvider<String>((ref) => 'nobility');
final selectedCitySizeProvider = StateProvider<String>((ref) => 'town');






class GovernmentView extends HookConsumerWidget {
  const GovernmentView({super.key,ar});
  static const routeName="/government";
    
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    


    
    
    return Scaffold(
    appBar: AppBar(
      title: Text(
                "List of government officials",
                ),
    ),
      body: Scaffold(
        body: Row(
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
            ProviderScope(
                child: const GovernmentDetailItem(),
            )
            ],
        ),
      ),
    )
    ])));
  }
}

class GovernmentDetailItem extends HookConsumerWidget {
  const GovernmentDetailItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final Informational gov = ref
      .watch(locationsProvider)
      .whereType<Informational>()
      .firstWhereOrNull((ell) => ell.locType == LocationType.government) ?? Informational(name: "LoadingErrorThing",locType: LocationType.civic,myID:"LoadingErrorThing");
    
// if (info == null) {
//   // Handle the case where no matching Informational is found
//   print("No Informational location found.");
// }
    // final myTown =ref.read(townProvider);
    // final people = ref.watch(peopleProvider);
    

  return SingleChildScrollView(
    child:Material(
      color: Colors.white,
      elevation: 6,
        child: GestureDetector(
          onTap: () {

          },
          // child: Container(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gov.printDetailGov2(ref,context),
          ),
         
          // )
        ),

    )
  );
  }
}