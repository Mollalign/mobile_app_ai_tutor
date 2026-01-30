import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Mapper for converting between document models and entities.
class DocumentMapper {
  /// Convert DocumentModel to Document entity.
  static Document toEntity(DocumentModel model) {
    return Document(
      id: model.id,
      projectId: model.projectId,
      originalFilename: model.originalFilename,
      fileType: FileType.fromString(model.fileType),
      fileSize: model.fileSize,
      status: DocumentStatus.fromString(model.status),
      errorMessage: model.errorMessage,
      chunkCount: model.chunkCount,
      fileSizeDisplay: model.fileSizeDisplay,
      createdAt: model.createdAt,
      processedAt: model.processedAt,
    );
  }

  /// Convert list of DocumentModels to list of Document entities.
  static List<Document> toEntityList(List<DocumentModel> models) {
    return models.map(toEntity).toList();
  }

  /// Convert DocumentStatsModel to DocumentStats entity.
  static DocumentStats toStatsEntity(DocumentStatsModel model) {
    return DocumentStats(
      totalDocuments: model.totalDocuments,
      readyDocuments: model.readyDocuments,
      pendingDocuments: model.pendingDocuments,
      processingDocuments: model.processingDocuments,
      failedDocuments: model.failedDocuments,
      totalSize: model.totalSize,
      byType: model.byType,
    );
  }
}
