import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teacher_repository.dart';
import '../../auth/models/app_user.dart';

final teacherRepositoryProvider =
    Provider<TeacherRepository>((ref) {
  return TeacherRepository();
});

final activeTeachersProvider =
    StreamProvider<List<AppUser>>((ref) {
  final repository =
      ref.watch(teacherRepositoryProvider);

  return repository.watchActiveTeachers();
});