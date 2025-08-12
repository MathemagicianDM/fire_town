

import 'package:firetown/providers/barrel_of_providers.dart';
import 'package:flutter/material.dart';
import '../enums_and_maps.dart';

import '../globals.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';


import "json_serializable_abstract_class.dart";

import "../providers/government_extension2.dart";
import "package:collection/collection.dart";
import "../search_models_providers_listeners/search_listener_memory.dart";
import "../search_models_providers_listeners/search_memory.dart";
import 'barrel_of_models.dart';


@immutable
class TownOnFire implements JsonSerializable {
  final String name;
  final String id;

  final Map<String, int> myDemographics;
  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id, 'myDemographics': myDemographics};
  }

  @override
  factory TownOnFire.fromJson(Map<String, dynamic> json) {
    return TownOnFire(
      name: json['name'] as String,
      id: json['id'] as String,
      myDemographics: Map<String, int>.from(json['myDemographics'] as Map),
    );
  }

  @override
  String compositeKey() {
    return '$id:$name';
  }
  // StateNotifierProvider<ShopList,List<Shop>> shopListProvider;

  // StateNotifierProvider<Trie, Map<String, Set<String>>> peopleSearch;
  // StateNotifierProvider<Trie, Map<String, Set<String>>> locationSearch;
  //   Box<String> peopleSearchBox;
  // Box<String> locationSearchBox;

  String randomAncestry({Set<String>? restrictedAncestries}) {
    Set<String> valid = restrictedAncestries ?? myDemographics.keys.toSet();
    int maxPoints = 0;
    for (final v in valid) {
      maxPoints += myDemographics[v]!;
    }
    int r = maxPoints > 0 ? random.nextInt(maxPoints) : 0;
    for (final v in valid) {
      if (r < myDemographics[v]!) {
        return v;
      } else {
        r -= myDemographics[v]!;
      }
    }
    debugPrint("*************************** an outsider!");
    return valid.toList()[random.nextInt(valid.length)];
  }

  const TownOnFire({
    required this.name,
    required this.id,
    required this.myDemographics,
  });

  Future<void> populateTown({
    required Function(String) onMessageUpdate,
    required String government,
    required CitySize mySize,
    required WidgetRef ref,
  }) async {
    String range = citySize2rangesOfNumPeople[mySize]!;
    int minNum = int.parse(range.split("-").first);
    int maxNum = int.parse(range.split("-").last);
    int numPeople = minNum + random.nextInt(maxNum - minNum);

    // // GovernmentQuery gq = GovernmentQuery(government, mySize.toString());

    // final roleMetaPN = ref.watch(roleMetaProvider.notifier);
    // await roleMetaPN.initialize();

    // final shopNamesPN = ref.watch(shopNamesProvider.notifier);
    // await shopNamesPN.initialize();

    // final shopQualitiesPN = ref.watch(shopQualitiesProvider.notifier);
    // await shopQualitiesPN.initialize();

    // final genericServicesPN = ref.read(genericServicesProvider.notifier);
    // await genericServicesPN.initialize();

    // final specialtyServicesPN = ref.read(specialtyServicesProvider.notifier);
    // await specialtyServicesPN.initialize();

    // // final json = await rootBundle.loadString("./lib/initialization_files/roleGen.json");
    // // await roleMetaPN.loadFromJsonAndCommit(json);

    // // final json = await rootBundle.loadString("./lib/demofiles/all_shop_names.json");
    // // await shopNamesPN.loadFromJsonAndCommit(json);

    // // final json2 = await rootBundle.loadString("./lib/demofiles/all_qualities.json");
    // // await shopQualitiesPN.loadFromJsonAndCommit(json2);

    // // final json3 = await rootBundle.loadString("./lib/demofiles/service_generic.json");
    // // await genericServicesPN.loadFromJsonAndCommit(json3);

    // // final json4 = await rootBundle.loadString("./lib/demofiles/service_special.json");
    // // await specialtyServicesPN.loadFromJsonAndCommit(json4);

    // final resonantArgumentsPN = ref.watch(resonantArgumentsProvider.notifier);
    // await resonantArgumentsPN.initialize();

    // // final json2 = await rootBundle.loadString("./lib/demofiles/Demotown.resonantArgument");
    // // await resonantArgumentsPN.loadFromJsonAndCommit(json2);

    // final quirksPN = ref.watch(quirksProvider.notifier);
    // await quirksPN.initialize();

    // // final json3 = await rootBundle.loadString("./lib/demofiles/Demotown.quirks");
    // // await quirksPN.loadFromJsonAndCommit(json3);

    // final givenNamesPN = ref.watch(givenNamesProvider.notifier);
    // await givenNamesPN.initialize();

    // // final json4 = await rootBundle.loadString("./lib/demofiles/Demotown.givenNamesIndividualNEW");
    // // await givenNamesPN.loadFromJsonAndCommit(json4);

    // final surnamesPN = ref.watch(surnamesProvider.notifier);
    // await surnamesPN.initialize();

    // final json5 = await rootBundle.loadString("./lib/demofiles/Demotown.surnamesIndividual");
    // await surnamesPN.loadFromJsonAndCommit(json5);

    final positions = ref.watch(positionsProvider);

    final govRoles = getListOfRoles(mySize, government, ref);

    // print("Hi");
    List<GovHelper> govHelpers = [];
    for (final gr in govRoles) {
      final p = positions.firstWhereOrNull((p) => p.positionKey == gr);
      if (p != null) {
        govHelpers.add(
          GovHelper(
            age: p.getRandomAge()!,
            position: gr,
            createMethod: govCreateMethod(government, gr),
            validRoles: govValidRoles(gr),
          ),
        );
      } else {
        final method = govCreateMethod(government, gr);
        govHelpers.add(
          GovHelper(
            position: gr,
            createMethod: method,
            age: getRandomAgeNoPosition(government)!,
            validRoles: getGovRolesNoPosition(government),
          ),
        );
      }
    }
    // Add a timeout after which you'll proceed with default values

    // final govRoles = await waitForDataAndGetRoles(ref, gq);

    onMessageUpdate("Creating people...");
    await createPeopleFS(numPeople, ref, govHelpers);
    onMessageUpdate("Created people√  Establishing Social Networks...");

    await createSocialNetworkFS(ref);
    onMessageUpdate(
      "Making & Adopting Children ${mySize.index >= CitySize.city.index ? "Takes a minute for cities and metropoli, sorry, lots of kids" : ""}...",
    );

    await makeChildren(ref.read(peopleProvider), ref);

    onMessageUpdate("People are done, establishing them in their jobs...");

    await setupMarketHirelings(ref);

    onMessageUpdate("Creating stores, etc...");

    final locationRoles = ref.watch(locationRolesProvider);

    final infoOnly = ref
        .read(locationRolesProvider)
        .where((cr) => cr.locationID == infoID);

    for (final cr in infoOnly) {
      switch (cr.myRole) {
        case Role.smith:
          await addRandomShopNoCommit(ShopType.smith, ref, cr.myID);
          break;
        case Role.tailor:
          await addRandomShopNoCommit(ShopType.clothier, ref, cr.myID);
          break;

        case Role.herbalist:
          await addRandomShopNoCommit(ShopType.herbalist, ref, cr.myID);
          break;
        case Role.jeweler:
          await addRandomShopNoCommit(ShopType.jeweler, ref, cr.myID);
          break;
        case Role.generalStoreOwner:
          await addRandomShopNoCommit(ShopType.generalStore, ref, cr.myID);
          break;
        case Role.magicShopOwner:
          await addRandomShopNoCommit(ShopType.magic, ref, cr.myID);
          break;
        case Role.hierophant:
          await addRandomShopNoCommit(ShopType.temple, ref, cr.myID);
          break;
        default:
          break;
      }
    }

    onMessageUpdate("Establishing taverns...");

    for (final cr in locationRoles) {
      switch (cr.myRole) {
        case Role.tavernKeeper:
          await addRandomShopNoCommit(ShopType.tavern, ref, cr.myID);
          break;
        default:
          break;
      }
    }

    // final locs = ref.read(locationsProvider);
    await commitShops(ref);

    // print(roles);

    onMessageUpdate("All done!  Taking you there.");

    // for(final t in ShopType.values){
    //   Map<ShopType,int> numShopsMap=citySize2numShops[mySize]!;
    //   int numShops = numShopsMap[t]!;
    //   for (int i =0; i < numShops; i++)
    //   {
    //     await addRandomShop(t, ref);
    //   }
    // }
    //
    //  final test2 = ref.read(locationRoleListProvider).where((lr)=>lr.locationID==hirelingID).toList();

    // print("All done");
  }
}

