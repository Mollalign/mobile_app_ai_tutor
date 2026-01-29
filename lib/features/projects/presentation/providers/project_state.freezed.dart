// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsState()';
}


}

/// @nodoc
class $ProjectsStateCopyWith<$Res>  {
$ProjectsStateCopyWith(ProjectsState _, $Res Function(ProjectsState) __);
}


/// Adds pattern-matching-related methods to [ProjectsState].
extension ProjectsStatePatterns on ProjectsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProjectsInitial value)?  initial,TResult Function( ProjectsLoading value)?  loading,TResult Function( ProjectsLoaded value)?  loaded,TResult Function( ProjectsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProjectsInitial() when initial != null:
return initial(_that);case ProjectsLoading() when loading != null:
return loading(_that);case ProjectsLoaded() when loaded != null:
return loaded(_that);case ProjectsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProjectsInitial value)  initial,required TResult Function( ProjectsLoading value)  loading,required TResult Function( ProjectsLoaded value)  loaded,required TResult Function( ProjectsError value)  error,}){
final _that = this;
switch (_that) {
case ProjectsInitial():
return initial(_that);case ProjectsLoading():
return loading(_that);case ProjectsLoaded():
return loaded(_that);case ProjectsError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProjectsInitial value)?  initial,TResult? Function( ProjectsLoading value)?  loading,TResult? Function( ProjectsLoaded value)?  loaded,TResult? Function( ProjectsError value)?  error,}){
final _that = this;
switch (_that) {
case ProjectsInitial() when initial != null:
return initial(_that);case ProjectsLoading() when loading != null:
return loading(_that);case ProjectsLoaded() when loaded != null:
return loaded(_that);case ProjectsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Project> projects,  bool isLoadingMore,  bool hasMore)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProjectsInitial() when initial != null:
return initial();case ProjectsLoading() when loading != null:
return loading();case ProjectsLoaded() when loaded != null:
return loaded(_that.projects,_that.isLoadingMore,_that.hasMore);case ProjectsError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Project> projects,  bool isLoadingMore,  bool hasMore)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ProjectsInitial():
return initial();case ProjectsLoading():
return loading();case ProjectsLoaded():
return loaded(_that.projects,_that.isLoadingMore,_that.hasMore);case ProjectsError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Project> projects,  bool isLoadingMore,  bool hasMore)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ProjectsInitial() when initial != null:
return initial();case ProjectsLoading() when loading != null:
return loading();case ProjectsLoaded() when loaded != null:
return loaded(_that.projects,_that.isLoadingMore,_that.hasMore);case ProjectsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProjectsInitial implements ProjectsState {
  const ProjectsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsState.initial()';
}


}




/// @nodoc


class ProjectsLoading implements ProjectsState {
  const ProjectsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsState.loading()';
}


}




/// @nodoc


class ProjectsLoaded implements ProjectsState {
  const ProjectsLoaded({required final  List<Project> projects, this.isLoadingMore = false, this.hasMore = true}): _projects = projects;
  

