import "package:firetown/providers/government_extension2.dart";
import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

enum LocationType {
  district,
  building,
  meetingPlace,
  street,
  landmark,
  shop,
  temple,
  civic,
  info,
  hireling,
  market,
  government,
}

enum ServiceType {
  food,
  beverage,
  room,
  weapon,
  armor,
  clothing,
  jewelry,
  components,
  potion,
  spell,
  item,
  magic,
  adventure,
  scroll,
}

enum CitySize {
  thorp, // 20--80
  hamlet, // 80 -- 200,
  village, // 200--400,
  town, //400--1000
  city, // 1000--10000
  metropolis // 10000--50000
}

enum GovCreateMethod {
  createRoles,
  createAndChoose,
  useExistingRoles,
}

Map<CitySize, String> citySize2rangesOfNumPeople = {
  CitySize.thorp: "20-80",
  CitySize.hamlet: "80-200",
  CitySize.village: "200-400",
  CitySize.town: "400-1000",
  CitySize.city: "3000-5000",
  CitySize.metropolis: "5000-10000"
};

enum ShopType {
  tavern,

  clothier,

  smith,

  jeweler,

  herbalist,

  temple,
  generalStore,
  magic,
}

enum WordType {
  first,

  second,

  withName,
}

enum Role {
  smith,
  tailor,
  herbalist,
  jeweler,
  tavernKeeper,
  hierophant,
  generalStoreOwner,
  streetRat,
  beggar,

  acolyte,
  apprentice,

  journeyman,

  owner,

  waitstaff,

  cook,

  entertainment,

  regular,

  customer,

  sage,
  hunter,
  gatherer,
  fisher,
  trapper,

  courier,
  laborer,
  porter,
  mason,
  torchBearer,
  mercenary,
  carpenter,
  perfumer,
  accountant,
  scribe,
  locksmith,
  servant,
  lumberjack,
  stonecutter,
  roofer,

  cobbler,
  furrier,
  barber,
  weaver,
  mercer,
  cooper,
  baker,
  saddler,
  butcher,
  fishmonger,
  spiceMerchant,
  painter,
  artist,
  ropemaker,
  sculptor,
  potter,
  rugmaker,
  candlemaker,
  waxmaker,
  florist,
  streetFoodVendor,
  farmer,
  beekeeper,
  soapmaker,
  magicShopOwner,

  government,
  minorNoble,
  townGuard,

  festivalMinisterGovernmentUniversal,
  spyMinisterGovernmentUniversal,
  guildMinisterGovernmentUniversal,
  diplomatMinisterGovernmentUniversal,
  magicMinisterGovernmentUniversal,
  warMinisterGovernmentUniversal,
  infrastructureMinisterGovernmentUniversal,
  justiceMinisterGovernmentUniversal,
  mintMinisterGovernmentUniversal,
  stewardGovernmentUniversal,
  guardCaptainGovernment,
  guardViceCaptainGovernment,
  guardWarrantGovernment,
  guardConstableGovernment,
  liegeGovernment,
  merchantCouncellorGovernment,
  presidentGovernment,
  luminaryGovernment,
  hierophantRulerGovernment,
  elderGovernment,
  tyrantGovernment,
  mayorGovernment,
  chancellorGovernment,
  treasurerGovernment,
  aldermanGovernment,
  nobleGovernment,
  highEnchanterGovernment,
  highEvokerGovernment,
  highIllusionistGovernment,
  highNecromancerGovernment,
  highConjurerGovernment,
  highTransmuterGovernment,
  highAbjurerGovernment,
  highDivinerGovernment,
  arcaneExarchGovernment,
  primarchArcaneGovernment,
  courtierGovernment,
  chancellorViceGovernment,

}


