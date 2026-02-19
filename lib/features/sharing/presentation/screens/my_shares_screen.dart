import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/sharing_models.dart';
import '../providers/sharing_providers.dart';

/// Screen for managing user's shared conversations.
class MySharesScreen extends ConsumerWidget {
  const MySharesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharesAsync = ref.watch(mySharesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shared Links'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sharesAsync.when(
        data: (shares) => shares.isEmpty
            ? _EmptySharesView()
            : _SharesList(shares: shares),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.read(mySharesProvider.notifier).loadShares(),
        ),
      ),
    );
  }
}

class _EmptySharesView extends StatelessWidget {
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.share2,
                size: 36,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No shared conversations',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'When you share a conversation, it will appear here',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharesList extends ConsumerWidget {
  final List<SharedConversationModel> shares;

  const _SharesList({required this.shares});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(mySharesProvider.notifier).loadShares(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: shares.length,
        itemBuilder: (context, index) {
          final share = shares[index];
          return _ShareCard(share: share)
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .slideX(begin: 0.1, delay: (index * 50).ms);
        },
      ),
    );
  }
}

class _ShareCard extends ConsumerWidget {
  final SharedConversationModel share;

  const _ShareCard({required this.share});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => _showShareDetails(context, ref),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    share.isActive ? LucideIcons.link : LucideIcons.unlink,
                    size: 18,
                    color: share.isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      share.title ?? 'Untitled conversation',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (share.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'Expired',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    LucideIcons.eye,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${share.viewCount} views',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    share.allowReplies ? LucideIcons.gitFork : LucideIcons.lock,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    share.allowReplies ? 'Replies allowed' : 'View only',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyLink(context),
                      icon: const Icon(LucideIcons.copy, size: 16),
                      label: const Text('Copy link'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    tooltip: 'Delete share',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    if (share.shareUrl != null) {
      Clipboard.setData(ClipboardData(text: share.shareUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  void _showShareDetails(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              share.title ?? 'Shared Conversation',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              icon: LucideIcons.eye,
              label: 'Views',
              value: '${share.viewCount}',
            ),
            _DetailRow(
              icon: LucideIcons.calendar,
              label: 'Created',
              value: _formatDate(share.createdAt),
            ),
            if (share.expiresAt != null)
              _DetailRow(
                icon: LucideIcons.clock,
                label: 'Expires',
                value: _formatDate(share.expiresAt!),
              ),
            _DetailRow(
              icon: share.allowReplies ? LucideIcons.gitFork : LucideIcons.lock,
              label: 'Replies',
              value: share.allowReplies ? 'Allowed' : 'Disabled',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleActive(ref);
                    },
                    icon: Icon(
                      share.isActive ? LucideIcons.unlink : LucideIcons.link,
                      size: 18,
                    ),
                    label: Text(share.isActive ? 'Disable' : 'Enable'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _copyLink(context);
                    },
                    icon: const Icon(LucideIcons.copy, size: 18),
                    label: const Text('Copy link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleActive(WidgetRef ref) {
    ref.read(mySharesProvider.notifier).updateShare(
          shareId: share.id,
          isActive: !share.isActive,
        );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.alertTriangle, color: colorScheme.error),
        title: const Text('Delete share?'),
        content: const Text(
          'This will remove the share link. Anyone with the link will no longer be able to view this conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(mySharesProvider.notifier).deleteShare(share.id);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

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
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load shares',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
