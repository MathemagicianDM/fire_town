import "package:firetown/providers/barrel_of_providers.dart";
import '../services/description_service.dart';
import '../services/pdf_export_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import "package:firetown/screens/service_edit.dart";
import "../enums_and_maps.dart";
import '../models/shop_trait_model.dart';

// import 'bottombar.dart';
import "../globals.dart";
// import "editHelpers.dart";
// import "personDetailView.dart";
import "shop_edit_view.dart";
import "../models/location_services_model.dart";
import "package:uuid/uuid.dart";
import '../widgets/location_encounters_widget.dart';
// import "models/town_model.dart";
import "package:firetown/models/barrel_of_models.dart";

Uuid _uuid=Uuid();

final ValueNotifier<GenericService?> selectedServiceNotifier = ValueNotifier(null);


class ShopDetailView extends HookConsumerWidget {
  const ShopDetailView({super.key, ar});
  static const routeName = "/shopdetailview";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final myID = arguments?['myID'];

    final shops = ref
        .watch(locationsProvider)
        .where((ell) => ell.locType == LocationType.shop)
        .cast<Shop>()
        .toList();

    final shopIndex = shops.indexWhere((shop) => shop.id == myID);

    


    return Scaffold(
        appBar: AppBar(
          title: Text("Details for ${shops[shopIndex].name} "),
        ),
        body: Scaffold(
            body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Navrail(),
          const VerticalDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 42),
                  if (shops.isNotEmpty) const Divider(height: 0),
                  ProviderScope(
                    overrides: [
                      currentShop.overrideWithValue(shops[shopIndex])
                    ],
                    child: const ShopDetailItem(),
                  )
                ],
              ),
            ),
          )
        ])));
  }
}

class ShopDetailItem extends HookConsumerWidget {
  const ShopDetailItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(currentShop);
    ref.watch(peopleProvider);
    ref.watch(locationRolesProvider);
    ref.watch(locationsProvider);
    ref.watch(roleMetaProvider.notifier);
    // final itemFocusNode = useFocusNode();
    // final itemIsFocused = useIsFocused(itemFocusNode);

