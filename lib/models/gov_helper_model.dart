import '../enums_and_maps.dart';
import '../globals.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'barrel_of_models.dart';
import "package:flutter/foundation.dart";

class GovHelper {
  String position;
  GovCreateMethod createMethod;
  AgeType age;
  List<Role> validRoles;
  GovHelper({
    required this.position,
    required this.createMethod,
    required this.age,
    required this.validRoles,
  });
}

Future<List<GovHelper>> assignGovernmentRoles(
  WidgetRef ref,
  GovernmentQuery gq,
) async {
  final repository = ref.watch(governmentRepositoryProvider);
  final specificRoles = await repository.getSelectedRolesForGovernment(
    gq.governmentType,
    gq.citySize.split(".").last,
  );
  final universalRoles = await repository.getSelectedRolesForGovernment(
    "universal",
    gq.citySize.split(".").last,
  );
  final guardRoles = await repository.getSelectedRolesForGovernment(
    "guards",
    gq.citySize.split(".").last,
  );

  final specificMethod = await repository.getGovernmentMethod(
    gq.governmentType,
  );
  final universalMethod = await repository.getGovernmentMethod(
    gq.governmentType,
  );
  final universalType = await repository.getGovernmenUnivesalType(
    gq.governmentType,
  );

  final specificMethodEnum = GovCreateMethod.values.firstWhere(
    (e) => e.name == specificMethod,
  );
  final universalMethodEnum = GovCreateMethod.values.firstWhere(
    (e) => e.name == universalMethod,
  );


  ref.watch(governmentPositionsDataProvider);
  final service = ref.watch(governmentPositionsServiceProvider);

  List<GovHelper> output = [];
  for (final r in specificRoles) {
    int howMany = 1;
    if (r.quantity != null) {
      int qmin = int.parse(r.quantity!.split("-").first);
      int qmax = int.parse(r.quantity!.split("-").last);
      howMany = qmin + random.nextInt(qmax - qmin + 1);
    }
    for (int j = 0; j < howMany; j++) {
      Role myRole = Role.government;
      if (r.role != null) {
        myRole = Role.values.firstWhere((e) => e.name == r.role);
      }
      
      output.add(
        GovHelper(
          position: r.title,
          createMethod: specificMethodEnum,
          // printName: service.getTitleForPosition(r.title, gq.governmentType),
          age: service.getRandomAgeForPosition(r.title) ?? AgeType.adult,
          validRoles: rolesFromUniversalType(myRole.name),
          // isGuard: false,
        ),
      );
    }
  }

  for (final r in universalRoles) {
    int howMany = 1;
    if (r.quantity != null) {
      int qmin = int.parse(r.quantity!.split("-").first);
      int qmax = int.parse(r.quantity!.split("-").last);
      howMany = qmin + random.nextInt(qmax - qmin + 1);
    }
    for (int j = 0; j < howMany; j++) {
      output.add(
        GovHelper(
          position: r.title,
          createMethod: universalMethodEnum,
          // printName:
          //     service.getTitleForPosition(r.title, gq.governmentType),
          age: service.getRandomAgeForPosition(r.title) ?? AgeType.adult,
          validRoles: rolesFromUniversalType(universalType),
          // isGuard: false,
        ),
      );
    }
  }

  for (final r in guardRoles) {
    int howMany = 1;
    if (r.quantity != null) {
      int qmin = int.parse(r.quantity!.split("-").first);
      int qmax = int.parse(r.quantity!.split("-").last);
      howMany = qmin + random.nextInt(qmax - qmin + 1);
    }
    for (int j = 0; j < howMany; j++) {
      output.add(
        GovHelper(
          position: r.title,
          createMethod: GovCreateMethod.createRoles,
          // printName:
          //     service.getTitleForPosition(r.title, gq.governmentType),
          age: service.getRandomAgeForPosition(r.title) ?? AgeType.adult,
          validRoles: rolesFromUniversalType(universalType),
          // isGuard: true
        ),
      );
    }
  }
  return output;
}

Future<List<GovHelper>> waitForDataAndGetRoles(
  WidgetRef ref,
  GovernmentQuery gq,
) async {
  // First check if data is already loaded
  if (ref.read(isDataLoadedProvider)) {
    return await assignGovernmentRoles(ref, gq);
  }

  // Set a maximum wait time
  final maxWaitTime = Duration(seconds: 20);
  final startTime = DateTime.now();

  // Loop until data is loaded or timeout
  while (!ref.read(isDataLoadedProvider)) {
    // Check for timeout
    if (DateTime.now().difference(startTime) > maxWaitTime) {
      debugPrint("Timed out waiting for data to load");
      return []; // Return default/empty value
    }

    // Wait a short time before checking again
    await Future.delayed(Duration(milliseconds: 100));
  }

  // Data is now loaded, proceed with the function
  return await assignGovernmentRoles(ref, gq);
}
