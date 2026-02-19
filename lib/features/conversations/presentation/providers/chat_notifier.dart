import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/websocket_service.dart';
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
/// 
/// Features:
/// - Real-time message synchronization via WebSocket
/// - Streaming AI responses via SSE
/// - Optimistic UI updates
class ChatChangeNotifier extends ChangeNotifier {
  final ConversationRepository _repository;
  final String _conversationId;
  final WebSocketService _wsService = WebSocketService();
  bool _disposed = false;

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
    _disposed = true;
    _streamSubscription?.cancel();
    
    // Clean up WebSocket connection
    _wsService.removeAllListeners(_conversationId);
    _wsService.disconnect(_conversationId);
    
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    // Always notify immediately - streaming needs real-time updates
    super.notifyListeners();
  }
  
  /// Safely notify listeners, deferring if during build phase.
  /// Use this for non-streaming updates.
  void _safeNotifyListeners() {
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

  /// Load the conversation with messages.
  Future<void> loadChat() async {
    _state = const ChatState.loading();
    _safeNotifyListeners();

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
      
      // Connect to WebSocket for real-time updates
      _connectWebSocket();
    } catch (e, stackTrace) {
      debugPrint('Error loading chat: $e');
      debugPrint('Stack trace: $stackTrace');
      _state = ChatState.error(message: _getErrorMessage(e));
    } finally {
      _safeNotifyListeners();
    }
  }
  
  /// Connect to WebSocket for real-time message sync.
  void _connectWebSocket() {
    // Add listener for incoming messages
    _wsService.addListener(_conversationId, _handleWebSocketMessage);
    
    // Connect to WebSocket
    _wsService.connect(_conversationId).then((connected) {
      if (connected) {
        debugPrint('WebSocket: Connected for conversation $_conversationId');
      } else {
        debugPrint('WebSocket: Failed to connect for conversation $_conversationId');
      }
    });
  }
  
  /// Handle incoming WebSocket messages.
  void _handleWebSocketMessage(WebSocketMessage message) {
    if (_disposed) return;
    if (_state is! ChatLoaded) return;
    
    debugPrint('WebSocket: Handling message type=${message.type}');
    
    if (message.isNewMessage) {
      _handleNewMessage(message.data);
    } else if (message.isError) {
      debugPrint('WebSocket: Error - ${message.data['error']}');
    }
  }
  
  /// Handle a new message from WebSocket.
  void _handleNewMessage(Map<String, dynamic> data) {
    if (_state is! ChatLoaded) return;
    final currentState = _state as ChatLoaded;
    
    try {
      // Parse the message data
      final messageId = data['id'] as String?;
      if (messageId == null) return;
      
      final content = data['content'] as String? ?? '';
      final role = data['role'] as String? ?? 'user';
      
      // Skip assistant messages while we're streaming - the streaming handler
      // already manages the assistant message, so WebSocket would create duplicates
      if (currentState.isStreaming && role == 'assistant') {
        debugPrint('WebSocket: Skipping assistant message during streaming');
        return;
      }
      
      // Check if we already have this message by ID (avoid duplicates)
      final existingIndex = currentState.messages.indexWhere((m) => m.id == messageId);
      if (existingIndex >= 0) {
        debugPrint('WebSocket: Message $messageId already exists, skipping');
        return;
      }
      
      // Also check by content for recent messages (handles race conditions with optimistic updates)
      final recentMessages = currentState.messages.where((m) => 
        !m.isStreaming && 
        !m.isPending &&
        m.role == MessageRole.fromString(role) &&
        m.content == content &&
        DateTime.now().difference(m.createdAt).inSeconds < 30
      );
      
      if (recentMessages.isNotEmpty) {
        debugPrint('WebSocket: Skipping duplicate message (content match)');
        return;
      }
      
      // Parse sources if present
      List<SourceCitation> sources = [];
      if (data['sources'] != null) {
        final sourcesData = data['sources'] as List<dynamic>?;
        if (sourcesData != null) {
          sources = sourcesData.map((s) {
            final sourceMap = s as Map<String, dynamic>;
            return SourceCitation(
              documentId: sourceMap['document_id'] as String? ?? '',
              documentName: sourceMap['document_name'] as String? ?? '',
              pageNumber: sourceMap['page_number'] as int?,
              relevanceScore: (sourceMap['relevance_score'] as num?)?.toDouble() ?? 0.0,
              excerpt: sourceMap['excerpt'] as String?,
            );
          }).toList();
        }
      }
      
      // Create the message entity
      final newMessage = Message(
        id: messageId,
        conversationId: _conversationId,
        role: MessageRole.fromString(role),
        content: content,
        sources: sources,
        tokensUsed: data['tokens_used'] as int?,
        createdAt: data['created_at'] != null 
            ? DateTime.parse(data['created_at'] as String)
            : DateTime.now(),
      );
      
      debugPrint('WebSocket: Adding new ${newMessage.role.name} message: ${newMessage.id}');
      
      // Add the message to the list
      _state = currentState.copyWith(
        messages: [...currentState.messages, newMessage],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket: Error parsing new message - $e');
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
    _safeNotifyListeners();

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

    _safeNotifyListeners();
  }

  /// Send a message with streaming response.
  Future<void> sendMessageStreaming(
    String content, {
    String? imageBase64,
    String? imageUrl,
    bool autoExtractUrls = true,
  }) async {
    if (_state is! ChatLoaded) {
      debugPrint('Cannot send message: state is not ChatLoaded');
      return;
    }
    final currentState = _state as ChatLoaded;
    if (currentState.isSending || currentState.isStreaming) {
      debugPrint('Cannot send message: already sending or streaming');
      return;
    }

    debugPrint('Starting streaming message: $content (hasImage: ${imageBase64 != null})');

    // Cancel any existing stream
    await _streamSubscription?.cancel();

    // Add user message
    final userMessage = Message(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
      hasImageAttachment: imageBase64 != null || imageUrl != null,
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
      imageBase64: imageBase64,
      imageUrl: imageUrl,
      autoExtractUrls: autoExtractUrls,
    )
        .listen(
      (chunk) {
        if (_disposed) return;
        if (_state is! ChatLoaded) return;
        final loadedState = _state as ChatLoaded;

        debugPrint('Received chunk: type=${chunk.type}');

        if (chunk.hasSources && chunk.sources != null) {
          sources = chunk.sources!
              .map((s) => ConversationMapper.sourceCitationFromModel(s))
              .toList();
          _state = loadedState.copyWith(pendingSources: sources);
          notifyListeners();
        } else if (chunk.isContent && chunk.content != null) {
          accumulatedContent += chunk.content!;
          debugPrint('Content accumulated: ${accumulatedContent.length} chars');

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
          debugPrint('Stream done, messageId=${chunk.messageId}');
          finalMessageId = chunk.messageId;
          _finishStreaming(finalMessageId, accumulatedContent, sources);
        } else if (chunk.isError) {
          debugPrint('Stream error: ${chunk.error}');
          _handleStreamError(chunk.error ?? 'Unknown error');
        }
      },
      onError: (error) {
        debugPrint('Stream subscription error: $error');
        _handleStreamError(_getErrorMessage(error));
      },
      onDone: () {
        debugPrint('Stream subscription done');
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
    // Use the accumulated content passed to this method, not the message's current content
    final messages = currentState.messages.map((m) {
      if (m.isStreaming) {
        // First update the content, then finish streaming
        final withContent = m.copyWithContent(content);
        return withContent.finishStreaming(
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
      _safeNotifyListeners();
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
      _safeNotifyListeners();
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
