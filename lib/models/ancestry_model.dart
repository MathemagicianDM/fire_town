import 'dart:math';
// import 'package:flutter/foundation.dart' show immutable;
// import 'package:riverpod/riverpod.dart';
// import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:flutter/material.dart';
// import 'package:rivertown/demographics_view.dart';
// import "person.dart";
import "../globals.dart";
// import "demographics_edit_view.dart";
// import "given_names.dart";
// import "surnames.dart";
// import "resonant_argument.dart";
// import "quirks.dart";
import "../enums_and_maps.dart";

// part "demographics.g.dart";

@immutable
class Ancestry implements JsonSerializable {
  const Ancestry({
    required this.name,
    required this.quiteYoungProb,
    required this.youngProb,
    required this.adultProb,
    required this.middleAgeProb,
    required this.oldProb,
    required this.quiteOldProb,
    required this.heHimProb,
    required this.sheHerProb,
    required this.theyThemProb,
    required this.heTheyProb,
    required this.sheTheyProb,
    required this.partnerWithinProb,
    required this.partnerOutsideProb,
    required this.breakupProb,
    required this.noChildrenProb,
    required this.childrenProb,
    required this.maxChildren,
    required this.adoptionWithinProb,
    required this.adoptionOutsideProb,
    required this.straightProb,
    required this.queerProb,
    required this.polyProb,
    required this.ifPolyFliptoQueerProb,
    required this.maxPolyPartner,
    required this.id,
  });

  final String name;

  final double quiteYoungProb;

  final double youngProb;

  final double adultProb;

  final double middleAgeProb;

  final double oldProb;

  final double quiteOldProb;

  final double heHimProb;

  final double sheHerProb;

  final double theyThemProb;

  final double heTheyProb;

  final double sheTheyProb;

  final double partnerWithinProb;

  final double partnerOutsideProb;

  final double breakupProb;

  final double noChildrenProb;

  final double childrenProb;

  final int maxChildren;

  final double adoptionWithinProb;

  final double adoptionOutsideProb;

  final double straightProb;

  final double queerProb;

  final double polyProb;

  final double ifPolyFliptoQueerProb;

  final int maxPolyPartner;

  final String id;