Map<Role, double> propActivate = {
  Role.smith: 1,
  Role.tailor: 1,
  Role.herbalist: 1,
  Role.jeweler: 1,
  Role.tavernKeeper: 1,
  Role.hierophant: 1,
  Role.generalStoreOwner: 1,
  Role.streetRat: 0.05,
  Role.beggar: 0.05,
  Role.apprentice: 0,
  Role.journeyman: 0,
  Role.owner: 0,
  Role.waitstaff: 1,
  Role.cook: 1,
  Role.entertainment: 1,
  Role.regular: 0,
  Role.customer: 0,
  Role.sage: 0.1,
  Role.hunter: 0.01,
  Role.gatherer: 0.01,
  Role.fisher: 0.01,
  Role.trapper: 0.01,
  Role.courier: 0.01,
  Role.laborer: 0.01,
  Role.porter: 0.01,
  Role.mason: 0.01,
  Role.torchBearer: 0.01,
  Role.mercenary: 0.05,
  Role.carpenter: 0.01,
  Role.perfumer: 0.01,
  Role.accountant: 0.01,
  Role.scribe: 0.01,
  Role.locksmith: 0.01,
  Role.servant: 0.01,
  Role.lumberjack: 0.01,
  Role.stonecutter: 0.01,
  Role.roofer: 0.01,
  Role.cobbler: 0.01,
  Role.furrier: 0.01,
  Role.barber: 0.01,
  Role.weaver: 0.01,
  Role.mercer: 0.01,
  Role.cooper: 0.01,
  Role.baker: 0.01,
  Role.saddler: 0.01,
  Role.butcher: 0.01,
  Role.fishmonger: 0.01,
  Role.spiceMerchant: 0.01,
  Role.painter: 0.01,
  Role.artist: 0.01,
  Role.ropemaker: 0.01,
  Role.sculptor: 0.01,
  Role.potter: 0.01,
  Role.rugmaker: 0.01,
  Role.candlemaker: 0.01,
  Role.waxmaker: 0.01,
  Role.florist: 0.01,
  Role.streetFoodVendor: 0.01,
  Role.farmer: 0.01,
  Role.beekeeper: 0.01,
  Role.soapmaker: 0.05,
  Role.magicShopOwner: 1,
};

enum AgeType {
  quiteYoung,
  young,
  adult,
  middleAge,
  old,
  quiteOld,
}

enum OrientationType {
  straight,

  queer
}

