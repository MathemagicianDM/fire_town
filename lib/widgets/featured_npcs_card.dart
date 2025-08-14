import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/barrel_of_providers.dart';
import '../services/town_stats_service.dart';
import '../models/barrel_of_models.dart';
import '../globals.dart';
import '../screens/shop_detail_view.dart';
import '../enums_and_maps.dart';
import 'flippable_person_card.dart';

class FeaturedNPCsCard extends ConsumerStatefulWidget {
  const FeaturedNPCsCard({super.key});

  @override
  ConsumerState<FeaturedNPCsCard> createState() => _FeaturedNPCsCardState();
}

class _FeaturedNPCsCardState extends ConsumerState<FeaturedNPCsCard> {
  ({Person person, LocationRole role})? _currentHireling;
  ({Person person, LocationRole role})? _currentShopNotable;
  Location? _currentShop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateFeaturedNPCs());
  }

  void _generateFeaturedNPCs() {
    final people = ref.read(peopleProvider);
    final roles = ref.read(locationRolesProvider);
    final locations = ref.read(locationsProvider);

    setState(() {
      _currentHireling = TownStatsService.getRandomHirelingWithRole(people, roles);
      _currentShopNotable = TownStatsService.getRandomShopNotableWithRole(people, roles);
      
      // Find which shop the notable person works at
      if (_currentShopNotable != null) {
        _currentShop = _findShopForPerson(_currentShopNotable!.person, roles, locations);
      } else {
        _currentShop = null;
      }
    });
  }
  
  Location? _findShopForPerson(Person person, List<LocationRole> roles, List<Location> locations) {
    // Find roles for this person
    final personRoles = roles.where((role) => role.myID == person.id);
    
    // Find shops where this person has a role
    for (final role in personRoles) {
      final location = locations.firstWhere(
        (loc) => loc.id == role.locationID,
        orElse: () => locations.first, // fallback, shouldn't happen
      );
      if (location.locType == LocationType.shop) {
        return location;
      }
    }
    return null;
  }

  String _roleToJobTitle(Role role) {
    switch (role) {
      case Role.courier: return 'Courier';
      case Role.porter: return 'Porter';
      case Role.mercenary: return 'Mercenary';
      case Role.torchBearer: return 'Torch Bearer';
      case Role.locksmith: return 'Locksmith';
      case Role.scribe: return 'Scribe';
      case Role.accountant: return 'Accountant';
      case Role.carpenter: return 'Carpenter';
      case Role.mason: return 'Mason';
      case Role.lumberjack: return 'Lumberjack';
      case Role.servant: return 'Servant';
      case Role.laborer: return 'Laborer';
      case Role.owner: return 'Owner';
      case Role.journeyman: return 'Journeyman';
      case Role.tavernKeeper: return 'Tavern Keeper';
      case Role.hierophant: return 'Hierophant';
      default: return 'Worker';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Random NPCs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateFeaturedNPCs,
                  tooltip: 'Generate new featured NPCs',
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                if (_currentHireling?.person != null) ...[
                  _RoleHeader(
                    icon: Icons.handshake,
                    title: _roleToJobTitle(_currentHireling!.role.myRole),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  FlippablePersonCard(
                    person: _currentHireling!.person,
                  ),
                ] else
                  _NoPersonAvailable(
                    icon: Icons.handshake,
                    title: 'Hireling',
                    color: Colors.green,
                  ),
                const SizedBox(height: 16),
                if (_currentShopNotable?.person != null) ...[
                  _RoleHeader(
                    icon: Icons.store,
                    title: _roleToJobTitle(_currentShopNotable!.role.myRole),
                    color: Colors.blue,
                    shop: _currentShop,
                  ),
                  const SizedBox(height: 8),
                  FlippablePersonCard(
                    person: _currentShopNotable!.person,
                  ),
                ] else
                  _NoPersonAvailable(
                    icon: Icons.store,
                    title: 'Shop Notable',
                    color: Colors.blue,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Location? shop;

  const _RoleHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (shop != null) ...[
            Text(
              ' at ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToShopDetail(context, shop!.id),
              child: Text(
                shop!.name,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToShopDetail(BuildContext context, String shopId) {
    navigatorKey.currentState!.restorablePushNamed(
      ShopDetailView.routeName,
      arguments: {'myID': shopId},
    );
  }
}

class _NoPersonAvailable extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _NoPersonAvailable({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoleHeader(
          icon: icon,
          title: title,
          color: color,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            'None available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}