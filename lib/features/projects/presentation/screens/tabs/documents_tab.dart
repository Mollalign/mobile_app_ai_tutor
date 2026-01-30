import 'dart:io';

import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../documents/data/repositories/repositories.dart';
import '../../../../documents/domain/entities/entities.dart';
import '../../../../documents/presentation/providers/providers.dart';
import '../../../../documents/presentation/widgets/widgets.dart';

/// Documents tab showing list of uploaded documents.
class DocumentsTab extends ConsumerStatefulWidget {
  final String projectId;

  const DocumentsTab({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends ConsumerState<DocumentsTab> {
  DocumentFilter _currentFilter = DocumentFilter.all;

  @override
  Widget build(BuildContext context) {
    final documentsNotifier = ref.watch(documentsNotifierProvider(widget.projectId));
    final uploadNotifier = ref.watch(uploadStateProvider(widget.projectId));

    // Use AnimatedBuilder to listen to ChangeNotifier updates
    return AnimatedBuilder(
      animation: Listenable.merge([documentsNotifier, uploadNotifier]),
      builder: (context, _) {
        return Scaffold(
          body: documentsNotifier.state.when(
            initial: () => const _LoadingState(),
            loading: () => const _LoadingState(),
            loaded: (documents, total, isLoadingMore, hasMore, stats) {
              return _LoadedContent(
                projectId: widget.projectId,
                documents: documents,
                stats: stats,
                isLoadingMore: isLoadingMore,
                hasMore: hasMore,
                uploadState: uploadNotifier.uploads,
                currentFilter: _currentFilter,
                onFilterChanged: (filter) {
                  setState(() => _currentFilter = filter);
                  ref.read(documentsNotifierProvider(widget.projectId))
                      .loadDocuments(refresh: true, status: filter.toStatus());
                },
              );
            },
            error: (message) => _ErrorState(
              message: message,
              onRetry: () => ref
                  .read(documentsNotifierProvider(widget.projectId))
                  .loadDocuments(refresh: true),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'documents_fab_${widget.projectId}',
            onPressed: () => _pickAndUploadFiles(context, ref),
            icon: const Icon(LucideIcons.upload),
            label: const Text('Upload'),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadFiles(BuildContext context, WidgetRef ref) async {
    final result = await picker.FilePicker.platform.pickFiles(
      type: picker.FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final uploadNotifier = ref.read(uploadStateProvider(widget.projectId));

      for (final file in result.files) {
        if (file.path != null) {
          uploadNotifier.uploadFile(File(file.path!));
        } else if (file.bytes != null) {
          uploadNotifier.uploadBytes(file.bytes!, file.name);
        }
      }
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1500.ms, color: colorScheme.surface),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load documents',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedContent extends ConsumerWidget {
  final String projectId;
  final List<Document> documents;
  final DocumentStats stats;
  final bool isLoadingMore;
  final bool hasMore;
  final List<UploadState> uploadState;
  final DocumentFilter currentFilter;
  final ValueChanged<DocumentFilter> onFilterChanged;

  const _LoadedContent({
    required this.projectId,
    required this.documents,
    required this.stats,
    required this.isLoadingMore,
    required this.hasMore,
    required this.uploadState,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filter documents if needed
    final filteredDocs = _filterDocuments(documents, currentFilter);

    if (documents.isEmpty && uploadState.isEmpty) {
      return _EmptyState(
        onUpload: () => _pickAndUploadFiles(context, ref),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(documentsNotifierProvider(projectId))
          .loadDocuments(refresh: true),
      child: CustomScrollView(
        slivers: [
          // Stats header
          if (stats.hasDocuments)
            SliverToBoxAdapter(
              child: DocumentStatsHeader(stats: stats)
                  .animate()
                  .fadeIn()
                  .slideY(begin: -0.1),
            ),

          // Filter chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: DocumentFilter.values.map((filter) {
                  final isSelected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(filter.displayName),
                      selected: isSelected,
                      onSelected: (_) => onFilterChanged(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.md),
          ),

          // Upload progress cards
          if (uploadState.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploading',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...uploadState.map((upload) => UploadProgressCard(
                      uploadState: upload,
                      onCancel: () => ref
                          .read(uploadStateProvider(projectId))
                          .cancelUpload(upload.filename),
                      onDismiss: () => ref
                          .read(uploadStateProvider(projectId))
                          .removeUpload(upload.filename),
                    )),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

          // Documents list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= filteredDocs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final doc = filteredDocs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DocumentCard(
                      document: doc,
                      onDelete: () => _confirmDelete(context, ref, doc),
                      onReprocess: doc.hasFailed
                          ? () => _reprocessDocument(context, ref, doc)
                          : null,
                      onDownload: doc.isReady
                          ? () => _downloadDocument(context, ref, doc)
                          : null,
                    ),
                  );
                },
                childCount: filteredDocs.length + (isLoadingMore ? 1 : 0),
              ),
            ),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  List<Document> _filterDocuments(List<Document> docs, DocumentFilter filter) {
    if (filter == DocumentFilter.all) return docs;
    
    return docs.where((doc) {
      switch (filter) {
        case DocumentFilter.ready:
          return doc.isReady;
        case DocumentFilter.processing:
          return doc.isProcessing;
        case DocumentFilter.failed:
          return doc.hasFailed;
        case DocumentFilter.all:
          return true;
      }
    }).toList();
  }

  Future<void> _pickAndUploadFiles(BuildContext context, WidgetRef ref) async {
    final result = await picker.FilePicker.platform.pickFiles(
      type: picker.FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final uploadNotifier = ref.read(uploadStateProvider(projectId));

      for (final file in result.files) {
        if (file.path != null) {
          uploadNotifier.uploadFile(File(file.path!));
        } else if (file.bytes != null) {
          uploadNotifier.uploadBytes(file.bytes!, file.name);
        }
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Document doc) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.trash2, color: colorScheme.error),
        title: const Text('Delete Document?'),
        content: Text(
          'Are you sure you want to delete "${doc.originalFilename}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(documentsNotifierProvider(projectId))
                  .deleteDocument(doc.id);
              
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _reprocessDocument(BuildContext context, WidgetRef ref, Document doc) async {
    final success = await ref
        .read(documentsNotifierProvider(projectId))
        .reprocessDocument(doc.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Reprocessing started'
                : 'Failed to reprocess document',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadDocument(BuildContext context, WidgetRef ref, Document doc) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Downloading...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 60),
      ),
    );

    try {
      final repository = ref.read(documentRepositoryProvider);
      final bytes = await repository.downloadDocument(
        projectId: projectId,
        documentId: doc.id,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${doc.originalFilename}');
      await file.writeAsBytes(bytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: ${doc.originalFilename}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.fileText,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No documents yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload your study materials to get started.\nSupported: PDF, DOCX, PPTX, TXT',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(LucideIcons.upload),
              label: const Text('Upload Document'),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ),
    );
  }
}
