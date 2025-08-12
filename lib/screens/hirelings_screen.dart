import 'package:firetown/providers/barrel_of_providers.dart';
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

class HirelingsView extends HookConsumerWidget {
  const HirelingsView({super.key,ar});
  static const routeName="/hirelings";
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    


    
    
    return Scaffold(
    appBar: AppBar(
      title: Text(
                "List of available hirelings",
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
                child: const HirelingDetailItem(),
            )
            ],
        ),
      ),
    )
    ])));
  }
}

class HirelingDetailItem extends HookConsumerWidget {
  const HirelingDetailItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final Informational hire = ref
      .watch(locationsProvider)
      .whereType<Informational>()
      .firstWhere((ell) => ell.locType == LocationType.hireling);

    final viewTheseRoles=ref.watch(roleMetaProvider)
                          .where((r)=>r.hireling).map((r)=>r.thisRole).toList();
    // final test = ref.read(myTown.locationRoleListProvider).where((lr)=>lr.locationID==hirelingID).toList();
  // print("hi");
    // final allShops=ref.watch(ref.read(townProvider).locationsListProvider);
    // final itemFocusNode = useFocusNode();
    // final itemIsFocused = useIsFocused(itemFocusNode);

    // final textEditingController = useTextEditingController();
    // final textFieldFocusNode = useFocusNode();
    // ref.watch(myTown.pendingRoleListProvider);
  return SingleChildScrollView(
    child:Material(
      color: Colors.white,
      elevation: 6,
        child: GestureDetector(
          onTap: () {
            // ignore: avoid_print
            // print(shop.name);
            // navigatorKey.currentState!.restorablePushNamed(
            //       ShopEditView.routeName,
            //       arguments: {
            //         'myID': shop.id,
            //       }
            //     );
          },
          // child: Container(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: hire.printDetail(ref,viewTheseRoles),
          ),
         
          // )
        ),

    )
  );
  }
}