// import 'package:flutter/foundation.dart' show immutable;
import 'package:firetown/models/json_serializable_abstract_class.dart';
import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';
// import 'package:firetown/edit_helpers.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firetown/enums_and_maps.dart';
// import 'package:firetown/shop_qualities.dart';
// import "shop_names.dart";
import "person_model.dart";
import "../globals.dart";

// part "new_shops.g.dart";

const _uuid=Uuid();

class ShopPerson{
  
  String myID;
  
  Role myRole;
  
  final List<String> myFocus;

  ShopPerson({required this.myID, required this.myRole, List<String>? myFocus}) : myFocus=myFocus??[];
  Map<String,dynamic> toJson()
  {
    return 
      {
        'myID':myID,
        'myRole': myRole.toString().split('.').last,
        'myFocus': myFocus
      }
    ;
  }
  factory ShopPerson.fromJson(String json)
  {
    Map<String,dynamic> data=jsonDecode(json);
    return ShopPerson(
      myID: data["myID"],
      myRole: Role.values.firstWhere((v)=>v.toString().split('.').last==data["myRole"]),
      myFocus: data["myFocus"],
      );
  }
}


@immutable
class ShopQuality implements JsonSerializable
{
  
  final String pro;
  
  final String con;
  
  final ShopType type;
  
  final String id;
  
  
  const ShopQuality
  (
    {
      required this.pro,
      required this.con,
      required this.type,
      required this.id
    }
  );
  @override
  Map<String,dynamic> toJson()
  {
    return {
      'Pro':pro,
      'Con':con,
      'ShopType': type.toString().split('.').last,
      'id':id
    };
  }
    @override
  factory ShopQuality.fromJson(var json)
  {
    final data = (json is String) ? jsonDecode(json) : json;
    return ShopQuality(
      pro: data["Pro"], 
      con: data["Con"],
      type: ShopType.values.firstWhere((v)=>v.toString().split('.').last == data["ShopType"]),
      id: data["id"] ?? _uuid.v4()
      );
  }
  @override
  factory ShopQuality.fromJson2(data)
  {
    return ShopQuality(
      pro: data["pro"] ?? data["Pro"], 
      con: data["con"] ?? data["Con"],
      type: ShopType.values.firstWhere((v)=>v.toString().split('.').last == data["ShopType"]),
      id: data["id"] ?? _uuid.v4()
      );
  }
  @override
  String compositeKey(){return id;}
}


class ShopName implements JsonSerializable
{
  
  final String word;
  
  final ShopType shopType;
  
  final WordType wordType;
  
  final String id;
  
  
  const ShopName
  (
    {
      required this.word,
      required this.shopType,
      required this.wordType,
      required this.id
    }
  );
  @override
  Map<String,dynamic> toJson()
  {
   return {
      "word":word,
      "shopType": shopType.toString().split('.').last,
      "wordType": wordType.toString().split('.').last,
      "id": id,
    };
  }
    @override
  factory ShopName.fromJson(var json)
  {
    final data = (json is String) ? jsonDecode(json) : json;
    return ShopName(
      word: data["word"],
      shopType: ShopType.values.firstWhere((v)=>v.toString().split('.').last==data["shopType"]),
      wordType: WordType.values.firstWhere((v)=>v.toString().split('.').last==data["wordType"]),
      id:data["id"] ?? _uuid.v4(),
    );
  }
  @override
  factory ShopName.fromJson2(Map<String,dynamic> data)
  {
    return ShopName(
      word: data["word"],
      shopType: ShopType.values.firstWhere((v)=>v.toString().split('.').last==data["shopType"]),
      wordType: WordType.values.firstWhere((v)=>v.toString().split('.').last==data["wordType"]),
      id:data["id"] ?? _uuid.v4(),
    );
  }
  @override
  String compositeKey(){return id;}
}



@immutable
class Shop 
{
  
  final String name;
  
  final ShopType shopType;
  
  final List<ShopPerson> myPeople;
  