  PronounType randomPronouns() {
    final probabilities = [
      {"prob": heHimProb, "type": PronounType.heHim},
      {"prob": sheHerProb, "type": PronounType.sheHer},
      {"prob": theyThemProb, "type": PronounType.theyThem},
      {"prob": heTheyProb, "type": PronounType.heThey},
      {"prob": sheTheyProb, "type": PronounType.sheThey},
    ];

    double r = random.nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["type"] as PronounType;
      }
    }

    return PronounType.any;
  }

  AgeType randomAge() {
    final probabilities = [
      {"prob": quiteYoungProb, "age": AgeType.quiteYoung},
      {"prob": youngProb, "age": AgeType.young},
      {"prob": adultProb, "age": AgeType.adult},
      {"prob": middleAgeProb, "age": AgeType.middleAge},
      {"prob": oldProb, "age": AgeType.old},
      {"prob": quiteOldProb, "age": AgeType.quiteOld},
    ];

    double r = random.nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["age"] as AgeType;
      }
    }

    return AgeType.adult;
  }

  PartnerType randomPartnerType() {
    final probabilities = [
      {"prob": partnerWithinProb, "type": PartnerType.sameAncestry},
      {"prob": partnerOutsideProb, "type": PartnerType.differentAncestry},
    ];

    double r = Random().nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["type"] as PartnerType;
      }
    }

    return PartnerType.noPartner;
  }

  bool breakup() {
    double r = Random().nextDouble();
    if (r < breakupProb) return true;
    return false;
  }

  int randomNumChildren() {
    int counter = 0;
    while (counter < maxChildren) {
      if (Random().nextDouble() < childrenProb) {
        counter++;
      } else {
        break;
      }
    }
    return counter;
  }

  AdoptionType randomAdoptionType() {
    final probabilities = [
      {"prob": adoptionWithinProb, "result": AdoptionType.sameAncestry},
      {"prob": adoptionOutsideProb, "result": AdoptionType.differentAncestry},
    ];

    double r = Random().nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["result"] as AdoptionType;
      }
    }

    return AdoptionType.noAdoption;
  }

  OrientationType randomOrientationType() {
    final probabilities = [
      {"prob": queerProb, "result": OrientationType.queer},
    ];

    double r = Random().nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["result"] as OrientationType;
      }
    }
    return OrientationType.straight;
  }

  PolyType randomPolyType() {
    final probabilities = [
      {"prob": polyProb, "result": PolyType.poly},
    ];

    double r = Random().nextDouble();

    for (var entry in probabilities) {
      r -= entry["prob"] as double;
      if (r < 0) {
        return entry["result"] as PolyType;
      }
    }

    return PolyType.notPoly;
  }

  bool flipOnPoly() {
    if (Random().nextDouble() < ifPolyFliptoQueerProb) {
      return true;
    } else {
      return false;
    }
  }

  Map<String, dynamic> get fields => {
    "name": name,
    "quiteYoungProb": quiteYoungProb,
    "youngProb": youngProb,
    "adultProb": adultProb,
    "middleAgeProb": middleAgeProb,
    "oldProb": oldProb,
    "quiteOldProb": quiteOldProb,
    "heHimProb": heHimProb,
    "sheHerProb": sheHerProb,
    "theyThemProb": theyThemProb,
    "heTheyProb": heTheyProb,
    "sheTheyProb": sheTheyProb,
    "partnerWithinProb": partnerWithinProb,
    "partnerOutsideProb": partnerOutsideProb,
    "breakupProb": breakupProb,
    "noChildrenProb": noChildrenProb,
    "childrenProb": childrenProb,
    "maxChildren": maxChildren,
    "adoptionWithinProb": adoptionWithinProb,
    "adoptionOutsideProb": adoptionOutsideProb,
    "straightProb": straightProb,
    "queerProb": queerProb,
    "polyProb": polyProb,
    "ifPolyFliptoQueerProb": ifPolyFliptoQueerProb,
    "maxPolyPartner": maxPolyPartner,
  };
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id.toString(),
      'quiteYoungProb': quiteYoungProb.toString(),
      'youngProb': youngProb.toString(),
      'adultProb': adultProb.toString(),
      'middleAgeProb': middleAgeProb.toString(),
      'oldProb': oldProb.toString(),
      'quiteOldProb': quiteOldProb.toString(),
      'heHimProb': heHimProb.toString(),
      'sheHerProb': sheHerProb.toString(),
      'theyThemProb': theyThemProb.toString(),
      'heTheyProb': heTheyProb.toString(),
      'sheTheyProb': sheTheyProb.toString(),
      'partnerWithinProb': partnerWithinProb.toString(),
      'partnerOutsideProb': partnerOutsideProb.toString(),
      'breakupProb': breakupProb.toString(),
      'noChildrenProb': noChildrenProb.toString(),
      'childrenProb': childrenProb.toString(),
      'maxChildren': maxChildren.toString(),
      'adoptionWithinProb': adoptionWithinProb.toString(),
      'adoptionOutsideProb': adoptionOutsideProb.toString(),
      'straightProb': straightProb.toString(),
      'queerProb': queerProb.toString(),
      'polyProb': polyProb.toString(),
      'ifPolyFliptoQueerProb': ifPolyFliptoQueerProb.toString(),
      'maxPolyPartner': maxPolyPartner.toString(),
    };
  }
  @override
  factory Ancestry.fromJson(dynamic json) {

    final Map<String, dynamic> data = json is String ? jsonDecode(json) : json;

    return Ancestry(
      name: data['name'],
      id: data['id'],
      quiteYoungProb: data['quiteYoungProb'] is String ? double.parse(data['quiteYoungProb']) : data['quiteYoungProb'],
      youngProb: data['youngProb'] is String ? double.parse(data['youngProb']) : data['youngProb'],
      adultProb: data['adultProb'] is String ? double.parse(data['adultProb']) : data['adultProb'],
      middleAgeProb: data['middleAgeProb'] is String ? double.parse(data['middleAgeProb']) : data['middleAgeProb'],
      oldProb: data['oldProb'] is String ? double.parse(data['oldProb']) : data['oldProb'],
      quiteOldProb: data['quiteOldProb'] is String ? double.parse(data['quiteOldProb']) : data['quiteOldProb'],
      heHimProb: data['heHimProb'] is String ? double.parse(data['heHimProb']) : data['heHimProb'],
      sheHerProb: data['sheHerProb'] is String ? double.parse(data['sheHerProb']) : data['sheHerProb'],
      theyThemProb: data['theyThemProb'] is String ?  double.parse(data['theyThemProb']) : data['theyThemProb'],
      heTheyProb: data['heTheyProb'] is String ? double.parse(data['heTheyProb']) : data['heTheyProb'],
      sheTheyProb: data['sheTheyProb'] is String ? double.parse(data['sheTheyProb']) : data['sheTheyProb'],
      partnerWithinProb: data['partnerWithinProb'] is String ? double.parse(data['partnerWithinProb']) : data['partnerWithinProb'],
      partnerOutsideProb: data['partnerOutsideProb'] is String ? double.parse(data['partnerOutsideProb']) : data['partnerOutsideProb'],
      breakupProb: data['breakupProb'] is String ? double.parse(data['breakupProb']) : data['breakupProb'],
      noChildrenProb: data['noChildrenProb'] is String ?double.parse(data['noChildrenProb']) : data['noChildrenProb'],
      childrenProb: data['childrenProb'] is String ?  double.parse(data['childrenProb']) : data['childrenProb'],
      maxChildren: data['maxChildren'] is String ? int.parse(data['maxChildren']) : data['maxChildren'],
      adoptionWithinProb: data['adoptionWithinProb'] is String ? double.parse(data['adoptionWithinProb']) : data['adoptionWithinProb'],
      adoptionOutsideProb: data['adoptionOutsideProb'] is String ? double.parse(data['adoptionOutsideProb']) : data['adoptionOutsideProb'],
      straightProb: data['straightProb'] is String ? double.parse(data['straightProb']) : data['straightProb'],
      queerProb:data['queerProb'] is String ? double.parse(data['queerProb']) : data['queerProb'],
      polyProb: data['polyProb'] is String ?  double.parse(data['polyProb']) : data['polyProb'],
      ifPolyFliptoQueerProb: data['ifPolyFliptoQueerProb'] is String ? double.parse(data['ifPolyFliptoQueerProb']) : data['ifPolyFliptoQueerProb'],
      maxPolyPartner: data['maxPolyPartner'] is String ? int.parse(data['maxPolyPartner']) : data['maxPolyPartner'],
    );
  }
  
  @override
