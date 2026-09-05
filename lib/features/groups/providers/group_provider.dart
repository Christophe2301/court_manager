import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/group_repository.dart';
import '../../../core/models/group.dart';
import '../../../core/constants/app_constants.dart';


final groupRepositoryProvider =
    Provider<GroupRepository>((ref) {
  return GroupRepository();
});


final activeGroupsProvider =
    StreamProvider<List<Group>>((ref) {

  final repository =
      ref.watch(groupRepositoryProvider);

  return repository.watchActiveGroupsForSeason(
  currentSeasonId,
);
});

final inactiveGroupsProvider =
    StreamProvider<List<Group>>((ref) {
  final repository =
      ref.watch(groupRepositoryProvider);

  return repository.watchInactiveGroupsForSeason(
  currentSeasonId,
);
});

final teacherGroupsProvider =
    StreamProvider.family<List<Group>, String>(
  (ref, teacherId) {

    final repository =
        ref.watch(groupRepositoryProvider);

    return repository.watchGroupsForTeacher(
      teacherId,
      currentSeasonId,
    );
  },
);