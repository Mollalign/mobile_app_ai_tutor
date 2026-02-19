/// Message role enum for UI.
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

  bool get isUser => this == MessageRole.user;
  bool get isAssistant => this == MessageRole.assistant;
  bool get isSystem => this == MessageRole.system;
}

/// Chat type enum for UI.
enum ChatType {
  quick,
  project;

  factory ChatType.fromString(String value) {
    return ChatType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatType.quick,
    );
  }

  bool get isQuick => this == ChatType.quick;
  bool get isProject => this == ChatType.project;

  String get displayName {
    switch (this) {
      case ChatType.quick:
        return 'Quick Chat';
      case ChatType.project:
        return 'Project Chat';
    }
  }

  String get description {
    switch (this) {
      case ChatType.quick:
        return 'Chat using general AI knowledge';
      case ChatType.project:
        return 'Chat using your project documents';
    }
  }
}

/// Source citation entity.
class SourceCitation {
  final String documentId;
  final String documentName;
  final int? pageNumber;
  final double relevanceScore;
  final String? excerpt;

  const SourceCitation({
    required this.documentId,
    required this.documentName,
    this.pageNumber,
    required this.relevanceScore,
    this.excerpt,
  });

  /// Display text for the citation.
  String get displayText {
    if (pageNumber != null) {
      return '$documentName (p. $pageNumber)';
    }
    return documentName;
  }

  /// Relevance as percentage.
  int get relevancePercent => (relevanceScore * 100).round();
}

/// Message entity for UI.
class Message {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final List<SourceCitation> sources;
  final int? tokensUsed;
  final DateTime createdAt;
  
  /// For pending messages (being streamed).
  final bool isPending;
  final bool isStreaming;
  
  /// Whether this message has an image attachment.
  final bool hasImageAttachment;
  
  /// Attachment metadata (URLs, extracted content, etc.).
  final Map<String, dynamic>? attachments;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.sources = const [],
    this.tokensUsed,
    required this.createdAt,
    this.isPending = false,
    this.isStreaming = false,
    this.hasImageAttachment = false,
    this.attachments,
  });

  /// Create a pending user message.
  factory Message.pending({
    required String conversationId,
    required String content,
  }) {
    return Message(
      id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
      isPending: true,
    );
  }

  /// Create a streaming assistant message.
  factory Message.streaming({
    required String conversationId,
  }) {
    return Message(
      id: 'streaming-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
  }

  /// Whether this message has sources.
  bool get hasSources => sources.isNotEmpty;

  /// Get relative time since creation.
  String get createdRelative {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Copy with updated content (for streaming).
  Message copyWithContent(String newContent) {
    return Message(
      id: id,
      conversationId: conversationId,
      role: role,
      content: newContent,
      sources: sources,
      tokensUsed: tokensUsed,
      createdAt: createdAt,
      isPending: isPending,
      isStreaming: isStreaming,
      hasImageAttachment: hasImageAttachment,
      attachments: attachments,
    );
  }

  /// Copy with streaming finished.
  Message finishStreaming({
    required String finalId,
    List<SourceCitation>? finalSources,
  }) {
    return Message(
      id: finalId,
      conversationId: conversationId,
      role: role,
      content: content,
      sources: finalSources ?? sources,
      tokensUsed: tokensUsed,
      createdAt: createdAt,
      isPending: false,
      isStreaming: false,
      hasImageAttachment: hasImageAttachment,
      attachments: attachments,
    );
  }
}

/// Conversation entity for UI.
class Conversation {
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
  final ChatType chatType;

  const Conversation({
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

  /// Display title (auto-generated if none).
  String get displayTitle => title ?? 'New conversation';

  /// Whether this is a project chat.
  bool get isProjectChat => chatType.isProject && projectId != null;

  /// Whether this is a quick chat.
  bool get isQuickChat => chatType.isQuick;

  /// Get relative time since last activity.
  String get lastActivityRelative {
    final time = lastMessageAt ?? updatedAt;
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (diff.inDays > 0) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return diff.inMinutes == 1 ? '1 minute ago' : '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// Conversation with messages for chat view.
class ConversationDetail extends Conversation {
  final List<Message> messages;

  const ConversationDetail({
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

  /// Get the last message preview.
  String? get lastMessagePreview {
    if (messages.isEmpty) return null;
    final lastMessage = messages.last;
    final preview = lastMessage.content;
    if (preview.length > 100) {
      return '${preview.substring(0, 100)}...';
    }
    return preview;
  }
}
