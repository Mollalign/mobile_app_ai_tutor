import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_utils.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import 'document_state.dart';

// ============================================================
// Providers
// ============================================================

/// Provider for documents list by project ID.
final documentsNotifierProvider = Provider.family.autoDispose<DocumentsChangeNotifier, String>(
  (ref, projectId) {
    final repository = ref.watch(documentRepositoryProvider);
    final notifier = DocumentsChangeNotifier(repository: repository, projectId: projectId);
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);

/// Provider for upload state.
final uploadNotifierProvider = Provider.family.autoDispose<UploadChangeNotifier, String>(
  (ref, projectId) {
    final repository = ref.watch(documentRepositoryProvider);
    final notifier = UploadChangeNotifier(
      repository: repository,
      projectId: projectId,
      onUploadComplete: () {
        // Refresh documents list when upload completes
        ref.read(documentsNotifierProvider(projectId)).loadDocuments(refresh: true);
      },
    );
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);

// Alias for backwards compatibility
final uploadStateProvider = uploadNotifierProvider;

// ============================================================
// Documents Notifier
// ============================================================

/// Notifier for managing documents list.
class DocumentsChangeNotifier extends ChangeNotifier {
  final DocumentRepository _repository;
  final String projectId;
  bool _disposed = false;
  
  static const int _pageSize = 20;
  int _currentOffset = 0;
  
  DocumentsState _state = const DocumentsState.initial();
  DocumentsState get state => _state;

  DocumentsChangeNotifier({
    required DocumentRepository repository,
    required this.projectId,
  }) : _repository = repository {
    loadDocuments();
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

  /// Load documents with optional filter.
  Future<void> loadDocuments({
    bool refresh = false,
    DocumentStatus? status,
  }) async {
    if (refresh) {
      _currentOffset = 0;
    }
    await _loadDocuments(status: status);
  }

  Future<void> _loadDocuments({DocumentStatus? status}) async {
    _state = const DocumentsState.loading();
    notifyListeners();

    try {
      // Fetch both documents and stats in parallel
      final results = await Future.wait([
        _repository.getDocuments(
          projectId: projectId,
          status: status,
          limit: _pageSize,
          offset: 0,
        ),
        _repository.getDocumentStats(projectId),
      ]);

      final (documents, total, hasMore) = results[0] as (List<Document>, int, bool);
      final stats = results[1] as DocumentStats;

      _state = DocumentsState.loaded(
        documents,
        total: total,
        isLoadingMore: false,
        hasMore: hasMore,
        stats: stats,
      );
    } catch (e) {
      _state = DocumentsState.error(_getErrorMessage(e));
    }
    notifyListeners();
  }

  /// Load more documents (pagination).
  Future<void> loadMore({DocumentStatus? status}) async {
    final currentState = _state;
    if (currentState is! DocumentsLoaded || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    _state = currentState.copyWith(isLoadingMore: true);
    notifyListeners();
    _currentOffset += _pageSize;

    try {
      final (documents, total, hasMore) = await _repository.getDocuments(
        projectId: projectId,
        status: status,
        limit: _pageSize,
        offset: _currentOffset,
      );

      _state = currentState.copyWith(
        documents: [...currentState.documents, ...documents],
        total: total,
        isLoadingMore: false,
        hasMore: hasMore,
      );
    } catch (e) {
      // Revert offset on failure
      _currentOffset -= _pageSize;
      _state = currentState.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }

  /// Delete a document.
  Future<bool> deleteDocument(String documentId) async {
    try {
      await _repository.deleteDocument(
        projectId: projectId,
        documentId: documentId,
      );

      // Remove from list
      final currentState = _state;
      if (currentState is DocumentsLoaded) {
        final updatedDocs = currentState.documents
            .where((d) => d.id != documentId)
            .toList();
        _state = currentState.copyWith(
          documents: updatedDocs,
          total: currentState.total - 1,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reprocess a failed document.
  Future<bool> reprocessDocument(String documentId) async {
    try {
      final updatedDoc = await _repository.reprocessDocument(
        projectId: projectId,
        documentId: documentId,
      );

      // Update in list
      final currentState = _state;
      if (currentState is DocumentsLoaded) {
        final updatedDocs = currentState.documents.map((d) {
          return d.id == documentId ? updatedDoc : d;
        }).toList();
        _state = currentState.copyWith(documents: updatedDocs);
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
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
    return 'Failed to load documents. Please try again.';
  }
}

// ============================================================
// Upload Notifier
// ============================================================

/// Notifier for managing file uploads.
class UploadChangeNotifier extends ChangeNotifier {
  final DocumentRepository _repository;
  final String projectId;
  final VoidCallback? onUploadComplete;
  bool _disposed = false;
  
  final Map<String, CancelToken> _cancelTokens = {};
  
  List<UploadState> _uploads = [];
  List<UploadState> get uploads => _uploads;

  UploadChangeNotifier({
    required DocumentRepository repository,
    required this.projectId,
    this.onUploadComplete,
  }) : _repository = repository;

  @override
  void dispose() {
    _disposed = true;
    // Cancel all pending uploads
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
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

  /// Upload a file.
  Future<void> uploadFile(File file) async {
    final filename = file.path.split('/').last;
    final cancelToken = CancelToken();
    _cancelTokens[filename] = cancelToken;

    // Add to upload list
    _uploads = [
      ..._uploads,
      UploadState(
        filename: filename,
        isUploading: true,
      ),
    ];
    notifyListeners();

    try {
      final document = await _repository.uploadDocument(
        projectId: projectId,
        file: file,
        onProgress: (sent, total) {
          _updateProgress(filename, sent / total);
        },
        cancelToken: cancelToken,
      );

      _cancelTokens.remove(filename);
      _updateUploadState(filename, (s) => s.copyWith(
        isUploading: false,
        isComplete: true,
        progress: 1.0,
        document: document,
      ));
      onUploadComplete?.call();
    } catch (e) {
      _cancelTokens.remove(filename);
      _updateUploadState(filename, (s) => s.copyWith(
        isUploading: false,
        error: friendlyErrorMessage(e),
      ));
    }
  }

  /// Upload from bytes.
  Future<void> uploadBytes(Uint8List bytes, String filename) async {
    final cancelToken = CancelToken();
    _cancelTokens[filename] = cancelToken;

    // Add to upload list
    _uploads = [
      ..._uploads,
      UploadState(
        filename: filename,
        isUploading: true,
      ),
    ];
    notifyListeners();

    try {
      final document = await _repository.uploadDocumentBytes(
        projectId: projectId,
        bytes: bytes,
        filename: filename,
        onProgress: (sent, total) {
          _updateProgress(filename, sent / total);
        },
        cancelToken: cancelToken,
      );

      _cancelTokens.remove(filename);
      _updateUploadState(filename, (s) => s.copyWith(
        isUploading: false,
        isComplete: true,
        progress: 1.0,
        document: document,
      ));
      onUploadComplete?.call();
    } catch (e) {
      _cancelTokens.remove(filename);
      _updateUploadState(filename, (s) => s.copyWith(
        isUploading: false,
        error: friendlyErrorMessage(e),
      ));
    }
  }

  /// Cancel an upload.
  void cancelUpload(String filename) {
    _cancelTokens[filename]?.cancel();
    _cancelTokens.remove(filename);
    _uploads = _uploads.where((s) => s.filename != filename).toList();
    notifyListeners();
  }

  /// Remove a completed upload from the list.
  void removeUpload(String filename) {
    _uploads = _uploads.where((s) => s.filename != filename).toList();
    notifyListeners();
  }

  /// Clear all completed uploads.
  void clearCompleted() {
    _uploads = _uploads.where((s) => s.isUploading).toList();
    notifyListeners();
  }

  void _updateProgress(String filename, double progress) {
    _updateUploadState(filename, (s) => s.copyWith(progress: progress));
  }

  void _updateUploadState(String filename, UploadState Function(UploadState) updater) {
    _uploads = _uploads.map((s) {
      if (s.filename == filename) {
        return updater(s);
      }
      return s;
    }).toList();
    notifyListeners();
  }
}