  final String pro1;
  
  final String pro2;
  
  final String con;

  final String? shopDescription;
  
  final String id;
  
  Shop({required this.name,
      required this.shopType,
      List<ShopPerson>? initPeople,
      required this.pro1,
      required this.pro2,
      required this.con,
      this.shopDescription,
      required this.id,
    } 
  ): myPeople=initPeople ?? [];

  Container printSummary(){
      return Container(
              margin: const EdgeInsets.symmetric(vertical: 8), // Space between sections
              padding: const EdgeInsets.all(12), // Padding inside the box
              decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 150, 220, 194), // Light background color
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        border: Border.all(color: const Color.fromARGB(255, 91, 151, 124))
                        ), // Optional border
              child:
              Column(children:[
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                enum2String(myEnum: shopType),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "$pro1 & $pro2 but $con",
                style: const TextStyle(fontSize: 14),
              ),

            ]));
    }
  List<Widget> printDetail(List<Person> people){
    List<ExpansionTile> peopleWidgets=[];
    var roles=roleLookup[shopType]!.toList();
    Role thisRole;
    String headerString="";
    List<Person> thePeopleInTheRoleHere;
    List<Container> myRoleWidgets;
    for(int i=0; i<roles.length; i++)
    {
      thisRole=roles.elementAt(i);
      thePeopleInTheRoleHere = people.where((p)=>(p.myRoles).map((l)=>(l.myRole==thisRole)&& (l.locationID==id)).contains(true)).toList();
      headerString=enum2String(myEnum: thisRole, plural: thePeopleInTheRoleHere.length>1);
      myRoleWidgets=[];
      for(int j=0; j<thePeopleInTheRoleHere.length;j++)
      {
        myRoleWidgets.add(thePeopleInTheRoleHere[j].printPersonSummary());
      }
      if(myRoleWidgets.isNotEmpty)
      {peopleWidgets.add(ExpansionTile(title: Text(headerString),
               expandedAlignment: Alignment.topLeft,
               expandedCrossAxisAlignment: CrossAxisAlignment.start,
               children: myRoleWidgets,
                ),
               );}
    }

      return [
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                enum2String(myEnum: shopType),
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "$pro1 & $pro2 but $con",
                style: const TextStyle(fontSize: 14),
              ),
              ...peopleWidgets,
            ];
    }
  
  // String toJson(){
  //     return jsonEncode({
  //       'name': name,
  //       'pro1': pro1,
  //       'pro2': pro2,
  //       'con': con,
  //       'id':id,
  //       'shopType': shopType.toString().split('.').last,
  //     });
  // }
  Map<String,dynamic> toJson() {
  return {
    'name': name,
    'pro1': pro1,
    'pro2': pro2,
    'con': con,
    'shopDescription': shopDescription,
    'id': id,
    'shopType': shopType.name, // Correct enum handling
  };
}

  factory Shop.fromJson(String json)
  {
    Map<String,dynamic> data= jsonDecode(json);
    return Shop(
      name: data["name"],
      pro1: data["pro1"],
      pro2: data["pro2"],
      con: data["con"],
      shopDescription: data["shopDescription"],
      id: data["id"],
      shopType: ShopType.values.firstWhere((v)=>v.toString().split('.').last==data["shopType"]),
    );
  }
  // factory Shop.fromOldStyleJson(String json)
  // {
  //   Map<String,dynamic> data= jsonDecode(json);
  //   return Shop(
  //     name: data["Name"],
  //     pro1: data["Pro1"],
  //     pro2: data["Pro2"],
  //     con: data["Con"],
  //     id: data["ID"],
  //     shopType: ShopType.values.firstWhere((v)=>v.toString().toLowerCase().split('.').last==data["shopType"].toString().to),
  //   );
  // }
}

class ShopList extends StateNotifier<List<Shop>>
{
  List<ShopQuality> possibleQualities;
  List<ShopName> possibleNames;
  
