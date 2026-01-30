import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/entities.dart';

part 'conversation_state.freezed.dart';

// ============================================================
// CONVERSATIONS LIST STATE
// ============================================================

/// State for the list of conversations.
@freezed
class ConversationsState with _$ConversationsState {
  /// Initial state.
  const factory ConversationsState.initial() = ConversationsInitial;

  /// Loading conversations.
  const factory ConversationsState.loading() = ConversationsLoading;

  /// Conversations loaded successfully.
  const factory ConversationsState.loaded({
    required List<Conversation> conversations,
    required int total,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = ConversationsLoaded;

  /// Error loading conversations.
  const factory ConversationsState.error({required String message}) =
      ConversationsError;
}

// ============================================================
// CHAT STATE (for a single conversation)
// ============================================================

/// State for the chat screen.
@freezed
class ChatState with _$ChatState {
  /// Initial state.
  const factory ChatState.initial() = ChatInitial;

  /// Loading conversation and messages.
  const factory ChatState.loading() = ChatLoading;

  /// Chat loaded successfully.
  const factory ChatState.loaded({
    required ConversationDetail conversation,
    required List<Message> messages,
    @Default(false) bool isSending,
    @Default(false) bool isStreaming,
    String? streamingContent,
    List<SourceCitation>? pendingSources,
  }) = ChatLoaded;

  /// Error loading chat.
  const factory ChatState.error({required String message}) = ChatError;
}

// ============================================================
// CREATE CONVERSATION STATE
// ============================================================

/// State for creating a new conversation.
@freezed
class CreateConversationState with _$CreateConversationState {
  /// Initial state.
  const factory CreateConversationState.initial() = CreateConversationInitial;

  /// Creating conversation.
  const factory CreateConversationState.loading() = CreateConversationLoading;

  /// Conversation created successfully.
  const factory CreateConversationState.success({
    required ConversationDetail conversation,
  }) = CreateConversationSuccess;

  /// Error creating conversation.
  const factory CreateConversationState.error({required String message}) =
      CreateConversationError;
}
