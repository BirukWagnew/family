import 'package:freezed_annotation/freezed_annotation.dart';
import '../../family/domain/base_person.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User implements BasePerson {
  const factory User({
    required String id,
    required String username,
    required String fullName,
    String? photoUrl,
    String? bio,
    required bool onboardingCompleted,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
