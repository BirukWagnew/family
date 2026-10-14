// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FamilyRequest {

 String get id; String get otherUserId; String get otherUserFullName; String get otherUserUsername; String? get otherUserPhotoUrl; RequestStatus get status; RequestDirection get direction; DateTime get createdAt; DateTime get expiresAt;
/// Create a copy of FamilyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyRequestCopyWith<FamilyRequest> get copyWith => _$FamilyRequestCopyWithImpl<FamilyRequest>(this as FamilyRequest, _$identity);

  /// Serializes this FamilyRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FamilyRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.otherUserId, _this.otherUserId) || other.otherUserId == _this.otherUserId)&&(identical(other.otherUserFullName, _this.otherUserFullName) || other.otherUserFullName == _this.otherUserFullName)&&(identical(other.otherUserUsername, _this.otherUserUsername) || other.otherUserUsername == _this.otherUserUsername)&&(identical(other.otherUserPhotoUrl, _this.otherUserPhotoUrl) || other.otherUserPhotoUrl == _this.otherUserPhotoUrl)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FamilyRequest;
  return Object.hash(runtimeType,_this.id,_this.otherUserId,_this.otherUserFullName,_this.otherUserUsername,_this.otherUserPhotoUrl,_this.status,_this.direction,_this.createdAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as FamilyRequest;
  return 'FamilyRequest(id: ${_this.id}, otherUserId: ${_this.otherUserId}, otherUserFullName: ${_this.otherUserFullName}, otherUserUsername: ${_this.otherUserUsername}, otherUserPhotoUrl: ${_this.otherUserPhotoUrl}, status: ${_this.status}, direction: ${_this.direction}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $FamilyRequestCopyWith<$Res>  {
  factory $FamilyRequestCopyWith(FamilyRequest value, $Res Function(FamilyRequest) _then) = _$FamilyRequestCopyWithImpl;
@useResult
$Res call({
 String id, String otherUserId, String otherUserFullName, String otherUserUsername, String? otherUserPhotoUrl, RequestStatus status, RequestDirection direction, DateTime createdAt, DateTime expiresAt
});




}
/// @nodoc
class _$FamilyRequestCopyWithImpl<$Res>
    implements $FamilyRequestCopyWith<$Res> {
  _$FamilyRequestCopyWithImpl(this._self, this._then);

  final FamilyRequest _self;
  final $Res Function(FamilyRequest) _then;

/// Create a copy of FamilyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? otherUserId = null,Object? otherUserFullName = null,Object? otherUserUsername = null,Object? otherUserPhotoUrl = freezed,Object? status = null,Object? direction = null,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(FamilyRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUserId: null == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as String,otherUserFullName: null == otherUserFullName ? _self.otherUserFullName : otherUserFullName // ignore: cast_nullable_to_non_nullable
as String,otherUserUsername: null == otherUserUsername ? _self.otherUserUsername : otherUserUsername // ignore: cast_nullable_to_non_nullable
as String,otherUserPhotoUrl: freezed == otherUserPhotoUrl ? _self.otherUserPhotoUrl : otherUserPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as RequestDirection,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyRequest].
extension FamilyRequestPatterns on FamilyRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyRequest value)  $default,){
final _that = this;
switch (_that) {
case _FamilyRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String otherUserId,  String otherUserFullName,  String otherUserUsername,  String? otherUserPhotoUrl,  RequestStatus status,  RequestDirection direction,  DateTime createdAt,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyRequest() when $default != null:
return $default(_that.id,_that.otherUserId,_that.otherUserFullName,_that.otherUserUsername,_that.otherUserPhotoUrl,_that.status,_that.direction,_that.createdAt,_that.expiresAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String otherUserId,  String otherUserFullName,  String otherUserUsername,  String? otherUserPhotoUrl,  RequestStatus status,  RequestDirection direction,  DateTime createdAt,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _FamilyRequest():
return $default(_that.id,_that.otherUserId,_that.otherUserFullName,_that.otherUserUsername,_that.otherUserPhotoUrl,_that.status,_that.direction,_that.createdAt,_that.expiresAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String otherUserId,  String otherUserFullName,  String otherUserUsername,  String? otherUserPhotoUrl,  RequestStatus status,  RequestDirection direction,  DateTime createdAt,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _FamilyRequest() when $default != null:
return $default(_that.id,_that.otherUserId,_that.otherUserFullName,_that.otherUserUsername,_that.otherUserPhotoUrl,_that.status,_that.direction,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FamilyRequest implements FamilyRequest {
  const _FamilyRequest({required this.id, required this.otherUserId, required this.otherUserFullName, required this.otherUserUsername, this.otherUserPhotoUrl, required this.status, required this.direction, required this.createdAt, required this.expiresAt});
  factory _FamilyRequest.fromJson(Map<String, dynamic> json) => _$FamilyRequestFromJson(json);

@override final  String id;
@override final  String otherUserId;
@override final  String otherUserFullName;
@override final  String otherUserUsername;
@override final  String? otherUserPhotoUrl;
@override final  RequestStatus status;
@override final  RequestDirection direction;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;

/// Create a copy of FamilyRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyRequestCopyWith<_FamilyRequest> get copyWith => __$FamilyRequestCopyWithImpl<_FamilyRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FamilyRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.otherUserId, otherUserId) || other.otherUserId == otherUserId)&&(identical(other.otherUserFullName, otherUserFullName) || other.otherUserFullName == otherUserFullName)&&(identical(other.otherUserUsername, otherUserUsername) || other.otherUserUsername == otherUserUsername)&&(identical(other.otherUserPhotoUrl, otherUserPhotoUrl) || other.otherUserPhotoUrl == otherUserPhotoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,otherUserId,otherUserFullName,otherUserUsername,otherUserPhotoUrl,status,direction,createdAt,expiresAt);
}

@override
String toString() {
    return 'FamilyRequest(id: $id, otherUserId: $otherUserId, otherUserFullName: $otherUserFullName, otherUserUsername: $otherUserUsername, otherUserPhotoUrl: $otherUserPhotoUrl, status: $status, direction: $direction, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$FamilyRequestCopyWith<$Res> implements $FamilyRequestCopyWith<$Res> {
  factory _$FamilyRequestCopyWith(_FamilyRequest value, $Res Function(_FamilyRequest) _then) = __$FamilyRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String otherUserId, String otherUserFullName, String otherUserUsername, String? otherUserPhotoUrl, RequestStatus status, RequestDirection direction, DateTime createdAt, DateTime expiresAt
});




}
/// @nodoc
class __$FamilyRequestCopyWithImpl<$Res>
    implements _$FamilyRequestCopyWith<$Res> {
  __$FamilyRequestCopyWithImpl(this._self, this._then);

  final _FamilyRequest _self;
  final $Res Function(_FamilyRequest) _then;

/// Create a copy of FamilyRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? otherUserId = null,Object? otherUserFullName = null,Object? otherUserUsername = null,Object? otherUserPhotoUrl = freezed,Object? status = null,Object? direction = null,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_FamilyRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUserId: null == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as String,otherUserFullName: null == otherUserFullName ? _self.otherUserFullName : otherUserFullName // ignore: cast_nullable_to_non_nullable
as String,otherUserUsername: null == otherUserUsername ? _self.otherUserUsername : otherUserUsername // ignore: cast_nullable_to_non_nullable
as String,otherUserPhotoUrl: freezed == otherUserPhotoUrl ? _self.otherUserPhotoUrl : otherUserPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as RequestDirection,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
