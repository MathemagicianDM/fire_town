
import 'package:firetown/screens/service_edit.dart';
import 'package:firetown/models/location_services_model.dart';

// Adjust the path to the Person model.
// For Relationship and Node.

import 'package:flutter/material.dart';

import '/enums_and_maps.dart';
import '../new_shops_models.dart';
import '../location_trait_model.dart';
import '../shop_trait_model.dart';
import '../../services/description_service.dart';
import '../../providers/shop_template_provider.dart';
import 'package:uuid/uuid.dart';
import '/globals.dart';

import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:collection/collection.dart';
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
  final List<LocationTrait> traits;

  @override
  String compositeKey() {
    return "$id.$name.${locType.name}";
  }

  Location(
      {required this.name,
      required this.locType,
      this.description = "Unknown Description",
      this.blurbText = "Unknown Blurb",
      this.traits = const [],
      String? myID,
      List<String>? myEncounterIDs})
      : id = myID ?? _uuid.v4();

  Location copyWith({
    String? name,
    String? id,
    String? blurbText,
    String? description,
    LocationType? locType,
    List<LocationTrait>? traits,
  }) {
    return Location(
      name: name ?? this.name,
      myID: id ?? this.id,
      blurbText: blurbText ?? this.blurbText,
      description: description ?? this.description,
      locType: locType ?? this.locType,
      traits: traits ?? this.traits,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "blurbText": blurbText,
      "description": description,
      "locType": locType.name,
      "traits": traits.map((t) => t.toJson()).toList(),
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
          description: json["description"] ?? "Unknown Description",
          traits: List<LocationTrait>.from(
            (json["traits"] ?? [])
                .map((t) => LocationTrait.fromJson2(t))
                .toList(),
          ),
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
      description: json["description"] ?? "Unknown Description",
      traits: List<LocationTrait>.from(
        (json["traits"] ?? [])
            .map((t) => LocationTrait.fromJson2(t))
            .toList(),
      ),
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
  final List<ShopTrait> insideTraits;
  final List<ShopTrait> outsideTraits;

  factory Shop.fromShop(
      {required Shop baseShop,
      String? pro1,
      String? pro2,
      String? con,
      List<Service>? services,
      String? name,
      String? description,
      List<ShopTrait>? insideTraits,
      List<ShopTrait>? outsideTraits}) {
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
        description: description ?? baseShop.description,
        traits: baseShop.traits,
        insideTraits: insideTraits ?? baseShop.insideTraits,
        outsideTraits: outsideTraits ?? baseShop.outsideTraits);
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
      super.traits,
      required this.type,
      required this.pro1,
      required this.pro2,
      required this.con,
      List<Service>? myServices,
      this.insideTraits = const [],
      this.outsideTraits = const []})
      : services = myServices ?? List.empty();

  Shop copyWith({
    String? name,
    String? id,
    String? blurbText,
    String? description,
    LocationType? locType,
    List<LocationTrait>? traits,
    String? pro1,
    String? pro2,
    String? con,
    ShopType? type,
    List<Service>? services,
    List<ShopTrait>? insideTraits,
    List<ShopTrait>? outsideTraits,
  }) {
    return Shop(
      name: name ?? this.name,
      myID: id ?? this.id,
      blurbText: blurbText ?? this.blurbText,
      description: description ?? this.description,
      locType: locType ?? this.locType,
      traits: traits ?? this.traits,
      pro1: pro1 ?? this.pro1,
      pro2: pro2 ?? this.pro2,
      con: con ?? this.con,
      type: type ?? this.type,
      myServices: services ?? this.services,
      insideTraits: insideTraits ?? this.insideTraits,
      outsideTraits: outsideTraits ?? this.outsideTraits,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> startingMap = super.toJson();
    startingMap.addAll({
      "pro1": pro1,
      "pro2": pro2,
      "con": con,
      "type": type.name,
      "services": services.map((s) => s.toJson()).toList(),
      "insideTraits": insideTraits.map((t) => t.toJson()).toList(),
      "outsideTraits": outsideTraits.map((t) => t.toJson()).toList(),
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
        insideTraits: List<ShopTrait>.from(
          (json["insideTraits"] ?? [])
              .map((t) => ShopTrait.fromJson2(t))
              .toList(),
        ),
        outsideTraits: List<ShopTrait>.from(
          (json["outsideTraits"] ?? [])
              .map((t) => ShopTrait.fromJson2(t))
              .toList(),
        ),
        myID: location.id,
        name: location.name,
        blurbText: location.blurbText,
        description: location.description,
        traits: location.traits));
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
          // Skip regular assignment - handled by assignRegularsAndCustomersToAllVenues()
          howMany = 0;
          validAges = {};
          familyToAddOnHire = [];
          break;
        case Role.customer:
          // Skip customer assignment - handled by assignRegularsAndCustomersToAllVenues()
          howMany = 0;
          validAges = {};
          familyToAddOnHire = [];
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

    // Create initial shop without traits for trait generation
    Shop tempShop = Shop(
        con: con,
        pro1: pro1,
        pro2: pro2,
        blurbText: "$pro1 & $pro2 but $con",
        name: newName,
        type: myType,
        myID: myShopID,
        myServices: services,
        traits: [],
        insideTraits: [],
        outsideTraits: []);

    // Generate initial traits for the shop
    final shopTemplates = ref.read(shopTemplateProvider);
    final descriptionService = DescriptionService();
    
    // Generate outside traits (1 trait)
    final outsideTraits = descriptionService.generateShopTraits(
      shop: tempShop,
      templates: shopTemplates,
      descriptionType: 'outside',
      maxTraits: 1,
    );
    
    // Generate inside traits (1 trait)
    final insideTraits = descriptionService.generateShopTraits(
      shop: tempShop,
      templates: shopTemplates,
      descriptionType: 'inside',
      maxTraits: 1,
    );

    Shop newShop = Shop(
        con: con,
        pro1: pro1,
        pro2: pro2,
        blurbText: "$pro1 & $pro2 but $con",
        name: newName,
        type: myType,
        myID: myShopID,
        myServices: services,
        traits: [],
        insideTraits: insideTraits,
        outsideTraits: outsideTraits);

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

  /// Post-generation assignment system for regulars and customers
  /// Prevents duplicate regulars across venues and adds drama/relationship logic
  Future<void> assignRegularsAndCustomersToAllVenues(WidgetRef ref) async {
    final people = ref.watch(peopleProvider);
    final locations = ref.watch(locationsProvider); 
    final locationRoles = ref.watch(locationRolesProvider);
    final relationships = ref.watch(relationshipsProvider);
    
    // 1. Get venues by type (only shops have ShopType)
    final taverns = locations.whereType<Shop>().where((shop) => shop.type == ShopType.tavern);
    final herbalists = locations.whereType<Shop>().where((shop) => shop.type == ShopType.herbalist);
    
    // 2. Priority assignment for owners first
    await _assignOwnerRegulars(taverns, people, locationRoles, relationships, ref);
    
    // 3. Special assignment for magic/temple staff (70% herbalist, 30% tavern)
    await _assignMagicTempleStaff(taverns, herbalists, people, locationRoles, ref);
    
    // 4. Assign remaining regulars with family + ex-drama logic
    await _assignRemainingRegulars(taverns, people, locationRoles, relationships, ref);
    
    // 5. Assign customers to all shops (preventing duplicates)
    await _assignCustomersToAllShops(locations.whereType<Shop>(), people, locationRoles, ref);
  }

  /// Priority assignment for shop owners (excluding magic/temple owners)
  Future<void> _assignOwnerRegulars(
    Iterable<Shop> taverns,
    List<Person> people,
    List<LocationRole> locationRoles,
    List<Node> relationships,
    WidgetRef ref
  ) async {
    // Get all NON-TAVERN shop owners (excluding magic/temple owners AND tavern owners)
    final nonTavernNonMagicTempleOwners = locationRoles
        .where((lr) => lr.myRole == Role.owner && 
                       !_isMagicOrTempleLocation(lr.locationID, ref) &&
                       !_isTavernLocation(lr.locationID, ref))
        .toList();
    
    // Group owners by their shop location to find their staff
    final ownersByShop = <String, List<LocationRole>>{};
    for (final owner in nonTavernNonMagicTempleOwners) {
      ownersByShop.putIfAbsent(owner.locationID, () => []).add(owner);
    }
    
    // Assign each owner and their shop staff to a random tavern (limit to prevent overcrowding)
    final shuffledShops = ownersByShop.keys.toList()..shuffle();
    final tavernList = taverns.toList()..shuffle();
    final maxOwnersPerTavern = 2; // Limit to 2 shop teams per tavern
    final ownerAssignments = <String, int>{}; // Track assignments per tavern
    
    for (int i = 0; i < shuffledShops.length && tavernList.isNotEmpty; i++) {
      final shopId = shuffledShops[i];
      
      // Find a tavern that hasn't reached the owner limit
      Shop? assignedTavern;
      for (final tavern in tavernList) {
        final currentOwnerCount = ownerAssignments[tavern.id] ?? 0;
        if (currentOwnerCount < maxOwnersPerTavern) {
          assignedTavern = tavern;
          ownerAssignments[tavern.id] = currentOwnerCount + 1;
          break;
        }
      }
      
      // Skip if all taverns are full
      if (assignedTavern == null) continue;
      
      final ownersAtShop = ownersByShop[shopId]!;
      
      // Get all shop staff (apprentices/journeymen) at this location
      final shopStaff = locationRoles
          .where((lr) => lr.locationID == shopId && 
                         {Role.apprentice, Role.journeyman}.contains(lr.myRole))
          .toList();
      
      // Add owners and their staff to the tavern
      for (final owner in ownersAtShop) {
        await _addPersonAndFamilyToTavern(owner.myID, assignedTavern, people, relationships, ref);
        await _addExPartnerDrama(owner.myID, assignedTavern, people, relationships, ref);
      }
      
      // Add shop staff as regulars (they follow their boss)
      for (final staff in shopStaff) {
        if (!_isAlreadyAssignedAsRegular(staff.myID, ref)) {
          await _addPersonAndFamilyToTavern(staff.myID, assignedTavern, people, relationships, ref);
          await _addExPartnerDrama(staff.myID, assignedTavern, people, relationships, ref);
        }
      }
    }
    
    // Handle tavern owners separately - they become customers at other shops (not tavern regulars)
    final tavernOwners = locationRoles
        .where((lr) => lr.myRole == Role.owner && 
                       _isTavernLocation(lr.locationID, ref))
        .toList();
    
    await _assignTavernOwnersAsCustomers(tavernOwners, ref);
  }

  /// 70% herbalist customer, 30% tavern regular for magic/temple staff
  Future<void> _assignMagicTempleStaff(
    Iterable<Shop> taverns,
    Iterable<Shop> herbalists,
    List<Person> people,
    List<LocationRole> locationRoles,
    WidgetRef ref
  ) async {
    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    
    // Find magic shop and temple staff
    final magicTempleStaff = locationRoles.where((lr) => 
      _isMagicOrTempleLocation(lr.locationID, ref) &&
      {Role.owner, Role.journeyman, Role.apprentice, Role.hierophant, Role.acolyte}
          .contains(lr.myRole)
    ).toList();
    
    final herbalistList = herbalists.toList();
    final tavernList = taverns.toList();
    
    for (final staff in magicTempleStaff) {
      final random = Random().nextDouble();
      
      if (random < 0.7 && herbalistList.isNotEmpty) {
        // 70% chance: Assign as herbalist customer
        final herbalist = herbalistList[Random().nextInt(herbalistList.length)];
        locationRolesPN.add(LocationRole(
          myID: staff.myID,
          locationID: herbalist.id,
          myRole: Role.customer,
          specialty: "magic_temple_connection"
        ));
      } else if (tavernList.isNotEmpty) {
        // 30% chance: Assign as tavern regular
        final tavern = tavernList[Random().nextInt(tavernList.length)];
        locationRolesPN.add(LocationRole(
          myID: staff.myID,
          locationID: tavern.id,
          myRole: Role.regular,
          specialty: "magic_temple_background"
        ));
        
        // Still add immediate family and potential ex-drama
        final relationships = ref.watch(relationshipsProvider);
        await _addPersonAndFamilyToTavern(staff.myID, tavern, people, relationships, ref);
        await _addExPartnerDrama(staff.myID, tavern, people, relationships, ref);
      }
    }
  }

  /// Assign remaining regular candidates with family and drama logic
  Future<void> _assignRemainingRegulars(
    Iterable<Shop> taverns,
    List<Person> people,
    List<LocationRole> locationRoles,
    List<Node> relationships,
    WidgetRef ref
  ) async {
    final roleMeta = ref.read(roleMetaProvider);
    
    // Get people who should be tavern regulars (excluding already assigned and magic/temple staff)
    final regularCandidates = locationRoles
        .where((lr) => lr.locationID == infoID && 
                       _isGoodTavernRegular(lr.myRole, roleMeta) &&
                       !_isAlreadyAssignedAsRegular(lr.myID, ref) &&
                       !_isMagicOrTempleStaff(lr.myRole))
        .map((lr) => lr.myID)
        .toList()
        ..shuffle();
    
    final tavernList = taverns.toList();
    
    // Distribute remaining candidates evenly across taverns
    for (int i = 0; i < regularCandidates.length; i++) {
      final tavern = tavernList[i % tavernList.length];
      final currentRegulars = _getCurrentRegularCount(tavern.id, ref);
      
      // Only add if under base capacity (family overflow still allowed)
      if (currentRegulars < 20) {
        final personId = regularCandidates[i];
        
        // Add person and immediate family
        await _addPersonAndFamilyToTavern(personId, tavern, people, relationships, ref);
        
        // Add potential ex-partner drama
        await _addExPartnerDrama(personId, tavern, people, relationships, ref);
      }
    }
  }

  /// Add person and immediate family (partners + children only) to tavern
  Future<void> _addPersonAndFamilyToTavern(
    String personId,
    Shop tavern,
    List<Person> people,
    List<Node> relationships,
    WidgetRef ref
  ) async {
    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    
    // Add the primary person
    locationRolesPN.add(LocationRole(
      myID: personId,
      locationID: tavern.id,
      myRole: Role.regular,
      specialty: ""
    ));
    
    // Find and add IMMEDIATE family (partners + children only)
    final immediateFamily = _getImmediateFamily(personId, relationships, people);
    
    for (final familyMember in immediateFamily) {
      // Check if they're not already assigned elsewhere
      if (!_isAlreadyAssignedAsRegular(familyMember.id, ref)) {
        locationRolesPN.add(LocationRole(
          myID: familyMember.id,
          locationID: tavern.id,
          myRole: Role.regular,
          specialty: ""
        ));
      }
    }
  }

  /// Add ex-partner drama logic - 40% chance ex shows up at same tavern
  Future<void> _addExPartnerDrama(
    String personId,
    Shop assignedTavern,
    List<Person> people,
    List<Node> relationships,
    WidgetRef ref
  ) async {
    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    
    // Find ex-partners using Node structure
    final personNode = relationships.firstWhereOrNull((node) => node.id == personId);
    if (personNode == null) return;
    
    final exPartners = personNode.relPairs
        .where((edge) => edge.iAmYour == RelationshipType.ex)
        .map((edge) => edge.you)
        .toList();
    
    for (final exId in exPartners) {
      // Check if ex isn't already assigned as regular elsewhere
      if (!_isAlreadyAssignedAsRegular(exId, ref)) {
        // 40% chance for drama - ex shows up at same tavern
        if (Random().nextDouble() < 0.4) {
          locationRolesPN.add(LocationRole(
            myID: exId,
            locationID: assignedTavern.id,
            myRole: Role.regular,
            specialty: "drama_potential" // Special tag for narrative purposes
          ));
        }
      }
    }
  }

  /// Get immediate family members (partners + children only)
  List<Person> _getImmediateFamily(
    String personId, 
    List<Node> relationships,
    List<Person> people
  ) {
    // Find the person's node and get family members
    final personNode = relationships.firstWhereOrNull((node) => node.id == personId);
    if (personNode == null) return [];
    
    final familyMembers = <Person>[];
    
    // Get partners (always included)
    final partnerIds = personNode.relPairs
        .where((edge) => edge.iAmYour == RelationshipType.partner)
        .map((edge) => edge.you)
        .toSet();
    
    familyMembers.addAll(
      people.where((p) => partnerIds.contains(p.id))
    );
    
    // Get children, but only those younger than adult age
    final childIds = personNode.relPairs
        .where((edge) => edge.iAmYour == RelationshipType.child)
        .map((edge) => edge.you)
        .toSet();
    
    final youngChildren = people.where((p) => 
      childIds.contains(p.id) && 
      p.age != AgeType.adult && 
      p.age != AgeType.old
    );
    
    familyMembers.addAll(youngChildren);
    
    return familyMembers;
  }

  /// Check if person is good tavern regular based on role meta
  bool _isGoodTavernRegular(Role role, List<RoleGeneration> roleMeta) {
    return roleMeta
        .where((rg) => rg.thisRole == role)
        .any((rg) => rg.priorityInTaverns || rg.promoteInTaverns);
  }

  /// Check if person is already assigned as regular somewhere
  bool _isAlreadyAssignedAsRegular(String personId, WidgetRef ref) {
    final locationRoles = ref.watch(locationRolesProvider);
    return locationRoles.any((lr) => 
      lr.myID == personId && 
      lr.myRole == Role.regular &&
      lr.locationID != infoID
    );
  }


  /// Get current regular count for a tavern
  int _getCurrentRegularCount(String tavernId, WidgetRef ref) {
    final locationRoles = ref.watch(locationRolesProvider);
    return locationRoles
        .where((lr) => lr.locationID == tavernId && lr.myRole == Role.regular)
        .length;
  }

  /// Check if role is magic or temple staff
  bool _isMagicOrTempleStaff(Role role) {
    return {
      Role.owner,           // Could be magic shop owner
      Role.journeyman,      // Could be magic shop journeyman  
      Role.apprentice,      // Could be magic shop apprentice
      Role.hierophant,      // Temple leader
      Role.acolyte,         // Temple staff
      Role.magicShopOwner   // Explicit magic shop owner
    }.contains(role);
  }

  /// Check if location is magic shop or temple
  bool _isMagicOrTempleLocation(String locationId, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final location = locations.firstWhereOrNull((loc) => loc.id == locationId);
    if (location is Shop) {
      return {ShopType.magic, ShopType.temple}.contains(location.type);
    }
    return false;
  }

  /// Check if location is a tavern
  bool _isTavernLocation(String locationId, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final location = locations.firstWhereOrNull((loc) => loc.id == locationId);
    if (location is Shop) {
      return location.type == ShopType.tavern;
    }
    return false;
  }

  /// Assign tavern owners as customers at other shops (herbalists, general stores, etc.)
  Future<void> _assignTavernOwnersAsCustomers(List<LocationRole> tavernOwners, WidgetRef ref) async {
    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    final locations = ref.watch(locationsProvider);
    
    // Get shops that tavern owners would visit as customers
    final customerShops = locations.whereType<Shop>().where((shop) => 
      {ShopType.herbalist, ShopType.generalStore, ShopType.clothier, 
       ShopType.smith, ShopType.jeweler, ShopType.magic}.contains(shop.type)
    ).toList();
    
    if (customerShops.isEmpty) return;
    
    // Track which shop types each tavern owner has been assigned to
    final tavernOwnerAssignments = <String, Set<ShopType>>{};
    
    for (final tavernOwner in tavernOwners) {
      tavernOwnerAssignments[tavernOwner.myID] = {};
      
      // Each tavern owner becomes a customer at 1-2 random shop types (reduced from 1-3)
      final numShopTypes = 1 + Random().nextInt(2); // 1-2 shop types
      final availableShopTypes = {ShopType.herbalist, ShopType.generalStore, ShopType.clothier, 
                                  ShopType.smith, ShopType.jeweler, ShopType.magic}.toList()..shuffle();
      
      int typesAssigned = 0;
      for (final shopType in availableShopTypes) {
        if (typesAssigned >= numShopTypes) break;
        
        final shopsOfType = customerShops.where((s) => s.type == shopType).toList();
        if (shopsOfType.isNotEmpty) {
          final shop = shopsOfType[Random().nextInt(shopsOfType.length)];
          
          // Add as customer with higher probability for essential shops
          double probability = 0.4; // Reduced base probability
          if (shop.type == ShopType.herbalist || shop.type == ShopType.generalStore) {
            probability = 0.7; // Reduced from 0.8
          }
          
          if (Random().nextDouble() < probability) {
            locationRolesPN.add(LocationRole(
              myID: tavernOwner.myID,
              locationID: shop.id,
              myRole: Role.customer,
              specialty: "tavern_owner_customer"
            ));
            tavernOwnerAssignments[tavernOwner.myID]!.add(shopType);
            typesAssigned++;
          }
        }
      }
    }
  }

  /// Assign customers to all shops, ensuring each person is only a customer at one shop per shop type
  Future<void> _assignCustomersToAllShops(
    Iterable<Shop> shops,
    List<Person> people,
    List<LocationRole> locationRoles,
    WidgetRef ref
  ) async {
    final locationRolesPN = ref.read(locationRolesProvider.notifier);
    final roleMeta = ref.read(roleMetaProvider);
    
    // Get people who could be customers (excluding those already assigned roles)
    final potentialCustomers = locationRoles
        .where((lr) => lr.locationID == infoID && 
                       _isGoodCustomer(lr.myRole, roleMeta) &&
                       !_isAlreadyAssignedAsCustomer(lr.myID, ref))
        .map((lr) => lr.myID)
        .toList()
        ..shuffle();
    
    // Group shops by type to ensure people only become customers at one shop per type
    final shopsByType = <ShopType, List<Shop>>{};
    for (final shop in shops) {
      shopsByType.putIfAbsent(shop.type, () => []).add(shop);
    }
    
    // Assign customers by shop type
    for (final shopType in shopsByType.keys) {
      final shopsOfType = shopsByType[shopType]!;
      final customersPerShop = 3 + Random().nextInt(3); // 3-5 customers per shop
      
      for (final shop in shopsOfType) {
        final availableCustomers = potentialCustomers.where((personId) => 
          !_isAlreadyCustomerOfShopType(personId, shopType, ref)
        ).toList();
        
        final numCustomersToAssign = min(customersPerShop, availableCustomers.length);
        int customersAssigned = 0;
        
        for (int i = 0; i < availableCustomers.length && customersAssigned < numCustomersToAssign; i++) {
          final customerId = availableCustomers[i];
          
          // Higher probability for certain shop types
          double probability = _getCustomerProbability(shopType);
          
          if (Random().nextDouble() < probability) {
            locationRolesPN.add(LocationRole(
              myID: customerId,
              locationID: shop.id,
              myRole: Role.customer,
              specialty: ""
            ));
            customersAssigned++;
            
            // Remove from potential customers list to prevent further assignments
            potentialCustomers.remove(customerId);
          }
        }
      }
    }
  }

  /// Check if person is good customer based on role meta
  bool _isGoodCustomer(Role role, List<RoleGeneration> roleMeta) {
    return roleMeta
        .where((rg) => rg.thisRole == role)
        .any((rg) => rg.prioritizeCustomer);
  }

  /// Check if person is already assigned as customer somewhere
  bool _isAlreadyAssignedAsCustomer(String personId, WidgetRef ref) {
    final locationRoles = ref.watch(locationRolesProvider);
    return locationRoles.any((lr) => 
      lr.myID == personId && 
      lr.myRole == Role.customer &&
      lr.locationID != infoID
    );
  }

  /// Check if person is already a customer of a specific shop type
  bool _isAlreadyCustomerOfShopType(String personId, ShopType shopType, WidgetRef ref) {
    final locationRoles = ref.watch(locationRolesProvider);
    final locations = ref.watch(locationsProvider);
    
    return locationRoles.any((lr) {
      if (lr.myID != personId || lr.myRole != Role.customer) return false;
      final location = locations.firstWhereOrNull((loc) => loc.id == lr.locationID);
      return location is Shop && location.type == shopType;
    });
  }

  /// Get customer assignment probability based on shop type
  double _getCustomerProbability(ShopType shopType) {
    switch (shopType) {
      case ShopType.herbalist:
      case ShopType.generalStore:
        return 0.8; // Essential shops
      case ShopType.smith:
      case ShopType.clothier:
        return 0.6; // Common needs
      case ShopType.jeweler:
      case ShopType.magic:
        return 0.4; // Specialty shops
      case ShopType.tavern:
        return 0.0; // Handled separately as regulars
      case ShopType.temple:
        return 0.0; // Handled separately
    }
  }


}
