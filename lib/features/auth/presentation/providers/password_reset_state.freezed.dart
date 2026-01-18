// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordResetState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordResetState()';
}


}

/// @nodoc
class $PasswordResetStateCopyWith<$Res>  {
$PasswordResetStateCopyWith(PasswordResetState _, $Res Function(PasswordResetState) __);
}


/// Adds pattern-matching-related methods to [PasswordResetState].
extension PasswordResetStatePatterns on PasswordResetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PasswordResetInitial value)?  initial,TResult Function( PasswordResetLoading value)?  loading,TResult Function( PasswordResetCodeSent value)?  codeSent,TResult Function( PasswordResetCodeVerified value)?  codeVerified,TResult Function( PasswordResetSuccess value)?  success,TResult Function( PasswordResetError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PasswordResetInitial() when initial != null:
return initial(_that);case PasswordResetLoading() when loading != null:
return loading(_that);case PasswordResetCodeSent() when codeSent != null:
return codeSent(_that);case PasswordResetCodeVerified() when codeVerified != null:
return codeVerified(_that);case PasswordResetSuccess() when success != null:
return success(_that);case PasswordResetError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PasswordResetInitial value)  initial,required TResult Function( PasswordResetLoading value)  loading,required TResult Function( PasswordResetCodeSent value)  codeSent,required TResult Function( PasswordResetCodeVerified value)  codeVerified,required TResult Function( PasswordResetSuccess value)  success,required TResult Function( PasswordResetError value)  error,}){
final _that = this;
switch (_that) {
case PasswordResetInitial():
return initial(_that);case PasswordResetLoading():
return loading(_that);case PasswordResetCodeSent():
return codeSent(_that);case PasswordResetCodeVerified():
return codeVerified(_that);case PasswordResetSuccess():
return success(_that);case PasswordResetError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PasswordResetInitial value)?  initial,TResult? Function( PasswordResetLoading value)?  loading,TResult? Function( PasswordResetCodeSent value)?  codeSent,TResult? Function( PasswordResetCodeVerified value)?  codeVerified,TResult? Function( PasswordResetSuccess value)?  success,TResult? Function( PasswordResetError value)?  error,}){
final _that = this;
switch (_that) {
case PasswordResetInitial() when initial != null:
return initial(_that);case PasswordResetLoading() when loading != null:
return loading(_that);case PasswordResetCodeSent() when codeSent != null:
return codeSent(_that);case PasswordResetCodeVerified() when codeVerified != null:
return codeVerified(_that);case PasswordResetSuccess() when success != null:
return success(_that);case PasswordResetError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String email)?  codeSent,TResult Function( String email,  String code)?  codeVerified,TResult Function()?  success,TResult Function( String message,  PasswordResetStep failedStep)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PasswordResetInitial() when initial != null:
return initial();case PasswordResetLoading() when loading != null:
return loading();case PasswordResetCodeSent() when codeSent != null:
return codeSent(_that.email);case PasswordResetCodeVerified() when codeVerified != null:
return codeVerified(_that.email,_that.code);case PasswordResetSuccess() when success != null:
return success();case PasswordResetError() when error != null:
return error(_that.message,_that.failedStep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String email)  codeSent,required TResult Function( String email,  String code)  codeVerified,required TResult Function()  success,required TResult Function( String message,  PasswordResetStep failedStep)  error,}) {final _that = this;
switch (_that) {
case PasswordResetInitial():
return initial();case PasswordResetLoading():
return loading();case PasswordResetCodeSent():
return codeSent(_that.email);case PasswordResetCodeVerified():
return codeVerified(_that.email,_that.code);case PasswordResetSuccess():
return success();case PasswordResetError():
return error(_that.message,_that.failedStep);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String email)?  codeSent,TResult? Function( String email,  String code)?  codeVerified,TResult? Function()?  success,TResult? Function( String message,  PasswordResetStep failedStep)?  error,}) {final _that = this;
switch (_that) {
case PasswordResetInitial() when initial != null:
return initial();case PasswordResetLoading() when loading != null:
return loading();case PasswordResetCodeSent() when codeSent != null:
return codeSent(_that.email);case PasswordResetCodeVerified() when codeVerified != null:
return codeVerified(_that.email,_that.code);case PasswordResetSuccess() when success != null:
return success();case PasswordResetError() when error != null:
return error(_that.message,_that.failedStep);case _:
  return null;

}
}

}

/// @nodoc


