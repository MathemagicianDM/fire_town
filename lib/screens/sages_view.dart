import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import 'package:firetown/models/town_extension/town_locations.dart';
// import 'package:firetown/personEdit.dart';

// import 'shop.dart';
// import 'person.dart';
// import "editHelpers.dart";
// import "personDetailView.dart";
// import "town.dart";
import "../enums_and_maps.dart";
import "../providers/barrel_of_providers.dart";

class SagesView extends HookConsumerWidget {
  const SagesView({super.key,ar});
  static const routeName="/sageview";
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    


    
    
    return Scaffold(
    appBar: AppBar(
      title: Text(
                "These people may have information \n about the town and nearby areas",
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
                child: const SageDetailItem(),
            )
            ],
        ),
      ),
    )
    ])));
  }
}

class SageDetailItem extends HookConsumerWidget {
  const SageDetailItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final Informational info = ref
      .watch(locationsProvider)
      .whereType<Informational>()
      .firstWhere((ell) => ell.locType == LocationType.info);
  final roleMeta = ref.read(roleMetaProvider);
// if (info == null) {
//   // Handle the case where no matching Informational is found
//   print("No Informational location found.");
// }
    final allShops=ref.watch(locationsProvider);
    final viewTheseRoles=roleMeta
                          .where((r)=>r.informational).map((r)=>r.thisRole).toList();

    
    // final itemFocusNode = useFocusNode();
    // final itemIsFocused = useIsFocused(itemFocusNode);

    // final textEditingController = useTextEditingController();
    // final textFieldFocusNode = useFocusNode();
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
            children: info.printDetail(ref,viewTheseRoles,shopList: allShops),
          ),
         
          // )
        ),

    )
  );
  }
}