String compositeKey() {
    return id;
  }
}




// class AncestryList extends StateNotifier<List<Ancestry>>
// {
//   AncestryList([List<Ancestry>? initialAncestries]) : super(initialAncestries ?? []);

//   void add({
//   required String     nameNew,
//   required double     quiteYoungProbNew,
//   required double     youngProbNew,
//   required double     adultProbNew,
//   required double     middleAgeProbNew,
//   required double     oldProbNew,
//   required double     quiteOldProbNew,
//   required double     heHimProbNew,
//   required double     sheHerProbNew,
//   required double     theyThemProbNew,
//   required double     heTheyProbNew,
//   required double     sheTheyProbNew,
            
//   required double     partnerWithinProbNew,
//   required double     partnerOutsideProbNew,
//   required double     breakupProbNew,
          
//   required double     noChildrenProbNew,
//   required double     childrenProbNew,
//   required int        maxChildrenNew,
//   required double     adoptionWithinProbNew,
//   required double     adoptionOutsideProbNew,

//   required double     straightProbNew,
//   required double     queerProbNew,

//   required double     polyProbNew,
//   required double     ifPolyFliptoQueerProbNew,
//   required int        maxPolyPartnerNew,



//   required int        idNew,

//   }){
//             state = [
//               ...state,
//               Ancestry(
//                name: nameNew,
//                quiteYoungProb:  quiteYoungProbNew,
//                youngProb:  youngProbNew,
//                adultProb:  adultProbNew,
//                middleAgeProb:  middleAgeProbNew,
//                oldProb:  oldProbNew,
//                quiteOldProb:  quiteOldProbNew,
//                heHimProb:  heHimProbNew,
//                sheHerProb:  sheHerProbNew,
//                theyThemProb:  theyThemProbNew,
//                heTheyProb:  heTheyProbNew,
//                sheTheyProb:  sheTheyProbNew,
//                partnerWithinProb:  partnerWithinProbNew,
//                partnerOutsideProb:  partnerOutsideProbNew,
//                breakupProb:  breakupProbNew,
//                noChildrenProb:  noChildrenProbNew,
//                childrenProb:  childrenProbNew,
//                maxChildren:  maxChildrenNew,
//                adoptionWithinProb:  adoptionWithinProbNew,
//                adoptionOutsideProb:  adoptionOutsideProbNew,
//                straightProb:  straightProbNew,
//                queerProb:  queerProbNew,
//                polyProb:  polyProbNew,
//                ifPolyFliptoQueerProb:  ifPolyFliptoQueerProbNew,
//                maxPolyPartner: maxPolyPartnerNew,

