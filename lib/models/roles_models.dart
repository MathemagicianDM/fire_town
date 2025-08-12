// import "dart:convert";


import "package:firetown/providers/role_meta_provider.dart";
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import "package:firetown/demographics_edit_view.dart";
// import 'shop.dart';
// import 'bottombar.dart';
// import "editHelpers.dart";
import "../enums_and_maps.dart";
import "json_serializable_abstract_class.dart";




// Create the RoleProvider
final roleServiceProvider = Provider<RoleService>((ref) {
  final roleMetas = ref.watch(roleMetaProvider);
  return RoleService(roleMetas);
});

class RoleService {
  final List<RoleGeneration> _roleMetas;
  
  RoleService(this._roleMetas);
  final Set<Role> _shopRolesSet = {Role.apprentice, Role.journeyman,
                         Role.herbalist, Role.generalStoreOwner,Role.jeweler, Role.acolyte, Role.hierophant,
                         Role.magicShopOwner, Role.smith, Role.tailor, Role.customer, Role.owner
  };

  final Set<Role> _govRoleSet = {Role.government, Role.townGuard, Role.minorNoble};

  final Set<Role> _templeRoleSet = {Role.hierophant, Role.acolyte, Role.regular};
  // All shop/market roles
  
  List<Role> get templeRoles => _templeRoleSet.toList();


  final  Set<Role> _tavernRoleSet = {Role.tavernKeeper, Role.waitstaff, Role.cook, Role.entertainment, Role.regular};
  // All shop/market roles
  
  List<Role> get tavernRoles => _tavernRoleSet.toList();

   List<Role> get govRoles => _govRoleSet.toList();
  

  List<Role> get shopRoles => _shopRolesSet.toList();
  
  // All informational roles
  List<Role> get informationalRoles => _roleMetas.where((role) => role.informational)
  .map((rg)=>rg.thisRole).toList()
  ..sort((a, b) => enum2String(myEnum: a).compareTo(enum2String(myEnum: b)));
  
  // Priority tavern roles
  List<Role> get priorityTavernRoles => _roleMetas.where(
    (role) => role.promoteInTaverns && role.priorityInTaverns
  )
  .map((rg)=>rg.thisRole).toList()
  ..sort((a, b) => enum2String(myEnum: a).compareTo(enum2String(myEnum: b)));
  
  // Hireling roles
  List<Role> get hirelingRoles => _roleMetas.where((role) => role.hireling)
  .map((rg)=>rg.thisRole).toList()
  ..sort((a, b) => enum2String(myEnum: a).compareTo(enum2String(myEnum: b)));
  

  List<Role> get marketRoles => _roleMetas.where((role) => role.showInMarket)
  .map((rg)=>rg.thisRole).toList()
  ..sort((a, b) => enum2String(myEnum: a).compareTo(enum2String(myEnum: b)));

  List<Role> get otherRoles => _roleMetas.where((role) => ![...shopRoles, ...informationalRoles, ...hirelingRoles,...marketRoles,...govRoles].contains(role.thisRole))
  .map((rg)=>rg.thisRole).toList()
  ..sort((a, b) => enum2String(myEnum: a).compareTo(enum2String(myEnum: b)));

  List<Role> get hideDropDownRoles => 
   [ ...informationalRoles,
     ...hirelingRoles,
     ...marketRoles,
     ...govRoles
     ]..removeWhere((r)=>shopRoles.contains(r));

  // Get roles by age type
  List<RoleGeneration> getRolesByAge(AgeType ageType) {
    return _roleMetas.where((role) => role.validAges.contains(ageType)).toList();
  }

