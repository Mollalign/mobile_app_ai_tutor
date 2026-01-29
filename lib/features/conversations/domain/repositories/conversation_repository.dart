import '../entities/entities.dart';
import '../../data/datasources/datasources.dart';

/// Repository interface for conversations.
abstract class ConversationRepository {
  /// Create a new conversation.
  Future<ConversationDetail> createConversation({
    String? projectId,
    String? title,
    bool isSocratic = true,
    String? initialMessage,
  });

  /// List conversations.
  Future<List<Conversation>> getConversations({
    String? projectId,
    int skip = 0,
    int limit = 50,
  });

  /// Get conversation with messages.
  Future<ConversationDetail> getConversation(String conversationId);

  /// Update conversation.
  Future<Conversation> updateConversation({
    required String conversationId,
    String? title,
    bool? isSocratic,
  });

  /// Delete conversation.
  Future<void> deleteConversation(String conversationId);

  /// Send a message (non-streaming).
  Future<Message> sendMessage({
    required String conversationId,
    required String message,
  });

  /// Send a message with streaming response.
  Stream<StreamChunk> sendMessageStream({
    required String conversationId,
    required String message,
  });
}
