// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationsState()';
}


}

/// @nodoc
class $ConversationsStateCopyWith<$Res>  {
$ConversationsStateCopyWith(ConversationsState _, $Res Function(ConversationsState) __);
}


/// Adds pattern-matching-related methods to [ConversationsState].
extension ConversationsStatePatterns on ConversationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConversationsInitial value)?  initial,TResult Function( ConversationsLoading value)?  loading,TResult Function( ConversationsLoaded value)?  loaded,TResult Function( ConversationsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConversationsInitial() when initial != null:
return initial(_that);case ConversationsLoading() when loading != null:
return loading(_that);case ConversationsLoaded() when loaded != null:
return loaded(_that);case ConversationsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConversationsInitial value)  initial,required TResult Function( ConversationsLoading value)  loading,required TResult Function( ConversationsLoaded value)  loaded,required TResult Function( ConversationsError value)  error,}){
final _that = this;
switch (_that) {
case ConversationsInitial():
return initial(_that);case ConversationsLoading():
return loading(_that);case ConversationsLoaded():
return loaded(_that);case ConversationsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConversationsInitial value)?  initial,TResult? Function( ConversationsLoading value)?  loading,TResult? Function( ConversationsLoaded value)?  loaded,TResult? Function( ConversationsError value)?  error,}){
final _that = this;
switch (_that) {
case ConversationsInitial() when initial != null:
return initial(_that);case ConversationsLoading() when loading != null:
return loading(_that);case ConversationsLoaded() when loaded != null:
return loaded(_that);case ConversationsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Conversation> conversations,  int total,  bool isLoadingMore,  bool hasMore)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConversationsInitial() when initial != null:
return initial();case ConversationsLoading() when loading != null:
return loading();case ConversationsLoaded() when loaded != null:
return loaded(_that.conversations,_that.total,_that.isLoadingMore,_that.hasMore);case ConversationsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Conversation> conversations,  int total,  bool isLoadingMore,  bool hasMore)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ConversationsInitial():
return initial();case ConversationsLoading():
return loading();case ConversationsLoaded():
return loaded(_that.conversations,_that.total,_that.isLoadingMore,_that.hasMore);case ConversationsError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Conversation> conversations,  int total,  bool isLoadingMore,  bool hasMore)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ConversationsInitial() when initial != null:
return initial();case ConversationsLoading() when loading != null:
return loading();case ConversationsLoaded() when loaded != null:
return loaded(_that.conversations,_that.total,_that.isLoadingMore,_that.hasMore);case ConversationsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ConversationsInitial implements ConversationsState {
  const ConversationsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationsState.initial()';
}


}




/// @nodoc


class ConversationsLoading implements ConversationsState {
  const ConversationsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationsState.loading()';
}


}




/// @nodoc


class ConversationsLoaded implements ConversationsState {
  const ConversationsLoaded({required final  List<Conversation> conversations, required this.total, this.isLoadingMore = false, this.hasMore = true}): _conversations = conversations;
  

 final  List<Conversation> _conversations;
 List<Conversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

 final  int total;
@JsonKey() final  bool isLoadingMore;
@JsonKey() final  bool hasMore;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationsLoadedCopyWith<ConversationsLoaded> get copyWith => _$ConversationsLoadedCopyWithImpl<ConversationsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsLoaded&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.total, total) || other.total == total)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conversations),total,isLoadingMore,hasMore);

