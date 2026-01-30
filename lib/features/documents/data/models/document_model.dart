/// Document model for API communication.
/// 
/// Matches the backend DocumentResponse schema.
class DocumentModel {
  final String id;
  final String projectId;
  final String originalFilename;
  final String fileType;
  final int fileSize;
  final String status;
  final String? errorMessage;
  final int chunkCount;
  final String fileSizeDisplay;
  final bool isReady;
  final DateTime createdAt;
  final DateTime? processedAt;

  const DocumentModel({
    required this.id,
    required this.projectId,
    required this.originalFilename,
    required this.fileType,
    required this.fileSize,
    required this.status,
    this.errorMessage,
    required this.chunkCount,
    required this.fileSizeDisplay,
    required this.isReady,
    required this.createdAt,
    this.processedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      originalFilename: json['original_filename'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      status: json['status'] as String,
      errorMessage: json['error_message'] as String?,
      chunkCount: (json['chunk_count'] as int?) ?? 0,
      fileSizeDisplay: json['file_size_display'] as String,
      isReady: (json['is_ready'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'original_filename': originalFilename,
      'file_type': fileType,
      'file_size': fileSize,
      'status': status,
      'error_message': errorMessage,
      'chunk_count': chunkCount,
      'file_size_display': fileSizeDisplay,
      'is_ready': isReady,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}

/// Document list response with pagination.
class DocumentListModel {
  final List<DocumentModel> documents;
  final int total;
  final bool hasMore;

  const DocumentListModel({
    required this.documents,
    required this.total,
    required this.hasMore,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    return DocumentListModel(
      documents: (json['documents'] as List<dynamic>)
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      hasMore: (json['has_more'] as bool?) ?? false,
    );
  }
}

/// Document upload response.
class DocumentUploadModel {
  final DocumentModel document;
  final String message;

  const DocumentUploadModel({
    required this.document,
    required this.message,
  });

  factory DocumentUploadModel.fromJson(Map<String, dynamic> json) {
    return DocumentUploadModel(
      document: DocumentModel.fromJson(json['document'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
}

/// Allowed file types response.
class AllowedTypesModel {
  final List<String> allowedTypes;

  const AllowedTypesModel({required this.allowedTypes});

  factory AllowedTypesModel.fromJson(Map<String, dynamic> json) {
    return AllowedTypesModel(
      allowedTypes: (json['allowed_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// Document stats response.
/// 
/// Matches the backend response format:
/// {"total":2,"by_status":{"ready":2},"by_type":{"pptx":2},"total_size":1347861}
class DocumentStatsModel {
  final int totalDocuments;
  final int readyDocuments;
  final int pendingDocuments;
  final int processingDocuments;
  final int failedDocuments;
  final int totalSize;
  final Map<String, int> byType;

  const DocumentStatsModel({
    required this.totalDocuments,
    required this.readyDocuments,
    required this.pendingDocuments,
    required this.processingDocuments,
    required this.failedDocuments,
    required this.totalSize,
    required this.byType,
  });

  factory DocumentStatsModel.fromJson(Map<String, dynamic> json) {
    // Parse by_status map to get individual counts
    final byStatus = json['by_status'] as Map<String, dynamic>? ?? {};
    
    // Parse by_type map
    final byTypeRaw = json['by_type'] as Map<String, dynamic>? ?? {};
    final byType = byTypeRaw.map((k, v) => MapEntry(k, v as int));

    return DocumentStatsModel(
      totalDocuments: (json['total'] as int?) ?? 0,
      readyDocuments: (byStatus['ready'] as int?) ?? 0,
      pendingDocuments: (byStatus['pending'] as int?) ?? 0,
      processingDocuments: (byStatus['processing'] as int?) ?? 0,
      failedDocuments: (byStatus['failed'] as int?) ?? 0,
      totalSize: (json['total_size'] as int?) ?? 0,
      byType: byType,
    );
  }
}