class PasswordResetInitial implements PasswordResetState {
  const PasswordResetInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordResetState.initial()';
}


}




/// @nodoc


class PasswordResetLoading implements PasswordResetState {
  const PasswordResetLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordResetState.loading()';
}


}




/// @nodoc


class PasswordResetCodeSent implements PasswordResetState {
  const PasswordResetCodeSent({required this.email});
  

 final  String email;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetCodeSentCopyWith<PasswordResetCodeSent> get copyWith => _$PasswordResetCodeSentCopyWithImpl<PasswordResetCodeSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetCodeSent&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'PasswordResetState.codeSent(email: $email)';
}


}

/// @nodoc
abstract mixin class $PasswordResetCodeSentCopyWith<$Res> implements $PasswordResetStateCopyWith<$Res> {
  factory $PasswordResetCodeSentCopyWith(PasswordResetCodeSent value, $Res Function(PasswordResetCodeSent) _then) = _$PasswordResetCodeSentCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$PasswordResetCodeSentCopyWithImpl<$Res>
    implements $PasswordResetCodeSentCopyWith<$Res> {
  _$PasswordResetCodeSentCopyWithImpl(this._self, this._then);

  final PasswordResetCodeSent _self;
  final $Res Function(PasswordResetCodeSent) _then;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(PasswordResetCodeSent(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PasswordResetCodeVerified implements PasswordResetState {
  const PasswordResetCodeVerified({required this.email, required this.code});
  

 final  String email;
 final  String code;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetCodeVerifiedCopyWith<PasswordResetCodeVerified> get copyWith => _$PasswordResetCodeVerifiedCopyWithImpl<PasswordResetCodeVerified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetCodeVerified&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,email,code);

@override
String toString() {
  return 'PasswordResetState.codeVerified(email: $email, code: $code)';
}


}

/// @nodoc
abstract mixin class $PasswordResetCodeVerifiedCopyWith<$Res> implements $PasswordResetStateCopyWith<$Res> {
  factory $PasswordResetCodeVerifiedCopyWith(PasswordResetCodeVerified value, $Res Function(PasswordResetCodeVerified) _then) = _$PasswordResetCodeVerifiedCopyWithImpl;
@useResult
$Res call({
 String email, String code
});




}
/// @nodoc
class _$PasswordResetCodeVerifiedCopyWithImpl<$Res>
    implements $PasswordResetCodeVerifiedCopyWith<$Res> {
  _$PasswordResetCodeVerifiedCopyWithImpl(this._self, this._then);

  final PasswordResetCodeVerified _self;
  final $Res Function(PasswordResetCodeVerified) _then;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? code = null,}) {
  return _then(PasswordResetCodeVerified(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PasswordResetSuccess implements PasswordResetState {
  const PasswordResetSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordResetState.success()';
}


}




/// @nodoc


class PasswordResetError implements PasswordResetState {
  const PasswordResetError({required this.message, required this.failedStep});
  

 final  String message;
 final  PasswordResetStep failedStep;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetErrorCopyWith<PasswordResetError> get copyWith => _$PasswordResetErrorCopyWithImpl<PasswordResetError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetError&&(identical(other.message, message) || other.message == message)&&(identical(other.failedStep, failedStep) || other.failedStep == failedStep));
}


@override
int get hashCode => Object.hash(runtimeType,message,failedStep);

@override
String toString() {
  return 'PasswordResetState.error(message: $message, failedStep: $failedStep)';
}


}

/// @nodoc
abstract mixin class $PasswordResetErrorCopyWith<$Res> implements $PasswordResetStateCopyWith<$Res> {
  factory $PasswordResetErrorCopyWith(PasswordResetError value, $Res Function(PasswordResetError) _then) = _$PasswordResetErrorCopyWithImpl;
@useResult
$Res call({
 String message, PasswordResetStep failedStep
});




}
/// @nodoc
class _$PasswordResetErrorCopyWithImpl<$Res>
    implements $PasswordResetErrorCopyWith<$Res> {
  _$PasswordResetErrorCopyWithImpl(this._self, this._then);

  final PasswordResetError _self;
  final $Res Function(PasswordResetError) _then;

/// Create a copy of PasswordResetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? failedStep = null,}) {
  return _then(PasswordResetError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,failedStep: null == failedStep ? _self.failedStep : failedStep // ignore: cast_nullable_to_non_nullable
as PasswordResetStep,
  ));
}


}

// dart format on
