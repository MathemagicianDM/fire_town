// import "dart:convert";


import "dart:convert";

import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import "package:firetown/demographics_edit_view.dart";
// import "package:firetown/demographics_view.dart";
// import 'package:firetown/navrail.dart';
// import 'providers.dart';
// import 'shop.dart';
// import 'bottombar.dart';
// import "editHelpers.dart";
import "../enums_and_maps.dart";
import "json_serializable_abstract_class.dart";
import "package:uuid/uuid.dart";


const _uuid = Uuid();

@immutable
class Services implements JsonSerializable{
  final String id;
  final String description;
  final String locationID;
  final bool alwaysAvailable;
  final String refreshInterval;
  final int numberAvailable;
  final bool onSale;
  final bool specialty;
  final String specialModifier;
  final bool haggle;
  final bool core20;
  final bool genFan;
  final String haggleRange;
  final String price;
  final bool replace;
  final bool neverAvailable;
  final ServiceType serviceType;

  @override
  String compositeKey(){
    return "$id$locationID";
  }

  const Services({required this.id, required this.description,required this.locationID, required this.alwaysAvailable,
            required this.refreshInterval, required this.numberAvailable, required this.specialty, required this.onSale,
            required this.specialModifier, required this.haggle, required this.core20, required this.genFan,
            required this.haggleRange, required this.price,required this.replace, required this.neverAvailable, required this.serviceType});

  @override
  Map<String,dynamic> toJson(){
    return {
      "id": id,
      "description": description,
      "locationID": locationID,
      "alwaysAvailable": alwaysAvailable,
      "refreshInterval": refreshInterval,
      "numberAvailable": numberAvailable,
      "onSale": onSale,
      "specialty": specialty,
      "specialModifier": specialModifier,
      "haggle": haggle,
      "core20": core20,
      "genFan": genFan,
      "haggleRange": haggleRange,
      "price": price,
      "replace": replace,
      "neverAvailable": neverAvailable,
      "serviceType": serviceType.name,
    };
  }
  factory Services.fromJson(Map<String,dynamic> json){
    return Services(
        alwaysAvailable: (json["alwaysAvailable"] is bool) ? json["alwaysAvailable"] as bool : json["alwaysAvailable"] == "true" ,
        id: json["id"],
        description: json["description"],
        locationID: json["locationID"],
        refreshInterval: json["refreshInterval"],
        numberAvailable: int.parse(json["numberAvailable"]),
        onSale: json["onSale"] is bool ? json["onSale"] as bool : json["onSale"] == "true",
        specialty: json["specialty"] is bool ? json["specialty"] as bool : json["specialty"] == "true",
        specialModifier: json["specialModifier"],
        haggle: json["haggle"] is bool ? json["haggle"] as bool : json["haggle"] == "true",
        core20: json["core20"] is bool ? json["core20"] as bool : json["core20"] == "true",
        genFan: json["genFan"] is bool ? json["genFan"] as bool : json["genFan"] == "true",
        haggleRange: json["haggleRange"],
        price: json["price"],
        replace: json["replace"] is bool ? json["replace"] as bool : json["replace"] == "true",
        neverAvailable: json["neverAvailable"] is bool ? json["neverAvailable"] as bool : json["neverAvailable"] == "true",
        serviceType: ServiceType.values.firstWhere((v)=>v.name==json["serviceType"]),
    );
  }
}

@immutable
class GenericService implements JsonSerializable{

    final String id;
    final String description;
    final List<ShopType> whereAvailable;
    final String refreshInterval;
    final int numberAvailable;
    final bool core20;
    final bool genFan;
    final List<ServiceType> serviceType;
    
    final Price price;

    @override
    String compositeKey(){
      return id;
    }
  
    GenericService({String? id, required this.description, required this.whereAvailable, required this.refreshInterval,
                    required this.numberAvailable, required this.core20, required this.genFan, required this.price, required this.serviceType}):id=id??_uuid.v4();

