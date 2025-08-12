import "package:firetown/providers/location_providers.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import "../enums_and_maps.dart";
// import 'shop.dart';
// import "new_shops.dart";
// import "tavern.dart";
// import "demographics.dart";

import "../models/town_model.dart";
import "package:firetown/models/town_extension/town_locations.dart";


enum ShopListFilter {
  all,
  tavern,
  smith,
  herbalist,
  clothier,
  jeweler,
}

// final givenNameProvider = Provider<ProviderList<GivenName>>((ref) {
//   return ProviderList<GivenName>(
//     myBox: Hive.box<String>("givenNames"),
//     fromJson: (json) => GivenName.fromJson(json),
//   );
// });

/// The currently active filter.
final shopListFilter = StateProvider((_) => ShopListFilter.all);

// final peopleBoxProvider =   StateProvider<Box<String>>((ref) =>Hive.box('peopleBox'));
// final relBoxProvider =    StateProvider<Box<String>>((ref) =>Hive.box('relationshipBox'));
// final locationsRoleBoxProvider = StateProvider<Box<String>>((ref)=> Hive.box("locationsRoleBox"));
// final locationBoxProvider = StateProvider<Box<String>>((ref) =>Hive.box('locBox'));

// final locationSearchBoxProvider = StateProvider<Box<String>>((ref) =>Hive.box('locSearchBox'));
// final peopleSearchBoxProvider =   StateProvider<Box<String>>((ref) =>Hive.box('peopleSearchBox'));

// final ancestryBoxProvider = Provider<Box<String>>((ref) =>Hive.box('ancestryBox'));

// final genericServiceBoxProvider = Provider<Box<String>>((ref)=>Hive.box("genericServiceBox"));
// final specialtyBoxProvider = Provider<Box<String>>((ref)=>Hive.box("specialtyBox"));

// final roleBoxProvider =   Provider<Box<String>>((ref) =>Hive.box('roleBox'));

// final resArgBoxProvider =   Provider<Box<String>>((ref) =>Hive.box('resArgBox'));
// final givenNameBoxProvider =Provider<Box<String>>((ref) =>Hive.box('givenNameBox'));
// final surnameBoxProvider =  Provider<Box<String>>((ref) =>Hive.box('surnameBox'));
// final quirkBoxProvider =    Provider<Box<String>>((ref) =>Hive.box('quirkBox'));
// // final bigShopBoxProvider =  Provider<Box<String>>((ref) =>Hive.box('bigShopBox'));
// final qualityBoxProvider =  Provider<Box<String>>((ref) =>Hive.box('shopQualityBox'));
// final shopNameBoxProvider = Provider<Box<String>>((ref) =>Hive.box('shopNameBox'));
// final townBoxProvider =     Provider<Box<String>>((ref) =>Hive.box('townBox'));

// final pendingRolesBoxProvider = StateProvider<Box<String>>((ref)=>Hive.box('pendingRolesBox'));


// final myWorldProvider = 
//  Provider<World>((ref){
//   final ancestryBox = ref.watch(ancestryBoxProvider);
//   final givenNameBox = ref.watch(givenNameBoxProvider);
//   final surnameBox = ref.watch(surnameBoxProvider);
//   final quirkBox = ref.watch(quirkBoxProvider);
//   final raBox = ref.watch(resArgBoxProvider);
//   final shopNameBox = ref.watch(shopNameBoxProvider);
//   final shopQualityBox = ref.watch(qualityBoxProvider);
//   final townBox = ref.watch(townBoxProvider);
//   final roleBox = ref.watch(roleBoxProvider);
//   final gSBox = ref.watch(genericServiceBoxProvider);
//   final sBox = ref.watch(specialtyBoxProvider);

//   return World(ancestryBox: ancestryBox, 
//                       givenNameBox: givenNameBox, 
//                       surnameBox: surnameBox, 
//                       quirkBox: quirkBox, 
//                       raBox: raBox, 
//                       shopNameBox: shopNameBox, 
//                       shopQualityBox: shopQualityBox, 
//                       townBox: townBox,
//                       roleBox: roleBox,
//                       genericServiceBox: gSBox,
//                       specialtyBox: sBox);
//  }); 

var townProvider =
 StateProvider<TownOnFire>((ref){

  return TownOnFire(
    name: "OnionTown",
    id: "1",
    myDemographics: {"Birdfolk": 100,
                     "Elf": 1},
  );
 }); 

final filteredShops = Provider<List<Shop>>((ref) {

  final filter = ref.watch(shopListFilter);
  final shops = ref.watch(locationsProvider).where((ell)=>ell.locType==LocationType.shop).cast<Shop>().toList();

  switch (filter) {
    case ShopListFilter.tavern: 
      return shops.where((shop) => shop.type==ShopType.tavern).toList();
    case ShopListFilter.clothier:
      return shops.where((shop) => shop.type==ShopType.clothier).toList();
    case ShopListFilter.jeweler:
      return shops.where((shop) => shop.type==ShopType.jeweler).toList();
    case ShopListFilter.herbalist:
      return shops.where((shop) => shop.type==ShopType.herbalist).toList();
    case ShopListFilter.smith:
      return shops.where((shop) => shop.type==ShopType.smith).toList();
    case ShopListFilter.all:
      return shops;
  }
});


