// Conversation and Message models for API communication.
// Matches the backend ConversationResponse and MessageResponse schemas.

// ============================================================
// ENUMS
// ============================================================

/// Message sender role.
enum MessageRole {
  user,
  assistant,
  system;

  factory MessageRole.fromString(String value) {
    return MessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRole.user,
    );
  }
}

/// Type of chat session.
enum ChatType {
  quick,    // No project, general knowledge
  project;  // Uses project documents

  factory ChatType.fromString(String value) {
    return ChatType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatType.quick,
    );
  }

  String get displayName {
    switch (this) {
      case ChatType.quick:
        return 'Quick Chat';
      case ChatType.project:
        return 'Project Chat';
    }
  }
}

// ============================================================
// SOURCE CITATION MODEL
// ============================================================

/// A single source citation for AI responses.
class SourceCitationModel {
  final String documentId;
  final String documentName;
  final int? pageNumber;
  final double relevanceScore;
  final String? excerpt;

  const SourceCitationModel({
    required this.documentId,
    required this.documentName,
    this.pageNumber,
    required this.relevanceScore,
    this.excerpt,
  });

  factory SourceCitationModel.fromJson(Map<String, dynamic> json) {
    return SourceCitationModel(
      documentId: json['document_id'] as String,
      documentName: json['document_name'] as String,
      pageNumber: json['page_number'] as int?,
      relevanceScore: (json['relevance_score'] as num).toDouble(),
      excerpt: json['excerpt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'document_name': documentName,
      'page_number': pageNumber,
      'relevance_score': relevanceScore,
      'excerpt': excerpt,
    };
  }
}

// ============================================================
// MESSAGE MODEL
// ============================================================

/// Message model for API communication.
class MessageModel {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final List<SourceCitationModel>? sources;
  final int? tokensUsed;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.sources,
    this.tokensUsed,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      sources: json['sources'] != null
          ? (json['sources'] as List<dynamic>)
              .map((e) => SourceCitationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      tokensUsed: json['tokens_used'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'sources': sources?.map((e) => e.toJson()).toList(),
      'tokens_used': tokensUsed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ============================================================
// CONVERSATION MODEL
// ============================================================

/// Conversation model for API communication.
class ConversationModel {
  final String id;
  final String userId;
  final String? projectId;
  final String? projectName;
  final String? title;
  final bool isSocratic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final DateTime? lastMessageAt;
  final String chatType;

  const ConversationModel({
    required this.id,
    required this.userId,
    this.projectId,
    this.projectName,
    this.title,
    required this.isSocratic,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessageAt,
    required this.chatType,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      projectName: json['project_name'] as String?,
      title: json['title'] as String?,
      isSocratic: json['is_socratic'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messageCount: (json['message_count'] as int?) ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      chatType: (json['chat_type'] as String?) ?? 'quick',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'title': title,
      'is_socratic': isSocratic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'message_count': messageCount,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'chat_type': chatType,
    };
  }
}

/// Conversation with messages for chat view.
class ConversationWithMessagesModel extends ConversationModel {
  final List<MessageModel> messages;

  const ConversationWithMessagesModel({
    required super.id,
    required super.userId,
    super.projectId,
    super.projectName,
    super.title,
    required super.isSocratic,
    required super.createdAt,
    required super.updatedAt,
    required super.messageCount,
    super.lastMessageAt,
    required super.chatType,
    required this.messages,
  });

  factory ConversationWithMessagesModel.fromJson(Map<String, dynamic> json) {
    return ConversationWithMessagesModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      title: json['title'] as String?,
      isSocratic: json['is_socratic'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messageCount: (json['message_count'] as int?) ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      chatType: (json['chat_type'] as String?) ?? 'quick',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projectName: json['project_name'] as String?,
    );
  }
}

/// Conversation list response.
class ConversationListModel {
  final List<ConversationModel> conversations;
  final int total;

  const ConversationListModel({
    required this.conversations,
    required this.total,
  });

  factory ConversationListModel.fromJson(Map<String, dynamic> json) {
    return ConversationListModel(
      conversations: (json['conversations'] as List<dynamic>)
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}

/// Chat response (non-streaming).
class ChatResponseModel {
  final MessageModel message;
  final List<SourceCitationModel> sources;
  final int tokensUsed;

  const ChatResponseModel({
    required this.message,
    required this.sources,
    required this.tokensUsed,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      message: MessageModel.fromJson(json['message'] as Map<String, dynamic>),
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => SourceCitationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tokensUsed: (json['tokens_used'] as int?) ?? 0,
    );
  }
}