  final Box bigShopBox;
  void writeBigBox() async{

    
    for(int i = 0; i<state.length; i++)
    {
     await bigShopBox.put('shop_${state[i].id}', jsonEncode(state[i].toJson()));
    }
    // await bigShopBox.put('initialShops', jsonEncode(state.map((s)=>s.toJson()).toList()));
    for(int i=0; i<possibleQualities.length; i++)
    {
      await bigShopBox.put('quality_${possibleQualities[i].id}', jsonEncode(possibleQualities[i].toJson()));
    }
    for(int i=0; i<possibleNames.length; i++)
    {
      await bigShopBox.put('name_${possibleNames[i].id}', jsonEncode(possibleNames[i].toJson()));
    }
    // await bigShopBox.put('possibleQualities', jsonEncode(possibleQualities.map((q)=>q.toJson()).toList()));
    // await bigShopBox.put('possibleNames', jsonEncode(possibleNames.map((n)=>n.toJson()).toList()));

  }
  ShopList({
    required this.possibleQualities,
    required this.possibleNames,
    required this.bigShopBox,
  }) : super(
    (_shopListConstruction(bigShopBox: bigShopBox))
  )
  {

  // List<String> keys=bigShopBox.keys.where((k)=>k.toString().startsWith("quality_")).cast<String>().toList();
  // possibleQualities=(keys.map((k)=>bigShopBox.get(k)).map((e)=>ShopQuality.fromJson(e))).toList();    

  // keys=bigShopBox.keys.where((k)=>k.toString().startsWith("name_")).cast<String>().toList();        
  //       possibleNames = (keys.map((k)=>bigShopBox.get(k)).map((e)=>ShopName.fromJson(e))).toList();      
  }
 static List<Shop> _shopListConstruction({required Box bigShopBox})
 {
  List<Shop> myShops=[];
  // List<String> keys=bigShopBox.keys.where((k)=>k.toString().startsWith("shop_")).cast<String>().toList();
   myShops=bigShopBox.values.map(((e)=>Shop.fromJson(e))).cast<Shop>().toList();
  return myShops;
  
 }
  Future<void> overwrite(ShopList myOverwrite) async{
    possibleNames=myOverwrite.possibleNames;
    possibleQualities=myOverwrite.possibleQualities;
    state=myOverwrite.state;
  }

  
  Future<Map<String,String>> random3Quirks({required myShopType}) async{
      final applicable = possibleQualities.where((q)=>q.type==myShopType).toList();

      Set<int> randomNumbers={};

      while(randomNumbers.length < 3)
      {
        randomNumbers.add(random.nextInt(applicable.length));
      }
      final my3=randomNumbers.toList();
      return <String,String>{
        "Pro1": applicable[my3[0]].pro,
        "Pro2": applicable[my3[1]].pro,
        "Con": applicable[my3[2]].con
      };

    }



  void add({required String newName,required ShopType newShopType,
            required String newPro1, required String newPro2,required String newCon,
            String? newID, List<ShopPerson>? newPeople}) async{
            
            Shop me=Shop(
                name: newName,
                shopType: newShopType,
                pro1: newPro1,
                pro2: newPro2,
                con: newCon,
                initPeople: newPeople??[],
                id: newID?? _uuid.v4(),
              );
            
            // shopBox.add(me);
            // bigShopBox.put("initialShops",me);

            await bigShopBox.put(me.id, jsonEncode(me.toJson()));
            state=_shopListConstruction(bigShopBox: bigShopBox);
    }


