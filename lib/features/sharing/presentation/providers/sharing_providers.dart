import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/sharing_remote_datasource.dart';
import '../../data/models/sharing_models.dart';

// ============================================================
// DATASOURCE PROVIDER
// ============================================================

final sharingDataSourceProvider = Provider<SharingRemoteDataSource>((ref) {
  return SharingRemoteDataSource();
});

// ============================================================
// MY SHARES PROVIDER
// ============================================================

final mySharesProvider = AsyncNotifierProvider<MySharesNotifier, List<SharedConversationModel>>(() {
  return MySharesNotifier();
});

class MySharesNotifier extends AsyncNotifier<List<SharedConversationModel>> {
  @override
  Future<List<SharedConversationModel>> build() async {
    return _loadShares();
  }

  Future<List<SharedConversationModel>> _loadShares() async {
    final dataSource = ref.read(sharingDataSourceProvider);
    try {
      final result = await dataSource.getMyShares();
      return result.shares;
    } catch (e) {
      debugPrint('Error loading shares: $e');
      rethrow;
    }
  }

  Future<void> loadShares() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadShares());
  }

  Future<SharedConversationModel> createShare({
    required String conversationId,
    String? title,
    bool allowReplies = true,
    int? expiresInDays,
  }) async {
    final dataSource = ref.read(sharingDataSourceProvider);
    final share = await dataSource.createPublicShare(
      conversationId: conversationId,
      title: title,
      allowReplies: allowReplies,
      expiresInDays: expiresInDays,
    );
    
    // Add to existing list
    state.whenData((shares) {
      state = AsyncValue.data([share, ...shares]);
    });
    
    return share;
  }

  Future<void> updateShare({
    required String shareId,
    String? title,
    bool? allowReplies,
    bool? isActive,
    int? expiresInDays,
  }) async {
    final dataSource = ref.read(sharingDataSourceProvider);
    final updated = await dataSource.updateShare(
      shareId: shareId,
      title: title,
      allowReplies: allowReplies,
      isActive: isActive,
      expiresInDays: expiresInDays,
    );
    
    state.whenData((shares) {
      state = AsyncValue.data(
        shares.map((s) => s.id == shareId ? updated : s).toList(),
      );
    });
  }

  Future<void> deleteShare(String shareId) async {
    final dataSource = ref.read(sharingDataSourceProvider);
    await dataSource.deleteShare(shareId);
    
    state.whenData((shares) {
      state = AsyncValue.data(
        shares.where((s) => s.id != shareId).toList(),
      );
    });
  }
}

// ============================================================
// SHARED WITH ME PROVIDER
// ============================================================

final sharedWithMeProvider = AsyncNotifierProvider<SharedWithMeNotifier, List<SharedConversationPreviewModel>>(() {
  return SharedWithMeNotifier();
});

class SharedWithMeNotifier extends AsyncNotifier<List<SharedConversationPreviewModel>> {
  @override
  Future<List<SharedConversationPreviewModel>> build() async {
    // Don't auto-load, wait for explicit load
    return [];
  }

  Future<void> loadShares() async {
    final dataSource = ref.read(sharingDataSourceProvider);
    state = const AsyncValue.loading();
    try {
      final result = await dataSource.getSharedWithMe();
      state = AsyncValue.data(result.shares);
    } catch (e, st) {
      debugPrint('Error loading shared with me: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

// ============================================================
// SHARE VIEW PROVIDER (for viewing shared conversations)
// ============================================================

final shareViewProvider = FutureProvider.family<SharedConversationFullModel, String>((ref, token) async {
  final dataSource = ref.watch(sharingDataSourceProvider);
  return dataSource.getSharedConversation(token);
});

// ============================================================
// SHARE STATS PROVIDER
// ============================================================

final shareStatsProvider = FutureProvider.family<ShareStatsModel, String>((ref, shareId) async {
  final dataSource = ref.watch(sharingDataSourceProvider);
  return dataSource.getShareStats(shareId);
});

// ============================================================
// SHARE ACTIONS
// ============================================================

class ShareActions {
  final SharingRemoteDataSource _dataSource;

  ShareActions(this._dataSource);

  Future<ConversationForkModel> forkSharedConversation({
    required String token,
    String? initialMessage,
  }) {
    return _dataSource.forkSharedConversation(
      token: token,
      initialMessage: initialMessage,
    );
  }

  Future<ConversationForkModel> forkConversation({
    required String conversationId,
    String? initialMessage,
  }) {
    return _dataSource.forkConversation(
      conversationId: conversationId,
      initialMessage: initialMessage,
    );
  }

  Future<List<Map<String, dynamic>>> sharePrivately({
    required String conversationId,
    required List<String> userEmails,
    bool canReply = true,
  }) {
    return _dataSource.sharePrivately(
      conversationId: conversationId,
      userEmails: userEmails,
      canReply: canReply,
    );
  }

  Future<void> revokeAccess({
    required String conversationId,
    required String userId,
  }) {
    return _dataSource.revokeAccess(
      conversationId: conversationId,
      userId: userId,
    );
  }
}

final shareActionsProvider = Provider<ShareActions>((ref) {
  return ShareActions(ref.watch(sharingDataSourceProvider));
});
