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
import '../services/pdf_export_service.dart';
import 'package:collection/collection.dart';

class MarketView extends HookConsumerWidget {
  const MarketView({super.key,ar});
  static const routeName="/market";
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    


    
    
    return Scaffold(
    appBar: AppBar(
      title: const Text("On market days, the following are available"),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Export Market to PDF',
          onPressed: () => _exportMarketToPDF(context, ref),
        ),
      ],
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
                child: const MarketDetailItem(),
            )
            ],
        ),
      ),
    )
    ])));
  }

  Future<void> _exportMarketToPDF(BuildContext context, WidgetRef ref) async {
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
                Text('Generating Market PDF...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);
      final allLocations = ref.read(locationsProvider);

      // Find the market location
      final market = allLocations
          .whereType<Informational>()
          .firstWhereOrNull((loc) => loc.locType == LocationType.market);

      if (market == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Market location not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await PDFExportService.exportLocationToPDF(
        location: market,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Market PDF exported successfully!'),
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
            content: Text('Error exporting Market PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class MarketDetailItem extends HookConsumerWidget {
  const MarketDetailItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final Informational hire = ref
      .watch(locationsProvider)
      .whereType<Informational>()
      .firstWhere((ell) => ell.locType == LocationType.market);

// if (info == null) {
//   // Handle the case where no matching Informational is found
//   print("No Informational location found.");
// }

    
        final viewTheseRoles=ref.watch(roleMetaProvider)
                          .where((r)=>r.showInMarket).map((r)=>r.thisRole).toList();
    // final roleMeta=ref.read(ref.read(myWorldProvider).allRoles.notifier);
    // ref.watch(ref.read(townProvider).pendingRoleListProvider);
    
    // final allShops=ref.watch(ref.read(townProvider).locationsListProvider);
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
            children: hire.printDetail(ref,viewTheseRoles),
          ),
         
          // )
        ),

    )
  );
  }

  Future<void> _exportMarketToPDF(BuildContext context, WidgetRef ref) async {
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
                Text('Generating Market PDF...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);
      final allLocations = ref.read(locationsProvider);

      // Find the market location
      final market = allLocations
          .whereType<Informational>()
          .firstWhereOrNull((loc) => loc.locType == LocationType.market);

      if (market == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Market location not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await PDFExportService.exportLocationToPDF(
        location: market,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Market PDF exported successfully!'),
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
            content: Text('Error exporting Market PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}