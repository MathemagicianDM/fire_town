import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
// import 'package:firetown/personEdit.dart';
// import 'load_json.dart';
import '../providers/barrel_of_providers.dart';
// import 'new_shops.dart';
// import 'person.dart';
// import 'bottombar.dart';
import "../globals.dart";
import "../helpers_functions.dart";
import '../models/town_extension/town_locations.dart';
// import "personDetailView.dart";


class ShopEditView extends HookConsumerWidget {
  const ShopEditView({super.key,ar});
  static const routeName="/shopeditview";
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final myID = arguments?['myID'];
    
    final shops = ref.watch(filteredShops);

    final shopIndex=shops.indexWhere((shop)=> shop.id==myID);
    
    
    
    return Scaffold(
    appBar: AppBar(
      title: Text("Edit Mode for ${shops[shopIndex].name}\nClick any field to edit, it will autosave "),
    ),
      body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [const Navrail(),const VerticalDivider(),
          Expanded( child: SingleChildScrollView(
            child:
        Column(
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const SizedBox(height: 42),
            ProviderScope(
                overrides:[currentShop.overrideWithValue(shops[shopIndex])],
                child: const ShopEditItem(),
            )
            ],
        ),
      ),
    )
    ]))));
  }
}

class ShopEditItem extends HookConsumerWidget {
  const ShopEditItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(currentShop);
    // final shopSearchNotif=ref.read(ref.read(townProvider).locationSearch.notifier);
    final nameFocusNode = useFocusNode();
    final nameIsFocused = useIsFocused(nameFocusNode);

    final pro1FocusNode = useFocusNode();
    final pro1IsFocused = useIsFocused(pro1FocusNode);

    final pro2FocusNode = useFocusNode();
    final pro2IsFocused = useIsFocused(pro2FocusNode);

    final conFocusNode = useFocusNode();
    final conIsFocused = useIsFocused(conFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    final locationsPN = ref.watch(locationsProvider.notifier);
  return Material(
      color: Colors.white,
      elevation: 6,
      child: Column(
        children: [
      Focus(
        focusNode: nameFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = shop.name;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            // shopSearchNotif.edit(shop.name,textEditingController.text,shop.id);
            locationsPN.replace(shop, Shop.fromShop(baseShop: shop,name: textEditingController.text));
            locationsPN.commitChanges();
            //                                          newName: textEditingController.text,
            //                                          );
          }
        },
        child: ListTile(
          onTap: () {
            nameFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: nameIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text("Name: ${shop.name}"),
        ),
      ),
      Focus(
        focusNode: pro1FocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = shop.pro1;
          } else {
            // shopSearchNotif.edit(shop.pro1,textEditingController.text,shop.id);
            locationsPN.replace(shop, Shop.fromShop(baseShop: shop,pro1: textEditingController.text));
            locationsPN.commitChanges();
          }
        },
        child: ListTile(
          onTap: () {
            pro1FocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: pro1IsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text("Pro 1: ${shop.pro1}"),
        ),
      ),
      Focus(
        focusNode: pro2FocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = shop.pro2;
          } else {
            // shopSearchNotif.edit(shop.pro2,textEditingController.text,shop.id);
            locationsPN.replace(shop, Shop.fromShop(baseShop: shop,pro2: textEditingController.text));
            locationsPN.commitChanges();

          }
        },
        child: ListTile(
          onTap: () {
            pro2FocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: pro2IsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text("Pro 2: ${shop.pro2}"),
        ),
      ),
       Focus(
        focusNode: conFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = shop.con;
          } else {
            // shopSearchNotif.edit(shop.con,textEditingController.text,shop.id);
            locationsPN.replace(shop, Shop.fromShop(baseShop: shop,con: textEditingController.text));
            locationsPN.commitChanges();
            // ref.read(ref.read(townProvider).locationsListProvider.notifier).replace(replaceID: shop.id,
            //                                              replacement: Shop.fromShop(baseShop: shop,con: textEditingController.text));
          }
        },
        child: ListTile(
          onTap: () {
            conFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: conIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text("but, Con: ${shop.con}"),
        ),
      ),
      
        ]
      
  )
  );
  }
}

Focus focusedText(String textInitial, String textDisplay, Shop shop, var ref, var myNode,var isFocused, TextEditingController textEditingController, var textFieldFocusNode)
{
  return Focus(
        focusNode: myNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = textInitial;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            ref.read(ref.read(townProvider).locationsListProvider.notifier).replace(replaceID: shop.id,
                                                         replacement: Shop.fromShop(baseShop: shop,name: textEditingController.text));
          }
        },
        child: ListTile(
          onTap: () {
            myNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(textDisplay),
        ),
      );
}