//               id: idNew,
//               )
//             ];
//     }
//   void edit({
//           String? nameNew,
//           double? quiteYoungProbNew,
//           double? youngProbNew,
//           double? adultProbNew,
//           double? middleAgeProbNew,
//           double? oldProbNew,
//           double? quiteOldProbNew,
//           double? heHimProbNew,
//           double? sheHerProbNew,
//           double? theyThemProbNew,
//           double? heTheyProbNew,
//           double? sheTheyProbNew,

//           double? partnerWithinProbNew,
//           double? partnerOutsideProbNew,
//           double? breakupProbNew,

//           double? noChildrenProbNew,
//           double? childrenProbNew,
//           int? maxChildrenNew,
//           double? adoptionWithinProbNew,
//           double? adoptionOutsideProbNew,

//           double? straightProbNew,
//           double? queerProbNew,

//           double? polyProbNew,
//           double? ifPolyFliptoQueerProbNew,
//           int? maxPolyPartnerNew,

//           required int replaceID,
//   }){
//             final newState = [...state];
//             final replacementIndex = newState.indexWhere((demoBut) => (demoBut.id) == replaceID);
//             final me=newState[replacementIndex];
//                if(replacementIndex != -1)
//                {
//                 newState[replacementIndex]=
//                 Ancestry(
//                 name: nameNew ?? me.name,
//                quiteYoungProb:  quiteYoungProbNew ?? me.quiteYoungProb,
//                youngProb:  youngProbNew ?? me.youngProb,
//                adultProb:  adultProbNew ?? me.adultProb,
//                middleAgeProb:  middleAgeProbNew ?? me.middleAgeProb,
//                oldProb:  oldProbNew ?? me.oldProb,
//                quiteOldProb:  quiteOldProbNew ?? me.quiteOldProb,
//                heHimProb:  heHimProbNew ?? me.heHimProb,
//                sheHerProb:  sheHerProbNew ?? me.sheHerProb,
//                theyThemProb:  theyThemProbNew ?? me.theyThemProb,
//                heTheyProb:  heTheyProbNew ?? me.heTheyProb,
//                sheTheyProb:  sheTheyProbNew ?? me.sheTheyProb,
//                partnerWithinProb:  partnerWithinProbNew ?? me.partnerWithinProb,
//                partnerOutsideProb:  partnerOutsideProbNew ?? me.partnerOutsideProb,
//                breakupProb:  breakupProbNew ?? me.breakupProb,
//                noChildrenProb:  noChildrenProbNew ?? me.noChildrenProb,
//                childrenProb:  childrenProbNew ?? me.childrenProb,
//                maxChildren:  maxChildrenNew ?? me.maxChildren,
//                adoptionWithinProb:  adoptionWithinProbNew ?? me.adoptionWithinProb,
//                adoptionOutsideProb:  adoptionOutsideProbNew ?? me.adoptionOutsideProb,
//                straightProb:  straightProbNew ?? me.straightProb,
//                queerProb:  queerProbNew ?? me.queerProb,
//                polyProb:  polyProbNew ?? me.polyProb,
//                ifPolyFliptoQueerProb:  ifPolyFliptoQueerProbNew ?? me.ifPolyFliptoQueerProb,
//                maxPolyPartner: maxPolyPartnerNew ?? me.maxPolyPartner,
//                id: replaceID,
//               );
//                }
//               state=newState;
//     }

