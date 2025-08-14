import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/barrel_of_providers.dart';
import '../services/town_stats_service.dart';
import '../enums_and_maps.dart';
import 'flippable_person_card.dart';

class TownHeaderCard extends ConsumerStatefulWidget {
  const TownHeaderCard({super.key});

  @override
  ConsumerState<TownHeaderCard> createState() => _TownHeaderCardState();
}

class _TownHeaderCardState extends ConsumerState<TownHeaderCard> {
  bool _showAllLeaders = false;

  String _getRoleTitle(Role role, WidgetRef ref) {
    // Handle specific role title conversions
    switch (role) {
      case Role.liegeGovernment:
        return "Liege";
      case Role.tyrantGovernment:
        return "Tyrant";
      case Role.mayorGovernment:
        return "Mayor";
      case Role.presidentGovernment:
        return "President";
      case Role.luminaryGovernment:
        return "Luminary";
      case Role.hierophantRulerGovernment:
        return "Hierophant Ruler";
      case Role.merchantCouncellorGovernment:
        return "Merchant Councillor";
      case Role.chancellorGovernment:
        return "Chancellor";
      case Role.elderGovernment:
        return "Elder";
      case Role.guardCaptainGovernment:
        // For guard roles, use the position lookup
        final positions = ref.watch(positionsProvider);
        final governmentType = ref.watch(governmentTypeProvider);
        try {
          final position = positions.firstWhere((p) => p.positionKey == "guardCaptain");
          return position.titles[governmentType] ?? "Guard Captain";
        } catch (e) {
          return "Guard Captain";
        }
      case Role.guardViceCaptainGovernment:
        final positions = ref.watch(positionsProvider);
        final governmentType = ref.watch(governmentTypeProvider);
        try {
          final position = positions.firstWhere((p) => p.positionKey == "guardViceCaptain");
          return position.titles[governmentType] ?? "Guard Vice Captain";
        } catch (e) {
          return "Guard Vice Captain";
        }
      default:
        return enum2String(myEnum: role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTown = ref.watch(townProvider);
    final people = ref.watch(peopleProvider);
    final roles = ref.watch(locationRolesProvider);
    final governmentType = ref.watch(governmentTypeProvider);

    final population = TownStatsService.getPopulationCount(people);
    final allLeaders = TownStatsService.getAllPotentialLeaders(people, roles);
    final guardWithRole = TownStatsService.getGuardCaptainWithRole(people, roles);
    final hasMultipleLeaders = allLeaders.length > 1;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currentTown.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      TextSpan(
                        text: ' (Pop: $population)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (governmentType.isNotEmpty)
                  Text(
                    'Government Style: ${_formatGovernmentType(governmentType)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (allLeaders.isNotEmpty) ...[
                        _RoleHeader(
                          icon: Icons.account_balance,
                          title: hasMultipleLeaders && _showAllLeaders
                              ? 'Town Leaders (${allLeaders.length})'
                              : hasMultipleLeaders
                                  ? '${_getRoleTitle(allLeaders.first.role, ref)} (Town Leader) +${allLeaders.length - 1} more'
                                  : '${_getRoleTitle(allLeaders.first.role, ref)} (Town Leader)',
                          color: Colors.purple,
                          onTap: hasMultipleLeaders ? () {
                            setState(() {
                              _showAllLeaders = !_showAllLeaders;
                            });
                          } : null,
                        ),
                        const SizedBox(height: 8),
                        if (_showAllLeaders && hasMultipleLeaders) ...
                          allLeaders.map((leader) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getRoleTitle(leader.role, ref),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                FlippablePersonCard(
                                  person: leader.person,
                                  startFlipped: true,
                                ),
                              ],
                            ),
                          ))
                        else
                          FlippablePersonCard(
                            person: allLeaders.first.person,
                            startFlipped: true,
                          ),
                      ] else
                        _NoPersonAssigned(
                          icon: Icons.account_balance,
                          title: 'Town Leader',
                          color: Colors.purple,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (guardWithRole != null) ...[
                        _RoleHeader(
                          icon: Icons.security,
                          title: '${_getRoleTitle(guardWithRole.role, ref)} (Guard Captain)',
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        FlippablePersonCard(
                          person: guardWithRole.person,
                          startFlipped: true,
                        ),
                      ] else
                        _NoPersonAssigned(
                          icon: Icons.security,
                          title: 'Guard Captain',
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  String _formatGovernmentType(String governmentType) {
    switch (governmentType) {
      case 'councilOfElders':
        return 'Council of Elders';
      case 'cityCouncil':
        return 'City Council';
      case 'monarchy':
        return 'Monarchy';
      case 'republic':
        return 'Republic';
      case 'oligarchy':
        return 'Oligarchy';
      case 'theocracy':
        return 'Theocracy';
      default:
        return governmentType.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        ).trim();
    }
  }
}

class _RoleHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _RoleHeader({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.expand_more,
              size: 16,
              color: color.withValues(alpha: 0.7),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class _NoPersonAssigned extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _NoPersonAssigned({
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
            'None assigned',
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