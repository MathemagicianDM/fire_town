
import 'package:firetown/screens/town_dashboard_view.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:firetown/screens/demographics_builder_screen.dart";
// import 'package:firetown/navrail.dart';
// import 'package:firetown/personEdit.dart';
import 'package:firetown/screens/shops_view.dart';
import 'ancestry_management_page.dart';
import 'template_manager_page.dart';
// import 'load_json.dart';
// import 'shop.dart';
// import 'person.dart';
// import 'bottombar.dart';
import "../globals.dart";
import "../models/town_model.dart";
import '../providers/barrel_of_providers.dart';
import '../providers/buffered_provider.dart';

// import "editHelpers.dart";
// import "personDetailView.dart";
// import "peopleView.dart";


class Home extends ConsumerStatefulWidget {
  const Home({super.key});
  static const routeName="/home";
  @override
  ConsumerState<Home> createState() => _TownPageState();
  
}

class _TownPageState extends ConsumerState<Home> {
  String? _currentID;
  bool _isInitialized = false;
  
  // List of authorized admin emails
  static const List<String> _authorizedAdmins = [
    'mathemagician@gmail.com',
    'sycrim@gmail.com',
  ];

  bool _isAuthorized(User? user) {
    if (user?.email == null) return false;
    return _authorizedAdmins.contains(user!.email!.toLowerCase());
  }
  @override
  void initState() {
    super.initState();
    _initData();
  }


  Future<void> _initData() async {
    try {
      
    // final townList = ref.read(townsProvider);
    final townListPN = ref.read(townsProvider.notifier);
    await townListPN.initialize();

    // final json = await rootBundle.loadString("./lib/demofiles/Demotown.demographics");
    // await ancestriesPN.loadFromJsonAndCommit(json);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

    } catch (e) {
      debugPrint("Error initializing: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    // print("Home page yo");
    final myTowns = ref.watch(townsProvider);
    final sortedTowns = [...myTowns]..sort((a, b) => a.name.compareTo(b.name));
    

    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to the Town Generator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Menu
            Row(children:[DropdownButton<String?>(
            value: _currentID,
            hint: Text(
              sortedTowns.isNotEmpty
                  ? "Select a Town"
                  : "Your towns will appear in this list",
            ),
            items: [
              // Allowing a null option
              const DropdownMenuItem<String?>(
                value: null,
                child: Text("No Town Selected"),
              ),
              ...sortedTowns.map((town) {
                return DropdownMenuItem<String?>(
                  value: town.id, // Ensure the value is unique
                  child: Text(town.name), // Display the town name
                );
              }),
            ],
              onChanged: (String? newValue) {
                setState(() {
                  _currentID = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{
                
                  if(_currentID==null){
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a town, or create one.")),
                    );
                  }else{
                  await loadTownFS(_currentID!,ref);
                  navigatorKey.currentState?.pushNamed(TownDashboardView.routeName);
                  }
                },
              child: const Text("Load Town"),
            ),
            ElevatedButton(
  onPressed: () async {
    if (_currentID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a town to delete :(")),
      );
    } else {
      String deleteID = _currentID!;
      
      // Reset _currentID and update the UI before deletion
      setState(() {
        _currentID = null;
      });
      final townsListPN = ref.watch(townsProvider.notifier);
      final delTown = sortedTowns.firstWhere((town) => town.id == deleteID);
      townsListPN.remove(delTown);
      final firebasePN = ref.watch(firestoreServiceProvider);
      await firebasePN.deleteTown(deleteID);

      await townsListPN.commitChanges();
      // Perform the delete operation
      // await ref
      //     .read(ref.read(myWorldProvider).myTownsProvider.notifier)
      //     .delete(deleteID);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Town and all its wonderful people successfully deleted. Where will you strike next?")),
      );
      navigatorKey.currentState?.pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const Home(),
          transitionDuration: Duration.zero, // No animation
          reverseTransitionDuration: Duration.zero, // No animation on back navigation
        ),
        (route) => false, // Remove all previous routes
      );
    }
  },
  child: const Text("Delete Town"),
),]),
            // Text Field for Name
            
            const SizedBox(height: 16),

            // Create Town Button
            ElevatedButton(
              onPressed: () async{

                  navigatorKey.currentState?.pushNamed(DemoDetermineStateful.routeName);
                  
              },
              child: const Text("Create a new Town"),
            ),
            const SizedBox(height: 16),

            // Go Back Button
            if(myTowns.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                navigatorKey.currentState?.pushNamed(ShopsView.routeName);
              },
              child: const Text("Go Back"),
            ),
            
            // Admin Panel Section
            if (_isAuthorized(FirebaseAuth.instance.currentUser)) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              _buildAdminSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Card(
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.red.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Administrator Tools',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in as: ${user?.email ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => navigatorKey.currentState?.pushNamed(
                      AncestryManagementPage.routeName,
                    ),
                    icon: const Icon(Icons.people_outline),
                    label: const Text('Ancestry Management'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => navigatorKey.currentState?.pushNamed(
                      TemplateManagerPage.routeName,
                    ),
                    icon: const Icon(Icons.description),
                    label: const Text('Template Manager'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}