    // final textEditingController = useTextEditingController();
    // final textFieldFocusNode = useFocusNode();
    return SingleChildScrollView(
        child: Material(
      color: Colors.white,
      elevation: 6,
      child: GestureDetector(
        onTap: () {
          // ignore: avoid_print
          print(shop.name);
          navigatorKey.currentState!
              .restorablePushNamed(ShopEditView.routeName, arguments: {
            'myID': shop.id,
          });
        },
        // child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...shop.printDetail(ref),
            // Add export buttons section
            const SizedBox(height: 16),
            _buildExportSection(context, ref, shop),
            // Add description section
            const SizedBox(height: 16),
            _buildShopDescriptionSection(context, ref, shop),
          ],
        ),

        // )
      ),
    ));
  }

  Widget _buildExportSection(BuildContext context, WidgetRef ref, Shop shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportShopToPDF(context, ref, shop),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export Shop to PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportAllLocationsToPDF(context, ref),
                    icon: const Icon(Icons.location_city),
                    label: const Text('Export All Locations to PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopDescriptionSection(BuildContext context, WidgetRef ref, Shop shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Descriptions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Outside Description Section
            _buildDescriptionTypeSection(
              context: context,
              ref: ref,
              shop: shop,
              title: 'Outside Description',
              traits: shop.outsideTraits,
              descriptionType: 'outside',
              color: Colors.green.shade50,
              borderColor: Colors.green.shade300,
            ),
            
            const SizedBox(height: 16),
            
            // Inside Description Section
            _buildDescriptionTypeSection(
              context: context,
              ref: ref,
              shop: shop,
              title: 'Inside Description',
              traits: shop.insideTraits,
              descriptionType: 'inside',
              color: Colors.blue.shade50,
              borderColor: Colors.blue.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTypeSection({
    required BuildContext context,
    required WidgetRef ref,
    required Shop shop,
    required String title,
    required List<ShopTrait> traits,
    required String descriptionType,
    required Color color,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Generate $descriptionType traits',
                  onPressed: () => _generateShopTraits(ref, shop, descriptionType),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add more $descriptionType traits',
                  onPressed: () => _addMoreShopTraits(ref, shop, descriptionType),
                ),
                if (traits.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Regenerate all $descriptionType traits',
                    onPressed: () => _regenerateShopTraits(ref, shop, descriptionType),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
            color: traits.isEmpty ? Colors.grey.shade50 : color,
          ),
          child: traits.isEmpty
              ? Text(
                  'No $descriptionType traits generated',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: traits.map((trait) => _buildTraitWidget(context, ref, shop, trait, descriptionType)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTraitWidget(BuildContext context, WidgetRef ref, Shop shop, ShopTrait trait, String descriptionType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              trait.description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 16),
            tooltip: 'Reroll this trait',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () => _rerollIndividualTrait(ref, shop, trait, descriptionType),
          ),
        ],
      ),
    );
  }

  void _generateShopTraits(WidgetRef ref, Shop shop, String descriptionType) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      final newTraits = descriptionService.generateShopTraits(
        shop: shop,
        templates: shopTemplates,
        descriptionType: descriptionType,
        maxTraits: 2,
      );
      
      if (newTraits.isNotEmpty) {
        // Update the shop with new traits
        final locationsListPN = ref.read(locationsProvider.notifier);
        final updatedShop = descriptionType == 'inside'
            ? Shop.fromShop(baseShop: shop, insideTraits: [...shop.insideTraits, ...newTraits])
            : Shop.fromShop(baseShop: shop, outsideTraits: [...shop.outsideTraits, ...newTraits]);
        
        locationsListPN.replace(shop, updatedShop);
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('${newTraits.length} $descriptionType trait(s) generated!')),
        );
      } else {
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('No suitable templates found for this shop type')),
        );
      }
    } catch (e) {
      if (!ref.context.mounted) return;
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error generating traits: $e')),
      );
    }
  }

  void _addMoreShopTraits(WidgetRef ref, Shop shop, String descriptionType) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      // Get existing trait tags to avoid conflicts
      final existingTraits = descriptionType == 'inside' ? shop.insideTraits : shop.outsideTraits;
      final existingTags = existingTraits.map((trait) => trait.tag).toSet();
      
      // Filter templates to exclude already used tags
      final availableTemplates = shopTemplates.where((template) =>
        template.descriptionType == descriptionType &&
        template.applicableShopTypes.contains(shop.type) &&
        !existingTags.contains(template.tag)
      ).toList();
      
      if (availableTemplates.isEmpty) {
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('No additional trait templates available')),
        );
        return;
      }
      
      final newTraits = descriptionService.generateShopTraits(
        shop: shop,
        templates: availableTemplates,
        descriptionType: descriptionType,
        maxTraits: 1, // Add one more trait at a time
      );
      
      if (newTraits.isNotEmpty) {
        // Add to existing traits
        final locationsListPN = ref.read(locationsProvider.notifier);
        final updatedShop = descriptionType == 'inside'
            ? Shop.fromShop(baseShop: shop, insideTraits: [...shop.insideTraits, ...newTraits])
            : Shop.fromShop(baseShop: shop, outsideTraits: [...shop.outsideTraits, ...newTraits]);
        
        locationsListPN.replace(shop, updatedShop);
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Added ${newTraits.length} more $descriptionType trait(s)!')),
        );
      } else {
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('No suitable templates found for new traits')),
        );
      }
    } catch (e) {
      if (!ref.context.mounted) return;
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error adding traits: $e')),
      );
    }
  }

  void _regenerateShopTraits(WidgetRef ref, Shop shop, String descriptionType) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      final newTraits = descriptionService.generateShopTraits(
        shop: shop,
        templates: shopTemplates,
        descriptionType: descriptionType,
        maxTraits: 2,
      );
      
      if (newTraits.isNotEmpty) {
        // Replace existing traits with new ones
        final locationsListPN = ref.read(locationsProvider.notifier);
        final updatedShop = descriptionType == 'inside'
            ? Shop.fromShop(baseShop: shop, insideTraits: newTraits)
            : Shop.fromShop(baseShop: shop, outsideTraits: newTraits);
        
        locationsListPN.replace(shop, updatedShop);
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('$descriptionType traits regenerated!')),
        );
      } else {
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('No suitable templates found for this shop type')),
        );
      }
    } catch (e) {
      if (!ref.context.mounted) return;
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error regenerating traits: $e')),
      );
    }
  }

  void _rerollIndividualTrait(WidgetRef ref, Shop shop, ShopTrait trait, String descriptionType) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      // Generate a new trait with the same tag using existing method
      final newTraits = descriptionService.generateShopTraits(
        shop: shop,
        templates: shopTemplates.where((template) => 
          template.tag == trait.tag && 
          template.descriptionType == descriptionType
        ).toList(),
        descriptionType: descriptionType,
        maxTraits: 1,
      );
      
      if (newTraits.isNotEmpty) {
        final newTrait = newTraits.first;
        
        // Update the shop with the rerolled trait
        final locationsListPN = ref.read(locationsProvider.notifier);
        
        List<ShopTrait> updatedTraits;
        if (descriptionType == 'inside') {
          updatedTraits = shop.insideTraits.map((t) => t.id == trait.id ? newTrait : t).toList();
          final updatedShop = Shop.fromShop(baseShop: shop, insideTraits: updatedTraits);
          locationsListPN.replace(shop, updatedShop);
        } else {
          updatedTraits = shop.outsideTraits.map((t) => t.id == trait.id ? newTrait : t).toList();
          final updatedShop = Shop.fromShop(baseShop: shop, outsideTraits: updatedTraits);
          locationsListPN.replace(shop, updatedShop);
        }
        
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Trait rerolled!')),
        );
      } else {
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('No alternative templates found for this trait')),
        );
      }
    } catch (e) {
      if (!ref.context.mounted) return;
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error rerolling trait: $e')),
      );
    }
  }

  Future<void> _exportShopToPDF(BuildContext context, WidgetRef ref, Shop shop) async {
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
                Text('Generating PDF...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);

      final success = await PDFExportService.exportShopToPDF(
        shop: shop,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF exported successfully for ${shop.name}!'),
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
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

class ShopDetailTabbed extends HookConsumerWidget {
  const ShopDetailTabbed({super.key, ar});
  static const routeName = "/ShopDetailTabbed";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final myID = arguments?['myID'];

    Shop shop = ref
            .watch(locationsProvider)
            .firstWhere(
                (ell) => ell.locType == LocationType.shop && ell.id == myID)
        as Shop;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Stack(
            children: [
              if (Navigator.of(context)
                  .canPop()) // Back button if there's a route to go back to
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // Menu functionality to be implemented later
                    },
                  ),
                ),
              Center(child: Text(shop.name)), // Title remains centered
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export to PDF',
              onSelected: (value) {
                if (value == 'single') {
                  _exportSingleShopFromTabbed(context, ref, shop);
                } else if (value == 'town') {
                  _exportTownFromTabbed(context, ref);
                } else if (value == 'all_locations') {
                  _exportAllLocationsFromTabbed(context, ref, shop);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'single',
                  child: Row(
                    children: [
                      Icon(Icons.store, size: 20),
                      SizedBox(width: 8),
                      Text('Export This Shop'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'town',
                  child: Row(
                    children: [
                      Icon(Icons.store, size: 20),
                      SizedBox(width: 8),
                      Text('Export All Shops'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'all_locations',
                  child: Row(
                    children: [
                      Icon(Icons.location_city, size: 20),
                      SizedBox(width: 8),
                      Text('Export All Locations'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Top pane (collapsible)
            ExpansionTile(
              initiallyExpanded: true,
              title: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 16), // Base style
                  children: [
                    TextSpan(
                        text: shop.pro1,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " & "),
                    TextSpan(
                        text: shop.pro2,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " but "),
                    TextSpan(
                        text: shop.con,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Owner and encounters side-by-side
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Owner section (left side)
                            Expanded(
                              flex: 1,
                              child: _buildOwnersSection(context, ref, shop),
                            ),
                            const SizedBox(width: 16),
                            // Encounters section (right side)
                            Expanded(
                              flex: 1,
                              child: LocationEncountersWidget(
                                locationType: LocationType.shop, 
                                locationId: shop.id,
                                shopType: shop.type,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom pane with tabs
            Expanded(
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Description"),
                      Tab(text: "People"),
                      Tab(text: "Services"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Center(
                            child: descriptionView(
                                context, ref, shop)), // Placeholder
                        peopleView(context,ref,shop), // Placeholder
                        servicesView(context, ref, shop), // Placeholder
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportSingleShopFromTabbed(BuildContext context, WidgetRef ref, Shop shop) async {
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
                Text('Generating PDF...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final allPeople = ref.read(peopleProvider);
      final allRoles = ref.read(locationRolesProvider);

      final success = await PDFExportService.exportShopToPDF(
        shop: shop,
        allPeople: allPeople,
        allRoles: allRoles,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF exported successfully for ${shop.name}!'),
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
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportTownFromTabbed(BuildContext context, WidgetRef ref) async {
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
            duration: Duration(seconds: 5),
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

  Future<void> _exportAllLocationsFromTabbed(BuildContext context, WidgetRef ref, Shop shop) async {
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

Widget showOwners(BuildContext context, WidgetRef ref, Shop shop) {

  ref.read(townProvider);
  final allRoles = ref.watch(locationRolesProvider);
  final people = ref.watch(peopleProvider);
  final roleMeta = ref.watch(roleMetaProvider.notifier);

  Role thisRole = Role.owner;
  if(shop.type == ShopType.temple){thisRole = Role.hierophant;}
  
  
  String headerString = "";
  List<Person> thePeopleInTheRoleHere;
  List<Widget> myRoleWidgets;

  Set<String> roleIDs = allRoles
      .where((lr) => lr.locationID == shop.id && lr.myRole == thisRole)
      .map((lr) => lr.myID)
      .toSet();

  thePeopleInTheRoleHere =
      people.where((p) => roleIDs.contains(p.id)).toSet().toList();

  // headerString=enum2String(myEnum: thisRole, plural: thePeopleInTheRoleHere.length>1);
  headerString =
      roleMeta.getString(thisRole, plural: thePeopleInTheRoleHere.length > 1);

  myRoleWidgets = thePeopleInTheRoleHere
      .map((p) => p.printFlippableCard())
      .toList();

  return ExpansionTile(
    title: Text(headerString),
    initiallyExpanded: true,
    expandedAlignment: Alignment.topLeft,
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: myRoleWidgets,
  );
}

Widget _buildOwnersSection(BuildContext context, WidgetRef ref, Shop shop) {

  ref.read(townProvider);
  final allRoles = ref.watch(locationRolesProvider);
  final people = ref.watch(peopleProvider);
  final roleMeta = ref.watch(roleMetaProvider.notifier);

  Role thisRole = Role.owner;
  if(shop.type == ShopType.temple){thisRole = Role.hierophant;}
  
  
  String headerString = "";
  List<Person> thePeopleInTheRoleHere;
  List<Widget> myRoleWidgets;

  Set<String> roleIDs = allRoles
      .where((lr) => lr.locationID == shop.id && lr.myRole == thisRole)
      .map((lr) => lr.myID)
      .toSet();

  thePeopleInTheRoleHere =
      people.where((p) => roleIDs.contains(p.id)).toSet().toList();

  // headerString=enum2String(myEnum: thisRole, plural: thePeopleInTheRoleHere.length>1);
  headerString =
      roleMeta.getString(thisRole, plural: thePeopleInTheRoleHere.length > 1);

  myRoleWidgets = thePeopleInTheRoleHere
      .map((p) => p.printFlippableCard())
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        headerString,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 8),
      ...myRoleWidgets,
    ],
  );
}

Widget descriptionView(BuildContext context, WidgetRef ref, Shop shop) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Outside Description Section
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store_mall_directory, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Outside Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (shop.outsideTraits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'No outside traits generated yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...shop.outsideTraits.map((trait) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      trait.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
              ],
            ),
          ),
        ),
        
        // Inside Description Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Inside Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (shop.insideTraits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'No inside traits generated yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...shop.insideTraits.map((trait) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      trait.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
              ],
            ),
          ),
        ),
        
      ],
    ),
  );
}

Widget peopleView(BuildContext context, WidgetRef ref, Shop shop) {
    List<ExpansionTile> peopleWidgets=[];
    // final thisTown = ref.read(townProvider);
    // final thisWorld =ref.read(myWorldProvider);


  
    Set<Role> rio=(roleLookup[shop.type]?? []).toSet();
    
    rio.remove(Role.owner);
    rio.remove(Role.hierophant);

    List<Role> rolesInOrder = rio.toList();
    


    Role thisRole;
    String headerString="";
    List<Person> thePeopleInTheRoleHere;
    List<Widget> myRoleWidgets;
    List<LocationRole> allRoles = ref.watch(locationRolesProvider);
    List<Person> people = ref.watch(peopleProvider);
    List<Location> allLocations = ref.watch(locationsProvider);

    final roleMetaPN = ref.read(roleMetaProvider.notifier);


    for(int i=0; i<rolesInOrder.length; i++)
    {
      thisRole=rolesInOrder.elementAt(i);
      Set<String> roleIDs= allRoles.where((lr)=>lr.locationID==shop.id && lr.myRole==thisRole).map((lr)=>lr.myID).toSet();
      
      thePeopleInTheRoleHere = people.where((p)=>roleIDs.contains(p.id)).toSet().toList();
      
      // headerString=enum2String(myEnum: thisRole, plural: thePeopleInTheRoleHere.length>1);
      headerString = roleMetaPN.getString(thisRole,plural: thePeopleInTheRoleHere.length>1);
      myRoleWidgets=[];
      // for(int j=0; j<thePeopleInTheRoleHere.length;j++)
      for(final p in thePeopleInTheRoleHere)
      {
        if(thisRole==Role.regular || thisRole==Role.customer)
        {
          List<LocationRole> otherRoles = allRoles.where((lr)=> lr.myID==p.id
          && lr.locationID!=shop.id).toList();
          Set<String> addString={};
          String thisString="";
          for(final or in otherRoles){
            // String myJob=enum2String(myEnum:or.myRole,plural: false );
            String myJob=roleMetaPN.getString(or.myRole);
          
            thisString=myJob;
            if({Role.apprentice,Role.journeyman,Role.owner,Role.customer,Role.regular}.contains(or.myRole))
            {
              int index=allLocations.indexWhere((ell)=>ell.id == or.locationID);
              if(index==-1){thisString="";}else{thisString="$thisString : ${allLocations[index].name}";}
              
              // String shopName=.name;
              
              // thisString="$thisString : $shopName";
            }else if(or.myRole.name.contains("Government")){
              if(or.myRole.name.contains("guard")){
                thisString = "Town Guard: ${roleMetaPN.getString(or.myRole,ref:ref)}";
              }else{
              thisString ="Government Official: ${roleMetaPN.getString(or.myRole,ref:ref)}";
              }
            }

            addString.add(thisString);
          }
          myRoleWidgets.add(p.printFlippableCard(additionalInfo: addString.toList()));
        }else{
        myRoleWidgets.add(p.printFlippableCard());
        }
      }
      if(myRoleWidgets.isNotEmpty)
      {peopleWidgets.add(ExpansionTile(title: Text(headerString),
               expandedAlignment: Alignment.topLeft,
               expandedCrossAxisAlignment: CrossAxisAlignment.start,
               children: myRoleWidgets,
                ),
               );}
    }
  return SingleChildScrollView(
    child: Align(
    alignment: Alignment.topCenter,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: peopleWidgets
        ),
      ));
}

// Widget servicesView(BuildContext context, WidgetRef ref, Shop shop) {
//   List<Service> alphaService = shop.services..sort((a,b)=>a.description.compareTo(b.description));

//   List<Widget> serviceWidgets = alphaService.map((s)=>s.printDetailTappable(shop.id)).toList();
//    ExpansionTile(title: Text("Highlighted Services/Items for Sale"),
//                              expandedAlignment: Alignment.topLeft,
//                expandedCrossAxisAlignment: CrossAxisAlignment.start,
//                children: serviceWidgets,
//                 );
//   return SingleChildScrollView(
//     child: Align(
//     alignment: Alignment.topLeft,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [...serviceWidgets,
//                 buildServiceButtons(context,ref,shop)
//                 ],
//         ),
//       ));
// }


// // Now add a row with two buttons at the end or wherever needed
// Widget buildServiceButtons(BuildContext context, WidgetRef ref, Shop shop) {
//   return Container(
//     width: 200, // Match the width of your containers
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     child: Row(
//       children: [
//         // First button
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               handleAddFromExistingButton(context,)
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color.fromARGB(255, 218, 183, 152),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               textStyle: const TextStyle(fontSize: 12,color: Colors.white),
//             ),
//             child: const Text(
//               'Add from existing services',
//               textAlign: TextAlign.center,
//               selectionColor: Colors.white,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8), // Space between buttons
//         // Second button
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () async{
//               // Handle creating new service
//               final town = ref.read(townProvider);
//               final locationsListProvider = ref.watch(town.locationsListProvider.notifier);
//               String newID = _uuid.v4();
//               Service newService = Service(cost: Price(cp: 0,sp:0,gp:0,pp:0),myID: newID,description: "New Service");
//               List<Service> newServices = [...shop.services,newService];
//               Shop newShop = Shop.fromShop(baseShop: shop, services: newServices);
//               await locationsListProvider.replace(replaceID: newShop.id, replacement: newShop);


//               navigatorKey.currentState!.restorablePushNamed(
//               ServiceEditItem.routeName,
//               arguments: {'serviceID': newID,
//                           'shopID': shop.id},
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color.fromARGB(255, 196, 226, 251),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               textStyle: const TextStyle(fontSize: 12),
//             ),
//             child: const Text(
//               'Create new service',
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Usage example - add this to your list of widgets
// For example, in a Column or ListView:
/*
Column(
  children: [
    ...containerList,
    buildServiceButtons(),
  ],
)
*/

Widget servicesView(BuildContext context, WidgetRef ref, Shop shop) {
  // Sort existing services alphabetically
 List<Service> alphaService = shop.services..sort((a,b)=>a.description.compareTo(b.description));

// Create service widgets
List<Widget> serviceWidgets = alphaService.map((s) {
  // Find the index of this specific service in the original shop.services list
  int serviceIndex = shop.services.indexOf(s);
  
  return s.printDetailTappable(
    shop.id,
    ref: ref,
    shop: shop,
    serviceIndex: serviceIndex
  );
}).toList();

  return SingleChildScrollView(
    child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing services expansion tile
          ExpansionTile(
            title: Text("Highlighted Services/Items for Sale"),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: serviceWidgets,
          ),
          // Existing service buttons and new dropdown
          buildServiceButtons(context, ref, shop)
        ],
      ),
    ),
  );
}

Widget buildServiceButtons(BuildContext context, WidgetRef ref, Shop shop) {
  // Get applicable generic services

  final applicableGenericServices = ref.read(genericServicesProvider)
      .where((g) => g.whereAvailable.contains(shop.type))
      .toList()..sort((a,b)=>a.description.compareTo(b.description));

  // State for dropdown selection


  return Column(
    children: [
      // Existing buttons row
      Container(
        width: 200, // Match the width of your containers
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // final town = ref.read(townProvider);
                  final locationsListProvider = ref.watch(locationsProvider.notifier);
                  String newID = _uuid.v4();
                  Service newService = Service(
                    cost: Price(cp: 0, sp: 0, gp: 0, pp: 0),
                    myID: newID,
                    description: "New Service"
                  );
                  List<Service> newServices = [...shop.services, newService];
                  Shop newShop = Shop.fromShop(baseShop: shop, services: newServices);
                  locationsListProvider.replace(
                    shop, 
                    newShop
                  );
                  await locationsListProvider.commitChanges();

                  navigatorKey.currentState!.restorablePushNamed(
                    ServiceEditItem.routeName,
                    arguments: {
                      'serviceID': newID,
                      'shopID': shop.id
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 196, 226, 251),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text(
                  'Create new service',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // New dropdown for adding generic services
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              // Wrap the DropdownButtonFormField with ValueListenableBuilder
              child: ValueListenableBuilder<GenericService?>(
                valueListenable: selectedServiceNotifier,
                builder: (context, selectedService, child) {
                  return DropdownButtonFormField<GenericService>(
                    decoration: InputDecoration(
                      labelText: 'Add Generic Service',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedService,
                    onChanged: (GenericService? newValue) {
                      // Explicitly update the ValueNotifier
                      selectedServiceNotifier.value = newValue;
                      // Debug print
                    },
                    items: applicableGenericServices
                        .map<DropdownMenuItem<GenericService>>((GenericService service) {
                      return DropdownMenuItem<GenericService>(
                        value: service,
                        child: Text(service.description),
                      );
                    }).toList(),
                    hint: Text('Select a generic service'),
                    isExpanded: true,
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                
                if (selectedServiceNotifier.value != null) {
                  // Convert GenericService to Service
                  Service newService = _convertGenericServiceToService(
                    ref, 
                    selectedServiceNotifier.value!, 
                    shop
                  );

                  // Add the new service to the shop
                  ref.read(townProvider);
                  final locationsListPN = ref.watch(locationsProvider.notifier);
                  
                  List<Service> newServices = [...shop.services, newService];
                  Shop newShop = Shop.fromShop(baseShop: shop, services: newServices);
                  
                  locationsListPN.replace(
                    shop, 
                    newShop
                  );
                  await locationsListPN.commitChanges();
                  

                  // Reset the dropdown
                  selectedServiceNotifier.value = null;
                }
              },
            ),
          ],
        ),
      ),
    ],
  );
}

// Helper method to convert GenericService to Service with optional specialty
Service _convertGenericServiceToService(
  WidgetRef ref, 
  GenericService genericService, 
  Shop shop
) {
  // Determine if there are applicable specialties
  Set<ServiceType> mySpecialties = _determineShopSpecialties(shop);
  
  String description = genericService.description;
  
  // Check if there are applicable specialties
  if (mySpecialties.intersection(genericService.serviceType.toSet()).isNotEmpty) {
    List<Specialty> applicableSpecialties = ref.watch(specialtyServicesProvider)
        .where((s) => s.appliesTo.toSet().intersection(mySpecialties).isNotEmpty)
        .toList();
    
    if (applicableSpecialties.isNotEmpty) {
      Specialty randSpec = randomElement(applicableSpecialties);
      description = "$description (${randSpec.description})";
    }
  }

  // Create and return the new Service
  return Service(
    cost: genericService.price,
    description: description,
  );
}

// Helper method to determine shop specialties
Set<ServiceType> _determineShopSpecialties(Shop shop) {
  Map<String, List<ServiceType>> pro2types = {
    "Great Food": [ServiceType.food],
    "Specializes in Weapons": [ServiceType.weapon],
    "Specializes in Armor": [ServiceType.armor],
    "Specializes in Adventuring Gear": [ServiceType.adventure],
    "Specializes in Healing": [ServiceType.potion],
    "Specializes in Remedies": [ServiceType.potion],
    "Specializes in adventuring gear": [ServiceType.adventure],
    "Caters to adventurers' needs": [ServiceType.adventure],
    "Specializes in Potions": [ServiceType.potion],
    "Specializes in Scrolls": [ServiceType.scroll],
  };

  Set<ServiceType> mySpecialties = {};
  
  if (pro2types[shop.pro1] != null) {
    mySpecialties.addAll(pro2types[shop.pro1]!);
  }
  if (pro2types[shop.pro2] != null) {
    mySpecialties.addAll(pro2types[shop.pro2]!);
  }

  return mySpecialties;
}