String enum2String({dynamic myEnum, bool? plural}) {
  switch (plural ?? false) {
    case true:
      {
        switch (myEnum) {
          case ShopType.clothier:
            return "Clothiers";
          case ShopType.generalStore:
            return "General Stores";
          case ShopType.herbalist:
            return "Herbalists";
          case ShopType.jeweler:
            return "Jewelers";
          case ShopType.smith:
            return "Smiths";
          case ShopType.tavern:
            return "Taverns";
          case ShopType.temple:
            return "Temple";
          case ShopType.magic:
            return "Magic Shops";
          case (Role.owner):
            return "Owners";
          case (Role.apprentice):
            return "Apprentices";
          case (Role.journeyman):
            return "Journeymen";
          case (Role.entertainment):
            return "Entertainers";
          case (Role.waitstaff):
            return "Waitstaff";
          case (Role.regular):
            return "Regulars";
          case (Role.cook):
            return "Cooks";
          case (Role.customer):
            return "Customers";
          case (Role.trapper):
            return "Trappers";
          case (Role.gatherer):
            return "Gatherers/Foragers";
          case (Role.hunter):
            return "Hunters";
          case (Role.fisher):
            return "Fishers";
          case (Role.sage):
            return "Sages / Elders";

          case (Role.courier):
            return "Couriers";
          case (Role.servant):
            return "Servants";
          case (Role.laborer):
            return "Laborers";
          case Role.locksmith:
            return "Locksmiths";
          case Role.porter:
            return "Porters";
          case Role.mason:
            return "Masons";
          case Role.torchBearer:
            return "Torch Bearers";
          case Role.mercenary:
            return "Mercenaries";
          case Role.carpenter:
            return "Carpenters";
          case Role.perfumer:
            return "Perfumers";
          case Role.accountant:
            return "Accountants";
          case Role.scribe:
            return "Scribes";

          case Role.lumberjack:
            return "Lumberjacks";
          case Role.stonecutter:
            return "Stonecutters";
          case Role.roofer:
            return "Roofers";
          case Role.cobbler:
            return "Cobblers";
          case Role.furrier:
            return "Furriers";
          case Role.barber:
            return "Barbers";
          case Role.weaver:
            return "Weavers";
          case Role.mercer:
            return "Mercers";
          case Role.cooper:
            return "Coopers";
          case Role.baker:
            return "Bakers";
          case Role.saddler:
            return "Saddlers";
          case Role.butcher:
            return "Butchers";
          case Role.fishmonger:
            return "Fishmongers";
          case Role.spiceMerchant:
            return "Spice Merchants";
          case Role.painter:
            return "Painters";
          case Role.ropemaker:
            return "Rope Makers";
          case Role.sculptor:
            return "Sculptors";
          case Role.potter:
            return "Potters";
          case Role.rugmaker:
            return "Rug Makers";
          case Role.candlemaker:
            return "Candle Makers";
          case Role.waxmaker:
            return "Wax Makers";
          case Role.florist:
            return "Florists";
          case Role.streetFoodVendor:
            return "Street Food Vendors";
          case Role.farmer:
            return "Farmers";
          case Role.beekeeper:
            return "Beekeepers";
          case Role.soapmaker:
            return "Soap Makers";
          case Role.streetRat:
            return "Street Rats";
          case Role.generalStoreOwner:
            return "General Store Owners";
          case Role.herbalist:
            return "Herbalists";
          case Role.smith:
            return "Smiths";
          case Role.tailor:
            return "Clothiers";
          case Role.jeweler:
            return "Jewelers";
          case Role.hierophant:
            return "Hierophants";
          case Role.beggar:
            return "Beggars";
          case Role.magicShopOwner:
            return "Magic Shop Owners";
          case Role.minorNoble:
            return "Minor Nobles";
          case Role.acolyte:
            return "Acolytes";
          case Role.government:
            return "Government Officials";
          case Role.tavernKeeper:
            return "Tavern Keepers";

          default:
            return "******IDK******* $myEnum";
        }
      }
    case false:
      switch (myEnum) {
        case (ShopType.tavern):
          return "Tavern";
        case (ShopType.clothier):
          return "Clothier";
        case (ShopType.smith):
          return "Smith";
        case (ShopType.jeweler):
          return "Jeweler";
        case (ShopType.herbalist):
          return "Herbalist";
        case (ShopType.temple):
          return "Temple";
        case (ShopType.generalStore):
          return "General Store";
        case (ShopType.magic):
          return "Magic Shop";

        case (Role.apprentice):
          return "Apprentice";
        case (Role.journeyman):
          return "Journeyman";
        case (Role.owner):
          return "Owner";
        case (Role.waitstaff):
          return "Waitstaff";
        case (Role.cook):
          return "Cook";
        case (Role.entertainment):
          return "Entertainment";
        case (Role.regular):
          return "Regular";
        case (Role.customer):
          return "Customer";
        case (Role.trapper):
          return "Trapper";
        case (Role.gatherer):
          return "Gatherer/Forager";
        case (Role.hunter):
          return "Hunter";
        case (Role.fisher):
          return "Fisher";
        case (Role.sage):
          return "Sage / Elder";

        case (Role.servant):
          return "Servant";
        case (Role.courier):
          return "Courier";
        case (Role.laborer):
          return "Laborer";
        case Role.porter:
          return "Porter";
        case Role.locksmith:
          return "Locksmith";
        case Role.mason:
          return "Mason";
        case Role.torchBearer:
          return "Torch Bearer";
        case Role.mercenary:
          return "Mercenary";
        case Role.carpenter:
          return "Carpenter";
        case Role.perfumer:
          return "Perfumer";
        case Role.accountant:
          return "Accountant";
        case Role.scribe:
          return "Scribe";

        case Role.lumberjack:
          return "Lumberjack";
        case Role.stonecutter:
          return "Stonecutter";
        case Role.roofer:
          return "Roofer";
        case Role.cobbler:
          return "Cobbler";
        case Role.furrier:
          return "Furrier";
        case Role.barber:
          return "Barber";
        case Role.weaver:
          return "Weaver";
        case Role.mercer:
          return "Mercer";
        case Role.cooper:
          return "Cooper";
        case Role.baker:
          return "Baker";
        case Role.saddler:
          return "Saddler";
        case Role.butcher:
          return "Butcher";
        case Role.fishmonger:
          return "Fishmonger";
        case Role.spiceMerchant:
          return "Spice Merchant";
        case Role.painter:
          return "Painter";
        case Role.ropemaker:
          return "Rope Maker";
        case Role.sculptor:
          return "Sculptor";
        case Role.potter:
          return "Potter";
        case Role.rugmaker:
          return "Rug Maker";
        case Role.candlemaker:
          return "Candle Maker";
        case Role.waxmaker:
          return "Wax Maker";
        case Role.florist:
          return "Florist";
        case Role.streetFoodVendor:
          return "Street Food Vendor";
        case Role.farmer:
          return "Farmer";
        case Role.beekeeper:
          return "Beekeeper";
        case Role.soapmaker:
          return "Soap Maker";
        case Role.streetRat:
          return "Street Rat";
        case Role.generalStoreOwner:
          return "General Store Owner";
        case Role.herbalist:
          return "Herbalist";
        case Role.smith:
          return "Smith";
        case Role.tailor:
          return "Clothier";
        case Role.jeweler:
          return "Jeweler";
        case Role.hierophant:
          return "Hierophant";
        case Role.beggar:
          return "Beggar";
        case Role.magicShopOwner:
          return "Magic Shop Owner";
        case Role.minorNoble:
          return "Minor Noble";
        case Role.acolyte:
          return "Acolyte";
        case Role.government:
          return "Government Official";
        case Role.tavernKeeper:
          return "Tavern Keeper";

        case AgeType.quiteYoung:
          return "Quite Young";
        case AgeType.young:
          return "Young";
        case AgeType.adult:
          return "Adult";
        case AgeType.middleAge:
          return "Middle-Age";
        case AgeType.old:
          return "Old";
        case AgeType.quiteOld:
          return "Quite Old";
        case PronounType.heHim:
          return "He/Him";
        case PronounType.sheHer:
          return "She/Her";
        case PronounType.theyThem:
          return "They/Them";
        case PronounType.heThey:
          return "He/They";
        case PronounType.sheThey:
          return "She/They";
        case PronounType.any:
          return "Any";
        case OrientationType.straight:
          return "Straight";
        case OrientationType.queer:
          return "Queer";
        case PolyType.poly:
          return "Poly";
        case PolyType.notPoly:
          return "Not Poly";

        default:
          return "******IDK******** $myEnum";
      }
  }
}

