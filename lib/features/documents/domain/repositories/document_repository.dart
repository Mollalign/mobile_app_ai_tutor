import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../entities/entities.dart';

/// Repository interface for document operations.
abstract class DocumentRepository {
  /// Get list of documents for a project.
  /// Returns (documents, total, hasMore).
  Future<(List<Document>, int, bool)> getDocuments({
    required String projectId,
    DocumentStatus? status,
    FileType? fileType,
    int limit = 20,
    int offset = 0,
  });

  /// Get a single document by ID.
  Future<Document> getDocument({
    required String projectId,
    required String documentId,
  });

  /// Get document statistics for a project.
  Future<DocumentStats> getDocumentStats(String projectId);

  /// Upload a document file.
  Future<Document> uploadDocument({
    required String projectId,
    required File file,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });

  /// Upload document from bytes.
  Future<Document> uploadDocumentBytes({
    required String projectId,
    required Uint8List bytes,
    required String filename,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });

  /// Delete a document.
  Future<void> deleteDocument({
    required String projectId,
    required String documentId,
  });

  /// Reprocess a failed document.
  Future<Document> reprocessDocument({
    required String projectId,
    required String documentId,
  });

  /// Download a document file.
  Future<Uint8List> downloadDocument({
    required String projectId,
    required String documentId,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  });

  /// Get allowed file types.
  Future<List<String>> getAllowedTypes(String projectId);
}