//   void editDynamic({required int replaceID, required String parameterName, required dynamic parameterValue, required PeopleList peopleNotif, required dynamic oldValue})
//     {
//       switch(parameterName) {
//         case "name":
//         edit(replaceID: replaceID,nameNew: parameterValue);
//         peopleNotif.updateAncestry(oldAncestry: oldValue, newAncestry: parameterValue);
//         break;
//         case "quiteYoungProb":
//           edit(replaceID: replaceID, quiteYoungProbNew: double.parse(parameterValue));
//           break;
//         case "youngProb":
//           edit(replaceID: replaceID, youngProbNew: double.parse(parameterValue));
//           break;
//         case "adultProb":
//           edit(replaceID: replaceID, adultProbNew: double.parse(parameterValue));
//           break;
//         case "middleAgeProb":
//           edit(replaceID: replaceID, middleAgeProbNew: (double.parse(parameterValue)));
//           break;
//         case "oldProb":
//           edit(replaceID: replaceID, oldProbNew: double.parse(parameterValue));
//           break;
//         case "quiteOldProb":
//           edit(replaceID: replaceID, quiteOldProbNew: double.parse(parameterValue));
//           break;
//         case "heHimProb":
//           edit(replaceID: replaceID, heHimProbNew: double.parse(parameterValue));
//           break;
//         case "sheHerProb":
//           edit(replaceID: replaceID, sheHerProbNew: double.parse(parameterValue));
//           break;
//         case "theyThemProb":
//           edit(replaceID: replaceID, theyThemProbNew: double.parse(parameterValue));
//           break;
//         case "heTheyProb":
//           edit(replaceID: replaceID, heTheyProbNew: double.parse(parameterValue));
//           break;
//         case "sheTheyProb":
//           edit(replaceID: replaceID, sheTheyProbNew: double.parse(parameterValue));
//           break;
//         case "partnerWithinProb":
//           edit(replaceID: replaceID, partnerWithinProbNew: double.parse(parameterValue));
//           break;
//         case "partnerOutsideProb":
//           edit(replaceID: replaceID, partnerOutsideProbNew: double.parse(parameterValue));
//           break;
//         case "breakupProb":
//           edit(replaceID: replaceID, breakupProbNew: double.parse(parameterValue));
//           break;
//         case "noChildrenProb":
//           edit(replaceID: replaceID, noChildrenProbNew: double.parse(parameterValue));
//           break;
//         case "childrenProb":
//           edit(replaceID: replaceID, childrenProbNew: double.parse(parameterValue));
//           break;
//         case "maxChildren":
//           edit(replaceID: replaceID, maxChildrenNew: int.parse(parameterValue));
//           break;
//         case "adoptionWithinProb":
//           edit(replaceID: replaceID, adoptionWithinProbNew: double.parse(parameterValue));
//           break;
//         case "adoptionOutsideProb":
//           edit(replaceID: replaceID, adoptionOutsideProbNew: double.parse(parameterValue));
//           break;
//         case "straightProb":
//           edit(replaceID: replaceID, straightProbNew: double.parse(parameterValue));
//           break;
//         case "queerProb":
//           edit(replaceID: replaceID, queerProbNew: double.parse(parameterValue));
//           break;
//         case "polyProb":
//           edit(replaceID: replaceID, polyProbNew: double.parse(parameterValue));
//           break;
//         case "ifPolyFliptoQueerProb":
//           edit(replaceID: replaceID, ifPolyFliptoQueerProbNew: double.parse(parameterValue));
//           break;
//         case "maxPolyPartner":
//           edit(replaceID: replaceID, maxPolyPartnerNew: int.parse(parameterValue));
//           break;
//         default:
//           // Handle unknown parameterName if necessary
//       }

//     }

