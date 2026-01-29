/// Document processing status enum.
enum DocumentStatus {
  pending,
  processing,
  ready,
  failed;

  factory DocumentStatus.fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DocumentStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.processing:
        return 'Processing';
      case DocumentStatus.ready:
        return 'Ready';
      case DocumentStatus.failed:
        return 'Failed';
    }
  }

  bool get isActionable => this == DocumentStatus.ready;
}

/// Document file type enum.
enum FileType {
  pdf,
  docx,
  pptx,
  txt;

  factory FileType.fromString(String value) {
    return FileType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FileType.txt,
    );
  }

  String get extension => name;

  String get displayName {
    switch (this) {
      case FileType.pdf:
        return 'PDF';
      case FileType.docx:
        return 'Word';
      case FileType.pptx:
        return 'PowerPoint';
      case FileType.txt:
        return 'Text';
    }
  }
}

/// Document entity for UI layer.
class Document {
  final String id;
  final String projectId;
  final String originalFilename;
  final FileType fileType;
  final int fileSize;
  final DocumentStatus status;
  final String? errorMessage;
  final int chunkCount;
  final String fileSizeDisplay;
  final DateTime createdAt;
  final DateTime? processedAt;

  const Document({
    required this.id,
    required this.projectId,
    required this.originalFilename,
    required this.fileType,
    required this.fileSize,
    required this.status,
    this.errorMessage,
    required this.chunkCount,
    required this.fileSizeDisplay,
    required this.createdAt,
    this.processedAt,
  });

  /// Whether the document is ready for AI queries.
  bool get isReady => status == DocumentStatus.ready;

  /// Whether the document is currently being processed.
  bool get isProcessing => 
      status == DocumentStatus.pending || status == DocumentStatus.processing;

  /// Whether the document failed processing.
  bool get hasFailed => status == DocumentStatus.failed;

  /// Get display name without extension.
  String get displayName {
    final parts = originalFilename.split('.');
    if (parts.length > 1) {
      parts.removeLast();
    }
    return parts.join('.');
  }

  /// Get file extension.
  String get extension {
    final parts = originalFilename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Get relative time since creation.
  String get createdRelative {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (diff.inDays > 0) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return diff.inMinutes == 1 ? '1 minute ago' : '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

/// Document statistics for a project.
class DocumentStats {
  final int totalDocuments;
  final int readyDocuments;
  final int pendingDocuments;
  final int processingDocuments;
  final int failedDocuments;
  final int totalChunks;

  const DocumentStats({
    required this.totalDocuments,
    required this.readyDocuments,
    required this.pendingDocuments,
    required this.processingDocuments,
    required this.failedDocuments,
    required this.totalChunks,
  });

  static const empty = DocumentStats(
    totalDocuments: 0,
    readyDocuments: 0,
    pendingDocuments: 0,
    processingDocuments: 0,
    failedDocuments: 0,
    totalChunks: 0,
  );

  /// Documents currently being processed.
  int get inProgressCount => pendingDocuments + processingDocuments;

  /// Whether there are any documents.
  bool get hasDocuments => totalDocuments > 0;

  /// Whether all documents are ready.
  bool get allReady => readyDocuments == totalDocuments && totalDocuments > 0;
}
