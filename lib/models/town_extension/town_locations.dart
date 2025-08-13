
import 'package:firetown/screens/service_edit.dart';
import 'package:firetown/models/location_services_model.dart';

// Adjust the path to the Person model.
// For Relationship and Node.

import 'package:flutter/material.dart';

import '/enums_and_maps.dart';
import '../new_shops_models.dart';
import 'package:uuid/uuid.dart';
import '/globals.dart';

import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import "package:firetown/screens/shop_detail_view.dart";
import "../../providers/barrel_of_providers.dart";
import '../barrel_of_models.dart';

const _uuid = Uuid();
String marketID = "fixed_market";
String hirelingID = "fixed_hireling";
String informationalID = "fixed_informational";
String governtmentID = "fixed_government";

class Service {
  String description;
  Price price;
  String id;
  int quantity;
  Service(
      {this.description = "Unknown Service",
      Price? cost,
      String? myID,
      int? quantity})
      : id = myID ?? _uuid.v4(),
        price = cost ?? Price(cp: -1, sp: -2, gp: -3, pp: -4),
        quantity = quantity ?? 0;
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cost": price.toJson(),
      "description": description,
      "quantity": quantity
    };
  }

  factory Service.fromJson(json) {
    return Service(
        description: json["description"],
        cost: Price.fromJson(json["cost"]),
        myID: json["id"],
        quantity: json["quantity"]);
  }

  Service copyWith(
      {String? id, Price? price, String? description, int? quantity}) {
    return Service(
        description: description ?? this.description,
        cost: price ?? this.price,
        myID: id ?? this.id,
        quantity: quantity ?? this.quantity);
  }

  Container printDetail() {
    return Container(
        width: 200,
        margin:
            const EdgeInsets.symmetric(vertical: 8), // Space between sections
        padding: const EdgeInsets.all(12), // Padding inside the box
        decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 255, 207, 158), // Light background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
                color: const Color.fromARGB(
                    255, 217, 153, 94))), // Optional border
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure left-alignment
          children: [
            Text(
              description,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null, // Allow unlimited lines),
            ),
            Text(price.toString()),
          ],
        ));
  }

  Widget printDetailTappable(String shopID,
      {required WidgetRef ref, required Shop shop, required int serviceIndex}) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState!.restorablePushNamed(
          ServiceEditItem.routeName,
          arguments: {'serviceID': id, 'shopID': shopID},
        );
      },
      child: Container(
        width: 300, // Increased width to accommodate controls
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 207, 158),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color.fromARGB(255, 217, 153, 94))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description and Price
            Text(
              description,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
            Text(price.toString()),

            // Quantity Controls Row
            const SizedBox(height: 8),
            Row(
              children: [
                // Minus Button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    if (quantity > 0) {
                      Service updatedService = copyWith(quantity: quantity - 1);

                      await _updateServiceInShop(
                          ref: ref,
                          shop: shop,
                          serviceIndex: serviceIndex,
                          updatedService: updatedService);
                    }
                  },
                ),

                // Quantity Display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Plus Button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    Service updatedService = copyWith(quantity: quantity + 1);

                    await _updateServiceInShop(
                        ref: ref,
                        shop: shop,
                        serviceIndex: serviceIndex,
                        updatedService: updatedService);
                  },
                ),

                const Spacer(), // Flexible space

                // Remove Button
                ElevatedButton(
                  onPressed: () async {
                    // Remove the service at the specific index
                    List<Service> updatedServices = List.from(shop.services)
                      ..removeAt(serviceIndex);

                    Shop updatedShop = Shop.fromShop(
                        baseShop: shop, services: updatedServices);

                    ref.read(townProvider);
                    final locationsPN =
                        ref.watch(locationsProvider.notifier);

                     locationsPN.replace(shop, updatedShop);
                    await locationsPN.commitChanges();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateServiceInShop(
      {required WidgetRef ref,
      required Shop shop,
      required int serviceIndex,
      required Service updatedService}) async {
    // Read the town provider
    // final town = ref.read(townProvider);
    final locationsPN = ref.watch(locationsProvider.notifier);
        // ref.watch(town.locationsListProvider.notifier);

    // Create a new list of services with the updated service
    List<Service> updatedServices = List.from(shop.services);
    updatedServices[serviceIndex] = updatedService;

    // Create a new shop with the updated services list
    Shop updatedShop = Shop.fromShop(baseShop: shop, services: updatedServices);

    // Replace the shop in the locations list provider
    locationsPN.replace(shop,updatedShop);
    await locationsPN.commitChanges();
  }

  Widget printDetailTappableWithControls(String shopID) {
    return GestureDetector(
        onTap: () {
          navigatorKey.currentState!.restorablePushNamed(
            ServiceEditItem.routeName,
            arguments: {'serviceID': id, 'shopID': shopID},
          );
        },
        child: Container(
            width: 200,
            margin: const EdgeInsets.symmetric(
                vertical: 8), // Space between sections
            padding: const EdgeInsets.all(12), // Padding inside the box
            decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 255, 207, 158), // Light background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(
                    color: const Color.fromARGB(
                        255, 217, 153, 94))), // Optional border
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Ensure left-alignment
              children: [
                Text(
                  description,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: null, // Allow unlimited lines),
                ),
                Text(price.toString()),
              ],
            )));
  }

  Widget printDetailTappable2(String shopID,
      {required WidgetRef ref, required Shop shop, required int serviceIndex}) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState!.restorablePushNamed(
          ServiceEditItem.routeName,
          arguments: {'serviceID': id, 'shopID': shopID},
        );
      },
      child: Container(
        width: 300, // Increased width to accommodate controls
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 207, 158),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color.fromARGB(255, 217, 153, 94))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description and Price
            Text(
              description,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
            Text(price.toString()),

            // Quantity Controls Row
            const SizedBox(height: 8),
            Row(
              children: [
                // Minus Button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    if (quantity > 1) {
                      Service updatedService = copyWith(quantity: quantity - 1);

                      await _updateServiceInShop(
                          ref: ref,
                          shop: shop,
                          serviceIndex: serviceIndex,
                          updatedService: updatedService);
                    }
                  },
                ),

                // Quantity Display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Plus Button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    Service updatedService = copyWith(quantity: quantity + 1);

                    await _updateServiceInShop(
                        ref: ref,
                        shop: shop,
                        serviceIndex: serviceIndex,
                        updatedService: updatedService);
                  },
                ),

                const Spacer(), // Flexible space

                // Remove Button
                ElevatedButton(
                  onPressed: () async {
                    // Remove the service at the specific index
                    List<Service> updatedServices = List.from(shop.services)
                      ..removeAt(serviceIndex);

                    Shop updatedShop = Shop.fromShop(
                        baseShop: shop, services: updatedServices);

                    ref.read(townProvider);
                    final locationsPN =
                        ref.watch(locationsProvider.notifier);
                    
                     locationsPN.replace(shop,updatedShop);
                      await locationsPN.commitChanges();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Helper method to update a service in the shop
  Future<void> _updateServiceInShop(
      {required WidgetRef ref,
      required Shop shop,
      required int serviceIndex,
      required Service updatedService}) async {
    ref.read(townProvider);
    final locationsPN =
        ref.watch(locationsProvider.notifier);

    List<Service> updatedServices = List.from(shop.services);
    updatedServices[serviceIndex] = updatedService;

    Shop updatedShop = Shop.fromShop(baseShop: shop, services: updatedServices);

    locationsPN.replace(shop,updatedShop);
    await locationsPN.commitChanges();
    
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Service &&
        other.id == id &&
        other.price == price &&
        other.description == description &&
        other.quantity == quantity; // Compare based on unique identifier
  }

  @override
  int get hashCode => Object.hash(id, price, description, quantity);
}

@immutable
class Location implements JsonSerializable {
  final String name;
  final String id;
  final String blurbText;
  final String description;
  final LocationType locType;

  @override
  String compositeKey() {
    return "$id.$name.${locType.name}";
  }

  Location(
      {required this.name,
      required this.locType,
      this.description = "Unknown Description",
      this.blurbText = "Unknown Blurb",
      String? myID,
      List<String>? myEncounterIDs})
      : id = myID ?? _uuid.v4();
  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "blurbText": blurbText,
      "description": description,
      "locType": locType.name,
      "factoryType": "Location",
    };
  }

  factory Location.fromJsonMultiplex(Map<String, dynamic> json) {
    switch (json["factoryType"]) {
      case "Shop":
        return Shop.fromJson(json);
      case "Location":
        return Location(
          name: json["name"],
          myID: json["id"],
          blurbText: json["blurbText"],
          locType:
              LocationType.values.firstWhere((v) => v.name == json["locType"]),
        );
      case "Informational":
        return Informational(
          myID: json["id"],
          name: json["name"],
          locType:
              LocationType.values.firstWhere((v) => v.name == json["locType"]),
        );
      default:
        throw Exception("Wrong factory type ${json.toString()}");
    }
  }
  factory Location.fromJsonSimplex(Map<String, dynamic> json) {
    return Location(
      name: json["name"],
      myID: json["id"],
      blurbText: json["blurbText"],
      locType: LocationType.values.firstWhere((v) => v.name == json["locType"]),
    );
  }
  Container printSummary() {
    return Container(
        margin:
            const EdgeInsets.symmetric(vertical: 8), // Space between sections
        padding: const EdgeInsets.all(12), // Padding inside the box
        decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 150, 220, 194), // Light background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
                color: const Color.fromARGB(
                    255, 91, 151, 124))), // Optional border
        child: Column(children: [
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            enum2String(myEnum: locType),
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            // "$pro1 & $pro2 but $con",
            blurbText,
            style: const TextStyle(fontSize: 14),
          ),
        ]));
  }

  Widget printSummaryTappable(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // navigatorKey.currentState!.restorablePushNamed(SearchPage.routeName,
          //     arguments: {'myID': id});
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: 8), // Space between sections
            padding: const EdgeInsets.all(12), // Padding inside the box
            decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 150, 220, 194), // Light background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(
                    color: const Color.fromARGB(
                        255, 91, 151, 124))), // Optional border
            child: Column(children: [
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                enum2String(myEnum: locType),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                // "$pro1 & $pro2 but $con",
                blurbText,
                style: const TextStyle(fontSize: 14),
              ),
            ])));
  }
}