//     Future<void> addJSON(String jsonString) async
//     {
//       var xList=json.decode(jsonString) as List;
//       for(var i = 0; i < xList.length; i++)
//       {
//         var x = xList[i];
//         print(x["name"]);
//         add(
//             nameNew: x["name"],
//             quiteYoungProbNew: x["quiteYoungProb"],
//             youngProbNew: x["youngProb"],
//             adultProbNew: x["adultProb"],
//             middleAgeProbNew: x["middleAgeProb"],
//             oldProbNew: x["oldProb"],
//             quiteOldProbNew: x["quiteOldProb"],
//             heHimProbNew: x["heHimProb"],
//             sheHerProbNew: x["sheHerProb"],
//             theyThemProbNew: x["theyThemProb"],
//             heTheyProbNew: x["heTheyProb"],
//             sheTheyProbNew: x["sheTheyProb"],
//             partnerWithinProbNew: x["partnerWithinProb"],
//             partnerOutsideProbNew: x["partnerOutsideProb"],
//             breakupProbNew: x["breakupProb"],
//             noChildrenProbNew: x["noChildrenProb"],
//             childrenProbNew: x["childrenProb"],
//             maxChildrenNew: x["maxChildren"],
//             adoptionWithinProbNew: x["adoptionWithinProb"],
//             adoptionOutsideProbNew: x["adoptionOutsideProb"],
//             straightProbNew: x["straightProb"],
//             queerProbNew: x["queerProb"],
//             polyProbNew: x["polyProb"],
//             ifPolyFliptoQueerProbNew: x["ifPolyFliptoQueerProb"],
//             maxPolyPartnerNew: x["maxPolyPartner"],
//             idNew: x["id"],
//           );
//       }
//     }
    
//     Future<String> randomAncestry() async
//     {
//       final int numAncestries = state.length;
//       int r=Random().nextInt(numAncestries);
//       return state[r].name;
//     }
//     Future<String> randomPronouns(String myAncestry) async
//     {
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(pronounToString(state[i].randomPronouns()));
//     }
//     Future<String> randomAge(String myAncestry) async
//     {
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(state[i].randomAge());
//     }
//     Future<String> randomOrientation(String myAncestry) async{
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(orientation2String[state[i].randomOrientationType()]);
//     }
//     Future<String> randomPoly(String myAncestry) async{
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(poly2String[state[i].randomPolyType()]);
//     }
//     Future<PartnerType> randomPartnerType(String myAncestry)
//     {
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(state[i].randomPartnerType());
//     }
//     Future<List<String>> getOtherAncestries(myAncestry) async {
//         return (state.where((s)=> s.name != myAncestry)).map((a)=>a.name).toList();
//     }
//     Future<bool> randomBreakUp(String myAncestry) async {
//       final int i = state.indexWhere((s)=>s.name==myAncestry);
//       return Future.value(state[i].breakup());
//     }
//     Future<int> numPartners({required PolyType myPoly, required myAncestry}) async
//     {
//       switch(myPoly)
//       {
//         case PolyType.poly: return Random().nextInt(state.singleWhere((a)=>a.name==myAncestry).maxPolyPartner)+1;
//         case PolyType.notPoly: return 1;
//       }
//     }
//     Future<List<AdoptionType>> randomChildrenTypes(String myAncestry) async {
//       final myDemo = state.singleWhere((c)=>myAncestry==c.name);
//       List<AdoptionType> myList=[];
//       for(int i=0; i<myDemo.randomNumChildren(); i++)
//       {
//         myList.add(myDemo.randomAdoptionType());
//       }
//       return myList;
//     }
//     Future<AdoptionType> randomAdoption(String myAncestry) async{
//       return state.singleWhere((c)=>c.name==myAncestry).randomAdoptionType(); 
//     }
//     Future<int> maxSpouse(String myAncestry) async
//     {
//       return state.singleWhere((c)=>c.name==myAncestry).maxPolyPartner; 
//     }
// }

// Future<void> makePeople({required int numPeople,
//             required AncestryList demoNotif,
//             required GivenNamesList firstNameNotif,
//             required SurnamesList surnameNotif,
//             required QuirkList quirksNotif,
//             required RAList resonantArgumentNotif,
//             required PeopleList peopleNotif}) async
//             {
//               var myAncestry;
//               var myID;
//               var mawwaige;
//               var otherAncestries;
//               var poly;
//               var myPoly;
//               var childrenTypes;
//               String childID;
//               String luckyOne;
//               int numPartners;
//               List<String> createdPeople=[];
//               List<String> theirAncestries=[];
//               List<PolyType> theirPolyTypes=[];
//               List<String?> partnersAndExes=[];