@override
String toString() {
  return 'ConversationsState.loaded(conversations: $conversations, total: $total, isLoadingMore: $isLoadingMore, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $ConversationsLoadedCopyWith<$Res> implements $ConversationsStateCopyWith<$Res> {
  factory $ConversationsLoadedCopyWith(ConversationsLoaded value, $Res Function(ConversationsLoaded) _then) = _$ConversationsLoadedCopyWithImpl;
@useResult
$Res call({
 List<Conversation> conversations, int total, bool isLoadingMore, bool hasMore
});




}
/// @nodoc
class _$ConversationsLoadedCopyWithImpl<$Res>
    implements $ConversationsLoadedCopyWith<$Res> {
  _$ConversationsLoadedCopyWithImpl(this._self, this._then);

  final ConversationsLoaded _self;
  final $Res Function(ConversationsLoaded) _then;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversations = null,Object? total = null,Object? isLoadingMore = null,Object? hasMore = null,}) {
  return _then(ConversationsLoaded(
conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ConversationsError implements ConversationsState {
  const ConversationsError({required this.message});
  

 final  String message;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationsErrorCopyWith<ConversationsError> get copyWith => _$ConversationsErrorCopyWithImpl<ConversationsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ConversationsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ConversationsErrorCopyWith<$Res> implements $ConversationsStateCopyWith<$Res> {
  factory $ConversationsErrorCopyWith(ConversationsError value, $Res Function(ConversationsError) _then) = _$ConversationsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ConversationsErrorCopyWithImpl<$Res>
    implements $ConversationsErrorCopyWith<$Res> {
  _$ConversationsErrorCopyWithImpl(this._self, this._then);

  final ConversationsError _self;
  final $Res Function(ConversationsError) _then;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ConversationsError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState()';
}


}

/// @nodoc
class $ChatStateCopyWith<$Res>  {
$ChatStateCopyWith(ChatState _, $Res Function(ChatState) __);
}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatInitial value)?  initial,TResult Function( ChatLoading value)?  loading,TResult Function( ChatLoaded value)?  loaded,TResult Function( ChatError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatLoading() when loading != null:
return loading(_that);case ChatLoaded() when loaded != null:
return loaded(_that);case ChatError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatInitial value)  initial,required TResult Function( ChatLoading value)  loading,required TResult Function( ChatLoaded value)  loaded,required TResult Function( ChatError value)  error,}){
final _that = this;
switch (_that) {
case ChatInitial():
return initial(_that);case ChatLoading():
return loading(_that);case ChatLoaded():
return loaded(_that);case ChatError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatInitial value)?  initial,TResult? Function( ChatLoading value)?  loading,TResult? Function( ChatLoaded value)?  loaded,TResult? Function( ChatError value)?  error,}){
final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial(_that);case ChatLoading() when loading != null:
return loading(_that);case ChatLoaded() when loaded != null:
return loaded(_that);case ChatError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ConversationDetail conversation,  List<Message> messages,  bool isSending,  bool isStreaming,  String? streamingContent,  List<SourceCitation>? pendingSources)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatLoading() when loading != null:
return loading();case ChatLoaded() when loaded != null:
return loaded(_that.conversation,_that.messages,_that.isSending,_that.isStreaming,_that.streamingContent,_that.pendingSources);case ChatError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ConversationDetail conversation,  List<Message> messages,  bool isSending,  bool isStreaming,  String? streamingContent,  List<SourceCitation>? pendingSources)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ChatInitial():
return initial();case ChatLoading():
return loading();case ChatLoaded():
return loaded(_that.conversation,_that.messages,_that.isSending,_that.isStreaming,_that.streamingContent,_that.pendingSources);case ChatError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ConversationDetail conversation,  List<Message> messages,  bool isSending,  bool isStreaming,  String? streamingContent,  List<SourceCitation>? pendingSources)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ChatInitial() when initial != null:
return initial();case ChatLoading() when loading != null:
return loading();case ChatLoaded() when loaded != null:
return loaded(_that.conversation,_that.messages,_that.isSending,_that.isStreaming,_that.streamingContent,_that.pendingSources);case ChatError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ChatInitial implements ChatState {
  const ChatInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.initial()';
}


}




/// @nodoc


class ChatLoading implements ChatState {
  const ChatLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatState.loading()';
}


}




/// @nodoc


