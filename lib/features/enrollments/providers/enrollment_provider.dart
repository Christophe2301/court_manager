import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/enrollment_repository.dart';
import '../../../core/models/enrollment.dart';


final enrollmentRepositoryProvider =
    Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepository();
});


final groupEnrollmentsProvider =
    StreamProvider.family<List<Enrollment>, String>(
  (ref, groupId) {

    final repository =
        ref.watch(enrollmentRepositoryProvider);

    return repository.watchEnrollmentsForGroup(
      groupId,
    );
  },
);