//               bool breakInUpIsHardToDo=true;
//               String yourID;
//               for(int i =0; i<numPeople; i++)
//               {

//                myAncestry=await demoNotif.randomAncestry();
//                myID=_uuid.v4();
//                createdPeople.add(myID);
//                theirAncestries.add(myAncestry);
//               poly=await demoNotif.randomPoly(myAncestry);
//               theirPolyTypes.add(string2Poly[poly]!);
//               await peopleNotif.createRandomPerson(demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif,
//                                             newAncestry: myAncestry,
//                                             newID: myID,
//                                             newPoly: poly,
//                                             );
//               }

//               for(int i=0; i < createdPeople.length;i++)
//               {
                
//                 myID=createdPeople[i];
//                 myAncestry=theirAncestries[i];
//                 myPoly=theirPolyTypes[i];
//                 numPartners=await demoNotif.numPartners(myPoly: myPoly, myAncestry: myAncestry);
//                 for(int j=0; j<numPartners;j++)
//                 {
//                 breakInUpIsHardToDo=true;
//                 if(await peopleNotif.canMarry(myID))
//                 {
//                   while(breakInUpIsHardToDo)                              
//                   {
//                     mawwaige=await demoNotif.randomPartnerType(myAncestry);
//                     switch(mawwaige){
//                     case PartnerType.sameAncestry:
//                           yourID=await peopleNotif.findASpouse(myID, [myAncestry]);
//                           yourID = await peopleNotif.makePartners(myID: myID, yourID: yourID, demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif);
//                           if(await demoNotif.randomBreakUp(myAncestry))
//                           {peopleNotif.makeExes(myID: myID);}
//                           else
//                           {
//                             breakInUpIsHardToDo=false;
//                           }
//                           break;
//                     case PartnerType.differentAncestry:
//                           otherAncestries= await demoNotif.getOtherAncestries(myAncestry);
//                           yourID = await peopleNotif.findASpouse(myID, otherAncestries);
//                           yourID = await peopleNotif.makePartners(myID: myID, yourID: yourID, demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif);
//                           if(await demoNotif.randomBreakUp(myAncestry))
//                           {peopleNotif.makeExes(myID: myID);}
//                           else
//                           {
//                           breakInUpIsHardToDo=false;
//                           }
//                           break;
//                       case PartnerType.noPartner:
//                           breakInUpIsHardToDo=false;
//                           break;

//                   }
//                   }
//                }
//                }
//                childrenTypes = await demoNotif.randomChildrenTypes(myAncestry);
//                for(AdoptionType c in childrenTypes)
//                {
//                   partnersAndExes=await peopleNotif.partnersAndExes(myID);
//                   if(partnersAndExes.isNotEmpty)
//                   {
//                     luckyOne=partnersAndExes[Random().nextInt(partnersAndExes.length)] ?? "Empty";
//                     }
//                     else
//                     {luckyOne = "Empty";}
//                   switch(c){
//                     case AdoptionType.sameAncestry:
//                         childID=await peopleNotif.adoption([myAncestry]); 
//                         await peopleNotif.makeChildrenParentRelationship(parent1: myID, parent2: luckyOne, child: childID, demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif);
//                         break;
//                       case AdoptionType.differentAncestry:
//                         childID = await peopleNotif.adoption(await demoNotif.getOtherAncestries(myAncestry));
//                         await peopleNotif.makeChildrenParentRelationship(parent1: myID, parent2: luckyOne, child: childID, demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif);
//                         break;
//                       case AdoptionType.noAdoption:
//                         childID=_uuid.v4();
//                         await peopleNotif.createRandomPerson(demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif,
//                         newID: childID,
//                         newAge: age2string[AgeType.quiteYoung],
//                         newAncestry: myAncestry
//                         );
//                         await peopleNotif.makeChildrenParentRelationship(parent1: myID, parent2: luckyOne, child: childID, demoNotif: demoNotif, firstNameNotif: firstNameNotif, surnameNotif: surnameNotif, quirksNotif: quirksNotif, resonantArgumentNotif: resonantArgumentNotif);
//                   }
//                }
//               }
//             }