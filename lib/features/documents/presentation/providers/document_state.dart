import '../../domain/entities/entities.dart';

/// State for document list.
sealed class DocumentsState {
  const DocumentsState();

  const factory DocumentsState.initial() = DocumentsInitial;
  const factory DocumentsState.loading() = DocumentsLoading;
  const factory DocumentsState.loaded(
    List<Document> documents, {
    required int total,
    required bool isLoadingMore,
    required bool hasMore,
    required DocumentStats stats,
  }) = DocumentsLoaded;
  const factory DocumentsState.error(String message) = DocumentsError;

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<Document> documents,
      int total,
      bool isLoadingMore,
      bool hasMore,
      DocumentStats stats,
    ) loaded,
    required T Function(String message) error,
  }) {
    return switch (this) {
      DocumentsInitial() => initial(),
      DocumentsLoading() => loading(),
      DocumentsLoaded(
        documents: final docs,
        total: final t,
        isLoadingMore: final ilm,
        hasMore: final hm,
        stats: final s,
      ) =>
        loaded(docs, t, ilm, hm, s),
      DocumentsError(message: final m) => error(m),
    };
  }

  T maybeMap<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(DocumentsLoaded state)? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      DocumentsInitial() => initial?.call() ?? orElse(),
      DocumentsLoading() => loading?.call() ?? orElse(),
      DocumentsLoaded() when loaded != null => loaded(this as DocumentsLoaded),
      DocumentsError(message: final m) => error?.call(m) ?? orElse(),
      _ => orElse(),
    };
  }
}

class DocumentsInitial extends DocumentsState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentsState {
  const DocumentsLoading();
}

class DocumentsLoaded extends DocumentsState {
  final List<Document> documents;
  final int total;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentStats stats;

  const DocumentsLoaded(
    this.documents, {
    required this.total,
    required this.isLoadingMore,
    required this.hasMore,
    required this.stats,
  });

  DocumentsLoaded copyWith({
    List<Document>? documents,
    int? total,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentStats? stats,
  }) {
    return DocumentsLoaded(
      documents ?? this.documents,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      stats: stats ?? this.stats,
    );
  }
}

class DocumentsError extends DocumentsState {
  final String message;
  const DocumentsError(this.message);
}

/// State for a single document upload.
class UploadState {
  final String filename;
  final double progress;
  final bool isUploading;
  final bool isComplete;
  final String? error;
  final Document? document;

  const UploadState({
    required this.filename,
    this.progress = 0.0,
    this.isUploading = false,
    this.isComplete = false,
    this.error,
    this.document,
  });

  UploadState copyWith({
    String? filename,
    double? progress,
    bool? isUploading,
    bool? isComplete,
    String? error,
    Document? document,
  }) {
    return UploadState(
      filename: filename ?? this.filename,
      progress: progress ?? this.progress,
      isUploading: isUploading ?? this.isUploading,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
      document: document ?? this.document,
    );
  }
}

/// State for document filter.
enum DocumentFilter {
  all,
  ready,
  processing,
  failed;

  String get displayName {
    switch (this) {
      case DocumentFilter.all:
        return 'All';
      case DocumentFilter.ready:
        return 'Ready';
      case DocumentFilter.processing:
        return 'Processing';
      case DocumentFilter.failed:
        return 'Failed';
    }
  }

  DocumentStatus? toStatus() {
    switch (this) {
      case DocumentFilter.all:
        return null;
      case DocumentFilter.ready:
        return DocumentStatus.ready;
      case DocumentFilter.processing:
        return DocumentStatus.processing;
      case DocumentFilter.failed:
        return DocumentStatus.failed;
    }
  }
}