Future<void> loadTownFS(String id, WidgetRef ref) async {
  try {
    final myTowns = ref.read(townsProvider);
    String myName = myTowns.firstWhere((v) => v.id == id).name;
    Map<String, int> myDemo = (myTowns
            .firstWhere((v) => v.id == id)
            .myDemographics)
        .map((key, value) => MapEntry(key, value));

    ref.read(townProvider.notifier).state = TownOnFire(
      name: myName,
      id: id,
      myDemographics: myDemo,
    );

    // Initialize government data first as it might be a dependency
    await initializeGovernmentData(ref);

    final firestoreService = ref.read(firestoreServiceProvider);
    final govType = await firestoreService.getTownGovernment(id);
    ref.read(governmentTypeProvider.notifier).state = govType;

    // Group providers by dependency levels and load them in parallel
    // Level 1: Core providers that others might depend on
    await Future.wait([
      ref.read(ancestriesProvider.notifier).initialize(),
      ref.read(quirksProvider.notifier).initialize(),
      ref.read(resonantArgumentsProvider.notifier).initialize(),
      ref.read(givenNamesProvider.notifier).initialize(),
      ref.read(surnamesProvider.notifier).initialize(), // This was missing
      ref.read(roleMetaProvider.notifier).initialize(),
      // Initialize template providers for description generation
      ref.read(physicalTemplatesProvider.notifier).initialize(),
      ref.read(clothingTemplatesProvider.notifier).initialize(),
      ref.read(shopTemplateProvider.notifier).initialize(),
    ]);

    // Level 2: Providers that might depend on Level 1
    await Future.wait([
      ref.read(peopleProvider.notifier).initialize(),
      ref.read(locationsProvider.notifier).initialize(),
      ref.read(shopNamesProvider.notifier).initialize(),
      ref.read(shopQualitiesProvider.notifier).initialize(),
      ref.read(genericServicesProvider.notifier).initialize(),
      ref.read(specialtyServicesProvider.notifier).initialize(),
      ref.read(pendingRolesProvider.notifier).initialize(),
    ]);

    // Level 3: Providers that might depend on Level 2
    await Future.wait([
      ref.read(locationRolesProvider.notifier).initialize(),
      ref.read(relationshipsProvider.notifier).initialize(),
    ]);

    initializeSearchListeners(ref);
    final people = ref.read(peopleProvider);
    final locations = ref.read(locationsProvider);

    initializeSearch(ref: ref, people: people, locations: locations);
  } catch (e, stackTrace) {
    debugPrint("Error loading town: $e");
    debugPrint("Stack trace: $stackTrace");
    // Consider showing an error to the user or implementing a retry mechanism
    rethrow; // Rethrow to allow calling code to handle the error
  }
}




