import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/sharing_models.dart';

/// Remote data source for sharing operations.
class SharingRemoteDataSource {
  final ApiClient _apiClient;

  SharingRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE PUBLIC SHARE
  // ============================================================

  /// Create a public share link for a conversation.
  Future<SharedConversationModel> createPublicShare({
    required String conversationId,
    String? title,
    bool allowReplies = true,
    int? expiresInDays,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.shares,
      queryParameters: {'conversation_id': conversationId},
      data: {
        if (title != null) 'title': title,
        'allow_replies': allowReplies,
        if (expiresInDays != null) 'expires_in_days': expiresInDays,
      },
    );

    return SharedConversationModel.fromJson(response.data!);
  }

  // ============================================================
  // LIST MY SHARES
  // ============================================================

  /// List shares created by the current user.
  Future<SharedByMeListModel> getMyShares({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.shares,
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );

    return SharedByMeListModel.fromJson(response.data!);
  }

  // ============================================================
  // GET SHARE DETAILS
  // ============================================================

  /// Get share details.
  Future<SharedConversationModel> getShare(String shareId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.share(shareId),
    );

    return SharedConversationModel.fromJson(response.data!);
  }

  // ============================================================
  // UPDATE SHARE
  // ============================================================

  /// Update share settings.
  Future<SharedConversationModel> updateShare({
    required String shareId,
    String? title,
    bool? allowReplies,
    bool? isActive,
    int? expiresInDays,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.share(shareId),
      data: {
        if (title != null) 'title': title,
        if (allowReplies != null) 'allow_replies': allowReplies,
        if (isActive != null) 'is_active': isActive,
        if (expiresInDays != null) 'expires_in_days': expiresInDays,
      },
    );

    return SharedConversationModel.fromJson(response.data!);
  }

  // ============================================================
  // DELETE SHARE
  // ============================================================

  /// Delete a share.
  Future<void> deleteShare(String shareId) async {
    await _apiClient.delete<void>(ApiConstants.share(shareId));
  }

  // ============================================================
  // GET SHARE STATS
  // ============================================================

  /// Get statistics for a share.
  Future<ShareStatsModel> getShareStats(String shareId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.shareStats(shareId),
    );

    return ShareStatsModel.fromJson(response.data!);
  }

  // ============================================================
  // VIEW SHARED CONVERSATION (PUBLIC - NO AUTH)
  // ============================================================

  /// View a shared conversation by token.
  Future<SharedConversationFullModel> getSharedConversation(String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.sharedConversation(token),
    );

    return SharedConversationFullModel.fromJson(response.data!);
  }

  // ============================================================
  // FORK SHARED CONVERSATION
  // ============================================================

  /// Fork a shared conversation to create your own copy.
  Future<ConversationForkModel> forkSharedConversation({
    required String token,
    String? initialMessage,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.forkSharedConversation(token),
      data: {
        if (initialMessage != null) 'initial_message': initialMessage,
      },
    );

    return ConversationForkModel.fromJson(response.data!);
  }

  // ============================================================
  // FORK MY CONVERSATION
  // ============================================================

  /// Fork a conversation you have access to.
  Future<ConversationForkModel> forkConversation({
    required String conversationId,
    String? initialMessage,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.forkConversation(conversationId),
      data: {
        if (initialMessage != null) 'initial_message': initialMessage,
      },
    );

    return ConversationForkModel.fromJson(response.data!);
  }

  // ============================================================
  // LIST SHARED WITH ME
  // ============================================================

  /// List conversations shared with the current user.
  Future<SharedWithMeListModel> getSharedWithMe({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.sharedWithMe,
      queryParameters: {
        'skip': skip,
        'limit': limit,
      },
    );

    return SharedWithMeListModel.fromJson(response.data!);
  }

  // ============================================================
  // PRIVATE SHARING
  // ============================================================

  /// Share a conversation privately with specific users.
  Future<List<Map<String, dynamic>>> sharePrivately({
    required String conversationId,
    required List<String> userEmails,
    bool canReply = true,
  }) async {
    try {
      final response = await _apiClient.post<List<dynamic>>(
        ApiConstants.sharePrivate(conversationId),
        data: {
          'user_emails': userEmails,
          'can_reply': canReply,
        },
      );

      return response.data!.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error sharing privately: $e');
      rethrow;
    }
  }

  /// Revoke a user's access to a conversation.
  Future<void> revokeAccess({
    required String conversationId,
    required String userId,
  }) async {
    await _apiClient.delete<void>(
      ApiConstants.revokeAccess(conversationId, userId),
    );
  }
}
