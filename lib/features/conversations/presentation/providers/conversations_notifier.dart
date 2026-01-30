import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'conversation_state.dart';

// ============================================================
// Providers
// ============================================================

/// Provider for all conversations (no project filter).
final conversationsNotifierProvider =
    Provider.autoDispose<ConversationsChangeNotifier>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  final notifier = ConversationsChangeNotifier(repository: repository);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider for project-specific conversations.
final projectConversationsNotifierProvider =
    Provider.family.autoDispose<ConversationsChangeNotifier, String>(
  (ref, projectId) {
    final repository = ref.watch(conversationRepositoryProvider);
    final notifier = ConversationsChangeNotifier(
      repository: repository,
      projectId: projectId,
    );
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);

// ============================================================
// Conversations Notifier
// ============================================================

/// Notifier that manages the list of conversations.
class ConversationsChangeNotifier extends ChangeNotifier {
  final ConversationRepository _repository;
  final String? _projectId;
  bool _disposed = false;

  ConversationsState _state = const ConversationsState.initial();
  ConversationsState get state => _state;

  static const int _pageSize = 20;
  int _currentPage = 0;

  ConversationsChangeNotifier({
    required ConversationRepository repository,
    String? projectId,
  })  : _repository = repository,
        _projectId = projectId {
    // Auto-load conversations when notifier is created
    loadConversations();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final shouldDefer = phase != SchedulerPhase.idle;

    if (shouldDefer) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          super.notifyListeners();
        }
      });
      return;
    }

    super.notifyListeners();
  }

  /// Load conversations (initial load or refresh).
  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
    }

    if (_state is! ConversationsLoaded || refresh) {
      _state = const ConversationsState.loading();
      notifyListeners();
    }

    try {
      debugPrint('Loading conversations: projectId=$_projectId, skip=${_currentPage * _pageSize}, limit=$_pageSize');
      
      final conversations = await _repository.getConversations(
        projectId: _projectId,
        skip: _currentPage * _pageSize,
        limit: _pageSize,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      debugPrint('Loaded ${conversations.length} conversations');

      List<Conversation> updatedList;
      if (refresh || _currentPage == 0) {
        updatedList = conversations;
      } else if (_state is ConversationsLoaded) {
        updatedList = [
          ...(_state as ConversationsLoaded).conversations,
          ...conversations,
        ];
      } else {
        updatedList = conversations;
      }

      _currentPage++;

      _state = ConversationsState.loaded(
        conversations: updatedList,
        total: updatedList.length,
        hasMore: conversations.length >= _pageSize,
        isLoadingMore: false,
      );
      
      debugPrint('State updated to loaded with ${updatedList.length} conversations');
    } catch (e, stackTrace) {
      // Log error for debugging
      debugPrint('Error loading conversations: $e');
      debugPrint('Stack trace: $stackTrace');
      _state = ConversationsState.error(message: _getErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }

  /// Load more conversations.
  Future<void> loadMore() async {
    if (_state is! ConversationsLoaded) return;
    final currentState = _state as ConversationsLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    _state = currentState.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final conversations = await _repository.getConversations(
        projectId: _projectId,
        skip: _currentPage * _pageSize,
        limit: _pageSize,
      );

      _currentPage++;

      _state = currentState.copyWith(
        conversations: [...currentState.conversations, ...conversations],
        total: currentState.total + conversations.length,
        hasMore: conversations.length >= _pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      _state = currentState.copyWith(isLoadingMore: false);
    }

    notifyListeners();
  }

  /// Delete a conversation.
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);

      if (_state is ConversationsLoaded) {
        final currentState = _state as ConversationsLoaded;
        final updatedList = currentState.conversations
            .where((c) => c.id != conversationId)
            .toList();
        _state = currentState.copyWith(
          conversations: updatedList,
          total: currentState.total - 1,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add a new conversation to the list.
  void addConversation(Conversation conversation) {
    if (_state is ConversationsLoaded) {
      final currentState = _state as ConversationsLoaded;
      _state = currentState.copyWith(
        conversations: [conversation, ...currentState.conversations],
        total: currentState.total + 1,
      );
      notifyListeners();
    } else {
      // If not loaded yet, create a new loaded state with just this conversation
      _state = ConversationsState.loaded(
        conversations: [conversation],
        total: 1,
        hasMore: false,
        isLoadingMore: false,
      );
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return 'Failed to load conversations. Please try again.';
  }
}
