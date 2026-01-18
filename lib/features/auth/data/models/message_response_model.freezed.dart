// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageResponseModel {

 String get message; bool get success;
/// Create a copy of MessageResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageResponseModelCopyWith<MessageResponseModel> get copyWith => _$MessageResponseModelCopyWithImpl<MessageResponseModel>(this as MessageResponseModel, _$identity);

  /// Serializes this MessageResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageResponseModel&&(identical(other.message, message) || other.message == message)&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,success);

@override
String toString() {
  return 'MessageResponseModel(message: $message, success: $success)';
}


}

/// @nodoc
abstract mixin class $MessageResponseModelCopyWith<$Res>  {
  factory $MessageResponseModelCopyWith(MessageResponseModel value, $Res Function(MessageResponseModel) _then) = _$MessageResponseModelCopyWithImpl;
@useResult
$Res call({
 String message, bool success
});




}
/// @nodoc
class _$MessageResponseModelCopyWithImpl<$Res>
    implements $MessageResponseModelCopyWith<$Res> {
  _$MessageResponseModelCopyWithImpl(this._self, this._then);

  final MessageResponseModel _self;
  final $Res Function(MessageResponseModel) _then;

/// Create a copy of MessageResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? success = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageResponseModel].
extension MessageResponseModelPatterns on MessageResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _MessageResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessageResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  bool success)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageResponseModel() when $default != null:
return $default(_that.message,_that.success);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  bool success)  $default,) {final _that = this;
switch (_that) {
case _MessageResponseModel():
return $default(_that.message,_that.success);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  bool success)?  $default,) {final _that = this;
switch (_that) {
case _MessageResponseModel() when $default != null:
return $default(_that.message,_that.success);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageResponseModel implements MessageResponseModel {
  const _MessageResponseModel({required this.message, this.success = true});
  factory _MessageResponseModel.fromJson(Map<String, dynamic> json) => _$MessageResponseModelFromJson(json);

@override final  String message;
@override@JsonKey() final  bool success;

/// Create a copy of MessageResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageResponseModelCopyWith<_MessageResponseModel> get copyWith => __$MessageResponseModelCopyWithImpl<_MessageResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageResponseModel&&(identical(other.message, message) || other.message == message)&&(identical(other.success, success) || other.success == success));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,success);

@override
String toString() {
  return 'MessageResponseModel(message: $message, success: $success)';
}


}

/// @nodoc
abstract mixin class _$MessageResponseModelCopyWith<$Res> implements $MessageResponseModelCopyWith<$Res> {
  factory _$MessageResponseModelCopyWith(_MessageResponseModel value, $Res Function(_MessageResponseModel) _then) = __$MessageResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String message, bool success
});




}
/// @nodoc
class __$MessageResponseModelCopyWithImpl<$Res>
    implements _$MessageResponseModelCopyWith<$Res> {
  __$MessageResponseModelCopyWithImpl(this._self, this._then);

  final _MessageResponseModel _self;
  final $Res Function(_MessageResponseModel) _then;

/// Create a copy of MessageResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? success = null,}) {
  return _then(_MessageResponseModel(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
