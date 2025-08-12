import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "../globals.dart";
import "../helpers_functions.dart";
import "../enums_and_maps.dart";
import "navrail.dart";
import "../providers/barrel_of_providers.dart";
import "../models/barrel_of_models.dart";

class PersonEditView extends HookConsumerWidget {
  const PersonEditView({super.key, ar});
  static const routeName = "/personeditview";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final myID = arguments?['myID'];

    final people = ref.watch(peopleProvider);

    final peopleIndex = people.indexWhere((p) => p.id == myID);

    Person me = people[peopleIndex];

    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Edit Mode for ${me.firstName} ${me.surname} \nClick any field to edit: saves are automatic"),
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
                body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Navrail(),
                  const VerticalDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        children: [
                          const SizedBox(height: 42),
                          ProviderScope(
                            overrides: [currentPerson.overrideWithValue(me)],
                            child: const PersonEditItem2(),
                          )
                        ],
                      ),
                    ),
                  )
                ]))));
  }
}

class PersonEditItem2 extends HookConsumerWidget {
  const PersonEditItem2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentPerson);
    final peoplePN =
        ref.watch(peopleProvider.notifier);
    // final peopleSearchNotif =
        // ref.watch(ref.read(townProvider).peopleSearch.notifier);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    // Define focus nodes and states dynamically


    // Generic text field helper
    Widget createTextField({
      required String fieldName,
      required String displayName,
      required String initialValue,
      required Function(String) onSave,
    }) {
      final focusNode = useFocusNode();
      final isFocused = useIsFocused(focusNode);

      return Focus(
        focusNode: focusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = initialValue;
          } else {
            onSave(textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            focusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text("$displayName: $initialValue"),
        ),
      );
    }

    // Dropdown menu for AgeType
    Widget createDropdownAgeType({
      required String displayName,
      required AgeType initialValue,
      required Function(AgeType) onSave,
    }) {
      return ListTile(
        title: Row(
          children: [
            Text("$displayName: "),
            SizedBox(
              width: 150, // Adjust width here
              child: DropdownButtonFormField<AgeType>(
                value: initialValue,
                items: AgeType.values.map((AgeType age) {
                  return DropdownMenuItem<AgeType>(
                    value: age,
                    child: Text(age2string[age]!),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onSave(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget createDropdownPronounType({
      required String displayName,
      required PronounType initialValue,
      required Function(PronounType) onSave,
    }) {
      return ListTile(
        title: Row(
          children: [
            Text("$displayName: "),
            SizedBox(
              width: 150, // Adjust width here
              child: DropdownButtonFormField<PronounType>(
                value: initialValue,
                items: PronounType.values.map((PronounType p) {
                  return DropdownMenuItem<PronounType>(
                    value: p,
                    child: Text(pronounToString(p)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onSave(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Column(
        children: [
          createTextField(
            fieldName: 'firstName',
            displayName: 'First Name',
            initialValue: me.firstName,
            onSave: (newValue) async {
              // peopleSearchNotif.edit(me.firstName, newValue, me.id);
              final newme = me.copyWith(firstName : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createTextField(
            fieldName: 'surname',
            displayName: 'Surname',
            initialValue: me.surname,
            onSave: (newValue) async{
              final newme = me.copyWith(surname : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createTextField(
            fieldName: 'ancestry',
            displayName: 'Ancestry',
            initialValue: me.ancestry,
            onSave: (newValue) async {
              final newme = me.copyWith(ancestry : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createDropdownPronounType(
            displayName: 'Pronouns',
            initialValue: me.pronouns,
            onSave: (newValue) async {
              final newme = me.copyWith(pronouns : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createDropdownAgeType(
            displayName: 'Age',
            initialValue: me.age,
            onSave: (newValue) async {
              final newme = me.copyWith(age : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createTextField(
            fieldName: 'quirk1',
            displayName: 'Quirk 1',
            initialValue: me.quirk1,
            onSave: (newValue) async {
              // peopleSearchNotif.edit(me.quirk1, newValue, me.id);
              final newme = me.copyWith(quirk1 : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createTextField(
            fieldName: 'quirk2',
            displayName: 'Quirk 2',
            initialValue: me.quirk2,
            onSave: (newValue) async {
              // peopleSearchNotif.edit(me.quirk2, newValue, me.id);
              final newme = me.copyWith(quirk2 : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          createTextField(
            fieldName: 'resonantArgument',
            displayName: 'Resonant Argument',
            initialValue: me.resonantArgument,
            onSave: (newValue) async {
              // peopleSearchNotif.edit(me.resonantArgument, newValue, me.id);
              final newme = me.copyWith(resonantArgument : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),

          createTextField(
            fieldName: 'faction',
            displayName: 'Faction',
            initialValue: me.faction,
            onSave: (newValue) async {
              final newme = me.copyWith(faction : newValue);
              peoplePN.replace(me, newme);
              await peoplePN.commitChanges();
            },
          ),
          // Add a divider before the role editor section
          Divider(height: 32, thickness: 1),

          // Add the role editor section
          buildRoleEditor(
            person: me,
            ref: ref,
          ),
        ],
      ),
    );
  }
}

// Add this to your PersonEditItem2 class after the existing fields section

// Widget to manage a person's roles across locations
Widget buildRoleEditor({
  required Person person,
  required WidgetRef ref,
}) {
  ref.watch(townProvider);
  final locationRoles = ref.watch(locationRolesProvider);
  // ref.watch(town.locationsListProvider);
  // ref.watch(ref.read(myWorldProvider).allRoles.notifier);
  // ref.watch(town.locationRoleListProvider.notifier);

  // Get all roles for this person
  final personRoles = locationRoles
      .where((lr) =>
          lr.myID == person.id &&
          !{marketID, hirelingID, informationalID}.contains(lr.locationID))
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Roles & Locations",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      // List existing roles
      ...personRoles.map((role) => buildRoleItem(
            role: role,
            person: person,
            ref: ref,
          )),
      // Add new role button
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text("Add New Role"),
          onPressed: () {
            // Show dialog to add a new role
            showDialog(
              context: navigatorKey.currentContext!,
              builder: (context) => AddRoleDialog(
                person: person,
                ref: ref,
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Widget to display a single role item with edit/delete options
Widget buildRoleItem({
  required LocationRole role,
  required Person person,
  required WidgetRef ref,
}) {
  ref.watch(townProvider);
  final locationRolesPN =
      ref.watch(locationRolesProvider.notifier);

  final allLocations = ref.watch(locationsProvider);
  final roleMetaPN = ref.read(roleMetaProvider.notifier);

  // Find location for this role
  final location = allLocations.firstWhere(
    (loc) => loc.id == role.locationID,
    orElse: () => Location(
      myID: "unknown",
      name: "unknown",
      locType: LocationType.info,
    ),
  );

  return Card(
    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Role info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleMetaPN.getString(role.myRole),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  location.name != "unknown"
                      ? "${location.name} (${_getLocationTypeString(location)})"
                      : "Profession",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // Actions
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Show dialog to edit this role
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (context) => EditRoleDialog(
                  person: person,
                  role: role,
                  ref: ref,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: navigatorKey.currentContext!,
                builder: (context) => AlertDialog(
                  title: Text("Remove Role"),
                  content: Text(
                      "Remove ${person.firstName} from role of '${roleMetaPN.getString(role.myRole)}' at ${location.name}?"),
                  actions: [
                    TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    TextButton(
                      child: Text("Remove"),
                      onPressed: () async {
                        // Remove the role

                         locationRolesPN
                            .removeByKey(role.compositeKey());
                            await locationRolesPN.commitChanges();

                        navigatorKey.currentState!.pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

// Helper function to get a readable string for location type
String _getLocationTypeString(Location location) {
  if (location.locType == LocationType.shop) {
    final shop = location as Shop;
    switch (shop.type) {
      case ShopType.smith:
        return "Smithy";
      case ShopType.clothier:
        return "Clothier";
      case ShopType.herbalist:
        return "Herbalist";
      case ShopType.jeweler:
        return "Jeweler";
      case ShopType.generalStore:
        return "General Store";
      case ShopType.magic:
        return "Magic Shop";
      case ShopType.temple:
        return "Temple";
      case ShopType.tavern:
        return "Tavern";
    }
  }
  return "Location";
}

// Dialog to add a new role
class AddRoleDialog extends StatefulWidget {
  final Person person;
  final WidgetRef ref;

  const AddRoleDialog({
    super.key,
    required this.person,
    required this.ref,
  });

  @override
  _AddRoleDialogState createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<AddRoleDialog> {
  String? selectedRole;
  String? selectedLocationId;
  bool showCreateShopOption = false;
  bool hideLocationDropdown = false;
  Map<ShopType, List<Location>> shopsByType = {};
  List<Location> otherLocations = [];

  @override
  void initState() {
    super.initState();
    _organizeLocations();
  }

  void _organizeLocations() {
    widget.ref.watch(townProvider);
    final allLocations = widget.ref.watch(locationsProvider);

    // Group shops by type
    shopsByType = {};
    otherLocations = [];

    for (var location in allLocations) {
      if (location.locType == LocationType.shop) {
        final shop = location as Shop;
        shopsByType.putIfAbsent(shop.type, () => []).add(shop);
      } else {
        otherLocations.add(location);
      }
    }
  }

  // Filter locations based on selected role
  List<DropdownMenuItem<String>> _buildLocationItems() {
    List<DropdownMenuItem<String>> items = [];

    // Get valid location types for this role
    Set<LocationType> validLocationTypes =
        _getValidLocationTypesForRole(selectedRole?.split(";").first);

    // Add "Create new shop" option for specific roles
    if (showCreateShopOption) {
      items.add(DropdownMenuItem<String>(
        value: "create_new_shop",
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            border: Border.all(color: Colors.green.shade600, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle,
                color: Colors.green.shade700,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "Create a new Shop for this role",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    // Add shops by type
    if (validLocationTypes.contains(LocationType.shop)) {
      shopsByType.forEach((shopType, shops) {
        // Check if this shop type is valid for the selected role
        if (_isShopTypeValidForRole(selectedRole?.split(";").first, shopType)) {
          // Add group header
          items.add(DropdownMenuItem<String>(
            value: "header_${shopType.toString()}",
            enabled: false,
            child: Text(
              "--- ${_getShopTypeString(shopType)} ---",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ));

          // Add shops of this type
          for (var shop in shops) {
            items.add(DropdownMenuItem<String>(
              value: shop.id,
              child: Text("  ${shop.name}"),
            ));
          }
        }
      });
    }

    // Add other location types
    if (otherLocations.isNotEmpty &&
        otherLocations.any((loc) => validLocationTypes.contains(loc.locType))) {
      items.add(DropdownMenuItem<String>(
        value: "header_other",
        enabled: false,
        child: Text(
          "--- Other Locations ---",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      ));

      for (var location in otherLocations) {
        if (validLocationTypes.contains(location.locType)) {
          items.add(DropdownMenuItem<String>(
            value: location.id,
            child: Text("  ${location.name}"),
          ));
        }
      }
    }

    return items;
  }

  // Get valid location types for role
  Set<LocationType> _getValidLocationTypesForRole(String? stringRole) {
    if (stringRole == null) return {};
    final role = Role.values.firstWhere((r) => r.name == stringRole);

    switch (role) {
      case Role.owner:
      case Role.smith:
      case Role.tailor:
      case Role.herbalist:
      case Role.jeweler:
      case Role.generalStoreOwner:
      case Role.magicShopOwner:
      case Role.hierophant:
      case Role.cook:
      case Role.waitstaff:
      case Role.entertainment:
      case Role.tavernKeeper:
      case Role.acolyte:
      case Role.customer:
      case Role.regular:
      case Role.journeyman:
      case Role.apprentice:
        return {LocationType.shop};
      default:
        return {};
    }
  }

  // Check if shop type is valid for role
  bool _isShopTypeValidForRole(String? stringRole, ShopType shopType) {
    if (stringRole == null) return false;
    final role = Role.values.firstWhere((r) => r.name == stringRole);

    switch (role) {
      case Role.smith:
        return shopType == ShopType.smith;
      case Role.tailor:
        return shopType == ShopType.clothier;
      case Role.herbalist:
        return shopType == ShopType.herbalist;
      case Role.jeweler:
        return shopType == ShopType.jeweler;
      case Role.generalStoreOwner:
        return shopType == ShopType.generalStore;
      case Role.magicShopOwner:
        return shopType == ShopType.magic;
      case Role.hierophant:
        return shopType == ShopType.temple;
      case Role.tavernKeeper:
      case Role.waitstaff:
      case Role.cook:
      case Role.entertainment:
        return shopType == ShopType.tavern;
      case Role.apprentice:
      case Role.journeyman:
        return {
          ShopType.clothier,
          ShopType.herbalist,
          ShopType.jeweler,
          ShopType.magic,
          ShopType.smith
        }.contains(shopType);
      case Role.owner:
        return true; // Can be owner of any shop
      default:
        return true; // Other roles can be in any shop
    }
  }

  String _getShopTypeString(ShopType type) {
    switch (type) {
      case ShopType.smith:
        return "Smithy";
      case ShopType.clothier:
        return "Clothier";
      case ShopType.herbalist:
        return "Herbalist";
      case ShopType.jeweler:
        return "Jeweler";
      case ShopType.generalStore:
        return "General Store";
      case ShopType.magic:
        return "Magic Shop";
      case ShopType.temple:
        return "Temple";
      case ShopType.tavern:
        return "Tavern";
      // ignore: unreachable_switch_default
      default:
        return "Shop";
    }
  }

  @override
  Widget build(BuildContext context) {
    final town = widget.ref.watch(townProvider);
    // widget.ref.watch(widget.ref.read(myWorldProvider).allRoles.notifier);
    final locationRolesPN = widget.ref
        .watch(locationRolesProvider.notifier);

    // Get all possible roles
    Role.values.toList();
    final displayItems =
        widget.ref.watch(roleServiceProvider).makeDropDownEntriesForAddRole();

    return AlertDialog(
      title: Text("Add Role"),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role dropdown
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              value: selectedRole,
              isExpanded: true,
              items: displayItems,
              onChanged: (newRole) {
                setState(() {
                  Role thisRole = Role.values
                      .firstWhere((r) => r.name == newRole.split(";").first);
                  selectedRole = newRole;
                  selectedLocationId = null;

                  // Check if this role can create a new shop
                  showCreateShopOption = [
                    Role.smith,
                    Role.tailor,
                    Role.herbalist,
                    Role.jeweler,
                    Role.generalStoreOwner,
                    Role.magicShopOwner,
                    Role.hierophant,
                    Role.tavernKeeper,
                  ].contains(thisRole);

                  // Determine if we should hide the location dropdown
                  hideLocationDropdown =
                      (widget.ref.watch(roleServiceProvider).hideDropDownRoles)
                          .contains(thisRole);
                });
              },
            ),
            SizedBox(height: 16),
            // Location dropdown (only show if the role requires a location)
            if (!hideLocationDropdown)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                value: selectedLocationId,
                isExpanded: true,
                items: _buildLocationItems(),
                onChanged: (newLocation) {
                  setState(() {
                    selectedLocationId = newLocation;
                  });
                },
                selectedItemBuilder: (context) {
                  return _buildLocationItems().map((item) {
                    if (item.value?.startsWith("header_") == true) {
                      return Text("");
                    }
                    if (item.value == "create_new_shop") {
                      return Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: Colors.green.shade700,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Create a new Shop for this role",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      );
                    }
                    return item.child;
                  }).toList();
                },
                itemHeight: 60,
                icon:
                    Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
                dropdownColor: Colors.grey.shade50,
              ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: selectedRole != null &&
                  (selectedLocationId != null ||
                      widget.ref
                          .read(roleServiceProvider)
                          .hideDropDownRoles
                          .contains(Role.values.firstWhere(
                              (r) => r.name == selectedRole!.split(";").first)))
              ? () async {
                  final newRole = Role.values.firstWhere(
                      (r) => r.name == selectedRole!.split(";").first);

                  if (selectedLocationId == "create_new_shop") {
                    // Remove the old role
                    Navigator.of(context).pop();

                    // Create a new shop based on the role
                    switch (newRole) {
                      case Role.smith:
                        await town.addRandomShopNoCommit(
                            ShopType.smith, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.tailor:
                        await town.addRandomShopNoCommit(
                            ShopType.clothier, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.herbalist:
                        await town.addRandomShopNoCommit(
                            ShopType.herbalist, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.jeweler:
                        await town.addRandomShopNoCommit(
                            ShopType.jeweler, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.generalStoreOwner:
                        await town.addRandomShopNoCommit(ShopType.generalStore,
                            widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.magicShopOwner:
                        await town.addRandomShopNoCommit(
                            ShopType.magic, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.hierophant:
                        await town.addRandomShopNoCommit(
                            ShopType.temple, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      case Role.tavernKeeper:
                        await town.addRandomShopNoCommit(
                            ShopType.tavern, widget.ref, widget.person.id);
                            commitShops(widget.ref);
                        break;
                      default:
                        break;
                    }
                  } else {
                    // Remove the old role
                    if (selectedLocationId != null) {
                      // Add the new role
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: selectedLocationId!,
                          myRole: newRole,
                          specialty: "");

                       locationRolesPN.add(newLocRole);
                      await locationRolesPN.commitChanges();
                    }

                    if (widget.ref
                        .read(roleServiceProvider)
                        .informationalRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: informationalID,
                          myRole: newRole,
                          specialty: "");
                       locationRolesPN.add(newLocRole);
                      await locationRolesPN.commitChanges();
                    }
                    if (widget.ref
                        .read(roleServiceProvider)
                        .hirelingRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: hirelingID,
                          myRole: newRole,
                          specialty: "");
                       locationRolesPN.add( newLocRole);
                       await locationRolesPN.commitChanges();
                    }
                    if (widget.ref
                        .read(roleServiceProvider)
                        .marketRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: marketID,
                          myRole: newRole,
                          specialty: "");
                       locationRolesPN.add(newLocRole);
                       await locationRolesPN.commitChanges();
                    }

                    final newLocRole = LocationRole(
                        myID: widget.person.id,
                        locationID: infoID,
                        myRole: newRole,
                        specialty: "");
                     locationRolesPN.add( newLocRole);
                     await locationRolesPN.commitChanges();

                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: Text("Save"),
        ),
      ],
      insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Dialog to edit an existing role
class EditRoleDialog extends StatefulWidget {
  final Person person;
  final LocationRole role;
  final WidgetRef ref;

  const EditRoleDialog({super.key, 
    required this.person,
    required this.role,
    required this.ref,
  });

  @override
  _EditRoleDialogState createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<EditRoleDialog> {
  String? selectedRole;

  String? selectedLocationId;
  bool showCreateShopOption = false;
  bool hideLocationDropdown = false;
  Map<ShopType, List<Location>> shopsByType = {};
  List<Location> otherLocations = [];

  @override
  void initState() {
    super.initState();

    Role myRole = widget.role.myRole;
    final rsP = widget.ref.read(roleServiceProvider);
    rsP.makeDropDownEntriesForAddRole();

    String appendString;
    if (rsP.shopRoles.contains(myRole)) {
      appendString = "header_shop";
    } else {
      if (rsP.tavernRoles.contains(myRole)) {
        appendString = "header_tavern";
      } else {
        if (rsP.templeRoles.contains(myRole)) {
          appendString = "header_temple";
        } else {
          if (rsP.hirelingRoles.contains(myRole)) {
            appendString = "header_hireling";
          } else {
            if (rsP.marketRoles.contains(myRole)) {
              appendString = "header_market";
            } else {
              if (rsP.informationalRoles.contains(myRole)) {
                appendString = "header_informational";
              } else {
                appendString = "header_other";
              }
            }
          }
        }
      }
    }
    selectedRole = "${widget.role.myRole.name};$appendString";
    selectedLocationId = widget.role.locationID;
    _organizeLocations();

    Role thisRole =
        Role.values.firstWhere((r) => r.name == selectedRole?.split(";").first);

    // Check if this role can create a new shop

    showCreateShopOption = [
      Role.smith,
      Role.tailor,
      Role.herbalist,
      Role.jeweler,
      Role.generalStoreOwner,
      Role.magicShopOwner,
      Role.hierophant
    ].contains(Role.values
        .firstWhere((r) => r.name == selectedRole?.split(";").first));

    hideLocationDropdown =
        (widget.ref.watch(roleServiceProvider).hideDropDownRoles)
            .contains(thisRole);
  }

  void _organizeLocations() {
    widget.ref.watch(townProvider);
    final allLocations = widget.ref.watch(locationsProvider);

    // Group shops by type
    shopsByType = {};
    otherLocations = [];

    for (var location in allLocations) {
      if (location.locType == LocationType.shop) {
        final shop = location as Shop;
        shopsByType.putIfAbsent(shop.type, () => []).add(shop);
      } else {
        otherLocations.add(location);
      }
    }
  }

  // Filter locations based on selected role
  List<DropdownMenuItem<String>> _buildLocationItems() {
    List<DropdownMenuItem<String>> items = [];

    // Get valid location types for this role
    Set<LocationType> validLocationTypes =
        _getValidLocationTypesForRole(selectedRole);

    // Add "Create new shop" option for specific roles
    if (showCreateShopOption) {
      items.add(DropdownMenuItem<String>(
        value: "create_new_shop",
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            border: Border.all(color: Colors.green.shade600, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle,
                color: Colors.green.shade700,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "Create a new Shop for this role",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    // Add shops by type
    if (validLocationTypes.contains(LocationType.shop)) {
      shopsByType.forEach((shopType, shops) {
        // Check if this shop type is valid for the selected role
        if (_isShopTypeValidForRole(selectedRole?.split(";").first, shopType)) {
          // Add group header
          items.add(DropdownMenuItem<String>(
            value: "header_${shopType.toString()}",
            enabled: false,
            child: Text(
              "--- ${_getShopTypeString(shopType)} ---",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ));

          // Add shops of this type
          for (var shop in shops) {
            items.add(DropdownMenuItem<String>(
              value: shop.id,
              child: Text("  ${shop.name}"),
            ));
          }
        }
      });
    }

    // Add other location types
    if (otherLocations.isNotEmpty &&
        otherLocations.any((loc) => validLocationTypes.contains(loc.locType))) {
      items.add(DropdownMenuItem<String>(
        value: "header_other",
        enabled: false,
        child: Text(
          "--- Other Locations ---",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
      ));

      for (var location in otherLocations) {
        if (validLocationTypes.contains(location.locType)) {
          items.add(DropdownMenuItem<String>(
            value: location.id,
            child: Text("  ${location.name}"),
          ));
        }
      }
    }

    return items;
  }

  // Get valid location types for role
  Set<LocationType> _getValidLocationTypesForRole(String? stringRole) {
    if (stringRole == null) return {};
    final role = Role.values
        .firstWhere((r) => r.name == stringRole, orElse: () => Role.owner);

    switch (role) {
      case Role.owner:
      case Role.smith:
      case Role.tailor:
      case Role.herbalist:
      case Role.jeweler:
      case Role.generalStoreOwner:
      case Role.magicShopOwner:
      case Role.hierophant:
      case Role.apprentice:
      case Role.journeyman:
      case Role.acolyte:
      case Role.cook:
      case Role.waitstaff:
      case Role.entertainment:
      case Role.tavernKeeper:
      case Role.customer:
      case Role.regular:
        return {LocationType.shop};
      case Role.government:
      case Role.minorNoble:
        return {LocationType.government};
      default:
        return {};
    }
  }

  // Check if shop type is valid for role
  bool _isShopTypeValidForRole(String? stringRole, ShopType shopType) {
    if (stringRole == null) return false;
    final role = Role.values
        .firstWhere((r) => r.name == stringRole, orElse: () => Role.owner);

    switch (role) {
      case Role.smith:
        return shopType == ShopType.smith;
      case Role.tailor:
        return shopType == ShopType.clothier;
      case Role.herbalist:
        return shopType == ShopType.herbalist;
      case Role.jeweler:
        return shopType == ShopType.jeweler;
      case Role.generalStoreOwner:
        return shopType == ShopType.generalStore;
      case Role.magicShopOwner:
        return shopType == ShopType.magic;
      case Role.hierophant:
      case Role.acolyte:
        return shopType == ShopType.temple;
      case Role.tavernKeeper:
      case Role.cook:
      case Role.waitstaff:
      case Role.entertainment:
        return shopType == ShopType.tavern;

      case Role.owner:
        return true; // Can be owner of any shop
      case Role.apprentice:
      case Role.journeyman:
        return {
          ShopType.smith,
          ShopType.clothier,
          ShopType.herbalist,
          ShopType.jeweler,
          ShopType.magic
        }.contains(shopType);
      case Role.customer:
        return {
          ShopType.smith,
          ShopType.clothier,
          ShopType.herbalist,
          ShopType.jeweler,
          ShopType.generalStore,
          ShopType.magic
        }.contains(shopType);
      case Role.regular:
        return {ShopType.temple, ShopType.tavern}
            .contains(shopType); // Can be in any shop
      default:
        return false; // Other roles can be in any shop
    }
  }

  String _getShopTypeString(ShopType type) {
    switch (type) {
      case ShopType.smith:
        return "Smithy";
      case ShopType.clothier:
        return "Clothier";
      case ShopType.herbalist:
        return "Herbalist";
      case ShopType.jeweler:
        return "Jeweler";
      case ShopType.generalStore:
        return "General Store";
      case ShopType.magic:
        return "Magic Shop";
      case ShopType.temple:
        return "Temple";
      case ShopType.tavern:
        return "Tavern";
      // ignore: unreachable_switch_default
      default:
        return "Shop";
    }
  }

  @override
  Widget build(BuildContext context) {
    final town = widget.ref.watch(townProvider);
    // widget.ref.watch(widget.ref.watch(myWorldProvider).allRoles.notifier);
    final locationRolePN =
        widget.ref.watch(locationRolesProvider.notifier);

    // Get all possible roles
    Role.values.toList();
    final displayItems =
        widget.ref.watch(roleServiceProvider).makeDropDownEntriesForAddRole();
    return AlertDialog(
      title: Text("Edit Role"),
      content: SizedBox(
        width: 500,
        // Remove fixed height to allow content to determine proper size
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role dropdown
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              value: selectedRole,
              isExpanded: true,
              items: displayItems,
              onChanged: (newRole) {
                setState(() {
                  Role thisRole = Role.values
                      .firstWhere((r) => r.name == newRole!.split(";").first);
                  selectedRole = newRole;

                  // Reset location selection when changing roles
                  selectedLocationId = null;

                  // Update whether to show create shop option
                  showCreateShopOption = [
                    Role.smith,
                    Role.tailor,
                    Role.herbalist,
                    Role.jeweler,
                    Role.generalStoreOwner,
                    Role.magicShopOwner,
                    Role.hierophant,
                    Role.tavernKeeper,
                  ].contains(thisRole);

                  // Update whether to hide location dropdown
                  hideLocationDropdown =
                      (widget.ref.watch(roleServiceProvider).hideDropDownRoles)
                          .contains(thisRole);

                  // Rebuild location items based on new role
                  _organizeLocations(); // Optional, if you need to refresh the location data
                });
              },
              icon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
              dropdownColor: Colors.grey.shade50,
            ),
            SizedBox(height: 16),
            // Location dropdown
            if (selectedRole != null && !hideLocationDropdown)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                value: selectedLocationId,
                isExpanded: true,
                items: _buildLocationItems(),
                onChanged: (newLocation) {
                  setState(() {
                    selectedLocationId = newLocation;
                  });
                },
                // Handle the selected item display
                selectedItemBuilder: (context) {
                  return _buildLocationItems().map((item) {
                    // Skip headers in the selected item display
                    if (item.value?.startsWith("header_") == true) {
                      return Text("");
                    }
                    // Use a special style for the create_new_shop item when selected
                    if (item.value == "create_new_shop") {
                      return Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: Colors.green.shade700,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Create a new Shop for this role",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      );
                    }
                    return item.child;
                  }).toList();
                },
                // Increase dropdown item height
                itemHeight: 60,
                icon:
                    Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
                dropdownColor: Colors.grey.shade50,
              ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            // widget.ref.read((widget.ref.read(townProvider).locationRoleListProvider.notifier)).refreshState();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: selectedRole != null &&
                  (selectedLocationId != null ||
                      widget.ref
                          .read(roleServiceProvider)
                          .hideDropDownRoles
                          .contains(Role.values.firstWhere(
                              (r) => r.name == selectedRole!.split(";").first)))
              ? () async {
                  final newRole = Role.values.firstWhere(
                      (r) => r.name == selectedRole!.split(";").first);

                  if (selectedLocationId == "create_new_shop") {
                    // Remove the old role
                     locationRolePN
                        .removeByKey(widget.role.compositeKey());
                        await locationRolePN.commitChanges();
                    Navigator.of(context).pop();

                    // Create a new shop based on the role
                    switch (newRole) {
                      case Role.smith:
                        await town.addRandomShopNoCommit(
                            ShopType.smith, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.tailor:
                        await town.addRandomShopNoCommit(
                            ShopType.clothier, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.herbalist:
                        await town.addRandomShopNoCommit(
                            ShopType.herbalist, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.jeweler:
                        await town.addRandomShopNoCommit(
                            ShopType.jeweler, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.generalStoreOwner:
                        await town.addRandomShopNoCommit(ShopType.generalStore,
                            widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.magicShopOwner:
                        await town.addRandomShopNoCommit(
                            ShopType.magic, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.hierophant:
                        await town.addRandomShopNoCommit(
                            ShopType.temple, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      case Role.tavernKeeper:
                        await town.addRandomShopNoCommit(
                            ShopType.tavern, widget.ref, widget.person.id);
                            await commitShops(widget.ref);
                        break;
                      default:
                        break;
                    }
                  } else if (newRole != widget.role.myRole ||
                      selectedLocationId != widget.role.locationID) {
                    // Remove the old role
                    locationRolePN
                        .removeByKey(widget.role.compositeKey());
                        await locationRolePN.commitChanges();
                    final rSP = widget.ref.read(roleServiceProvider);
                    if (rSP.informationalRoles.contains(widget.role.myRole)) {
                      String key = LocationRole(
                              locationID: informationalID,
                              myID: widget.role.myID,
                              myRole: widget.role.myRole,
                              specialty: widget.role.specialty)
                          .compositeKey();
                      locationRolePN.removeByKey(key);
                      await locationRolePN.commitChanges();
                    }
                    if (rSP.marketRoles.contains(widget.role.myRole)) {
                      String key = LocationRole(
                              locationID: marketID,
                              myID: widget.role.myID,
                              myRole: widget.role.myRole,
                              specialty: widget.role.specialty)
                          .compositeKey();
                      locationRolePN.removeByKey(key);
                      await locationRolePN.commitChanges();
                    }
                    if (rSP.hirelingRoles.contains(widget.role.myRole)) {
                      String key = LocationRole(
                              locationID: hirelingID,
                              myID: widget.role.myID,
                              myRole: widget.role.myRole,
                              specialty: widget.role.specialty)
                          .compositeKey();
                      locationRolePN.removeByKey(key);
                      await locationRolePN.commitChanges();
                    }

                    if (selectedLocationId != null) {
                      // Add the new role
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: selectedLocationId!,
                          myRole: newRole,
                          specialty: "");

                       locationRolePN.add(newLocRole);
                      await locationRolePN.commitChanges();
                    }

                    if (widget.ref
                        .read(roleServiceProvider)
                        .informationalRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: informationalID,
                          myRole: newRole,
                          specialty: "");
                       locationRolePN.add(newLocRole);
                       await locationRolePN.commitChanges();
                    }
                    if (widget.ref
                        .read(roleServiceProvider)
                        .hirelingRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: hirelingID,
                          myRole: newRole,
                          specialty: "");
                       locationRolePN.add(newLocRole);
                       await locationRolePN.commitChanges();
                    }
                    if (widget.ref
                        .read(roleServiceProvider)
                        .marketRoles
                        .contains(newRole)) {
                      final newLocRole = LocationRole(
                          myID: widget.person.id,
                          locationID: marketID,
                          myRole: newRole,
                          specialty: "");
                       locationRolePN.add(newLocRole);
                       await locationRolePN.commitChanges();
                    }

                    final newLocRole = LocationRole(
                        myID: widget.person.id,
                        locationID: infoID,
                        myRole: newRole,
                        specialty: "");
                     locationRolePN.add( newLocRole);
                     await locationRolePN.commitChanges();

                    Navigator.of(context).pop();
                  } else {
                    // No changes, just close dialog
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: Text("Save"),
        ),
      ],
      // Make the dialog larger overall
      insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// UPDATE THE MAIN PersonEditItem2 CLASS TO ADD THIS SECTION

// Add this to the build method of PersonEditItem2 class, to include the role editor section
// Add this at the end of the children list in the Column widget
// Widget build(BuildContext context, WidgetRef ref) {
//   // ... existing code ...

//   return Material(
//     color: Colors.white,
//     elevation: 6,
//     child: Column(
//       children: [
//         // ... existing fields ...
//         createTextField(
//           fieldName: 'faction',
//           displayName: 'Faction',
//           initialValue: me.faction,
//           onSave: (newValue) {
//             peopleNotif.edit(replaceID: me.id, newFaction: newValue);
//           },
//         ),
        
//         // Add a divider before the role editor section
//         Divider(height: 32, thickness: 1),
        
//         // Add the role editor section
//         buildRoleEditor(person: me, ref: ref),
//       ],
//     ),
//   );
// }