dynamic string2Enum(String s) {
  final Map<String, dynamic> enumMap = {
    "Tavern": ShopType.tavern,
    "Clothier": ShopType.clothier,
    "Smith": ShopType.smith,
    "Jeweler": ShopType.jeweler,
    "Herbalist": ShopType.herbalist,
    "Temple": ShopType.temple,
    "First": WordType.first,
    "With Name": WordType.withName,
    "Second": WordType.second,
    "Apprentice": Role.apprentice,
    "Journeyman": Role.journeyman,
    "Owner": Role.owner,
    "Waitstaff": Role.waitstaff,
    "Cook": Role.cook,
    "Entertainment": Role.entertainment,
    "Regular": Role.regular,
    "Customer": Role.customer,
    "Quite Young": AgeType.quiteYoung,
    "Young": AgeType.young,
    "Adult": AgeType.adult,
    "Middle-Age": AgeType.middleAge,
    "Middle Age": AgeType.middleAge,
    "Old": AgeType.old,
    "Quite Old": AgeType.quiteOld,
    "He/Him": PronounType.heHim,
    "She/Her": PronounType.sheHer,
    "They/Them": PronounType.theyThem,
    "He/They": PronounType.heThey,
    "She/They": PronounType.sheThey,
    "Any": PronounType.any,
    "Straight": OrientationType.straight,
    "Queer": OrientationType.queer,
    "Poly": PolyType.poly,
    "Not Poly": PolyType.notPoly,
    "generalStore": ShopType.generalStore,
    "magic": ShopType.magic,
  };

  return enumMap[s];
}

