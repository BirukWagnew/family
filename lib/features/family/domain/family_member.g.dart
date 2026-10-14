// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyMember _$FamilyMemberFromJson(Map<String, dynamic> json) =>
    _FamilyMember(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      connectedSince: DateTime.parse(json['connectedSince'] as String),
    );

Map<String, dynamic> _$FamilyMemberToJson(_FamilyMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
      'photoUrl': instance.photoUrl,
      'bio': instance.bio,
      'connectedSince': instance.connectedSince.toIso8601String(),
    };