  void edit({String? newName,
             ShopType? newShopType, 
             String? newPro1, 
             String? newPro2, 
             String? newCon,
             String? newShopDescription,
             List<ShopPerson>? newPeople,
             required String replaceID
              }
             )
            async {
               final newState = [...state];
               final replacementIndex = newState.indexWhere((shop) => (shop.id) == replaceID);
               
               if(replacementIndex != -1)
               {
                final oldShop=newState[replacementIndex];
                Shop me=Shop(
                  name: newName?? oldShop.name,
                  shopType: newShopType?? oldShop.shopType,
                  pro1: newPro1 ?? oldShop.pro1,
                  pro2: newPro2 ?? oldShop.pro2,
                  con: newCon ?? oldShop.con,
                  shopDescription: newShopDescription ?? oldShop.shopDescription,
                  initPeople: newPeople?? oldShop.myPeople,
                  id: replaceID
                );
                await bigShopBox.put(me.id, jsonEncode(me.toJson()));
                state=_shopListConstruction(bigShopBox: bigShopBox);
                // state[replacementIndex]=me; //shows edit when backing out.
               }
            }

  Future<void> addJSONoldStyle({required String jsonString,ShopType? myShop}) async
    {
      var xList=json.decode(jsonString) as List;
      List<ShopPerson> myNewPeople;
      for(var i = 0; i < xList.length; i++)
      {
        var x = xList[i];
        switch(myShop)
        {
          case(ShopType.tavern):
            myNewPeople=[...x["OwnerID"].map((id)=>ShopPerson(myID: id, myRole: Role.owner)),
                         ...x["WaitStaff"].map((id)=>ShopPerson(myID: id, myRole: Role.waitstaff)),
                         ...x["Cooks"].map((id)=>ShopPerson(myID: id, myRole: Role.cook)),
                         ...x["Entertainers"].map((id)=>ShopPerson(myID: id, myRole: Role.entertainment)),
                         ...x["Regulars"].map((id)=>ShopPerson(myID: id, myRole: Role.regular)),
                         ];
            break;
          case(ShopType.clothier):
          case(ShopType.herbalist):
          case(ShopType.jeweler):
          case(ShopType.smith):
          default:
            myNewPeople=[...x["Apprentices"].map((id)=>ShopPerson(myID: id, myRole: Role.apprentice)),
          ...x["Journeymen"].map((id)=>ShopPerson(myID: id, myRole: Role.journeyman)),
          ...x["OwnerID"].map((id)=>ShopPerson(myID: id, myRole: Role.owner))]; break;
          
        }
        add(
          newName: x["Name"],
          newShopType: string2Enum(x["Type"]),
          newPro1: x["Pro1"],
          newPro2: x["Pro2"],
          newCon: x["Con"],
          newPeople: myNewPeople,
          newID:x["ID"]
      );
      }
    }

  Future<String> newShopName({required List<String> ownerFirstNames,
                              required List<String> ownerSurnames,
                              required ShopType shopType}) async{
  double r=random.nextDouble();
  bool firstSecond=r<0.65;
  bool ownerFirstShopSecond=r<0.75;
  bool ownerLastShopSecond=r<0.9;
  bool ownerFirstShopFirstShopSecond=r<-0.95;
  bool ownerLastShopFirstShopSecond=r<1;

  List<ShopName> myShopWords=possibleNames.where((n)=>n.shopType==shopType).toList();
  List<String> shopFirstWords=myShopWords.where((w)=>w.wordType==WordType.first).map((w)=>w.word).toList();
  List<String> shopSecondWords=myShopWords.where((w)=>w.wordType==WordType.second).map((w)=>w.word).toList();
  List<String> shopNameWords=myShopWords.where((w)=>w.wordType==WordType.withName).map((w)=>w.word).toList();
  
  String rOwnerFN=ownerFirstNames[random.nextInt(ownerFirstNames.length)];
  String rOwnerLN=ownerSurnames[random.nextInt(ownerSurnames.length)];
  String rShopFW=shopFirstWords[random.nextInt(shopFirstWords.length)];
  String rShopSW=shopSecondWords[random.nextInt(shopSecondWords.length)];
  String rShopNW=shopNameWords[random.nextInt(shopNameWords.length)];
  

  
  if(firstSecond)
  {
    return "$rShopFW $rShopSW";
  }
  if(ownerFirstShopSecond)
  {
    return "$rOwnerFN's $rShopSW";
  }
  if(ownerLastShopSecond)
  {
    return "$rOwnerLN's $rShopSW";
  }
  if(ownerFirstShopFirstShopSecond)
  {
    return "$rOwnerFN's $rShopNW $rShopSW";
  }
  if(ownerLastShopFirstShopSecond)
  {
    return "$rOwnerLN's $rShopNW $rShopSW";
  }
  return "******Shouldn't See This*******";

  }