@immutable
class Shop extends Location {
  final String pro1;
  final String pro2;
  final String con;
  final ShopType type;
  final List<Service> services;

  factory Shop.fromShop(
      {required Shop baseShop,
      String? pro1,
      String? pro2,
      String? con,
      List<Service>? services,
      String? name,
      String? description}) {
    String blurbText =
        "${pro1 ?? baseShop.pro1} & ${pro2 ?? baseShop.pro2} but ${con ?? baseShop.con}";
    return Shop(
        con: con ?? baseShop.con,
        pro1: pro1 ?? baseShop.pro1,
        pro2: pro2 ?? baseShop.pro2,
        name: name ?? baseShop.name,
        type: baseShop.type,
        myID: baseShop.id,
        myServices: services ?? baseShop.services,
        blurbText: blurbText,
        description: description ?? baseShop.description);
  }
  @override
  Container printSummary() {
    return Container(
        margin:
            const EdgeInsets.symmetric(vertical: 8), // Space between sections
        padding: const EdgeInsets.all(12), // Padding inside the box
        decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 150, 220, 194), // Light background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(
                color: const Color.fromARGB(
                    255, 91, 151, 124))), // Optional border
        child: Column(children: [
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            enum2String(myEnum: type),
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            // "$pro1 & $pro2 but $con",
            blurbText,
            style: const TextStyle(fontSize: 14),
          ),
        ]));
  }

  @override
  Widget printSummaryTappable(BuildContext context) {
    return GestureDetector(
        onTap: () {
          navigatorKey.currentState!.restorablePushNamed(
              ShopDetailView.routeName,
              arguments: {'myID': id});
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: 8), // Space between sections
            padding: const EdgeInsets.all(12), // Padding inside the box
            decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 150, 220, 194), // Light background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(
                    color: const Color.fromARGB(
                        255, 91, 151, 124))), // Optional border
            child: Column(children: [
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                enum2String(myEnum: type),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                // "$pro1 & $pro2 but $con",
                blurbText,
                style: const TextStyle(fontSize: 14),
              ),
            ])));
  }

  List<Widget> printDetail(WidgetRef ref) {
    List<ExpansionTile> peopleWidgets = [];
    final people = ref.watch(peopleProvider);
    final allRoles = ref.watch(locationRolesProvider);
    final allLocations = ref.watch(locationsProvider);
    final roleMeta = ref.watch(roleMetaProvider.notifier);

    var rolesInOrder = roleLookup[type]!.toList();

    Role thisRole;
    String headerString = "";
    List<Person> thePeopleInTheRoleHere;
    List<Widget> myRoleWidgets;
    for (int i = 0; i < rolesInOrder.length; i++) {
      thisRole = rolesInOrder.elementAt(i);
      Set<String> roleIDs = allRoles
          .where((lr) => lr.locationID == id && lr.myRole == thisRole)
          .map((lr) => lr.myID)
          .toSet();

      thePeopleInTheRoleHere =
          people.where((p) => roleIDs.contains(p.id)).toSet().toList();

      // headerString=enum2String(myEnum: thisRole, plural: thePeopleInTheRoleHere.length>1);
      headerString = roleMeta.getString(thisRole,
          plural: thePeopleInTheRoleHere.length > 1);
      myRoleWidgets = [];
      // for(int j=0; j<thePeopleInTheRoleHere.length;j++)
      for (final p in thePeopleInTheRoleHere) {
        if (thisRole == Role.regular || thisRole == Role.customer) {
          List<LocationRole> otherRoles = allRoles
              .where((lr) => lr.myID == p.id && lr.locationID != id)
              .toList();
          Set<String> addString = {};
          String thisString = "";
          for (final or in otherRoles) {
            // String myJob=enum2String(myEnum:or.myRole,plural: false );
            String myJob = roleMeta.getString(or.myRole);

            thisString = myJob;
            if ({
              Role.apprentice,
              Role.journeyman,
              Role.owner,
              Role.customer,
              Role.regular
            }.contains(or.myRole)) {
              int index =
                  allLocations.indexWhere((ell) => ell.id == or.locationID);
              if (index == -1) {
                thisString = "";
              } else {
                thisString = "$thisString : ${allLocations[index].name}";
              }

              // String shopName=.name;

              // thisString="$thisString : $shopName";
            }
            addString.add(thisString);
          }
          myRoleWidgets
              .add(p.printFlippableCard(additionalInfo: addString.toList()));
        } else {
          myRoleWidgets.add(p.printFlippableCard());
        }
      }
      if (myRoleWidgets.isNotEmpty) {
        peopleWidgets.add(
          ExpansionTile(
            title: Text(headerString),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: myRoleWidgets,
          ),
        );
      }
    }

    List<Widget> serviceWidgets = services.map((s) => s.printDetail()).toList();

    return [
      const SizedBox(height: 4),
      Text(
        name,
        style: const TextStyle(fontSize: 14),
      ),
      Text(
        enum2String(myEnum: type),
        style: const TextStyle(fontSize: 14),
      ),
      Text(
        "$pro1 & $pro2 but $con",
        style: const TextStyle(fontSize: 14),
      ),
      ...peopleWidgets,
      ExpansionTile(
        title: Text("Highlighted Services/Items for Sale"),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: serviceWidgets,
      )
    ];
  }

  Shop(
      {required super.name,
      super.myID,
      super.blurbText,
      super.description,
      super.locType = LocationType.shop,
      required this.type,
      required this.pro1,
      required this.pro2,
      required this.con,
      List<Service>? myServices})
      : services = myServices ?? List.empty();
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> startingMap = super.toJson();
    startingMap.addAll({
      "pro1": pro1,
      "pro2": pro2,
      "con": con,
      "type": type.name,
      "services": services.map((s) => s.toJson()).toList(),
      "factoryType": "Shop",
    });
    return startingMap;
  }

  @override
  factory Shop.fromJson(json) {
    final location = Location.fromJsonSimplex(json);
    return (Shop(
        con: json["con"],
        pro1: json["pro1"],
        pro2: json["pro2"],
        type: ShopType.values.firstWhere((v) => v.name == json["type"]),
        myServices:
            (json["services"] as List).map((s) => Service.fromJson(s)).toList(),
        myID: location.id,
        name: location.name,
        blurbText: location.blurbText,
        description: location.description));
  }
}

