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

  return repository.watchActiveGroups();
});


final teacherGroupsProvider =
    StreamProvider.family<List<Group>, String>(
  (ref, teacherId) {

    final repository =
        ref.watch(groupRepositoryProvider);

    return repository.watchGroupsForTeacher(
      teacherId,
    );
  },
);