 final  List<Project> _projects;
 List<Project> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

@JsonKey() final  bool isLoadingMore;
@JsonKey() final  bool hasMore;

/// Create a copy of ProjectsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectsLoadedCopyWith<ProjectsLoaded> get copyWith => _$ProjectsLoadedCopyWithImpl<ProjectsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsLoaded&&const DeepCollectionEquality().equals(other._projects, _projects)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_projects),isLoadingMore,hasMore);

@override
String toString() {
  return 'ProjectsState.loaded(projects: $projects, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $ProjectsLoadedCopyWith<$Res> implements $ProjectsStateCopyWith<$Res> {
  factory $ProjectsLoadedCopyWith(ProjectsLoaded value, $Res Function(ProjectsLoaded) _then) = _$ProjectsLoadedCopyWithImpl;
@useResult
$Res call({
 List<Project> projects, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class _$ProjectsLoadedCopyWithImpl<$Res>
    implements $ProjectsLoadedCopyWith<$Res> {
  _$ProjectsLoadedCopyWithImpl(this._self, this._then);

  final ProjectsLoaded _self;
  final $Res Function(ProjectsLoaded) _then;

/// Create a copy of ProjectsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projects = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(ProjectsLoaded(
projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ProjectsError implements ProjectsState {
  const ProjectsError({required this.message});
  

 final  String message;

/// Create a copy of ProjectsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectsErrorCopyWith<ProjectsError> get copyWith => _$ProjectsErrorCopyWithImpl<ProjectsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProjectsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProjectsErrorCopyWith<$Res> implements $ProjectsStateCopyWith<$Res> {
  factory $ProjectsErrorCopyWith(ProjectsError value, $Res Function(ProjectsError) _then) = _$ProjectsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProjectsErrorCopyWithImpl<$Res>
    implements $ProjectsErrorCopyWith<$Res> {
  _$ProjectsErrorCopyWithImpl(this._self, this._then);

  final ProjectsError _self;
  final $Res Function(ProjectsError) _then;

/// Create a copy of ProjectsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProjectsError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ProjectDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState()';
}


}

/// @nodoc
class $ProjectDetailStateCopyWith<$Res>  {
$ProjectDetailStateCopyWith(ProjectDetailState _, $Res Function(ProjectDetailState) __);
}


/// Adds pattern-matching-related methods to [ProjectDetailState].
extension ProjectDetailStatePatterns on ProjectDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProjectDetailInitial value)?  initial,TResult Function( ProjectDetailLoading value)?  loading,TResult Function( ProjectDetailLoaded value)?  loaded,TResult Function( ProjectDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProjectDetailInitial() when initial != null:
return initial(_that);case ProjectDetailLoading() when loading != null:
return loading(_that);case ProjectDetailLoaded() when loaded != null:
return loaded(_that);case ProjectDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProjectDetailInitial value)  initial,required TResult Function( ProjectDetailLoading value)  loading,required TResult Function( ProjectDetailLoaded value)  loaded,required TResult Function( ProjectDetailError value)  error,}){
final _that = this;
switch (_that) {
case ProjectDetailInitial():
return initial(_that);case ProjectDetailLoading():
return loading(_that);case ProjectDetailLoaded():
return loaded(_that);case ProjectDetailError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProjectDetailInitial value)?  initial,TResult? Function( ProjectDetailLoading value)?  loading,TResult? Function( ProjectDetailLoaded value)?  loaded,TResult? Function( ProjectDetailError value)?  error,}){
final _that = this;
switch (_that) {
case ProjectDetailInitial() when initial != null:
return initial(_that);case ProjectDetailLoading() when loading != null:
return loading(_that);case ProjectDetailLoaded() when loaded != null:
return loaded(_that);case ProjectDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Project project)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProjectDetailInitial() when initial != null:
return initial();case ProjectDetailLoading() when loading != null:
return loading();case ProjectDetailLoaded() when loaded != null:
return loaded(_that.project);case ProjectDetailError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Project project)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ProjectDetailInitial():
return initial();case ProjectDetailLoading():
return loading();case ProjectDetailLoaded():
return loaded(_that.project);case ProjectDetailError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Project project)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ProjectDetailInitial() when initial != null:
return initial();case ProjectDetailLoading() when loading != null:
return loading();case ProjectDetailLoaded() when loaded != null:
return loaded(_that.project);case ProjectDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProjectDetailInitial implements ProjectDetailState {
  const ProjectDetailInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState.initial()';
}


}




/// @nodoc


class ProjectDetailLoading implements ProjectDetailState {
  const ProjectDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState.loading()';
}


}




/// @nodoc


class ProjectDetailLoaded implements ProjectDetailState {
  const ProjectDetailLoaded({required this.project});
  

 final  Project project;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDetailLoadedCopyWith<ProjectDetailLoaded> get copyWith => _$ProjectDetailLoadedCopyWithImpl<ProjectDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailLoaded&&(identical(other.project, project) || other.project == project));
}


@override
int get hashCode => Object.hash(runtimeType,project);

@override
String toString() {
  return 'ProjectDetailState.loaded(project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectDetailLoadedCopyWith<$Res> implements $ProjectDetailStateCopyWith<$Res> {
  factory $ProjectDetailLoadedCopyWith(ProjectDetailLoaded value, $Res Function(ProjectDetailLoaded) _then) = _$ProjectDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Project project
});


$ProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$ProjectDetailLoadedCopyWithImpl<$Res>
    implements $ProjectDetailLoadedCopyWith<$Res> {
  _$ProjectDetailLoadedCopyWithImpl(this._self, this._then);

  final ProjectDetailLoaded _self;
  final $Res Function(ProjectDetailLoaded) _then;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? project = null,}) {
  return _then(ProjectDetailLoaded(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,
  ));
}

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class ProjectDetailError implements ProjectDetailState {
  const ProjectDetailError({required this.message});
  

 final  String message;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDetailErrorCopyWith<ProjectDetailError> get copyWith => _$ProjectDetailErrorCopyWithImpl<ProjectDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProjectDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProjectDetailErrorCopyWith<$Res> implements $ProjectDetailStateCopyWith<$Res> {
  factory $ProjectDetailErrorCopyWith(ProjectDetailError value, $Res Function(ProjectDetailError) _then) = _$ProjectDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProjectDetailErrorCopyWithImpl<$Res>
    implements $ProjectDetailErrorCopyWith<$Res> {
  _$ProjectDetailErrorCopyWithImpl(this._self, this._then);

  final ProjectDetailError _self;
  final $Res Function(ProjectDetailError) _then;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProjectDetailError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ProjectMutationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectMutationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectMutationState()';
}


}

/// @nodoc
class $ProjectMutationStateCopyWith<$Res>  {
$ProjectMutationStateCopyWith(ProjectMutationState _, $Res Function(ProjectMutationState) __);
}


/// Adds pattern-matching-related methods to [ProjectMutationState].
extension ProjectMutationStatePatterns on ProjectMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProjectMutationIdle value)?  idle,TResult Function( ProjectMutationLoading value)?  loading,TResult Function( ProjectMutationSuccess value)?  success,TResult Function( ProjectMutationError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProjectMutationIdle() when idle != null:
return idle(_that);case ProjectMutationLoading() when loading != null:
return loading(_that);case ProjectMutationSuccess() when success != null:
return success(_that);case ProjectMutationError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProjectMutationIdle value)  idle,required TResult Function( ProjectMutationLoading value)  loading,required TResult Function( ProjectMutationSuccess value)  success,required TResult Function( ProjectMutationError value)  error,}){
final _that = this;
switch (_that) {
case ProjectMutationIdle():
return idle(_that);case ProjectMutationLoading():
return loading(_that);case ProjectMutationSuccess():
return success(_that);case ProjectMutationError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProjectMutationIdle value)?  idle,TResult? Function( ProjectMutationLoading value)?  loading,TResult? Function( ProjectMutationSuccess value)?  success,TResult? Function( ProjectMutationError value)?  error,}){
final _that = this;
switch (_that) {
case ProjectMutationIdle() when idle != null:
return idle(_that);case ProjectMutationLoading() when loading != null:
return loading(_that);case ProjectMutationSuccess() when success != null:
return success(_that);case ProjectMutationError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( String message,  Project? project)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProjectMutationIdle() when idle != null:
return idle();case ProjectMutationLoading() when loading != null:
return loading();case ProjectMutationSuccess() when success != null:
return success(_that.message,_that.project);case ProjectMutationError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( String message,  Project? project)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ProjectMutationIdle():
return idle();case ProjectMutationLoading():
return loading();case ProjectMutationSuccess():
return success(_that.message,_that.project);case ProjectMutationError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( String message,  Project? project)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ProjectMutationIdle() when idle != null:
return idle();case ProjectMutationLoading() when loading != null:
return loading();case ProjectMutationSuccess() when success != null:
return success(_that.message,_that.project);case ProjectMutationError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProjectMutationIdle implements ProjectMutationState {
  const ProjectMutationIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectMutationIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectMutationState.idle()';
}


}




/// @nodoc


class ProjectMutationLoading implements ProjectMutationState {
  const ProjectMutationLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectMutationLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectMutationState.loading()';
}


}




/// @nodoc


class ProjectMutationSuccess implements ProjectMutationState {
  const ProjectMutationSuccess({required this.message, this.project});
  

 final  String message;
 final  Project? project;

/// Create a copy of ProjectMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectMutationSuccessCopyWith<ProjectMutationSuccess> get copyWith => _$ProjectMutationSuccessCopyWithImpl<ProjectMutationSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectMutationSuccess&&(identical(other.message, message) || other.message == message)&&(identical(other.project, project) || other.project == project));
}


@override
int get hashCode => Object.hash(runtimeType,message,project);

@override
String toString() {
  return 'ProjectMutationState.success(message: $message, project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectMutationSuccessCopyWith<$Res> implements $ProjectMutationStateCopyWith<$Res> {
  factory $ProjectMutationSuccessCopyWith(ProjectMutationSuccess value, $Res Function(ProjectMutationSuccess) _then) = _$ProjectMutationSuccessCopyWithImpl;
@useResult
$Res call({
 String message, Project? project
});


$ProjectCopyWith<$Res>? get project;

}
/// @nodoc
class _$ProjectMutationSuccessCopyWithImpl<$Res>
    implements $ProjectMutationSuccessCopyWith<$Res> {
  _$ProjectMutationSuccessCopyWithImpl(this._self, this._then);

  final ProjectMutationSuccess _self;
  final $Res Function(ProjectMutationSuccess) _then;

/// Create a copy of ProjectMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? project = freezed,}) {
  return _then(ProjectMutationSuccess(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project?,
  ));
}

/// Create a copy of ProjectMutationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $ProjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class ProjectMutationError implements ProjectMutationState {
  const ProjectMutationError({required this.message});
  

 final  String message;

/// Create a copy of ProjectMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectMutationErrorCopyWith<ProjectMutationError> get copyWith => _$ProjectMutationErrorCopyWithImpl<ProjectMutationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectMutationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProjectMutationState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProjectMutationErrorCopyWith<$Res> implements $ProjectMutationStateCopyWith<$Res> {
  factory $ProjectMutationErrorCopyWith(ProjectMutationError value, $Res Function(ProjectMutationError) _then) = _$ProjectMutationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProjectMutationErrorCopyWithImpl<$Res>
    implements $ProjectMutationErrorCopyWith<$Res> {
  _$ProjectMutationErrorCopyWithImpl(this._self, this._then);

  final ProjectMutationError _self;
  final $Res Function(ProjectMutationError) _then;

/// Create a copy of ProjectMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProjectMutationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
