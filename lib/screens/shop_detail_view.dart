import "package:firetown/providers/barrel_of_providers.dart";
import '../providers/shop_template_provider.dart';
import '../services/description_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
import "package:firetown/screens/service_edit.dart";
import "../enums_and_maps.dart";

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
            // Add description section
            const SizedBox(height: 16),
            _buildShopDescriptionSection(context, ref, shop),
          ],
        ),

        // )
      ),
    ));
  }

  Widget _buildShopDescriptionSection(BuildContext context, WidgetRef ref, Shop shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shop Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (shop.description.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate description',
                        onPressed: () => _regenerateShopDescription(ref, shop),
                      ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      tooltip: 'Generate description',
                      onPressed: () => _generateShopDescription(ref, shop),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: shop.description.isEmpty ? Colors.grey.shade50 : Colors.white,
              ),
              child: Text(
                shop.description.isEmpty ? 'No description generated' : shop.description,
                style: TextStyle(
                  fontSize: 14,
                  color: shop.description.isEmpty ? Colors.grey.shade600 : Colors.black87,
                  fontStyle: shop.description.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateShopDescription(WidgetRef ref, Shop shop) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      final newDescription = descriptionService.generateFullShopDescription(
        shop: shop,
        shopTemplates: shopTemplates,
        maxTraits: 2,
      );
      
      if (newDescription != null) {
        // Update the shop with new description
        final locationsListPN = ref.read(locationsProvider.notifier);
        final updatedShop = Shop.fromShop(baseShop: shop, description: newDescription);
        
        locationsListPN.replace(shop, updatedShop);
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Shop description generated!')),
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
        SnackBar(content: Text('Error generating description: $e')),
      );
    }
  }

  void _regenerateShopDescription(WidgetRef ref, Shop shop) async {
    try {
      final shopTemplates = ref.read(shopTemplateProvider);
      final descriptionService = DescriptionService();
      
      final newDescription = descriptionService.generateFullShopDescription(
        shop: shop,
        shopTemplates: shopTemplates,
        maxTraits: 2,
      );
      
      if (newDescription != null) {
        // Update the shop with new description
        final locationsListPN = ref.read(locationsProvider.notifier);
        final updatedShop = Shop.fromShop(baseShop: shop, description: newDescription);
        
        locationsListPN.replace(shop, updatedShop);
        await locationsListPN.commitChanges();
        
        if (!ref.context.mounted) return;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Shop description regenerated!')),
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
        SnackBar(content: Text('Error regenerating description: $e')),
      );
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
        ),
        body: Column(
          children: [
            // Top pane (fixed)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
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
                    softWrap: true, // Allow wrapping to the next line if needed
                  ),
                  const SizedBox(height: 8),
                  // Owner and encounters side-by-side
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Owner section (left side)
                        Expanded(
                          flex: 1,
                          child: showOwners(context, ref, shop),
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
      .map((p) => p.printPersonSummaryTappable(context))
      .toList();

  return ExpansionTile(
    title: Text(headerString),
    expandedAlignment: Alignment.topLeft,
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: myRoleWidgets,
  );
}

Widget descriptionView(BuildContext context, WidgetRef ref, Shop shop) {
  return Text(shop.description);
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
          myRoleWidgets.add(p.printPersonSummaryTappable(context,additionalInfo: addString.toList()));
        }else{
        myRoleWidgets.add(p.printPersonSummaryTappable(context));
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