    @override
    Map<String,dynamic> toJson(){
      return{
        "id":id,
        "description": description,
        "whereAvailable": whereAvailable.map((wA)=>wA.name).toList(),
        "serviceType": serviceType.map((sT)=>sT.name).toList(),
        "refreshInterval": refreshInterval,
        "numberAvailable": numberAvailable,
        "core20": core20,
        "genFan": genFan,
        "price": price.toJson(),
      };
    }

    factory GenericService.fromJson(json){
      json = json is String ? jsonDecode(json) : json;
      return GenericService(
        id: json["id"]?? _uuid.v4(),
        description: json["description"],
        whereAvailable: (json["whereAvailable"] as List<dynamic>).map((e)=> ShopType.values.firstWhere((v)=>v.name==e)).toList(),
        refreshInterval: json["refreshInterval"],
        serviceType: ((json["serviceType"] ?? [])as List<dynamic>).map((e)=>ServiceType.values.firstWhere((v)=>v.name==e)).toList(),
        numberAvailable: json["numberAvailable"] is String ? int.parse(json["numberAvailable"]) : json["numberAvailable"],
        core20: json["core20"] is bool ? json["core20"] as bool: json["core20"] == "true",
        genFan: json["genFan"] is bool ? json["genFan"] as bool: json["genFan"] == "true",
        price: Price.fromJson(json["price"]),
      );
    }

}

@immutable
class Specialty implements JsonSerializable{
  final String id;
  final List<ServiceType> appliesTo;
  final String description;
  final double priceMultiplier;
  const Specialty({required this.id, required this.appliesTo, required this.description, required this.priceMultiplier});

  @override
  String compositeKey(){
    return id;
  }

  @override
  Map<String,dynamic> toJson(){
    return {
      "id":id,
      "appliesTo": appliesTo.map((e)=>e.name).toList(),
      "description":description,
      "priceMultiplier": priceMultiplier,
    };
  }

  factory Specialty.fromJson(json){
    json = json is String ? jsonDecode(json) : json;
    return Specialty(
      id: json["id"] ?? _uuid.v4(),
      appliesTo: (json["appliesTo"] as List).map((v)=>ServiceType.values.firstWhere((f)=>f.name==v)).toList(),
      description: json["description"],
      priceMultiplier: json["priceMultiplier"] is double? json["priceMultiplier"] : double.parse(json["priceMultiplier"]),
    );

  }

  
}


class Price{
  int pp;
  int gp;
  int sp;
  int cp;

  Price({required this.pp, required this.gp, required this.sp, required this.cp});
  Price multiplyPrice(double factor) {
  // Scale each denomination

  // Convert everything to total copper
  int totalCopper = (pp * 1000) +
      (gp * 100) +
      (sp * 10)+
      cp;

  int newCopper = (totalCopper * factor).truncate();

  // Normalize the total copper into denominations
  int fPlat = newCopper ~/ 1000;
  newCopper %= 1000;
  int fGold = newCopper ~/ 100;
  newCopper %= 100;
  int fSilv = newCopper ~/ 10;
  int fCopp = (newCopper % 10);

  return Price(
    cp: fCopp,
    sp: fSilv,
    gp: fGold,
    pp: fPlat,
  );
}
Map<String,dynamic> toJson(){
  return {
    "cp": cp,
    "sp": sp,
    "gp": gp,
    "pp": pp
  };
}
factory Price.fromJson(json){
  return Price(
    cp: json["cp"] is int ? json["cp"] : int.parse(json["cp"]),
    sp: json["sp"] is int ? json["sp"] : int.parse(json["sp"]),
    gp: json["gp"] is int ? json["gp"] : int.parse(json["gp"]),
    pp: json["pp"] is int ? json["pp"] : int.parse(json["pp"])
  );
}
@override
String toString(){
  String output="";
  output = pp > 0 ? "$pp pp" : output;

  if(output == "" && gp > 0){
    output = "$gp gp";
  }else if(gp>0){
    output = "$output, $gp gp";
  }
  if(output == "" && sp > 0){
    output = "$sp sp";
  }else if(sp>0){
    output = "$output, $sp sp";
  }
  if(output == "" && cp > 0){
    output = "$cp cp";
  }else if(cp>0){
    output = "$output, $cp cp";
  }
  return output;
  }
}