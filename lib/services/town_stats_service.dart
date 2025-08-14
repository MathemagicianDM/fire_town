import 'dart:math';
import 'package:collection/collection.dart';
import '../models/barrel_of_models.dart';
import '../enums_and_maps.dart';

class TownStatsService {
  static int getPopulationCount(List<Person> people) {
    return people.length;
  }

  static Person? getTownLeader(List<Person> people, List<LocationRole> roles) {
    // Priority order: liegeGovernment > tyrantGovernment > mayorGovernment > presidentGovernment > other leadership roles
    final leaderRoles = [
      Role.liegeGovernment,
      Role.tyrantGovernment,
      Role.mayorGovernment,
      Role.presidentGovernment,
      Role.luminaryGovernment,
      Role.hierophantRulerGovernment,
      Role.merchantCouncellorGovernment,
      Role.elderGovernment,
      Role.government,
    ];

    for (final role in leaderRoles) {
      final leader = _findPersonWithRole(people, roles, role);
      if (leader != null) return leader;
    }
    return null;
  }

  static ({Person person, Role role})? getTownLeaderWithRole(List<Person> people, List<LocationRole> roles) {
    // Priority order: liegeGovernment > tyrantGovernment > mayorGovernment > presidentGovernment > other leadership roles
    final leaderRoles = [
      Role.liegeGovernment,
      Role.tyrantGovernment,
      Role.mayorGovernment,
      Role.presidentGovernment,
      Role.luminaryGovernment,
      Role.hierophantRulerGovernment,
      Role.merchantCouncellorGovernment,
      Role.elderGovernment,
      Role.government,
    ];

    for (final role in leaderRoles) {
      final leader = _findPersonWithRole(people, roles, role);
      if (leader != null) return (person: leader, role: role);
    }
    return null;
  }

  static Person? getGuardCaptain(List<Person> people, List<LocationRole> roles) {
    return _findPersonWithRole(people, roles, Role.guardCaptainGovernment) ??
        _findPersonWithRole(people, roles, Role.guardViceCaptainGovernment);
  }

  static ({Person person, Role role})? getGuardCaptainWithRole(List<Person> people, List<LocationRole> roles) {
    final captain = _findPersonWithRole(people, roles, Role.guardCaptainGovernment);
    if (captain != null) return (person: captain, role: Role.guardCaptainGovernment);
    
    final viceCaptain = _findPersonWithRole(people, roles, Role.guardViceCaptainGovernment);
    if (viceCaptain != null) return (person: viceCaptain, role: Role.guardViceCaptainGovernment);
    
    return null;
  }

  static Person? getRandomHireling(List<Person> people, List<LocationRole> roles) {
    final hirelingRoles = [
      Role.courier,
      Role.porter,
      Role.mercenary,
      Role.torchBearer,
      Role.locksmith,
      Role.scribe,
      Role.accountant,
      Role.carpenter,
      Role.mason,
      Role.lumberjack,
      Role.servant,
      Role.laborer,
    ];
    return _findRandomPersonWithAnyRole(people, roles, hirelingRoles);
  }

  static Person? getRandomShopNotable(List<Person> people, List<LocationRole> roles) {
    final notableRoles = [
      Role.owner,
      Role.journeyman,
      Role.tavernKeeper,
      Role.hierophant,
    ];
    return _findRandomPersonWithAnyRole(people, roles, notableRoles);
  }

  static Person? _findPersonWithRole(List<Person> people, List<LocationRole> roles, Role targetRole) {
    final roleEntry = roles.firstWhereOrNull((lr) => lr.myRole == targetRole);
    if (roleEntry == null) return null;

    return people.firstWhereOrNull((p) => p.id == roleEntry.myID);
  }

  static Person? _findRandomPersonWithAnyRole(
      List<Person> people, List<LocationRole> roles, List<Role> targetRoles) {
    final matchingRoles = roles.where((lr) => targetRoles.contains(lr.myRole)).toList();
    if (matchingRoles.isEmpty) return null;

    final random = Random();
    final randomRole = matchingRoles[random.nextInt(matchingRoles.length)];

    return people.firstWhereOrNull((p) => p.id == randomRole.myID);
  }

  static ({Person person, LocationRole role})? getRandomHirelingWithRole(
      List<Person> people, List<LocationRole> roles) {
    final hirelingRoles = [
      Role.courier,
      Role.porter,
      Role.mercenary,
      Role.torchBearer,
      Role.locksmith,
      Role.scribe,
      Role.accountant,
      Role.carpenter,
      Role.mason,
      Role.lumberjack,
      Role.servant,
      Role.laborer,
    ];
    return _findRandomPersonWithAnyRoleAndRole(people, roles, hirelingRoles);
  }

  static ({Person person, LocationRole role})? getRandomShopNotableWithRole(
      List<Person> people, List<LocationRole> roles) {
    final notableRoles = [
      Role.owner,
      Role.journeyman,
      Role.tavernKeeper,
      Role.hierophant,
    ];
    return _findRandomPersonWithAnyRoleAndRole(people, roles, notableRoles);
  }

  static ({Person person, LocationRole role})? _findRandomPersonWithAnyRoleAndRole(
      List<Person> people, List<LocationRole> roles, List<Role> targetRoles) {
    final matchingRoles = roles.where((lr) => targetRoles.contains(lr.myRole)).toList();
    if (matchingRoles.isEmpty) return null;

    final random = Random();
    final randomRole = matchingRoles[random.nextInt(matchingRoles.length)];
    final person = people.firstWhereOrNull((p) => p.id == randomRole.myID);
    
    if (person == null) return null;
    return (person: person, role: randomRole);
  }

  static List<({Person person, Role role})> getAllPotentialLeaders(List<Person> people, List<LocationRole> roles) {
    // Roles that can have multiple equal-claim leaders
    final equalClaimRoles = [
      Role.merchantCouncellorGovernment,
      Role.hierophantRulerGovernment,
      Role.elderGovernment,
    ];

    final leaders = <({Person person, Role role})>[];

    // First check for single-authority roles
    final singleAuthorityRoles = [
      Role.liegeGovernment,
      Role.tyrantGovernment,
      Role.mayorGovernment,
      Role.presidentGovernment,
      Role.luminaryGovernment,
    ];

    for (final role in singleAuthorityRoles) {
      final leader = _findPersonWithRole(people, roles, role);
      if (leader != null) {
        leaders.add((person: leader, role: role));
        return leaders; // Return immediately for single-authority roles
      }
    }

    // If no single authority found, collect all equal-claim leaders
    for (final role in equalClaimRoles) {
      final matchingRoles = roles.where((lr) => lr.myRole == role).toList();
      for (final locationRole in matchingRoles) {
        final person = people.firstWhereOrNull((p) => p.id == locationRole.myID);
        if (person != null) {
          leaders.add((person: person, role: role));
        }
      }
    }

    // Fallback to general government role
    if (leaders.isEmpty) {
      final leader = _findPersonWithRole(people, roles, Role.government);
      if (leader != null) {
        leaders.add((person: leader, role: Role.government));
      }
    }

    return leaders;
  }
}