class ChatLoaded implements ChatState {
  const ChatLoaded({required this.conversation, required final  List<Message> messages, this.isSending = false, this.isStreaming = false, this.streamingContent, final  List<SourceCitation>? pendingSources}): _messages = messages,_pendingSources = pendingSources;
  

 final  ConversationDetail conversation;
 final  List<Message> _messages;
 List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@JsonKey() final  bool isSending;
@JsonKey() final  bool isStreaming;
 final  String? streamingContent;
 final  List<SourceCitation>? _pendingSources;
 List<SourceCitation>? get pendingSources {
  final value = _pendingSources;
  if (value == null) return null;
  if (_pendingSources is EqualUnmodifiableListView) return _pendingSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatLoadedCopyWith<ChatLoaded> get copyWith => _$ChatLoadedCopyWithImpl<ChatLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatLoaded&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.streamingContent, streamingContent) || other.streamingContent == streamingContent)&&const DeepCollectionEquality().equals(other._pendingSources, _pendingSources));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(_messages),isSending,isStreaming,streamingContent,const DeepCollectionEquality().hash(_pendingSources));

@override
String toString() {
  return 'ChatState.loaded(conversation: $conversation, messages: $messages, isSending: $isSending, isStreaming: $isStreaming, streamingContent: $streamingContent, pendingSources: $pendingSources)';
}


}

/// @nodoc
abstract mixin class $ChatLoadedCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatLoadedCopyWith(ChatLoaded value, $Res Function(ChatLoaded) _then) = _$ChatLoadedCopyWithImpl;
@useResult
$Res call({
 ConversationDetail conversation, List<Message> messages, bool isSending, bool isStreaming, String? streamingContent, List<SourceCitation>? pendingSources
});




}
/// @nodoc
class _$ChatLoadedCopyWithImpl<$Res>
    implements $ChatLoadedCopyWith<$Res> {
  _$ChatLoadedCopyWithImpl(this._self, this._then);

  final ChatLoaded _self;
  final $Res Function(ChatLoaded) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversation = null,Object? messages = null,Object? isSending = null,Object? isStreaming = null,Object? streamingContent = freezed,Object? pendingSources = freezed,}) {
  return _then(ChatLoaded(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ConversationDetail,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,streamingContent: freezed == streamingContent ? _self.streamingContent : streamingContent // ignore: cast_nullable_to_non_nullable
as String?,pendingSources: freezed == pendingSources ? _self._pendingSources : pendingSources // ignore: cast_nullable_to_non_nullable
as List<SourceCitation>?,
  ));
}


}

/// @nodoc


class ChatError implements ChatState {
  const ChatError({required this.message});
  

 final  String message;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatErrorCopyWith<ChatError> get copyWith => _$ChatErrorCopyWithImpl<ChatError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatErrorCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) _then) = _$ChatErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatErrorCopyWithImpl<$Res>
    implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._self, this._then);

  final ChatError _self;
  final $Res Function(ChatError) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChatError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CreateConversationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateConversationState()';
}


}

/// @nodoc
class $CreateConversationStateCopyWith<$Res>  {
$CreateConversationStateCopyWith(CreateConversationState _, $Res Function(CreateConversationState) __);
}


