import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../mappers/mappers.dart';

/// Implementation of ConversationRepository.
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource _remoteDataSource;

  ConversationRepositoryImpl({
    ConversationRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ConversationRemoteDataSource();

  @override
  Future<ConversationDetail> createConversation({
    String? projectId,
    String? title,
    bool isSocratic = true,
    String? initialMessage,
  }) async {
    final model = await _remoteDataSource.createConversation(
      projectId: projectId,
      title: title,
      isSocratic: isSocratic,
      initialMessage: initialMessage,
    );
    return ConversationMapper.conversationDetailFromModel(model);
  }

  @override
  Future<List<Conversation>> getConversations({
    String? projectId,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _remoteDataSource.getConversations(
      projectId: projectId,
      skip: skip,
      limit: limit,
    );
    return response.conversations
        .map((m) => ConversationMapper.conversationFromModel(m))
        .toList();
  }

  @override
  Future<ConversationDetail> getConversation(String conversationId) async {
    final model = await _remoteDataSource.getConversation(conversationId);
    return ConversationMapper.conversationDetailFromModel(model);
  }

  @override
  Future<Conversation> updateConversation({
    required String conversationId,
    String? title,
    bool? isSocratic,
  }) async {
    final model = await _remoteDataSource.updateConversation(
      conversationId: conversationId,
      title: title,
      isSocratic: isSocratic,
    );
    return ConversationMapper.conversationFromModel(model);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _remoteDataSource.deleteConversation(conversationId);
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await _remoteDataSource.sendMessage(
      conversationId: conversationId,
      message: message,
    );
    return ConversationMapper.messageFromChatResponse(response);
  }

  @override
  Stream<StreamChunk> sendMessageStream({
    required String conversationId,
    required String message,
  }) {
    return _remoteDataSource.sendMessageStream(
      conversationId: conversationId,
      message: message,
    );
  }
}

/// Provider for the conversation repository.
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl();
});
