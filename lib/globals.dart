import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:firetown/demographics.dart';
// import 'package:firetown/tavern.dart';

// import 'shop.dart';
import 'models/person_model.dart';
import 'dart:math';
import "models/town_extension/town_locations.dart";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final currentShop = Provider<Shop>((ref) => throw UnimplementedError());
final currentPerson = Provider<Person>((ref) => throw UnimplementedError());
final currentPartners = Provider<List<Person>>((ref) => throw UnimplementedError());
final currentExes=Provider<List<Person>>((ref) => throw UnimplementedError());
final currentChildren=Provider<List<Person>>((ref) => throw UnimplementedError());



// final currentTavern = Provider<Tavern>((ref) => throw UnimplementedError());
// final currentAncestry = Provider<Ancestry>((ref)=>throw UnimplementedError());

final random=Random();

bool isLoading=true;
bool isDone=false;
    

dynamic randomElement(List<dynamic> myList) {
  if (myList.isNotEmpty) {
    return myList[random.nextInt(myList.length)];
  }
  return null;
}