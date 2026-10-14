import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_request.freezed.dart';
part 'family_request.g.dart';

enum RequestStatus { pending, accepted, rejected, expired }
enum RequestDirection { incoming, outgoing }

@freezed
abstract class FamilyRequest with _$FamilyRequest {
  const factory FamilyRequest({
    required String id,
    required String otherUserId,
    required String otherUserFullName,
    required String otherUserUsername,
    String? otherUserPhotoUrl,
    required RequestStatus status,
    required RequestDirection direction,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _FamilyRequest;

  factory FamilyRequest.fromJson(Map<String, dynamic> json) => _$FamilyRequestFromJson(json);
}
