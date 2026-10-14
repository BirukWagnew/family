import 'package:freezed_annotation/freezed_annotation.dart';
import 'base_person.dart';

part 'family_member.freezed.dart';
part 'family_member.g.dart';

@freezed
abstract class FamilyMember with _$FamilyMember implements BasePerson {
  const factory FamilyMember({
    required String id,
    required String username,
    required String fullName,
    String? photoUrl,
    String? bio,
    required DateTime connectedSince,
  }) = _FamilyMember;

  factory FamilyMember.fromJson(Map<String, dynamic> json) => _$FamilyMemberFromJson(json);
}