// class LocationList extends ProviderList<Location> {
//   LocationList({required super.myBox})
//       : super(fromJson: Location.fromJsonMultiplex);
// }

@immutable
class Informational extends Location {
  Informational(
      {required super.myID, required super.name, required super.locType});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> startingMap = super.toJson();
    startingMap.addAll({
      "factoryType": "Informational",
    });
    return startingMap;
  }

  List<Widget> printDetail(WidgetRef ref,
      List<Role> viewTheseRoles,
      {List<Location>? shopList}) {
    List<ExpansionTile> peopleWidgets = [];

    final people = ref.watch(peopleProvider);
    
    final roleMetaPN = ref.read(roleMetaProvider.notifier);
    final locationRoles = ref.watch(locationRolesProvider);
    List<PendingRoles> pendingRoles = ref.watch(pendingRolesProvider);

    // Sort roles alphabetically based on their string representation
    var rolesInOrder = List<Role>.from(viewTheseRoles)
      ..sort((a, b) => roleMetaPN
          .getString(a, plural: false)
          .compareTo(roleMetaPN.getString(b, plural: false)));

    for (int i = 0; i < rolesInOrder.length; i++) {
      final thisRole = rolesInOrder.elementAt(i);
      Set<String> roleIDs = locationRoles
          .where((lr) => lr.locationID == id && lr.myRole == thisRole)
          .map((lr) => lr.myID)
          .toSet();

      var thePeopleInTheRoleHere =
          people.where((p) => roleIDs.contains(p.id)).toList();
      if (thisRole == Role.owner) {
        Set<String> allOwnerIDs = locationRoles
            .where((lr) => lr.myRole == thisRole)
            .map((lr) => lr.myID)
            .toSet();
        thePeopleInTheRoleHere =
            people.where((p) => allOwnerIDs.contains(p.id)).toList();
      }

      final penRole = pendingRoles.firstWhere((pr) => pr.role == thisRole,
          orElse: () => PendingRoles(howMany: 0, role: thisRole));

      int howMany = thePeopleInTheRoleHere.length + penRole.howMany;

      String headerString = roleMetaPN.getString(thisRole,
          plural: thePeopleInTheRoleHere.length > 1);
      headerString = "$headerString ($howMany)";

      List<Widget> myRoleWidgets = [];
      for (int j = 0; j < thePeopleInTheRoleHere.length; j++) {
        List<String> shopString = [];

        if (thisRole == Role.owner && shopList != null) {
          List<String> theShopID = locationRoles
              .where((lr) =>
                  (lr.myRole == thisRole) &&
                  (lr.myID == thePeopleInTheRoleHere[j].id))
              .map((lr) => lr.locationID)
              .toList();

          final myShops = shopList
              .where((s) => theShopID.contains(s.id))
              .cast<Shop>()
              .toList();

          shopString = myShops
              .map((shop) => "Owner of ${shop.type.name} : ${shop.name}")
              .toList();
        }

        myRoleWidgets.add(thePeopleInTheRoleHere[j]
            .printFlippableCard(additionalInfo: shopString));
      }

      if (myRoleWidgets.isNotEmpty) {
        List<Widget> expansionChildren = [...myRoleWidgets];

        // Add "Show more" button if there are more people than shown
        if (thePeopleInTheRoleHere.length < howMany) {
          expansionChildren.add(
            TextButton(
              onPressed: () async =>
                  await ref.read(townProvider).handleShowMore(thisRole, ref),
              child: Text(
                  "Show more ${roleMetaPN.getString(thisRole, plural: true)}"),
            ),
          );
        }

        peopleWidgets.add(
          ExpansionTile(
            title: Text(headerString),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: expansionChildren,
          ),
        );
      }
    }

    return [...peopleWidgets];
  }

  List<Widget> printDetailGov2(
      WidgetRef ref, BuildContext context) {
    List<ExpansionTile> peopleWidgets = [];
    
    final roleMeta = ref.watch(roleMetaProvider.notifier);
    final locationRoles = ref.watch(locationRolesProvider);
    
    final locations = ref.watch(locationsProvider);
    final people = ref.watch(peopleProvider);

    List<LocationRole> theseRoles =
        locationRoles.where((lr) => lr.locationID == id).toList();

    List<Role> roleGroupings = theseRoles.map((tr)=>tr.myRole).toSet().toList();
    roleGroupings.sort((a,b)=>stringForHeaders(ref,a).compareTo(stringForHeaders(ref,b)));

    // List<String> specialties = theseRoles
    //     .map((lr) => lr.specialty)
    //     .toSet()
    //     .toList()
    //   ..sort((a, b) => a.compareTo(b));

    // Sort roles alphabetically based on their string representation

    for (final rG in roleGroupings) {

      
    
      Set<String> roleIDs = locationRoles
          .where((lr) => lr.locationID == id && lr.myRole==rG)
          .map((lr) => lr.myID)
          .toSet();

      var thePeopleInTheRoleHere =
          people.where((p) => roleIDs.contains(p.id)).toList();
      // if (thisRole == Role.owner) {
      //   Set<String> allOwnerIDs = allRoles
      //       .where((lr) => lr.myRole == thisRole)
      //       .map((lr) => lr.myID)
      //       .toSet();
      //   thePeopleInTheRoleHere = people.where((p) => allOwnerIDs.contains(p.id)).toList();
      // }

      String headerString = stringForHeaders(ref,rG);

      List<Widget> myRoleWidgets = [];
      for (int j = 0; j < thePeopleInTheRoleHere.length; j++) {
        List<String> shopString;
        int locRoleIndex = locationRoles.indexWhere((lr) =>
            lr.locationID == infoID && lr.myID == thePeopleInTheRoleHere[j].id);
        if (locRoleIndex == -1) {
          shopString = ["Adopted"];
        } else {
          shopString = [
            // roleMeta.getString(locationRoleList[locRoleIndex].myRole,ref: ref)
          ];
        }

        final locRole = locationRoles
            .where((lr) =>
                lr.myID == thePeopleInTheRoleHere[j].id &&
                !{governtmentID, infoID, informationalID, marketID}
                    .contains(lr.locationID))
            .toList();
        for (int i = 0; i < locRole.length; i++) {
          final lr = locRole[i];
          final loc = locations.firstWhere((l) => l.id == lr.locationID);
          if (lr.myRole == Role.owner) {
            shopString.add("Owner of ${loc.name} : ${(loc as Shop).type.name}");
          } else {
            shopString.add("${roleMeta.getString(lr.myRole)} at ${loc.name}");
          }
          if (i + 1 < locRole.length) {
            // shopString.add("\n");
          }
        }

        myRoleWidgets.add(thePeopleInTheRoleHere[j]
            .printFlippableCard(additionalInfo: shopString));
      }

      if (myRoleWidgets.isNotEmpty) {
        List<Widget> expansionChildren = [...myRoleWidgets];

        peopleWidgets.add(
          ExpansionTile(
            title: Text(headerString),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: expansionChildren,
          ),
        );
      }
    }

    return [...peopleWidgets];
  }
}




