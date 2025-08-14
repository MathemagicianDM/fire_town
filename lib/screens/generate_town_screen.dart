import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:firetown/navrail.dart';
// import 'package:firetown/personEdit.dart';
import 'package:firetown/screens/shops_view.dart';
// import 'load_json.dart';
// import 'shop.dart';
// import 'person.dart';
// import 'bottombar.dart';
import "../globals.dart";

import "../enums_and_maps.dart";
// import "editHelpers.dart";
// import "personDetailView.dart";
// import "peopleView.dart";
import "package:uuid/uuid.dart";
// import "../town_storage.dart";
import "../providers/barrel_of_providers.dart";
import "../models/town_model.dart";
import "../providers/buffered_provider.dart";


const _uuid = Uuid();

class TownGeneratorPage extends HookConsumerWidget {
late final CitySize citySize;
TownGeneratorPage({super.key});

  static const routeName="/generate_town_screen";
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State management for the current step and messages
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final CitySize citySize = args!["citySize"] as CitySize? ?? CitySize.town;
    final String name = args["name"];
    final demographic = args["demographic"];
    final government = args["government"];

    
    // print("Government Selected: $government");
    String myID=_uuid.v4();
    final message = useState("Starting...");
    useState(0);
    final isGenerating = useState(true);

    
    
    // Start the generation process when the page is built
    useEffect(() {
      Future.microtask(() async {
        await ref.read(firestoreServiceProvider).updateTownGovernment(myID,government);
        ref.read(governmentTypeProvider.notifier).state = government;

        
          final townsListPN = ref.read(townsProvider.notifier);
          final tof = TownOnFire(id:myID, name:name, myDemographics: demographic);

          townsListPN.add(tof);
          await townsListPN.commitChanges();
          
          ref.watch(townProvider.notifier).state = tof;
          // await ref.read(ref.read(myWorldProvider).myTownsProvider.notifier)
                              // .add(addMe: TownStorage(id:myID, townName: name,
                              // demographic:demographic ));
          await loadTownFS(myID,ref);

                  // await ref.read(myWorldProvider).loadTown(myID,ref);

          

          await ref.read(townProvider).populateTown(mySize:citySize,ref:ref,government:government,
          onMessageUpdate: (String newMessage) {
            message.value = newMessage;
          });
          

        // Navigate to the "shopsview" page when done
        isGenerating.value = false;
        navigatorKey.currentState?.pushReplacementNamed(ShopsView.routeName);
      });
      return null;
    }, []); // Runs only once on page load

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generating Town"),
      ),
      body: Center(
        child: isGenerating.value
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    message.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
            : const SizedBox.shrink(), // Empty widget if done (will navigate away)
      ),
    );
  }
}

          