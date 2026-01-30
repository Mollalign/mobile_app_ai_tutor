import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../mappers/mappers.dart';

/// Provider for the document repository.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final apiClient = ApiClient();
  final dataSource = DocumentRemoteDataSourceImpl(apiClient);
  return DocumentRepositoryImpl(dataSource);
});

/// Implementation of DocumentRepository.
class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _dataSource;

  DocumentRepositoryImpl(this._dataSource);

  @override
  Future<(List<Document>, int, bool)> getDocuments({
    required String projectId,
    DocumentStatus? status,
    FileType? fileType,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _dataSource.getDocuments(
      projectId: projectId,
      status: status?.name,
      fileType: fileType?.name,
      limit: limit,
      offset: offset,
    );

    final documents = DocumentMapper.toEntityList(result.documents);
    return (documents, result.total, result.hasMore);
  }

  @override
  Future<Document> getDocument({
    required String projectId,
    required String documentId,
  }) async {
    final result = await _dataSource.getDocument(
      projectId: projectId,
      documentId: documentId,
    );

    return DocumentMapper.toEntity(result);
  }

  @override
  Future<DocumentStats> getDocumentStats(String projectId) async {
    final result = await _dataSource.getDocumentStats(projectId);
    return DocumentMapper.toStatsEntity(result);
  }

  @override
  Future<Document> uploadDocument({
    required String projectId,
    required File file,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await _dataSource.uploadDocument(
      projectId: projectId,
      file: file,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    return DocumentMapper.toEntity(result.document);
  }

  @override
  Future<Document> uploadDocumentBytes({
    required String projectId,
    required Uint8List bytes,
    required String filename,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final result = await _dataSource.uploadDocumentBytes(
      projectId: projectId,
      bytes: bytes,
      filename: filename,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    return DocumentMapper.toEntity(result.document);
  }

  @override
  Future<void> deleteDocument({
    required String projectId,
    required String documentId,
  }) async {
    await _dataSource.deleteDocument(
      projectId: projectId,
      documentId: documentId,
    );
  }

  @override
  Future<Document> reprocessDocument({
    required String projectId,
    required String documentId,
  }) async {
    final result = await _dataSource.reprocessDocument(
      projectId: projectId,
      documentId: documentId,
    );

    return DocumentMapper.toEntity(result);
  }

  @override
  Future<Uint8List> downloadDocument({
    required String projectId,
    required String documentId,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    return await _dataSource.downloadDocument(
      projectId: projectId,
      documentId: documentId,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<List<String>> getAllowedTypes(String projectId) async {
    final result = await _dataSource.getAllowedTypes(projectId);
    return result.allowedTypes;
  }
}