  List<DropdownMenuItem> makeDropDownEntries(String headerString, String headerOutput, List<Role> roleList){
    List<DropdownMenuItem> dropDown =[
      DropdownMenuItem<String>(
                              value: headerString,
                              enabled: false,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  headerOutput,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
    ];
    dropDown.addAll(roleList.map((e) => DropdownMenuItem<String>(
                  value: "${e.name};$headerString",
                  child: Text(enum2String(myEnum: e)),
                )).toList());
    return dropDown;
  }
  
  List<DropdownMenuItem> makeDropDownEntriesForAddRole(){
   
    List<DropdownMenuItem> output =[];
    output.addAll(makeDropDownEntries("header_shop","----Roles for Shops----",shopRoles));
    output.addAll(makeDropDownEntries("header_tavern","----Roles that show up in taverns----",tavernRoles));
    output.addAll(makeDropDownEntries("header_temple","----Roles for Temples----",templeRoles));
    output.addAll(makeDropDownEntries("header_hireling","----Roles that show up as hirelings----",hirelingRoles));
    output.addAll(makeDropDownEntries("header_market","----Roles that show up in markets----",marketRoles));
    output.addAll(makeDropDownEntries("header_informational","----Roles that might provide information/research----",informationalRoles));
    output.addAll(makeDropDownEntries("header_other","----Other Roles----",otherRoles));
    return output;
  }
  // Get customer priority roles
  List<RoleGeneration> get customerPriorityRoles => _roleMetas.where(
    (role) => role.prioritizeCustomer
  ).toList();
  
  // Find a role by singular name
  RoleGeneration? findRoleBySingular(String name) {
    try {
      return _roleMetas.firstWhere((role) => role.singular.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
  
  // Find roles with a specific distribution rate
  List<RoleGeneration> getRolesByDistribution(int onePerHowMany) {
    return _roleMetas.where((role) => role.onePerHowMany == onePerHowMany).toList();
  }
}



class RoleGeneration implements JsonSerializable{
   Role thisRole;
   int onePerHowMany;
   bool hireling;
   bool promoteInTaverns;
   bool showInMarket;
   bool priorityInTaverns;
   bool informational;
   String singular;
   String plural;
   List<AgeType> validAges;
   bool prioritizeCustomer;
   RoleGeneration({required this.thisRole, required this.onePerHowMany,required this.hireling,required this.promoteInTaverns,required this.priorityInTaverns, required this.showInMarket, required this.prioritizeCustomer, required this.validAges, required this.informational, required this.singular, required this.plural});
  
  @override
  String compositeKey() {
    return thisRole.name;
  }
   @override
  Map<String,dynamic> toJson(){
    return {
      "thisRole": thisRole.name,
      "onePerHowMany": onePerHowMany,
      "hireling": hireling,
      "promoteInTaverns": promoteInTaverns,
      "priorityInTaverns": priorityInTaverns,
      "showInMarket": showInMarket,
      "prioritizeCustomer":prioritizeCustomer,
      "informational":informational,
      "validAges": validAges.map((va)=>va.name).toList(),
      "singular": singular,
      "plural": plural
   };
   }

factory RoleGeneration.fromJson(Map<String, dynamic> json) {
  return RoleGeneration(
    thisRole: Role.values.firstWhere((v)=> v.name==json["thisRole"]),
    validAges: json["validAges"]==null ?
      [] : (json["validAges"] as List).map((j)=>AgeType.values.firstWhere((v)=>v.name==j)).toList(),
    onePerHowMany: json["onePerHowMany"] is int
        ? json["onePerHowMany"] as int
        : int.parse(json["onePerHowMany"] as String),
    hireling: json["hireling"] is bool ?
    json["hireling"] as bool : json["hireling"] == "true",
    informational: json["informational"] is bool ?
    json["informational"] as bool : json["informational"] == "true",
    promoteInTaverns: json["promoteInTaverns"] is bool ?
    json["promoteInTaverns"] as bool : json["promoteInTaverns"] == "true",

    priorityInTaverns: json["priorityInTaverns"]is bool ?
    json["priorityInTaverns"] as bool : json["priorityInTaverns"]== "true",
    showInMarket: json["showInMarket"] is bool?
    json["priorityInTaverns"] as bool : json["priorityInTaverns"]== "true",
    prioritizeCustomer: json["prioritizeCustomer"] is bool?
    json["prioritizeCustomer"] as bool : json["prioritizeCustomer"]== "true",
    
    singular: json["singular"]??"Singular",
    plural: json["plural"]??"Plural"
  );
}
}

