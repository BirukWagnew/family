// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyRequest _$FamilyRequestFromJson(Map<String, dynamic> json) =>
    _FamilyRequest(
      id: json['id'] as String,
      otherUserId: json['otherUserId'] as String,
      otherUserFullName: json['otherUserFullName'] as String,
      otherUserUsername: json['otherUserUsername'] as String,
      otherUserPhotoUrl: json['otherUserPhotoUrl'] as String?,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      direction: $enumDecode(_$RequestDirectionEnumMap, json['direction']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$FamilyRequestToJson(_FamilyRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'otherUserId': instance.otherUserId,
      'otherUserFullName': instance.otherUserFullName,
      'otherUserUsername': instance.otherUserUsername,
      'otherUserPhotoUrl': instance.otherUserPhotoUrl,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'direction': _$RequestDirectionEnumMap[instance.direction]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.accepted: 'accepted',
  RequestStatus.rejected: 'rejected',
  RequestStatus.expired: 'expired',
};

const _$RequestDirectionEnumMap = {
  RequestDirection.incoming: 'incoming',
  RequestDirection.outgoing: 'outgoing',
};