  // Future<void> createRandomShop({required ShopType shopType, required PeopleList peopleNotif}) async
  // {
    
  //   String myShopID= _uuid.v4();
  //   var myQuirks=await random3Quirks(myShopType: shopType);
  //   String pro1= myQuirks["Pro1"]!;
  //   String pro2= myQuirks["Pro2"]!;
  //   String con = myQuirks["Con"]!;
  //   String newName="";

  //   int staffMultiplier=1;
  //   if({pro1,pro2}.intersection({"Well staffed","Popular"}).isNotEmpty){staffMultiplier=2;}
  //   else if({con}.intersection({"Not well staffed","Unpopular"}).isNotEmpty) {staffMultiplier=0;}

  //   int entertainMultiplier=1;
  //   if({pro1,pro2}.intersection({"Great Music","Great Storytelling"}).isNotEmpty){entertainMultiplier=2;}


  //   bool twoOwners=random.nextDouble()<0.05;
  //   bool familyBusiness=random.nextDouble()<0.5;


    
  //   List<Role> roleTypes=roleLookup[shopType]??defaultRoles;

  //   Role myRole;
  //   int howMany=1;
  //   Set<AgeType> validAges;
  //   Set<AgeType> adultOrMore=AgeType.values.where((at)=>(at).index>=AgeType.adult.index).toSet();
  //   Set<AgeType> children=AgeType.values.where((at)=>(at).index<AgeType.adult.index).toSet();
  //   Set<AgeType> typicalWork={AgeType.adult,AgeType.middleAge,AgeType.old};
  //   List<Person> ownerList=[];
  //   List<Person> familyWorkers=[];
    
  //   Person me;
  //   List<Person> meQueue=[];
  //   List<LocationRole> roleQueue=[];
  //   for(int i=0; i<roleTypes.length; i++)
  //   {
  //     myRole=roleTypes[i];
  //     switch(myRole)
  //     {
  //       case Role.owner:
  //         howMany=1;
  //         if(twoOwners){howMany=2;}
  //         validAges=adultOrMore;
  //         break;
  //       case Role.apprentice:
  //         howMany=1*staffMultiplier;
  //         validAges=children;
  //         break;
  //       case Role.journeyman:
  //         howMany=2*staffMultiplier;
  //         validAges={AgeType.adult};
  //         break;
  //       case Role.entertainment:
  //         howMany=1*staffMultiplier*entertainMultiplier;
  //         validAges=typicalWork;
  //         break;
  //       case Role.regular:
  //         howMany=20;
  //         validAges=adultOrMore;
  //         break;
  //       case Role.customer:
  //         howMany=5;
  //         validAges=adultOrMore;
  //         break;
  //       case Role.cook: 
  //         howMany=1*staffMultiplier;
  //         validAges=typicalWork;
  //         break;
  //       case Role.waitstaff:
  //         howMany=2*staffMultiplier;
  //         validAges=typicalWork;
  //         break;
  //       default: 
  //         howMany=0;
  //         validAges={};
  //     }
      

  //     for(int j=0; j<howMany;j++)
  //     {
  //         // print("$myRole Family Workers: ${familyWorkers.length}");
  //         List<Person> possibleWorkers=await peopleNotif.personWho((p)=>(
  //         (!p.isEmployed())&&validAges.contains(p.age) && !meQueue.contains(p)
  //         ));
  //         List<String> famIDs=familyWorkers.map((f)=>f.id).toList();
  //         if(familyBusiness)
  //         {
  //           List<Person> firstPass=possibleWorkers.where((p)=>famIDs.contains(p.id)).toList();

