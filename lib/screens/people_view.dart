import 'package:firetown/providers/barrel_of_providers.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firetown/screens/navrail.dart';
// import 'package:firetown/personEdit.dart';

// import 'shop.dart';
// import 'person.dart';
// import 'bottombar.dart';
import "../globals.dart";
// import "editHelpers.dart";
import "person_detail_view.dart";


class PeopleView extends HookConsumerWidget {
  const PeopleView({super.key});
  static const routeName="/allpeopleview";
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final people = ref.watch(ref.read(townProvider).peopleListProvider);
    final people = ref.watch(peopleProvider);
    return GestureDetector(
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
            if (people.isNotEmpty) const Divider(height: 0),
            for (var i = 0; i < people.length; i++) ...[

              if (i > 0) const Divider(height: 0),
              ProviderScope(
                  overrides: [
                    currentPerson.overrideWithValue(people[i]),
                  ],
                  child: const PersonItem(),
              ),
            

            ],
            
          ],
        ),
        // bottomNavigationBar: const Menu(),
      ),
    )])));
  }
}




class PersonItem extends HookConsumerWidget {
  const PersonItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(currentPerson);
    
    // final itemFocusNode = useFocusNode();
    // final itemIsFocused = useIsFocused(itemFocusNode);

    // final textEditingController = useTextEditingController();
    // final textFieldFocusNode = useFocusNode();

    return person.printFlippableCard();
  }
}