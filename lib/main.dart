// import "dart:convert";

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "package:firetown/screens/demographics_builder_screen.dart";
import "package:firetown/screens/hirelings_screen.dart";
import "package:firetown/screens/generate_town_screen.dart";
import "package:firetown/screens/market_screen.dart";
// import "package:firetown/demographics_edit_view.dart";
// import "package:firetown/demographics_view.dart";
// import 'package:firetown/navrail.dart';
import 'package:firetown/screens/person_edit.dart';
import "package:firetown/screens/service_edit.dart";
// import 'providers.dart';
// import 'shop.dart';
// import 'bottombar.dart';
import "globals.dart";
// import "editHelpers.dart";
import "screens/person_detail_view.dart";
import "screens/people_view.dart";
import "screens/shops_view.dart";
import "screens/shop_edit_view.dart";
import "screens/shop_detail_view.dart";
import "screens/home.dart";
import "screens/sages_view.dart";
import "screens/search_page.dart";
import "screens/government_screen.dart";

import 'firebase_options.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'screens/auth_wrapper.dart';
import 'screens/phoneme_management_page.dart';
import 'screens/ancestry_management_page.dart';
import 'screens/encounter_builder_page.dart';
import 'screens/admin_panel.dart';
import 'screens/template_manager_page.dart';



// import "tavern_view.dart";
// import "tavern_detail_view.dart";
// import "tavern_edit_view.dart";



/// Keys for components for testing

final addTodoKey = UniqueKey();

