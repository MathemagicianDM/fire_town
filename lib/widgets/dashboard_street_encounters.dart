import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/location_encounters_widget.dart';
import '../enums_and_maps.dart';

class DashboardStreetEncountersCard extends ConsumerWidget {
  const DashboardStreetEncountersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.explore, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Around Town',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Use existing LocationEncountersWidget with street encounters
            LocationEncountersWidget(
              locationType: LocationType.street,
              locationId: 'town_streets', // Special ID for general street encounters
            ),
          ],
        ),
      ),
    );
  }
}