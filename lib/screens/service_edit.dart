import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:firetown/personEdit.dart';
// import 'load_json.dart';
import '../providers/barrel_of_providers.dart';
// import 'new_shops.dart';
// import 'person.dart';
// import 'bottombar.dart';
import "../helpers_functions.dart";
import '../models/town_extension/town_locations.dart';
import "../models/location_services_model.dart";
// import "personDetailView.dart";

class ServiceEditItem extends HookConsumerWidget {
  const ServiceEditItem({super.key});
  static const routeName = "/serviceedititem";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final serviceID = arguments?['serviceID'];
    final shopID = arguments?['shopID'];
    ref.read(townProvider);
    final locations = ref.watch(locationsProvider);
    final locationsPN = ref.watch(locationsProvider.notifier);

    Shop shop = locations.firstWhere((ell) => ell.id == shopID) as Shop;
    final services = shop.services;
    final serviceIndex = services.indexWhere((s) => s.id == serviceID);
    final service = services[serviceIndex];

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    // Create a map of field names to their focus nodes and states
    final focusNodes = {
      'description': useFocusNode(),
      'cp': useFocusNode(),
      'sp': useFocusNode(),
      'gp': useFocusNode(),
      'pp': useFocusNode(),
    };

    final isFocused = {
      'description': useIsFocused(focusNodes['description']!),
      'cp': useIsFocused(focusNodes['cp']!),
      'sp': useIsFocused(focusNodes['sp']!),
      'gp': useIsFocused(focusNodes['gp']!),
      'pp': useIsFocused(focusNodes['pp']!),
    };

    // Create a helper function for text fields
    Widget createTextField({
      required String fieldName,
      required String displayName,
      required String initialValue,
      required Function(String) onSave,
      bool isNumeric = false,
    }) {
      return Focus(
        focusNode: focusNodes[fieldName]!,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = initialValue;
          } else {
            onSave(textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            focusNodes[fieldName]!.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title:
              isFocused[fieldName]!
                  ? TextField(
                    autofocus: true,
                    focusNode: textFieldFocusNode,
                    controller: textEditingController,
                    keyboardType:
                        isNumeric ? TextInputType.number : TextInputType.text,
                  )
                  : Text("$displayName: $initialValue"),
        ),
      );
    }

    // Helper function specifically for price fields
    Widget createPriceField({
      required String coinType,
      required String displayName,
      required int value,
    }) {
      return createTextField(
        fieldName: coinType,
        displayName: displayName,
        initialValue: value.toString(),
        isNumeric: true,
        onSave: (newValue) async {
          final newIntValue = int.tryParse(newValue) ?? value;

          // Create a new price object copying all existing values except the one being edited
          final newPrice = Price(
            cp: coinType == 'cp' ? newIntValue : service.price.cp,
            sp: coinType == 'sp' ? newIntValue : service.price.sp,
            gp: coinType == 'gp' ? newIntValue : service.price.gp,
            pp: coinType == 'pp' ? newIntValue : service.price.pp,
          );

          List<Service> newServices = shop.services;
          newServices[serviceIndex].price = newPrice;
          Shop newShop = Shop.fromShop(baseShop: shop, services: newServices);
          locationsPN.replace(shop, newShop);
          await locationsPN.commitChanges();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Stack(
          children: [
            if (Navigator.of(
              context,
            ).canPop()) // Back button if there's a route to go back to
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // Menu functionality to be implemented later
                  },
                ),
              ),
            Center(
              child: Text("${shop.name} : editing a service"),
            ), // Title remains centered
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Description field
            createTextField(
              fieldName: 'description',
              displayName: 'Description',
              initialValue: service.description,
              onSave: (newValue) async {
                List<Service> newServices = shop.services;
                newServices[serviceIndex].description = newValue;
                Shop newShop = Shop.fromShop(
                  baseShop: shop,
                  services: newServices,
                );
                locationsPN.replace(shop, newShop);
                await locationsPN.commitChanges();
              },
            ),

            // Price fields
            createPriceField(
              coinType: 'cp',
              displayName: 'Copper Pieces',
              value: service.price.cp,
            ),
            createPriceField(
              coinType: 'sp',
              displayName: 'Silver Pieces',
              value: service.price.sp,
            ),
            createPriceField(
              coinType: 'gp',
              displayName: 'Gold Pieces',
              value: service.price.gp,
            ),
            createPriceField(
              coinType: 'pp',
              displayName: 'Platinum Pieces',
              value: service.price.pp,
            ),
          ],
        ),
      ),
    );
  }
}