  //           // print("First Pass # ${firstPass.length}");
  //           if(firstPass.isNotEmpty)
  //           {
  //             me =firstPass[random.nextInt(firstPass.length)];
  //             // print("NEPOTISM BAYBEEEE ${me.id}");
  //           }else
  //           {
  //             me =possibleWorkers[random.nextInt(possibleWorkers.length)];
  //           }
  //         }
  //         else{
  //           me =possibleWorkers[random.nextInt(possibleWorkers.length)];
  //         }
          
  //         if(myRole==Role.owner)
  //         {
  //             ownerList.add(me);
  //         }
          
  //       meQueue.add(me);
  //       roleQueue.add(LocationRole(locationID: myShopID,specialty: "",myRole: myRole));
        

  //       List<Person> mf=await peopleNotif.familyOf(me.id);
  //       for(int k=0; k<mf.length;k++)
  //       {
  //         familyWorkers.add(mf[k]);
  //       }
      
  //     }
      

  //   }
  //   for(int k=0; k<roleQueue.length;k++)
  //   {
  //     me=meQueue[k];
  //     if({Role.owner,Role.cook,Role.entertainment,Role.waitstaff}.contains(roleQueue[k].myRole))
  //     {
  //       List<Person> mf=await peopleNotif.familyOf(me.id);
  //       for(int j=0;j<mf.length;j++)
  //       {
  //         if(!(meQueue.map((m)=>m.id).toSet().contains(mf[j].id)))
  //         {
  //           await peopleNotif.addLocationRoleToPerson(myID: mf[j].id, myRole: LocationRole(locationID: myShopID,myRole: Role.familyOfStaff,specialty: ""));
  //         }
  //       }
  //     }
  //     else if(roleQueue[k].myRole==Role.regular)
  //     {
  //       List<Person> mf=await peopleNotif.familyOf(me.id);
  //       for(int j=0;j<mf.length;j++)
  //       {
  //         if(!(meQueue.map((m)=>m.id).toSet().contains(mf[j].id)))
  //         {
  //           await peopleNotif.addLocationRoleToPerson(myID: mf[j].id, myRole: LocationRole(locationID: myShopID,myRole: Role.familyOfRegular,specialty: ""));
  //         }
  //       }
  //     }
  //     await peopleNotif.addLocationRoleToPerson(myID: me.id,myRole: LocationRole(locationID: myShopID,specialty: "",myRole: roleQueue[k].myRole));
  //   }
  //   newName=await newShopName(ownerFirstNames: ownerList.map((o)=>o.firstName).toList(),
  //    ownerSurnames: ownerList.map((o)=>o.surname).toList(),
  //     shopType: shopType);


  // add(newCon: con,newPro1: pro1,newPro2: pro2,newName:newName,newShopType: shopType,newID:myShopID);
  


    

  // }

  String toJson()
  {
    return jsonEncode({
      'initialShops': state.map((s)=>s.toJson()).toList(),
      'possibleQualities': possibleQualities.map((q)=>q.toJson()).toList(),
      'possibleNames': possibleNames.map((n)=>n.toJson()).toList(),
    });
  }

  // factory ShopList.fromJson(String jsonString) {
  // final Map<String, dynamic> data = jsonDecode(jsonString);

  // var iShop=(data["initialShops"] as List<dynamic>)
  //       .map((shop) => Shop.fromJson(jsonEncode(shop)))
  //       .toList();
  // return ShopList(
  //   initialShops: iShop,
  //   possibleQualities: (data["possibleQualities"] as List<dynamic>)
  //       .map((quality) => ShopQuality.fromJson(jsonEncode(quality)))
  //       .toList(),
  //   possibleNames: (data["possibleNames"] as List<dynamic>)
  //       .map((name) => ShopName.fromJson(jsonEncode(name)))
  //       .toList(),
  // );
  // }
}