Map<dynamic, List<Role>> roleLookup = {
  ShopType.tavern: [
    Role.owner,
    Role.tavernKeeper,
    Role.waitstaff,
    Role.cook,
    Role.entertainment,
    Role.regular
  ],
  ShopType.smith: [Role.owner, Role.journeyman, Role.apprentice, Role.customer],
  ShopType.clothier: [
    Role.owner,
    Role.journeyman,
    Role.apprentice,
    Role.customer
  ],
  ShopType.herbalist: [
    Role.owner,
    Role.journeyman,
    Role.apprentice,
    Role.customer
  ],
  ShopType.jeweler: [
    Role.owner,
    Role.journeyman,
    Role.apprentice,
    Role.customer
  ],
  ShopType.generalStore: [Role.owner, Role.customer],
  ShopType.magic: [Role.owner, Role.journeyman, Role.apprentice, Role.customer],
  ShopType.temple: [Role.hierophant, Role.acolyte],
  // LocationType.info: [Role.owner,Role.sage, Role.hunter, Role.gatherer, Role.fisher, Role.trapper,Role.owner],
  // LocationType.hireling: [Role.owner,Role.mercenary, Role.torchBearer, Role.locksmith, Role.porter, Role.courier, Role.scribe, Role.perfumer, Role.accountant, Role.carpenter, Role.mason, Role.lumberjack,Role.stonecutter, Role.servant, Role.laborer],
  // LocationType.market:[Role.cobbler,Role.furrier,Role.barber,Role.weaver,Role.mercer,Role.cooper,Role.baker,Role.saddler,Role.butcher,Role.fishmonger,Role.spiceMerchant,Role.painter,Role.ropemaker,Role.sculptor,Role.potter,Role.rugmaker,Role.candlemaker,Role.waxmaker,Role.soapmaker, Role.florist,Role.streetFoodVendor,Role.farmer,Role.beekeeper,],
};

List<Role> defaultRoles = [
  Role.owner,
  Role.journeyman,
  Role.apprentice,
  Role.customer
];

enum RelationshipType {
  parent,
  partner,
  ex,
  child,
  friend,
  enemy,
  sibling,
  family,
}

enum AdoptionType {
  sameAncestry,
  differentAncestry,
  noAdoption
}

enum PartnerType {
  sameAncestry,
  differentAncestry,
  noPartner,
}

enum PronounType {
  heHim,
  sheHer,
  theyThem,
  heThey,
  sheThey,
  any,
}

final Map<AgeType, String> age2string = {
  AgeType.quiteYoung: "Quite Young",
  AgeType.young: "Young",
  AgeType.adult: "Adult",
  AgeType.middleAge: "Middle-Age",
  AgeType.old: "Old",
  AgeType.quiteOld: "Quite Old"
};

final Map<String, AgeType> string2AgeType = {
  age2string[AgeType.quiteYoung] ?? "Quite Young": AgeType.quiteYoung,
  age2string[AgeType.young] ?? "Young": AgeType.young,
  age2string[AgeType.adult] ?? "Adult": AgeType.adult,
  age2string[AgeType.middleAge] ?? "Middle-Age": AgeType.middleAge,
  age2string[AgeType.old] ?? "Old": AgeType.old,
  age2string[AgeType.quiteOld] ?? "Quite Old": AgeType.quiteOld,
};

final Map<AgeType, Set<AgeType>> allowedToPartner = {
  AgeType.quiteYoung: {},
  AgeType.young: {},
  AgeType.adult: {AgeType.adult, AgeType.middleAge},
  AgeType.middleAge: {AgeType.adult, AgeType.middleAge, AgeType.old},
  AgeType.old: {AgeType.middleAge, AgeType.old, AgeType.quiteOld},
  AgeType.quiteOld: {AgeType.old, AgeType.quiteOld}
};

String pronounToString(PronounType pronounType) {
  const pronounMapping = {
    PronounType.heHim: "He/Him",
    PronounType.sheHer: "She/Her",
    PronounType.theyThem: "They/Them",
    PronounType.heThey: "He/They",
    PronounType.sheThey: "She/They",
    PronounType.any: "Any",
  };

  return pronounMapping[pronounType] ?? "Unknown";
}

final Map<String, PronounType> pronounString2type = {
  pronounToString(PronounType.heHim): PronounType.heHim,
  pronounToString(PronounType.sheHer): PronounType.sheHer,
  pronounToString(PronounType.heThey): PronounType.heThey,
  pronounToString(PronounType.sheThey): PronounType.sheThey,
  pronounToString(PronounType.theyThem): PronounType.theyThem,
  pronounToString(PronounType.any): PronounType.any
};

final Map<String, OrientationType> orierientationString2type = {
  orientation2String[OrientationType.straight] ?? "Straight":
      OrientationType.straight,
  orientation2String[OrientationType.queer] ?? "Queer": OrientationType.queer,
};

