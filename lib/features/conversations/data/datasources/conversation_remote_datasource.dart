import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/models.dart';

/// Remote data source for conversations.
class ConversationRemoteDataSource {
  final ApiClient _apiClient;

  ConversationRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CONVERSATION CRUD
  // ============================================================

  /// Create a new conversation.
  Future<ConversationWithMessagesModel> createConversation({
    String? projectId,
    String? title,
    bool isSocratic = true,
    String? initialMessage,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.conversations,
      data: {
        if (projectId != null) 'project_id': projectId,
        if (title != null) 'title': title,
        'is_socratic': isSocratic,
        if (initialMessage != null) 'initial_message': initialMessage,
      },
    );

    return ConversationWithMessagesModel.fromJson(response.data!);
  }

  /// List conversations.
  Future<ConversationListModel> getConversations({
    String? projectId,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      debugPrint('getConversations: projectId=$projectId, skip=$skip, limit=$limit');
      
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (projectId != null) {
        queryParams['project_id'] = projectId;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.conversations,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        debugPrint('getConversations: response.data is null');
        return const ConversationListModel(conversations: [], total: 0);
      }

      debugPrint('getConversations: received response, parsing...');
      final result = ConversationListModel.fromJson(response.data!);
      debugPrint('getConversations: parsed ${result.conversations.length} conversations');
      return result;
    } catch (e, stackTrace) {
      debugPrint('Error in getConversations: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get conversation with messages.
  Future<ConversationWithMessagesModel> getConversation(
    String conversationId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.conversation(conversationId),
    );

    return ConversationWithMessagesModel.fromJson(response.data!);
  }

  /// Update conversation.
  Future<ConversationModel> updateConversation({
    required String conversationId,
    String? title,
    bool? isSocratic,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.conversation(conversationId),
      data: {
        if (title != null) 'title': title,
        if (isSocratic != null) 'is_socratic': isSocratic,
      },
    );

    return ConversationModel.fromJson(response.data!);
  }

  /// Delete conversation.
  Future<void> deleteConversation(String conversationId) async {
    await _apiClient.delete<void>(
      ApiConstants.conversation(conversationId),
    );
  }

  // ============================================================
  // CHAT (NON-STREAMING)
  // ============================================================

  /// Send a message and get response (non-streaming).
  Future<ChatResponseModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.messages(conversationId),
      data: {'message': message},
    );

    return ChatResponseModel.fromJson(response.data!);
  }

  // ============================================================
  // CHAT (STREAMING via SSE)
  // ============================================================

  /// Send a message and stream the response.
  /// 
  /// Returns a stream of [StreamChunk] events:
  /// - `sources`: Source citations (sent first if available)
  /// - `content`: Text chunks as they're generated
  /// - `done`: Completion signal with message ID
  /// - `error`: Error message if something goes wrong
  Stream<StreamChunk> sendMessageStream({
    required String conversationId,
    required String message,
  }) async* {
    final client = Dio();
    
    try {
      // Get auth token
      final authToken = await _apiClient.getAuthToken();
      
      final response = await client.post<ResponseBody>(
        ApiConstants.messagesStream(conversationId),
        data: {'message': message},
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      String buffer = '';
      int rawChunkCount = 0;

      debugPrint('SSE: Stream started');
      
      await for (final chunk in stream) {
        rawChunkCount++;
        final decoded = utf8.decode(chunk);
        buffer += decoded;
        debugPrint('SSE: Raw chunk #$rawChunkCount received, ${decoded.length} bytes');
        debugPrint('SSE: Raw content: ${decoded.substring(0, decoded.length > 100 ? 100 : decoded.length)}...');
        
        // Process complete SSE events (split by double newline)
        final events = buffer.split('\n\n');
        
        // Keep incomplete event in buffer
        buffer = events.removeLast();
        
        debugPrint('SSE: Found ${events.length} complete events in buffer');
        
        for (final event in events) {
          if (event.trim().isEmpty) continue;
          
          debugPrint('SSE: Parsing event: ${event.substring(0, event.length > 80 ? 80 : event.length)}...');
          final parsed = _parseSSEEvent(event);
          if (parsed != null) {
            debugPrint('SSE: Parsed event type: ${parsed.type}');
            yield parsed;
          }
        }
      }
      
      debugPrint('SSE: Stream ended, processing remaining buffer: ${buffer.length} bytes');
      
      // Process any remaining buffer
      if (buffer.trim().isNotEmpty) {
        final parsed = _parseSSEEvent(buffer);
        if (parsed != null) {
          debugPrint('SSE: Final parsed event type: ${parsed.type}');
          yield parsed;
        }
      }
    } catch (e) {
      yield StreamChunk(
        type: StreamChunkType.error,
        error: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  /// Parse a single SSE event.
  StreamChunk? _parseSSEEvent(String event) {
    String? eventType;
    String? data;

    for (final line in event.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
      }
    }

    if (data == null) return null;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;

      switch (eventType) {
        case 'sources':
          final sources = (json['sources'] as List<dynamic>?)
              ?.map((e) => SourceCitationModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return StreamChunk(
            type: StreamChunkType.sources,
            sources: sources,
          );

        case 'content':
          return StreamChunk(
            type: StreamChunkType.content,
            content: json['text'] as String?,
          );

        case 'done':
          return StreamChunk(
            type: StreamChunkType.done,
            messageId: json['message_id'] as String?,
          );

        case 'error':
          return StreamChunk(
            type: StreamChunkType.error,
            error: json['error'] as String?,
          );

        default:
          // Unknown event type, might be content
          if (json.containsKey('text')) {
            return StreamChunk(
              type: StreamChunkType.content,
              content: json['text'] as String?,
            );
          }
          return null;
      }
    } catch (e) {
      // If we can't parse JSON, treat as plain text content
      return StreamChunk(
        type: StreamChunkType.content,
        content: data,
      );
    }
  }
}

// ============================================================
// STREAM CHUNK MODEL
// ============================================================

enum StreamChunkType {
  sources,
  content,
  done,
  error,
}

class StreamChunk {
  final StreamChunkType type;
  final String? content;
  final List<SourceCitationModel>? sources;
  final String? messageId;
  final String? error;

  const StreamChunk({
    required this.type,
    this.content,
    this.sources,
    this.messageId,
    this.error,
  });

  bool get isContent => type == StreamChunkType.content;
  bool get isDone => type == StreamChunkType.done;
  bool get isError => type == StreamChunkType.error;
  bool get hasSources => type == StreamChunkType.sources && sources != null;
}
