// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  username: json['username'] as String,
  fullName: json['fullName'] as String,
  photoUrl: json['photoUrl'] as String?,
  bio: json['bio'] as String?,
  onboardingCompleted: json['onboardingCompleted'] as bool,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'fullName': instance.fullName,
  'photoUrl': instance.photoUrl,
  'bio': instance.bio,
  'onboardingCompleted': instance.onboardingCompleted,
};