final Map<OrientationType, String> orientation2String = {
  OrientationType.straight: "Straight",
  OrientationType.queer: "Queer",
};

enum PolyType {
  poly,
  notPoly,
}

final Map<PolyType, String> poly2String = {
  PolyType.poly: "Poly",
  PolyType.notPoly: "Not Poly",
};

final Map<String, PolyType> string2Poly = {
  poly2String[PolyType.poly] ?? "Poly": PolyType.poly,
  poly2String[PolyType.notPoly] ?? "Not Poly": PolyType.notPoly,
};

final Map<PronounType, Set<PronounType>> straightCandidatePronouns = {
  PronounType.heHim: {PronounType.sheHer, PronounType.sheThey},
  PronounType.sheHer: {PronounType.heHim, PronounType.heThey},
  PronounType.heThey: {PronounType.sheHer, PronounType.sheThey},
  PronounType.sheThey: {PronounType.heHim, PronounType.heThey},
  PronounType.theyThem: {PronounType.theyThem, PronounType.any},
  PronounType.any: {PronounType.any, PronounType.theyThem}
};

final Map<PronounType, Set<PronounType>> queerCandidatePronouns = {
  PronounType.heHim: {
    PronounType.heHim,
    PronounType.heThey,
    PronounType.theyThem,
    PronounType.any
  },
  PronounType.sheHer: {
    PronounType.sheHer,
    PronounType.sheThey,
    PronounType.theyThem,
    PronounType.any
  },
  PronounType.heThey: {
    PronounType.heHim,
    PronounType.heThey,
    PronounType.theyThem,
    PronounType.any
  },
  PronounType.sheThey: {
    PronounType.sheHer,
    PronounType.sheThey,
    PronounType.theyThem,
    PronounType.any
  },
  PronounType.theyThem: {PronounType.theyThem, PronounType.any},
  PronounType.any: PronounType.values.toSet()
};


String govTypeForPrint(String govString){
  switch(govString){
    case "nobility": return "Nobility";
    case "merchantCouncil": return "Merchants' Council";
    case "directDemocracy": return "Direct Democracy";
    case "mageocracy": return "Mageocracy";
    case "theocracy": return "Theocracy";
    case "councilOfElders": return "Council of Elders";
    case "tyranny": return "Tyranny";
    case "cityCouncil": return "City Council";
    default: return "unknown government";
  }

}

Role positionString2Role(String positionString){
  return Role.values.firstWhereOrNull((v)=>v.name.split("Government").first==positionString) ?? Role.government;
}

bool isGuard(String positionString){
  return positionString.startsWith("guard");
}

GovCreateMethod govCreateMethod(String government, String position){
  Role myRole = Role.values.firstWhere((r)=>r.name.split("Government").first == position);
  
  if(government == "directDemocracy"){
    return GovCreateMethod.createAndChoose;
  }
  else if(myRole.name.split("Government").last == "Universal"){
    return GovCreateMethod.createRoles;
  }
  else if(myRole.name.startsWith("guard")){return GovCreateMethod.createRoles;}
  else{
    switch(government){
      case "nobility": 
      case "mageocracy": 
      case "tyranny": 
      case "cityCouncil":
      case "theocracy": 
          return GovCreateMethod.createRoles;
      case "councilOfElders":
      case "merchantCouncil":
          return GovCreateMethod.useExistingRoles;
      default: return GovCreateMethod.createRoles;
    }
  }
}