/// Adds pattern-matching-related methods to [CreateConversationState].
extension CreateConversationStatePatterns on CreateConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateConversationInitial value)?  initial,TResult Function( CreateConversationLoading value)?  loading,TResult Function( CreateConversationSuccess value)?  success,TResult Function( CreateConversationError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateConversationInitial() when initial != null:
return initial(_that);case CreateConversationLoading() when loading != null:
return loading(_that);case CreateConversationSuccess() when success != null:
return success(_that);case CreateConversationError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateConversationInitial value)  initial,required TResult Function( CreateConversationLoading value)  loading,required TResult Function( CreateConversationSuccess value)  success,required TResult Function( CreateConversationError value)  error,}){
final _that = this;
switch (_that) {
case CreateConversationInitial():
return initial(_that);case CreateConversationLoading():
return loading(_that);case CreateConversationSuccess():
return success(_that);case CreateConversationError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateConversationInitial value)?  initial,TResult? Function( CreateConversationLoading value)?  loading,TResult? Function( CreateConversationSuccess value)?  success,TResult? Function( CreateConversationError value)?  error,}){
final _that = this;
switch (_that) {
case CreateConversationInitial() when initial != null:
return initial(_that);case CreateConversationLoading() when loading != null:
return loading(_that);case CreateConversationSuccess() when success != null:
return success(_that);case CreateConversationError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ConversationDetail conversation)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateConversationInitial() when initial != null:
return initial();case CreateConversationLoading() when loading != null:
return loading();case CreateConversationSuccess() when success != null:
return success(_that.conversation);case CreateConversationError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ConversationDetail conversation)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case CreateConversationInitial():
return initial();case CreateConversationLoading():
return loading();case CreateConversationSuccess():
return success(_that.conversation);case CreateConversationError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ConversationDetail conversation)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case CreateConversationInitial() when initial != null:
return initial();case CreateConversationLoading() when loading != null:
return loading();case CreateConversationSuccess() when success != null:
return success(_that.conversation);case CreateConversationError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CreateConversationInitial implements CreateConversationState {
  const CreateConversationInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateConversationState.initial()';
}


}




/// @nodoc


class CreateConversationLoading implements CreateConversationState {
  const CreateConversationLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateConversationState.loading()';
}


}




/// @nodoc


class CreateConversationSuccess implements CreateConversationState {
  const CreateConversationSuccess({required this.conversation});
  

 final  ConversationDetail conversation;

/// Create a copy of CreateConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateConversationSuccessCopyWith<CreateConversationSuccess> get copyWith => _$CreateConversationSuccessCopyWithImpl<CreateConversationSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationSuccess&&(identical(other.conversation, conversation) || other.conversation == conversation));
}


@override
int get hashCode => Object.hash(runtimeType,conversation);

@override
String toString() {
  return 'CreateConversationState.success(conversation: $conversation)';
}


}

/// @nodoc
abstract mixin class $CreateConversationSuccessCopyWith<$Res> implements $CreateConversationStateCopyWith<$Res> {
  factory $CreateConversationSuccessCopyWith(CreateConversationSuccess value, $Res Function(CreateConversationSuccess) _then) = _$CreateConversationSuccessCopyWithImpl;
@useResult
$Res call({
 ConversationDetail conversation
});




}
/// @nodoc
class _$CreateConversationSuccessCopyWithImpl<$Res>
    implements $CreateConversationSuccessCopyWith<$Res> {
  _$CreateConversationSuccessCopyWithImpl(this._self, this._then);

  final CreateConversationSuccess _self;
  final $Res Function(CreateConversationSuccess) _then;

/// Create a copy of CreateConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conversation = null,}) {
  return _then(CreateConversationSuccess(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ConversationDetail,
  ));
}


}

/// @nodoc


class CreateConversationError implements CreateConversationState {
  const CreateConversationError({required this.message});
  

 final  String message;

/// Create a copy of CreateConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateConversationErrorCopyWith<CreateConversationError> get copyWith => _$CreateConversationErrorCopyWithImpl<CreateConversationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateConversationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CreateConversationState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $CreateConversationErrorCopyWith<$Res> implements $CreateConversationStateCopyWith<$Res> {
  factory $CreateConversationErrorCopyWith(CreateConversationError value, $Res Function(CreateConversationError) _then) = _$CreateConversationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CreateConversationErrorCopyWithImpl<$Res>
    implements $CreateConversationErrorCopyWith<$Res> {
  _$CreateConversationErrorCopyWithImpl(this._self, this._then);

  final CreateConversationError _self;
  final $Res Function(CreateConversationError) _then;

/// Create a copy of CreateConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CreateConversationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
