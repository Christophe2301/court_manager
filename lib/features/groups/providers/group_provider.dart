import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/group_repository.dart';
import '../../../core/models/group.dart';


final groupRepositoryProvider =
    Provider<GroupRepository>((ref) {
  return GroupRepository();
});


final activeGroupsProvider =
    StreamProvider<List<Group>>((ref) {

  final repository =
      ref.watch(groupRepositoryProvider);

  return repository.watchActiveGroupsForSeason(
  '2026-2027',
);
});

final inactiveGroupsProvider =
    StreamProvider<List<Group>>((ref) {
  final repository =
      ref.watch(groupRepositoryProvider);

  return repository.watchInactiveGroupsForSeason(
  '2026-2027',
);
});

final teacherGroupsProvider =
    StreamProvider.family<List<Group>, String>(
  (ref, teacherId) {

    final repository =
        ref.watch(groupRepositoryProvider);

    return repository.watchGroupsForTeacher(
      teacherId,
      '2026-2027',
    );
  },
);