List<Role> govValidRoles(String position){
  Role translatedRole = Role.values.firstWhereOrNull((v)=>v.name.split("Government").first==position) ?? Role.government;
  switch(translatedRole){
    case Role.festivalMinisterGovernmentUniversal: return [];
    case Role.spyMinisterGovernmentUniversal: return [];
    case Role.guildMinisterGovernmentUniversal: return [];
    case Role.diplomatMinisterGovernmentUniversal: return [];
    case Role.magicMinisterGovernmentUniversal: return [];
    case Role.warMinisterGovernmentUniversal: return [];
    case Role.infrastructureMinisterGovernmentUniversal: return [];
    case Role.justiceMinisterGovernmentUniversal: return [];
    case Role.mintMinisterGovernmentUniversal: return [];
    case Role.stewardGovernmentUniversal: return [];
    case Role.guardCaptainGovernment:return [];
    case Role.guardViceCaptainGovernment:return [];
    case Role.guardWarrantGovernment:return [];
    case Role.guardConstableGovernment:return [];
    case Role.liegeGovernment:return [];
    case Role.merchantCouncellorGovernment: return [Role.smith, Role.tailor,  Role.herbalist,  Role.jeweler,  Role.tavernKeeper,  Role.generalStoreOwner,  Role.magicShopOwner,   Role.spiceMerchant];
    case Role.presidentGovernment:return [];
    case Role.luminaryGovernment:return [];
    case Role.hierophantRulerGovernment:return [Role.hierophant];
    case Role.elderGovernment: return [Role.sage];
    case Role.tyrantGovernment:return [];
    case Role.mayorGovernment: return [];
    case Role.chancellorGovernment: return [];
    case Role.treasurerGovernment: return [];
    case Role.aldermanGovernment:return [];
    case Role.nobleGovernment: return [];
    case Role.highEnchanterGovernment:return [];
    case Role.highEvokerGovernment:return [];
    case Role.highIllusionistGovernment:return [];
    case Role.highNecromancerGovernment:return [];
    case Role.highConjurerGovernment:return [];
    case Role.highTransmuterGovernment:return [];
    case Role.highAbjurerGovernment:return [];
    case Role.highDivinerGovernment:return [];
    case Role.arcaneExarchGovernment:return [];
    case Role.primarchArcaneGovernment:return [];
    case Role.courtierGovernment:return [];
    case Role.chancellorViceGovernment:return [];
    default: return [];
  }
}


String stringForHeaders(WidgetRef ref,Role role){
  final positions = ref.read(positionsProvider);
  switch(role){
  case Role.festivalMinisterGovernmentUniversal:
  case Role.spyMinisterGovernmentUniversal:
  case Role.guildMinisterGovernmentUniversal:
  case Role.diplomatMinisterGovernmentUniversal:
  case Role.magicMinisterGovernmentUniversal:
  case Role.warMinisterGovernmentUniversal:
  case Role.infrastructureMinisterGovernmentUniversal:
  case Role.justiceMinisterGovernmentUniversal:
  case Role.mintMinisterGovernmentUniversal:
  case Role.stewardGovernmentUniversal:
  return positions.firstWhere((p)=>p.positionKey==role.name.split("Government").first).titles[ref.watch(governmentTypeProvider)]!;
  case Role.guardCaptainGovernment:
  case Role.guardViceCaptainGovernment:
  case Role.guardWarrantGovernment:
  case Role.guardConstableGovernment:
      return "Guard: ${positions.firstWhere((p)=>p.positionKey==role.name.split("Government").first).titles[ref.watch(governmentTypeProvider)]!}";  
  case Role.liegeGovernment: return "Liege";
  case Role.merchantCouncellorGovernment: return "Merchant Councellor";
  case Role.presidentGovernment: return "President";
  case Role.luminaryGovernment: return "Luminary";
  case Role.hierophantRulerGovernment: return "Head Hierophant";
  case Role.elderGovernment: return "Elder";
  case Role.tyrantGovernment: return "Tyrant";
  case Role.mayorGovernment: return "Mayor";
  case Role.chancellorGovernment: return "Chancellor";
  case Role.treasurerGovernment:  return "Treasurer";
  case Role.aldermanGovernment: return "Alderman";
  case Role.nobleGovernment: return "Noble";
  case Role.highEnchanterGovernment: return "High Enchanter";
  case Role.highEvokerGovernment: return "High Evoker";
  case Role.highIllusionistGovernment: return "High Illusionist";
  case Role.highNecromancerGovernment: return "High Necromancer";
  case Role.highConjurerGovernment: return "High Conjurer";
  case Role.highTransmuterGovernment: return "High Transmuter";
  case Role.highAbjurerGovernment: return "High Abjurer";
  case Role.highDivinerGovernment: return "High Diviner";
  case Role.arcaneExarchGovernment: return "Arcane Exarch";
  case Role.primarchArcaneGovernment: return "Primarch Arcane";
  case Role.courtierGovernment: return "Courtier";
  case Role.chancellorViceGovernment: return "Vice Chancellor";
  case Role.minorNoble: return "Minor Noble";
  default: return "Unknown Gov Title";
  }

}