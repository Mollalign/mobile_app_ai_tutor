// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RefreshTokenModel {

@JsonKey(name: 'access_token') String get accessToken;@JsonKey(name: 'token_type') String get tokenType;@JsonKey(name: 'expires_in') int get expiresIn;
/// Create a copy of RefreshTokenModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshTokenModelCopyWith<RefreshTokenModel> get copyWith => _$RefreshTokenModelCopyWithImpl<RefreshTokenModel>(this as RefreshTokenModel, _$identity);

  /// Serializes this RefreshTokenModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshTokenModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,expiresIn);

@override
String toString() {
  return 'RefreshTokenModel(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $RefreshTokenModelCopyWith<$Res>  {
  factory $RefreshTokenModelCopyWith(RefreshTokenModel value, $Res Function(RefreshTokenModel) _then) = _$RefreshTokenModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn
});




}
/// @nodoc
class _$RefreshTokenModelCopyWithImpl<$Res>
    implements $RefreshTokenModelCopyWith<$Res> {
  _$RefreshTokenModelCopyWithImpl(this._self, this._then);

  final RefreshTokenModel _self;
  final $Res Function(RefreshTokenModel) _then;

/// Create a copy of RefreshTokenModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresIn = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshTokenModel].
extension RefreshTokenModelPatterns on RefreshTokenModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshTokenModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshTokenModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshTokenModel value)  $default,){
final _that = this;
switch (_that) {
case _RefreshTokenModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshTokenModel value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshTokenModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshTokenModel() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _RefreshTokenModel():
return $default(_that.accessToken,_that.tokenType,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _RefreshTokenModel() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshTokenModel implements RefreshTokenModel {
  const _RefreshTokenModel({@JsonKey(name: 'access_token') required this.accessToken, @JsonKey(name: 'token_type') required this.tokenType, @JsonKey(name: 'expires_in') required this.expiresIn});
  factory _RefreshTokenModel.fromJson(Map<String, dynamic> json) => _$RefreshTokenModelFromJson(json);

@override@JsonKey(name: 'access_token') final  String accessToken;
@override@JsonKey(name: 'token_type') final  String tokenType;
@override@JsonKey(name: 'expires_in') final  int expiresIn;

/// Create a copy of RefreshTokenModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshTokenModelCopyWith<_RefreshTokenModel> get copyWith => __$RefreshTokenModelCopyWithImpl<_RefreshTokenModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshTokenModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshTokenModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,expiresIn);

@override
String toString() {
  return 'RefreshTokenModel(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$RefreshTokenModelCopyWith<$Res> implements $RefreshTokenModelCopyWith<$Res> {
  factory _$RefreshTokenModelCopyWith(_RefreshTokenModel value, $Res Function(_RefreshTokenModel) _then) = __$RefreshTokenModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn
});




}
/// @nodoc
class __$RefreshTokenModelCopyWithImpl<$Res>
    implements _$RefreshTokenModelCopyWith<$Res> {
  __$RefreshTokenModelCopyWithImpl(this._self, this._then);

  final _RefreshTokenModel _self;
  final $Res Function(_RefreshTokenModel) _then;

/// Create a copy of RefreshTokenModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresIn = null,}) {
  return _then(_RefreshTokenModel(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