List<Role> rolesFromUniversalType(String universalType) {
  switch (universalType) {
    case "any":
      return Role.values
          .where((role) => !role.name.contains("Government"))
          .toList();
    case "NA":
      return [];
    case "sage":
      return [Role.sage];
    case "hierophant":
      return [Role.hierophant];
    case "new":
      return [Role.government];
    case "owner":
      return [
        Role.owner,
        Role.generalStoreOwner,
        Role.herbalist,
        Role.jeweler,
        Role.magicShopOwner,
        Role.smith,
        Role.spiceMerchant,
        Role.tavernKeeper,
        Role.tailor,
      ];
    default:
      return Role.values
          .where((role) => !role.name.contains("Government"))
          .toList();
  }
}


AgeType? getRandomAgeNoPosition(String government) {
  double r = random.nextDouble();
  Map<AgeType, double> ageProbabilities = {
    AgeType.quiteYoung: 0,
    AgeType.young: 0,
    AgeType.adult: 30,
    AgeType.middleAge: 40,
    AgeType.old: 20,
    AgeType.quiteOld: 10,
  };
  if (government == "councilOfElders") {
    ageProbabilities = {
      AgeType.quiteYoung: 0,
      AgeType.young: 0,
      AgeType.adult: 0,
      AgeType.middleAge: 5,
      AgeType.old: 40,
      AgeType.quiteOld: 55,
    };
  }
  for (final entry in ageProbabilities.entries) {
    r = r - entry.value;
    if (r <= 0) {
      return entry.key;
    }
  }
  return null; //Probabilities didn't add up to 1
}

GovCreateMethod getGovCreateMethod(String governmentType) {
  switch (governmentType) {
    case "councilOfElders":
      return GovCreateMethod.useExistingRoles;
    case "cityCouncil":
      return GovCreateMethod.createRoles;
    case "directDemocrarcy":
      return GovCreateMethod.createAndChoose;
    case "mageocracy":
      return GovCreateMethod.createRoles;
    case "merchantsCouncil":
      return GovCreateMethod.useExistingRoles;
    case "nobility":
      return GovCreateMethod.createRoles;
    case "theocracy":
      return GovCreateMethod.useExistingRoles;
    case "tyranny":
      return GovCreateMethod.createRoles;
    default:
      return GovCreateMethod.createRoles;
  }
}

List<Role> getGovRolesNoPosition(String governmentType) {
  switch (governmentType) {
    case "councilOfElders":
      return [Role.sage];
    case "cityCouncil":
      return [];
    case "directDemocrarcy":
      return [];
    case "mageocracy":
      return [];
    case "merchantCouncil":
      return [
        Role.generalStoreOwner,
        Role.herbalist,
        Role.jeweler,
        Role.magicShopOwner,
        Role.smith,
        Role.tavernKeeper,
        Role.spiceMerchant,
        Role.tailor,
      ];
    case "nobility":
      return [];
    case "theocracy":
      return [Role.hierophant];
    case "tyranny":
      return [];
    default:
      return [];
  }
}

Future<void> commitShops(WidgetRef ref) async {
  final locationRolesPN = ref.read(locationRolesProvider.notifier);

  final locationsPN = ref.read(locationsProvider.notifier);
  final peoplePN = ref.read(peopleProvider.notifier);

  locationRolesPN.commitChanges();
  locationsPN.commitChanges();
  peoplePN.commitChanges();
}
