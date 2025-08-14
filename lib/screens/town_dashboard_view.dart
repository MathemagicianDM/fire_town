import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'navrail.dart';
import '../widgets/town_header_card.dart';
import '../widgets/featured_npcs_card.dart';
import '../widgets/talk_of_town_card.dart';
import '../widgets/dashboard_street_encounters.dart';
import '../widgets/quick_access_card.dart';

class TownDashboardView extends ConsumerWidget {
  const TownDashboardView({super.key});
  static const routeName = '/town_dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Navrail(),
          const VerticalDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Town header with basic stats
                    const TownHeaderCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Two-column layout for middle section
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1000) {
                          // Wide screen: side by side layout
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    const FeaturedNPCsCard(),
                                    const SizedBox(height: 16),
                                    const QuickAccessCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                flex: 1,
                                child: TalkOfTownCard(),
                              ),
                            ],
                          );
                        } else {
                          // Narrow screen: stacked layout
                          return const Column(
                            children: [
                              FeaturedNPCsCard(),
                              SizedBox(height: 16),
                              TalkOfTownCard(),
                              SizedBox(height: 16),
                              QuickAccessCard(),
                            ],
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Full-width street encounters
                    const DashboardStreetEncountersCard(),
                    
                    // Add some bottom padding
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}