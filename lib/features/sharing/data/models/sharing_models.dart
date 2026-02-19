// Sharing models for API communication.
// Matches the backend sharing schemas.

// ============================================================
// ENUMS
// ============================================================

enum ShareType {
  publicLink,
  private;

  factory ShareType.fromString(String value) {
    switch (value) {
      case 'public_link':
        return ShareType.publicLink;
      case 'private':
        return ShareType.private;
      default:
        return ShareType.publicLink;
    }
  }

  String toJson() {
    switch (this) {
      case ShareType.publicLink:
        return 'public_link';
      case ShareType.private:
        return 'private';
    }
  }
}

// ============================================================
// SHARED CONVERSATION MODEL
// ============================================================

/// Model for a public share link.
class SharedConversationModel {
  final String id;
  final String conversationId;
  final String shareToken;
  final String? title;
  final ShareType shareType;
  final bool allowReplies;
  final bool isActive;
  final DateTime? expiresAt;
  final int viewCount;
  final DateTime createdAt;
  final String? shareUrl;
  final bool isExpired;

  const SharedConversationModel({
    required this.id,
    required this.conversationId,
    required this.shareToken,
    this.title,
    required this.shareType,
    required this.allowReplies,
    required this.isActive,
    this.expiresAt,
    required this.viewCount,
    required this.createdAt,
    this.shareUrl,
    this.isExpired = false,
  });

  factory SharedConversationModel.fromJson(Map<String, dynamic> json) {
    return SharedConversationModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      shareToken: json['share_token'] as String,
      title: json['title'] as String?,
      shareType: ShareType.fromString(json['share_type'] as String? ?? 'public_link'),
      allowReplies: json['allow_replies'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      shareUrl: json['share_url'] as String?,
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'share_token': shareToken,
      'title': title,
      'share_type': shareType.toJson(),
      'allow_replies': allowReplies,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'share_url': shareUrl,
      'is_expired': isExpired,
    };
  }
}

// ============================================================
// SHARED CONVERSATION PREVIEW
// ============================================================

/// Preview of a shared conversation (for recipients).
class SharedConversationPreviewModel {
  final String shareId;
  final String? title;
  final String sharedByName;
  final DateTime sharedAt;
  final int messageCount;
  final bool allowReplies;
  final bool isSocratic;
  final List<Map<String, dynamic>> previewMessages;

  const SharedConversationPreviewModel({
    required this.shareId,
    this.title,
    required this.sharedByName,
    required this.sharedAt,
    required this.messageCount,
    required this.allowReplies,
    required this.isSocratic,
    this.previewMessages = const [],
  });

  factory SharedConversationPreviewModel.fromJson(Map<String, dynamic> json) {
    return SharedConversationPreviewModel(
      shareId: json['share_id'] as String,
      title: json['title'] as String?,
      sharedByName: json['shared_by_name'] as String? ?? 'Unknown',
      sharedAt: DateTime.parse(json['shared_at'] as String),
      messageCount: json['message_count'] as int? ?? 0,
      allowReplies: json['allow_replies'] as bool? ?? true,
      isSocratic: json['is_socratic'] as bool? ?? true,
      previewMessages: (json['preview_messages'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }
}

// ============================================================
// SHARED CONVERSATION FULL
// ============================================================

/// Full shared conversation with all messages.
class SharedConversationFullModel extends SharedConversationPreviewModel {
  final String conversationId;
  final List<SharedMessageModel> messages;

  const SharedConversationFullModel({
    required super.shareId,
    super.title,
    required super.sharedByName,
    required super.sharedAt,
    required super.messageCount,
    required super.allowReplies,
    required super.isSocratic,
    super.previewMessages,
    required this.conversationId,
    required this.messages,
  });

  factory SharedConversationFullModel.fromJson(Map<String, dynamic> json) {
    return SharedConversationFullModel(
      shareId: json['share_id'] as String,
      title: json['title'] as String?,
      sharedByName: json['shared_by_name'] as String? ?? 'Unknown',
      sharedAt: DateTime.parse(json['shared_at'] as String),
      messageCount: json['message_count'] as int? ?? 0,
      allowReplies: json['allow_replies'] as bool? ?? true,
      isSocratic: json['is_socratic'] as bool? ?? true,
      previewMessages: (json['preview_messages'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      conversationId: json['conversation_id'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => SharedMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Simplified message model for shared conversations.
class SharedMessageModel {
  final String id;
  final String role;
  final String content;
  final DateTime? createdAt;

  const SharedMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
  });

  factory SharedMessageModel.fromJson(Map<String, dynamic> json) {
    return SharedMessageModel(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

// ============================================================
// CONVERSATION FORK RESPONSE
// ============================================================

/// Response after forking a shared conversation.
class ConversationForkModel {
  final String forkId;
  final String conversationId;
  final String? originalConversationId;
  final int messageCount;
  final DateTime createdAt;

  const ConversationForkModel({
    required this.forkId,
    required this.conversationId,
    this.originalConversationId,
    required this.messageCount,
    required this.createdAt,
  });

  factory ConversationForkModel.fromJson(Map<String, dynamic> json) {
    return ConversationForkModel(
      forkId: json['fork_id'] as String,
      conversationId: json['conversation_id'] as String,
      originalConversationId: json['original_conversation_id'] as String?,
      messageCount: json['message_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

// ============================================================
// SHARE STATS
// ============================================================

/// Statistics for a shared conversation.
class ShareStatsModel {
  final String shareId;
  final int viewCount;
  final int forkCount;
  final int accessGrantCount;
  final DateTime createdAt;
  final DateTime? lastViewedAt;

  const ShareStatsModel({
    required this.shareId,
    required this.viewCount,
    required this.forkCount,
    required this.accessGrantCount,
    required this.createdAt,
    this.lastViewedAt,
  });

  factory ShareStatsModel.fromJson(Map<String, dynamic> json) {
    return ShareStatsModel(
      shareId: json['share_id'] as String,
      viewCount: json['view_count'] as int? ?? 0,
      forkCount: json['fork_count'] as int? ?? 0,
      accessGrantCount: json['access_grant_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'] as String)
          : null,
    );
  }
}

// ============================================================
// LIST RESPONSES
// ============================================================

/// List of shares created by the current user.
class SharedByMeListModel {
  final List<SharedConversationModel> shares;
  final int total;

  const SharedByMeListModel({
    required this.shares,
    required this.total,
  });

  factory SharedByMeListModel.fromJson(Map<String, dynamic> json) {
    return SharedByMeListModel(
      shares: (json['shares'] as List<dynamic>)
          .map((e) => SharedConversationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

/// List of shares shared with the current user.
class SharedWithMeListModel {
  final List<SharedConversationPreviewModel> shares;
  final int total;

  const SharedWithMeListModel({
    required this.shares,
    required this.total,
  });

  factory SharedWithMeListModel.fromJson(Map<String, dynamic> json) {
    return SharedWithMeListModel(
      shares: (json['shares'] as List<dynamic>)
          .map((e) => SharedConversationPreviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
