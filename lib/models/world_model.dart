import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firetown/providers/barrel_of_providers.dart';
// import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
// import 'package:firetown/person.dart';
// import 'package:firetown/providers.dart';
import '../enums_and_maps.dart';
import 'new_shops_models.dart';
import 'package:uuid/uuid.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:math';
// import 'enums_and_maps.dart';
// import '../town_storage.dart';
import "location_services_model.dart";
// import "search.dart";
import "../providers/government_extension2.dart";
import 'barrel_of_models.dart';



const _uuid = Uuid();


class World {
  Box<String> townBox;
  Box<String> raBox;
  Box<String> quirkBox;
  Box<String> givenNameBox;
  Box<String> surnameBox;
  Box<String> ancestryBox;
  Box<String> shopNameBox;
  Box<String> shopQualityBox;
  Box<String> roleBox;
  Box<String> genericServiceBox;
  Box<String> specialtyBox;

  List<Ancestry> ancestries;
  List<String> resonantArguments;
  List<String> quirks;
  List<GivenName> givenNames;
  List<Surname> surnames;
  List<ShopQuality> shopQualities;
  List<ShopName> shopNames;
  List<GenericService> genericServices;
  List<Specialty> allSpecialties;

  // StateNotifierProvider<RolesContainer, List<RoleGeneration>> allRoles;

  // StateNotifierProvider<ProviderList<TownStorage>, List<TownStorage>>
  // myTownsProvider;

  World({
    required this.townBox,
    required this.raBox,
    required this.quirkBox,
    required this.givenNameBox,
    required this.surnameBox,
    required this.ancestryBox,
    required this.shopNameBox,
    required this.shopQualityBox,
    required this.roleBox,
    required this.genericServiceBox,
    required this.specialtyBox,
  }) : ancestries =
           ancestryBox.values
               .map((a) => Ancestry.fromJson(a))
               .cast<Ancestry>()
               .toList(),
       resonantArguments = raBox.values.toList(),
       quirks = quirkBox.values.toList(),
       givenNames =
           givenNameBox.values
               .map((a) => GivenName.fromJson(a))
               .cast<GivenName>()
               .toList(),
       surnames =
           surnameBox.values
               .map((a) => Surname.fromJson(a))
               .cast<Surname>()
               .toList(),
       shopQualities =
           shopQualityBox.values
               .map((a) => ShopQuality.fromJson(a))
               .cast<ShopQuality>()
               .toList(),
       shopNames =
           shopNameBox.values
               .map((a) => ShopName.fromJson(a))
               .cast<ShopName>()
               .toList(),
       genericServices =
           genericServiceBox.values
               .map((a) => GenericService.fromJson(a))
               .cast<GenericService>()
               .toList(),
       allSpecialties =
           specialtyBox.values
               .map((a) => Specialty.fromJson(a))
               .cast<Specialty>()
               .toList()
      //  myTownsProvider = StateNotifierProvider<
      //    ProviderList<TownStorage>,
      //    List<TownStorage>
      //  >((ref) {
      //    return ProviderList(myBox: townBox, fromJson: TownStorage.fromJson);
      //  }),
      //  allRoles = StateNotifierProvider<RolesContainer, List<RoleGeneration>>((
      //    ref,
      //  ) {
      //    return RolesContainer(myBox: roleBox);
      //  }
       ;

  Future<void> loadTown(String id, WidgetRef ref) async {
  

    try {
      await initializeGovernmentData(ref);
      final firestoreService = ref.read(firestoreServiceProvider);
      final govType = await firestoreService.getTownGovernment(id);
      // print("Retrieved government type: $govType");

      ref.read(governmentTypeProvider.notifier).state = govType;
      // print("After update, provider state: ${ref.read(governmentTypeProvider)}");
    } catch (e) {
      debugPrint("Error getting government data: $e");
    }

  }

  Future<void> loadShopQualtiesFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      Map<String, dynamic> sq =
          ShopQuality(
            pro: x["pro"],
            con: x["con"],
            type: string2Enum(x["type"]),
            id: _uuid.v4(),
          ).toJson();
      shopQualityBox.add(jsonEncode(sq));
    }
    shopQualities =
        shopQualityBox.values
            .map((e) => ShopQuality.fromJson(e))
            .cast<ShopQuality>()
            .toList();
  }

  Future<void> loadShopNamesFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      ShopName sn = ShopName(
        word: x["word"],
        shopType: string2Enum(x["shopType"]),
        wordType: string2Enum(x["wordType"]),
        id: _uuid.v4(),
      );
      shopNameBox.add(jsonEncode(sn.toJson()));
    }
    shopNames =
        shopNameBox.values
            .map((e) => ShopName.fromJson(e))
            .cast<ShopName>()
            .toList();
  }

  Future<void> loadResonantArgumentFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      raBox.add(x["argument"]);
    }
    resonantArguments = raBox.values.cast<String>().toList();
  }

  Future<void> loadQuirksFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      quirkBox.add(x["quirk"]);
    }
    quirks = quirkBox.values.cast<String>().toList();
  }

  Future<void> loadGivenNamesFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      GivenName gn = GivenName(
        name: x["name"],
        ancestry: [...x["ancestry"]],
        pronouns:
            (x["pronouns"] as List<dynamic>)
                .map((p) => string2Enum(p) as PronounType)
                .toList(),
        id: _uuid.v4(),
      );

      givenNameBox.add(jsonEncode(gn.toJson()));
    }
    givenNames =
        givenNameBox.values
            .map((e) => GivenName.fromJson(e))
            .cast<GivenName>()
            .toList();
  }

  Future<void> loadSurnamesFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;
    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      Surname sn = Surname(
        name: x["name"],
        ancestry: [...x["ancestry"]],
        id: _uuid.v4(),
      );

      surnameBox.add(jsonEncode(sn.toJson()));
    }
    surnames =
        surnameBox.values
            .map((e) => Surname.fromJson(e))
            .cast<Surname>()
            .toList();
  }

  Future<void> loadAncestriesFromJSON(String jsonString) async {
    var xList = json.decode(jsonString) as List;

    for (var i = 0; i < xList.length; i++) {
      var x = xList[i];
      Ancestry a = Ancestry(
        name: x["name"],
        quiteYoungProb: x["quiteYoungProb"],
        youngProb: x["youngProb"],
        adultProb: x["adultProb"],
        middleAgeProb: x["middleAgeProb"],
        oldProb: x["oldProb"],
        quiteOldProb: x["quiteOldProb"],
        heHimProb: x["heHimProb"],
        sheHerProb: x["sheHerProb"],
        theyThemProb: x["theyThemProb"],
        heTheyProb: x["heTheyProb"],
        sheTheyProb: x["sheTheyProb"],
        partnerWithinProb: x["partnerWithinProb"],
        partnerOutsideProb: x["partnerOutsideProb"],
        breakupProb: x["breakupProb"],
        noChildrenProb: x["noChildrenProb"],
        childrenProb: x["childrenProb"],
        maxChildren: x["maxChildren"],
        adoptionWithinProb: x["adoptionWithinProb"],
        adoptionOutsideProb: x["adoptionOutsideProb"],
        straightProb: x["straightProb"],
        queerProb: x["queerProb"],
        polyProb: x["polyProb"],
        ifPolyFliptoQueerProb: x["ifPolyFliptoQueerProb"],
        maxPolyPartner: x["maxPolyPartner"],
        id: x["id"],
      );

      ancestryBox.add(jsonEncode(a.toJson()));
      ancestries =
          ancestryBox.values
              .map((e) => Ancestry.fromJson(e))
              .cast<Ancestry>()
              .toList();
    }
  }
}
