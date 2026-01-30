import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'conversation_state.dart';

// ============================================================
// Provider
// ============================================================

/// Provider for creating conversations.
/// NOTE: Not autoDispose to prevent disposal during async operations.
final createConversationNotifierProvider =
    Provider<CreateConversationChangeNotifier>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  final notifier = CreateConversationChangeNotifier(repository: repository);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

// ============================================================
// Create Conversation Notifier
// ============================================================

/// Notifier for creating new conversations.
class CreateConversationChangeNotifier extends ChangeNotifier {
  final ConversationRepository _repository;
  bool _disposed = false;

  CreateConversationState _state = const CreateConversationState.initial();
  CreateConversationState get state => _state;

  CreateConversationChangeNotifier({required ConversationRepository repository})
      : _repository = repository;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Create a new conversation.
  Future<ConversationDetail?> createConversation({
    String? projectId,
    String? title,
    bool isSocratic = true,
    String? initialMessage,
  }) async {
    _state = const CreateConversationState.loading();
    _safeNotifyListeners();

    try {
      final conversation = await _repository.createConversation(
        projectId: projectId,
        title: title,
        isSocratic: isSocratic,
        initialMessage: initialMessage,
      );

      _state = CreateConversationState.success(conversation: conversation);
      _safeNotifyListeners();
      return conversation;
    } catch (e) {
      debugPrint('Error in createConversation: $e');
      _state = CreateConversationState.error(message: _getErrorMessage(e));
      _safeNotifyListeners();
      return null;
    }
  }

  /// Reset state to initial.
  void reset() {
    _state = const CreateConversationState.initial();
    _safeNotifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return 'Failed to create conversation. Please try again.';
  }
}