extension TownLocationsOnFire on TownOnFire {

  Map<String, String> random3Quirks(WidgetRef ref, {required myShopType}) {
    final shopQualities = ref.watch(shopQualitiesProvider);
    final applicable =
        shopQualities.where((q) => q.type == myShopType).toList();

    Set<int> randomNumbers = {};

    while (randomNumbers.length < 3) {
      randomNumbers.add(random.nextInt(applicable.length));
    }
    final my3 = randomNumbers.toList();
    return <String, String>{
      "pro1": applicable[my3[0]].pro,
      "pro2": applicable[my3[1]].pro,
      "con": applicable[my3[2]].con
    };
  }


Future<void> addRandomShopNoCommit(
      ShopType myType, WidgetRef ref, String ownerID) async {
    
    final people = ref.watch(peopleProvider);
    final peoplePN = ref.read(peopleProvider.notifier);

    final locationRoles = ref.watch(locationRolesProvider);
    final roleMeta = ref.read(roleMetaProvider);

    final relationships = ref.watch(relationshipsProvider);
    final relationshipsPN = ref.watch(relationshipsProvider.notifier);

    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    
    final locationsPN = ref.read(locationsProvider.notifier);
    
    // final locSearchProvider = ref.read(locationSearch.notifier);
    // final peopleSearchProvider = ref.read(peopleSearch.notifier);

    final shopNames = ref.read(shopNamesProvider);
    final genericServices = ref.read(genericServicesProvider);
    final specialtyServices = ref.read(specialtyServicesProvider);

    List<Function> updateBuffer = List.empty(growable: true);

    bool isNotEmployed(String p) {
      return locationRoles.where((lr) => lr.myID == p).isEmpty;
    }

    List<String> relationshipWhere(String p, List<RelationshipType> relationshipTypes) {
      return relationships
          .firstWhere((r) => r.id == p)
          .relPairs
          .where((rp) => relationshipTypes.contains(rp.iAmYour))
          .map((rp) => rp.you)
          .toList();
    }

    String newShopName(
        {required List<String> ownerFirstNames,
        required List<String> ownerSurnames,
        required ShopType shopType}) {
      double r = random.nextDouble();
      bool firstSecond = r < 0.65;
      bool ownerFirstShopSecond = r < 0.75;
      bool ownerLastShopSecond = r < 0.9;
      bool ownerFirstShopFirstShopSecond = r < -0.95;
      bool ownerLastShopFirstShopSecond = r < 1;

      String rShopFW;
      String rShopSW;
      String rShopNW;

      String randomAlignment() {
        double r = random.nextDouble();
        if (r < 0.2) {
          return " Lawful Good";
        }
        if (r < 0.4) {
          return " Neutral Good";
        }
        if (r < 0.5) {
          return " Chaotic Good";
        }
        if (r < 0.6) {
          return " Lawful Neutral";
        }
        if (r < 0.7) {
          return " True Neutral";
        }
        if (r < 0.85) {
          return " Chaotic Neutral";
        }
        if (r < 0.9) {
          return " Lawful Evil";
        }
        if (r < 0.95) {
          return " Neutral Evil";
        }
        if (r < 0.99) {
          return " Chaotic Evil";
        }
        return "n Unaligned";
      }

      if (shopType == ShopType.temple) {
        String alignment = randomAlignment();
        return "Temple to a$alignment Deity";
      }

      List<ShopName> myShopWords =
          shopNames.where((n) => n.shopType == shopType).toList();
      List<String> shopFirstWords = myShopWords
          .where((w) => w.wordType == WordType.first)
          .map((w) => w.word)
          .toList();
      List<String> shopSecondWords = myShopWords
          .where((w) => w.wordType == WordType.second)
          .map((w) => w.word)
          .toList();
      List<String> shopNameWords = myShopWords
          .where((w) => w.wordType == WordType.withName)
          .map((w) => w.word)
          .toList();

      String rOwnerFN = ownerFirstNames[random.nextInt(ownerFirstNames.length)];
      String rOwnerLN = ownerSurnames[random.nextInt(ownerSurnames.length)];

      rShopFW = shopFirstWords[random.nextInt(shopFirstWords.length)];
      rShopSW = shopSecondWords[random.nextInt(shopSecondWords.length)];
      rShopNW = shopNameWords[random.nextInt(shopNameWords.length)];

      if (firstSecond) {
        return "$rShopFW $rShopSW";
      }
      if (ownerFirstShopSecond) {
        return "$rOwnerFN's $rShopSW";
      }
      if (ownerLastShopSecond) {
        return "$rOwnerLN's $rShopSW";
      }
      if (ownerFirstShopFirstShopSecond) {
        return "$rOwnerFN's $rShopNW $rShopSW";
      }
      if (ownerLastShopFirstShopSecond) {
        return "$rOwnerLN's $rShopNW $rShopSW";
      }
      return "******Shouldn't See This*******";
    }

    List<Person> ownerList = [];
    String myShopID = _uuid.v4();
    var myQuirks = random3Quirks(ref,myShopType: myType);
    String pro1 = myQuirks["pro1"]!;
    String pro2 = myQuirks["pro2"]!;
    String con = myQuirks["con"]!;
    String newName = "";
    // int counter=0;
    int staffMultiplier = 1;
    if ({pro1, pro2}.intersection({"Well staffed", "Popular"}).isNotEmpty) {
      staffMultiplier = 2;
    } else if ({con}
        .intersection({"Not well staffed", "Unpopular"}).isNotEmpty) {
      staffMultiplier = 0;
    }

    int entertainMultiplier = 1;
    if ({pro1, pro2}
        .intersection({"Great Music", "Great Storytelling"}).isNotEmpty) {
      entertainMultiplier = 2;
    }

    bool twoOwners = random.nextDouble() < 0.05;
    bool familyBusiness = random.nextDouble() < 0.5;

    List<Role> roleTypes = roleLookup[myType] ?? defaultRoles;

    Role myRole;
    int howMany = 1;
    Set<AgeType> validAges;
    Set<AgeType> adultOrMore = {
      AgeType.adult,
      AgeType.middleAge,
      AgeType.old,
      AgeType.quiteOld
    };
    Set<AgeType> children =
        AgeType.values.where((at) => (at).index < AgeType.adult.index).toSet();
    Set<AgeType> typicalWork = {AgeType.adult, AgeType.middleAge, AgeType.old};

    List<RelationshipType> familyToAddOnHire = [RelationshipType.partner];

    for (int i = 0; i < roleTypes.length; i++) {
      myRole = roleTypes[i];
      switch (myRole) {
        case Role.owner:
          howMany = 1;
          if (twoOwners) {
            howMany = 2;
          }
          validAges = adultOrMore;
          familyToAddOnHire = [
            RelationshipType.partner,
            RelationshipType.sibling,
            RelationshipType.child
          ];
          break;
        case Role.apprentice:
          howMany = 1 * staffMultiplier;
          validAges = children;
          familyToAddOnHire = [
            RelationshipType.parent,
            RelationshipType.sibling
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.journeyman:
          howMany = 2 * staffMultiplier;
          validAges = {AgeType.adult};
          familyToAddOnHire = [
            RelationshipType.parent,
            RelationshipType.sibling
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.entertainment:
          howMany = 1 * staffMultiplier * entertainMultiplier;
          validAges = typicalWork;
          familyToAddOnHire = [
            RelationshipType.partner,
            RelationshipType.sibling,
            RelationshipType.child
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.regular:
          howMany = 20;
          validAges = adultOrMore;
          familyToAddOnHire = [
            RelationshipType.parent,
            RelationshipType.sibling,
            RelationshipType.child,
            RelationshipType.friend,
            RelationshipType.partner
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.customer:
          howMany = 5;
          validAges = adultOrMore;
          familyToAddOnHire = [
            RelationshipType.parent,
            RelationshipType.sibling,
            RelationshipType.child,
            RelationshipType.friend,
            RelationshipType.partner
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.cook:
          howMany = 1 * staffMultiplier;
          validAges = typicalWork;
          familyToAddOnHire = [
            RelationshipType.partner,
            RelationshipType.sibling,
            RelationshipType.child
          ]; // iAmYour==parent, sibling, etc

          break;
        case Role.waitstaff:
          howMany = 2 * staffMultiplier;
          validAges = typicalWork;
          familyToAddOnHire = [
            RelationshipType.partner,
            RelationshipType.sibling,
            RelationshipType.child
          ]; // iAmYour==parent, sibling, etc
          break;
        case Role.acolyte:
          howMany = 4;
          validAges = typicalWork;
          validAges.add(AgeType.young);
          break;
        default:
          howMany = 0;
          validAges = {};
          familyToAddOnHire = [RelationshipType.partner];
      }

      List<String> familyOfCurrentWorkersIDs = [];
      List<String> possibleWorkers = [];
      if (myRole == Role.customer) {
        Set<Role> customerRoles = roleMeta
            .where((rg) => rg.prioritizeCustomer)
            .map((rg) => rg.thisRole)
            .toSet();
        if (myType == ShopType.magic) {
          customerRoles = customerRoles.intersection(
              {Role.mercenary, Role.sage, Role.herbalist, Role.hierophant});
        }
        possibleWorkers = locationRoles
            .where((lr) =>
                (lr.locationID == infoID && customerRoles.contains(lr.myRole)))
            .map((lr) => lr.myID)
            .toList();
      } else if (myRole == Role.regular) {
        Set<Role> regularRoles;
        if (random.nextDouble() < 0.5) {
          regularRoles = roleMeta
              .where((rg) => rg.priorityInTaverns)
              .map((rg) => rg.thisRole)
              .toSet();
        } else {
          regularRoles = roleMeta
              .where((rg) => rg.promoteInTaverns)
              .map((rg) => rg.thisRole)
              .toSet();
        }
        possibleWorkers = locationRoles
            .where((lr) =>
                (lr.locationID == infoID && regularRoles.contains(lr.myRole)))
            .map((lr) => lr.myID)
            .toList();
      } else {
        possibleWorkers = people
            .where((p) => ((isNotEmployed(p.id)) && validAges.contains(p.age)))
            .map((p) => p.id)
            .toList();
      }
      possibleWorkers.removeWhere((id) => id == ownerID);

      int j = 0;

      if (myRole == Role.owner || myRole == Role.hierophant) {
        String worker = ownerID;
        ownerList.add(people.firstWhere((p) => p.id == ownerID));
        final locRole = LocationRole(
            locationID: myShopID, myID: worker, myRole: myRole, specialty: "");

        locationRolesPN.add(locRole);
        // updateBuffer.add(() async => locationRolesPN.add(addMe: locRole));
        j = 1;
      }
      for (j; j < howMany; j++) {
        String worker;

        if (possibleWorkers.isNotEmpty) {
          if (familyBusiness) {
            final x = familyOfCurrentWorkersIDs
                .toSet()
                .intersection(possibleWorkers.toSet());
            if (x.isNotEmpty) {
              worker = randomElement(x.toList());
            } else {
              worker = randomElement(possibleWorkers);
            }
            familyOfCurrentWorkersIDs
                .addAll(relationshipWhere(worker, familyToAddOnHire));
            possibleWorkers.removeWhere((p) => p == worker);
          } else {
            worker = randomElement(possibleWorkers);
            possibleWorkers.removeWhere((p) => p == worker);
          }
        } else {
          final workerAsPerson =
              createRandomPerson(ref, newAge: randomElement(validAges.toList()));
          worker = workerAsPerson.id;

          peoplePN.add(workerAsPerson);

          // updateBuffer.add(() async =>
          //     peopleSearchProvider.addPersonToSearch(workerAsPerson));
          final n = Node(id: worker, relPairs: {});
          relationshipsPN.add(n);
        }

        final locRole = LocationRole(
            locationID: myShopID, myID: worker, myRole: myRole, specialty: "");
        // counter++;
        locationRolesPN.add(locRole);
      }
    }
    // print("Yo");
    newName = newShopName(
        ownerFirstNames: ownerList.map((o) => o.firstName).toList(),
        ownerSurnames: ownerList.map((o) => o.surname).toList(),
        shopType: myType);

    List<GenericService> applicableGenericServices =
        genericServices
            .where((g) => g.whereAvailable.contains(myType))
            .toList();
    int numServices = 8;
    Set<String> limitedSelect = {"Limited Selection", "Not well stocked"};
    Set<String> bigSelect = {"Great Selection", "Well stocked"};

    if (limitedSelect.contains(con)) {
      numServices = 4;
    }
    if ({pro1, pro2}.intersection(bigSelect).isNotEmpty) {
      numServices = 16;
    }

    List<int> randomNumbers = List.empty(growable: true);
    for (int i = 0;
        i < min(numServices, applicableGenericServices.length);
        i++) {
      int x = random.nextInt(applicableGenericServices.length);
      while (randomNumbers.contains(x)) {
        x = random.nextInt(applicableGenericServices.length);
      }
      randomNumbers.add(x);
    }
    List<Service> services = List.empty(growable: true);

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
    if (pro2types[pro1] != null) {
      mySpecialties.addAll(pro2types[pro1]!);
    }
    if (pro2types[pro2] != null) {
      mySpecialties.addAll(pro2types[pro2]!);
    }

    List<Specialty> applicableSpecialties;
    for (var x in randomNumbers) {
      String desc = applicableGenericServices[x].description;
      if (mySpecialties
          .intersection(applicableGenericServices[x].serviceType.toSet())
          .isNotEmpty) {
        applicableSpecialties = specialtyServices
            .where((s) =>
                s.appliesTo.toSet().intersection(mySpecialties).isNotEmpty)
            .toList();
        if (applicableSpecialties.isNotEmpty) {
          Specialty randSpec = randomElement(applicableSpecialties);
          desc = "$desc (${randSpec.description})";
        }
      }

      services.add(Service(
        cost: applicableGenericServices[x].price,
        description: desc,
      ));
    }

    Shop newShop = Shop(
        con: con,
        pro1: pro1,
        pro2: pro2,
        blurbText: "$pro1 & $pro2 but $con",
        name: newName,
        type: myType,
        myID: myShopID,
        myServices: services);

    // print(myShopID);
    locationsPN.add(newShop);
    // updateBuffer.add(() async => locationsPN.add(addMe: newShop));
    // updateBuffer.add(() async => locSearchProvider.addShopToSearch(newShop));
    // print("Shop Name: $newName, counter:$counter");

    for (final update in updateBuffer) {
      try {
        await update();
      } catch (e, stackTrace) {
        debugPrint("Error executing update: $e\n$stackTrace");
      }
    }
  }


  Future<void> setupMarketHirelings(WidgetRef ref) async {
    dynamic commitBuffer = [];
    final locationRoles = ref.watch(locationRolesProvider);

    final allMeta = ref.read(roleMetaProvider);

    ref.read(locationsProvider.notifier);
    final locationsPN = ref.read(locationsProvider.notifier);
    commitBuffer.add(()async=> await locationsPN.commitChanges());

    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    commitBuffer.add(()async =>await locationRolesPN.commitChanges() );


    List<Role> hirelingRoles =
        allMeta.where((r) => r.hireling).map((r) => r.thisRole).toList();
    List<Role> marketRoles =
        allMeta.where((r) => r.showInMarket).map((r) => r.thisRole).toList();
    List<Role> infoRoles =
        allMeta.where((r) => r.informational).map((r) => r.thisRole).toList();

    for (final lr
        in locationRoles.where((lr) => lr.locationID == infoID)) {
      if (hirelingRoles.contains(lr.myRole)) {
        // print("hireling");
        final locRole = LocationRole(
            locationID: hirelingID,
            myID: lr.myID,
            myRole: lr.myRole,
            specialty: lr.specialty);
        // updateBuffer.add(() async => locationRolesPN.add(addMe: locRole));
        locationRolesPN.add(locRole);
      }
      if (marketRoles.contains(lr.myRole)) {
        // print("market");
        final locRole = LocationRole(
            locationID: marketID,
            myID: lr.myID,
            myRole: lr.myRole,
            specialty: lr.specialty);
        // updateBuffer.add(() async => locationRolesPN.add(addMe: locRole));
        locationRolesPN.add(locRole);
      }
      if (infoRoles.contains(lr.myRole)) {
        // print("informational");
        final locRole = LocationRole(
            locationID: informationalID,
            myID: lr.myID,
            myRole: lr.myRole,
            specialty: lr.specialty);
        // updateBuffer.add(() async => locationRolesPN.add(addMe: locRole));
        locationRolesPN.add(locRole);
      }
    }

    final newInfo = Informational(
        myID: informationalID,
        locType: LocationType.info,
        name: "Sources of information/research");

    final newHires = Informational(
        myID: hirelingID, locType: LocationType.hireling, name: "Hirelings");

    final newMarket = Informational(
        myID: marketID, locType: LocationType.market, name: "Market");

    // updateBuffer.add(() async => locations.add(addMe: newHires));
    locationsPN.add(newHires);
    // updateBuffer.add(() async => locations.add(addMe: newInfo));
    locationsPN.add(newInfo);
    // updateBuffer.add(() async => locations.add(addMe: newMarket));
    locationsPN.add(newMarket);

    for (final commit in commitBuffer) {
      await commit();
    }
  }


}
