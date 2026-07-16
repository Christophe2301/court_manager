import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/member_repository.dart';
import '../../../core/models/member.dart';


final memberRepositoryProvider =
    Provider<MemberRepository>((ref) {
  return MemberRepository();
});


final groupMembersProvider =
    StreamProvider.family<List<Member>, String>(
  (ref, groupId) {

    final repository =
        ref.watch(memberRepositoryProvider);

    return repository.watchMembersForGroup(
      groupId,
    );
  },
);