// coverage:ignore-start
void main() async {
  
  
  // await Hive.initFlutter();
  // await initAllBoxes();
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

// await Hive.openBox<String>('shopListBox');
// await Hive.openBox<String>('ancestryBox');
// await Hive.openBox<String>('resArgBox');
// await Hive.openBox<String>('givenNameBox');
// await Hive.openBox<String>('surnameBox');
// await Hive.openBox<String>('quirkBox');
// await Hive.openBox<String>('shopNameBox');
// await Hive.openBox<String>('shopQualityBox');
// await Hive.openBox<String>("peopleSearchBox");
// await Hive.openBox<String>("locSearchBox");
// await Hive.openBox<String>("bigShopBox");
// await Hive.openBox<String>("townBox");
// Box gsBox =await  Hive.openBox<String>("genericServiceBox");
// Box sBox = await Hive.openBox<String>("specialtyBox");
// var roleBox = await  Hive.openBox<String>("roleBox");
// // await Hive.openBox<String>("relationshipBox");

// // Box peopleBox = await Hive.openBox<String>("peopleBox");


// Box bsBox= await Hive.openBox<String>("bigShopBox");

// Box relationshipBox=await Hive.openBox<String>("relationshipBox");
// Box locationsRoleBox = await Hive.openBox<String>("locationsRoleBox");
// Box locbox = await Hive.openBox<String>("locbox");
// await Hive.openBox<String>("pendingRolesBox");

// var prevInRoleBox=roleBox.values.map((e)=>RoleGeneration.fromJson((jsonDecode(e)))).cast<RoleGeneration>().toList();
// var prevInGSBox = gsBox.values.map((e)=>GenericService.fromJson((jsonDecode(e)))).cast<GenericService>().toList();
// var prevInSBox = sBox.values.map((e)=>Specialty.fromJson((jsonDecode(e)))).cast<Specialty>().toList();
// print("igh");

// var previouslyInPeoplepBox=peopleBox.values.map((e)=>Person.fromJson((e))).cast<Person>().toList();

// var theRelationships = relationshipBox.values.map((v)=>Node.fromJson(v)).cast<Node>().toList();
// var theNotPolyPeople = previouslyInPeoplepBox.where((p)=>p.poly==PolyType.notPoly).toList();
// var thePolyPeople = previouslyInPeoplepBox.where((p)=>p.poly==PolyType.poly).toList();
// var theirRelationships=theRelationships.where((n) => theNotPolyPeople.map((p)=>p.id).contains(n.id)).toList();
// var theBaddiesIDs=theirRelationships.where((n)=>n.relPairs.where((e)=>
// e.iAmYour==RelationshipType.partner).toList().length>1).map((e)=>e.id);
// var theBaddies=theNotPolyPeople.where((p)=>theBaddiesIDs.contains(p.id)).toList();
// var theBaddiesRelationships=theRelationships.where((n)=>theBaddiesIDs.contains(n.id)).toList();
// (p.countPartner()>1)&&p.poly==PolyType.notPoly);

// print("Hap");
// await freshTownFromJSON();
// await resetFromOldJSON();


// await setupRoleGenGox();
// print("hi");


// var ogGet=Hive.box<String>('bigShopBox').get("possibleQualities");

// var decodedOgGet=;
// var x=decodedOgGet.elementAt(0);
// var sqj=jsonEncode(x);
// var sq=ShopQuality.fromJson(sqj);

// List<ShopQuality> sql = await (jsonDecode(Hive.box<String>('bigShopBox').get("possibleQualities") as List<dynamic>??"[]"))
//         .map((e) => ShopQuality.fromJson(jsonEncode(e))).toList();
    

  runApp(const ProviderScope(child: App()));
}
// coverage:ignore-end

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // home: Home(),
      // initialRoute: Home.routeName,
      restorationScopeId: 'app',
      // routes:{
      //   PersonEditView.routeName : (context) => const PersonEditView(),
      //   PersonDetailView.routeName : (context) => const PersonDetailView(),
      //   PeopleView.routeName: (context) => const PeopleView(),
      //   ShopsView.routeName: (context) => const ShopsView(),
      //   ShopEditView.routeName: (context) => const ShopEditView(),
      //   ShopDetailView.routeName: (context) => const ShopDetailView(),
      //   Home.routeName: (context) => const Home(),
      // },
    onGenerateRoute: (RouteSettings routeSettings) {
      return MaterialPageRoute<void>(
        settings: routeSettings,
        builder: (context)  { switch(routeSettings.name){
                                // case TavernsView.routeName : return const TavernsView();
                                // case TavernDetailView.routeName : return const TavernDetailView();
                                // case TavernEditView.routeName : return const TavernEditView();
                                case PersonEditView.routeName : return const PersonEditView();
                                
                                case PersonDetailView.routeName : return const PersonDetailView();
                                case PeopleView.routeName: return const PeopleView();
                                case ShopsView.routeName: return const ShopsView();
                                case ShopEditView.routeName: return const ShopEditView();
                                case ShopDetailView.routeName: return const ShopDetailView();
                                case ShopDetailTabbed.routeName: return const ShopDetailTabbed();
                                
                                case Home.routeName: return const Home();

                                case DemoDetermineStateful.routeName: return DemoDetermineStateful();
                                case SagesView.routeName: return SagesView();
                                case HirelingsView.routeName: return HirelingsView();
                                case MarketView.routeName: return MarketView();
                                case TownGeneratorPage.routeName: return TownGeneratorPage();
                                case SearchPage.routeName: return SearchPage();
                                case ServiceEditItem.routeName: return ServiceEditItem();
                                // case GovernmentViewer.routeName: return GovernmentViewer();
                                // case GovernmentPositionSelectorPage.routeName: return GovernmentPositionSelectorPage();
                                case GovernmentView.routeName: return GovernmentView();
                                // case SyllabusManagementPage.routeName: return SyllabusManagementPage();
                                case PhonemeManagementPage.routeName: return PhonemeManagementPage();
                                case AncestryManagementPage.routeName: return AncestryManagementPage();
                                case EncounterBuilderPage.routeName: return EncounterBuilderPage();
                                case AdminPanel.routeName: return AdminPanel();
                                case TemplateManagerPage.routeName: return TemplateManagerPage();
                                // case DemographicsView.routeName: return const DemographicsView();
                                // case DemographicsEditView.routeName: return const DemographicsEditView();
                                // default: return const Home();
                                default: return const AuthWrapper();
                                }
                            }
                                
    );
    },
      // switch (settings.name) {
      //   case Home.routeName:
      //     return MaterialPageRoute(
      //       builder: (context) => const Home(),
      //       settings: settings,
      //     );
      //     case ShopsView.routeName:
      //     return MaterialPageRoute(builder: (context)=> const ShopsView(), settings: settings);
      //   default: 
      //     return MaterialPageRoute(builder: (context) => const Home(),settings: settings);
      // }
      // onGenerateRoute: (RouteSettings routeSettings) {     
      //       return MaterialPageRoute<void>(
      //         settings: routeSettings,
      //         builder: (BuildContext context) {
      //           switch (routeSettings.name) {
      //             case PersonDetailView.routeName:
      //               return PersonDetailView();
      //             case PeopleView.routeName:
      //               return PeopleView();
      //             case ShopEditView.routeName:
      //             return ShopEditView();
      //             case HomeData.routeName:
      //               return HomeData();
      //             case ShopView.routeName:
      //               return ShopView();
      //             default:
      //               return Home();
      //           }
      //         },
            // );
          // }
    );
  }
}




