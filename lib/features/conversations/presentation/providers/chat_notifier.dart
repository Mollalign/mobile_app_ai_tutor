import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/datasources.dart';
import '../../data/mappers/mappers.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'conversation_state.dart';

// ============================================================
// Provider
// ============================================================

/// Provider for a single chat conversation.
final chatNotifierProvider =
    Provider.family.autoDispose<ChatChangeNotifier, String>(
  (ref, conversationId) {
    final repository = ref.watch(conversationRepositoryProvider);
    final notifier = ChatChangeNotifier(
      repository: repository,
      conversationId: conversationId,
    );
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);

// ============================================================
// Chat Notifier
// ============================================================

/// Notifier that manages the state of a single chat conversation.
class ChatChangeNotifier extends ChangeNotifier {
  final ConversationRepository _repository;
  final String _conversationId;

  ChatState _state = const ChatState.initial();
  ChatState get state => _state;

  StreamSubscription<StreamChunk>? _streamSubscription;

  ChatChangeNotifier({
    required ConversationRepository repository,
    required String conversationId,
  })  : _repository = repository,
        _conversationId = conversationId;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Load the conversation with messages.
  Future<void> loadChat() async {
    _state = const ChatState.loading();
    notifyListeners();

    try {
      debugPrint('Loading chat: conversationId=$_conversationId');
      
      final conversation = await _repository.getConversation(_conversationId).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );
      
      debugPrint('Loaded chat with ${conversation.messages.length} messages');
      
      _state = ChatState.loaded(
        conversation: conversation,
        messages: conversation.messages,
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading chat: $e');
      debugPrint('Stack trace: $stackTrace');
      _state = ChatState.error(message: _getErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }

  /// Send a message (non-streaming).
  Future<void> sendMessage(String content) async {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;
    if (currentState.isSending || currentState.isStreaming) return;

    // Add pending user message
    final userMessage = Message.pending(
      conversationId: _conversationId,
      content: content,
    );

    _state = currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isSending: true,
    );
    notifyListeners();

    try {
      final response = await _repository.sendMessage(
        conversationId: _conversationId,
        message: content,
      );

      // Replace pending message and add AI response
      final updatedMessages =
          currentState.messages.where((m) => !m.isPending).toList();

      // Add the actual user message
      final actualUserMessage = Message(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: _conversationId,
        role: MessageRole.user,
        content: content,
        createdAt: DateTime.now(),
      );

      _state = currentState.copyWith(
        messages: [...updatedMessages, actualUserMessage, response],
        isSending: false,
      );
    } catch (e) {
      // Remove pending message on error
      _state = currentState.copyWith(
        messages: currentState.messages.where((m) => !m.isPending).toList(),
        isSending: false,
      );
    }

    notifyListeners();
  }

  /// Send a message with streaming response.
  Future<void> sendMessageStreaming(String content) async {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;
    if (currentState.isSending || currentState.isStreaming) return;

    // Cancel any existing stream
    await _streamSubscription?.cancel();

    // Add user message
    final userMessage = Message(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
    );

    // Add streaming placeholder for AI
    final streamingMessage = Message.streaming(conversationId: _conversationId);

    _state = currentState.copyWith(
      messages: [...currentState.messages, userMessage, streamingMessage],
      isStreaming: true,
      streamingContent: '',
      pendingSources: null,
    );
    notifyListeners();

    String accumulatedContent = '';
    List<SourceCitation>? sources;
    String? finalMessageId;

    _streamSubscription = _repository
        .sendMessageStream(
      conversationId: _conversationId,
      message: content,
    )
        .listen(
      (chunk) {
        if (_state is! ChatLoaded) return;
        final loadedState = _state as ChatLoaded;

        if (chunk.hasSources && chunk.sources != null) {
          sources = chunk.sources!
              .map((s) => ConversationMapper.sourceCitationFromModel(s))
              .toList();
          _state = loadedState.copyWith(pendingSources: sources);
          notifyListeners();
        } else if (chunk.isContent && chunk.content != null) {
          accumulatedContent += chunk.content!;

          // Update the streaming message content
          final messages = loadedState.messages.map((m) {
            if (m.isStreaming) {
              return m.copyWithContent(accumulatedContent);
            }
            return m;
          }).toList();

          _state = loadedState.copyWith(
            messages: messages,
            streamingContent: accumulatedContent,
          );
          notifyListeners();
        } else if (chunk.isDone) {
          finalMessageId = chunk.messageId;
          _finishStreaming(finalMessageId, accumulatedContent, sources);
        } else if (chunk.isError) {
          _handleStreamError(chunk.error ?? 'Unknown error');
        }
      },
      onError: (error) {
        _handleStreamError(_getErrorMessage(error));
      },
      onDone: () {
        // If we haven't received a done event, finish anyway
        if (_state is ChatLoaded) {
          final loadedState = _state as ChatLoaded;
          if (loadedState.isStreaming) {
            _finishStreaming(finalMessageId, accumulatedContent, sources);
          }
        }
      },
    );
  }

  void _finishStreaming(
    String? messageId,
    String content,
    List<SourceCitation>? sources,
  ) {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;

    // Replace streaming message with final message
    final messages = currentState.messages.map((m) {
      if (m.isStreaming) {
        return m.finishStreaming(
          finalId: messageId ?? 'ai-${DateTime.now().millisecondsSinceEpoch}',
          finalSources: sources,
        );
      }
      return m;
    }).toList();

    _state = currentState.copyWith(
      messages: messages,
      isStreaming: false,
      streamingContent: null,
      pendingSources: null,
    );
    notifyListeners();
  }

  void _handleStreamError(String error) {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;

    // Remove the streaming message on error
    final messages =
        currentState.messages.where((m) => !m.isStreaming).toList();

    _state = currentState.copyWith(
      messages: messages,
      isStreaming: false,
      streamingContent: null,
      pendingSources: null,
    );
    notifyListeners();
  }

  /// Toggle Socratic mode.
  Future<void> toggleSocraticMode() async {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;

    try {
      final updated = await _repository.updateConversation(
        conversationId: _conversationId,
        isSocratic: !currentState.conversation.isSocratic,
      );

      // Update conversation in state
      final updatedConversation = ConversationDetail(
        id: currentState.conversation.id,
        userId: currentState.conversation.userId,
        projectId: currentState.conversation.projectId,
        projectName: currentState.conversation.projectName,
        title: updated.title,
        isSocratic: updated.isSocratic,
        createdAt: currentState.conversation.createdAt,
        updatedAt: updated.updatedAt,
        messageCount: currentState.conversation.messageCount,
        lastMessageAt: currentState.conversation.lastMessageAt,
        chatType: currentState.conversation.chatType,
        messages: currentState.messages,
      );

      _state = currentState.copyWith(conversation: updatedConversation);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  /// Update conversation title.
  Future<void> updateTitle(String title) async {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;

    try {
      final updated = await _repository.updateConversation(
        conversationId: _conversationId,
        title: title,
      );

      final updatedConversation = ConversationDetail(
        id: currentState.conversation.id,
        userId: currentState.conversation.userId,
        projectId: currentState.conversation.projectId,
        projectName: currentState.conversation.projectName,
        title: updated.title,
        isSocratic: currentState.conversation.isSocratic,
        createdAt: currentState.conversation.createdAt,
        updatedAt: updated.updatedAt,
        messageCount: currentState.conversation.messageCount,
        lastMessageAt: currentState.conversation.lastMessageAt,
        chatType: currentState.conversation.chatType,
        messages: currentState.messages,
      );

      _state = currentState.copyWith(conversation: updatedConversation);
      notifyListeners();
    } catch (e) {
      // Handle error
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
    return 'An error occurred. Please try again.';
  }
}
