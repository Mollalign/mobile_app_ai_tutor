import '../../domain/entities/entities.dart' as entities;
import '../models/models.dart';

/// Mapper for converting conversation models to entities.
class ConversationMapper {
  /// Convert SourceCitationModel to SourceCitation.
  static entities.SourceCitation sourceCitationFromModel(SourceCitationModel model) {
    return entities.SourceCitation(
      documentId: model.documentId,
      documentName: model.documentName,
      pageNumber: model.pageNumber,
      relevanceScore: model.relevanceScore,
      excerpt: model.excerpt,
    );
  }

  /// Convert MessageModel to Message.
  static entities.Message messageFromModel(MessageModel model) {
    return entities.Message(
      id: model.id,
      conversationId: model.conversationId,
      role: entities.MessageRole.fromString(model.role),
      content: model.content,
      sources: model.sources
              ?.map((s) => sourceCitationFromModel(s))
              .toList() ??
          [],
      tokensUsed: model.tokensUsed,
      createdAt: model.createdAt,
    );
  }

  /// Convert ConversationModel to Conversation.
  static entities.Conversation conversationFromModel(ConversationModel model) {
    return entities.Conversation(
      id: model.id,
      userId: model.userId,
      projectId: model.projectId,
      projectName: model.projectName,
      title: model.title,
      isSocratic: model.isSocratic,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      messageCount: model.messageCount,
      lastMessageAt: model.lastMessageAt,
      chatType: entities.ChatType.fromString(model.chatType),
    );
  }

  /// Convert ConversationWithMessagesModel to ConversationDetail.
  static entities.ConversationDetail conversationDetailFromModel(
    ConversationWithMessagesModel model,
  ) {
    return entities.ConversationDetail(
      id: model.id,
      userId: model.userId,
      projectId: model.projectId,
      projectName: model.projectName,
      title: model.title,
      isSocratic: model.isSocratic,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      messageCount: model.messageCount,
      lastMessageAt: model.lastMessageAt,
      chatType: entities.ChatType.fromString(model.chatType),
      messages: model.messages.map((m) => messageFromModel(m)).toList(),
    );
  }

  /// Convert ChatResponseModel to Message (the AI response).
  static entities.Message messageFromChatResponse(ChatResponseModel response) {
    return entities.Message(
      id: response.message.id,
      conversationId: response.message.conversationId,
      role: entities.MessageRole.fromString(response.message.role),
      content: response.message.content,
      sources: response.sources.map((s) => sourceCitationFromModel(s)).toList(),
      tokensUsed: response.tokensUsed,
      createdAt: response.message.createdAt,
    );
  }
}
