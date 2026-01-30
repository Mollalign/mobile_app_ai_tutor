import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/models.dart';

/// Remote data source for document operations.
abstract class DocumentRemoteDataSource {
  /// Get list of documents for a project.
  Future<DocumentListModel> getDocuments({
    required String projectId,
    String? status,
    String? fileType,
    int limit = 20,
    int offset = 0,
  });

  /// Get document by ID.
  Future<DocumentModel> getDocument({
    required String projectId,
    required String documentId,
  });

  /// Get document statistics for a project.
  Future<DocumentStatsModel> getDocumentStats(String projectId);

  /// Upload a document file.
  Future<DocumentUploadModel> uploadDocument({
    required String projectId,
    required File file,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });

  /// Upload document from bytes (web/memory).
  Future<DocumentUploadModel> uploadDocumentBytes({
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
  Future<DocumentModel> reprocessDocument({
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
  Future<AllowedTypesModel> getAllowedTypes(String projectId);
}

/// Implementation of DocumentRemoteDataSource using ApiClient.
class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final ApiClient _apiClient;

  DocumentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DocumentListModel> getDocuments({
    required String projectId,
    String? status,
    String? fileType,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (status != null) queryParams['status'] = status;
    if (fileType != null) queryParams['file_type'] = fileType;

    final response = await _apiClient.get(
      ApiConstants.documents(projectId),
      queryParameters: queryParams,
    );

    return DocumentListModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DocumentModel> getDocument({
    required String projectId,
    required String documentId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.document(projectId, documentId),
    );

    return DocumentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DocumentStatsModel> getDocumentStats(String projectId) async {
    final response = await _apiClient.get(
      ApiConstants.documentStats(projectId),
    );

    return DocumentStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DocumentUploadModel> uploadDocument({
    required String projectId,
    required File file,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final filename = file.path.split('/').last;
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: filename,
      ),
    });

    final response = await _apiClient.postForm(
      ApiConstants.documents(projectId),
      formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );

    return DocumentUploadModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DocumentUploadModel> uploadDocumentBytes({
    required String projectId,
    required Uint8List bytes,
    required String filename,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final response = await _apiClient.postForm(
      ApiConstants.documents(projectId),
      formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );

    return DocumentUploadModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDocument({
    required String projectId,
    required String documentId,
  }) async {
    await _apiClient.delete(
      ApiConstants.document(projectId, documentId),
    );
  }

  @override
  Future<DocumentModel> reprocessDocument({
    required String projectId,
    required String documentId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.reprocessDocument(projectId, documentId),
    );

    return DocumentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Uint8List> downloadDocument({
    required String projectId,
    required String documentId,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.downloadDocument(projectId, documentId),
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );

    return response.data as Uint8List;
  }

  @override
  Future<AllowedTypesModel> getAllowedTypes(String projectId) async {
    final response = await _apiClient.get(
      ApiConstants.allowedFileTypes(projectId),
    );

    return AllowedTypesModel.fromJson(response.data as Map<String, dynamic>);
  }
}
