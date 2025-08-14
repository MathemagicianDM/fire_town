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
import '../services/pdf_export_service.dart';
import '../providers/barrel_of_providers.dart';

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
      title: const Text("List of government officials"),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Export Government to PDF',
          onPressed: () => _exportGovernmentToPDF(context, ref),
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
                child: const GovernmentDetailItem(),
            )
            ],
        ),
      ),
    )
    ])));
  }

  Future<void> _exportGovernmentToPDF(BuildContext context, WidgetRef ref) async {
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
                Text('Generating Government PDF...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);
      final allLocations = ref.read(locationsProvider);

      // Find the government location
      final government = allLocations
          .whereType<Informational>()
          .firstWhereOrNull((loc) => loc.locType == LocationType.government);

      if (government == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Government location not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await PDFExportService.exportLocationToPDF(
        location: government,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Government PDF exported successfully!'),
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
            content: Text('Error exporting Government PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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