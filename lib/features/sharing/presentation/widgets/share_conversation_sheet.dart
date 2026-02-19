import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/sharing_models.dart';
import '../providers/sharing_providers.dart';

/// Bottom sheet for sharing a conversation.
class ShareConversationSheet extends ConsumerStatefulWidget {
  final String conversationId;
  final String? conversationTitle;

  const ShareConversationSheet({
    super.key,
    required this.conversationId,
    this.conversationTitle,
  });

  @override
  ConsumerState<ShareConversationSheet> createState() => _ShareConversationSheetState();
}

class _ShareConversationSheetState extends ConsumerState<ShareConversationSheet> {
  bool _isCreating = false;
  bool _allowReplies = true;
  int? _expiresInDays;
  SharedConversationModel? _createdShare;
  String _shareMode = 'public'; // 'public' or 'private'
  final _emailsController = TextEditingController();
  bool _isSharingPrivate = false;

  @override
  void dispose() {
    _emailsController.dispose();
    super.dispose();
  }

  Future<void> _createPublicShare() async {
    setState(() => _isCreating = true);

    try {
      final share = await ref.read(mySharesProvider.notifier).createShare(
        conversationId: widget.conversationId,
        title: widget.conversationTitle,
        allowReplies: _allowReplies,
        expiresInDays: _expiresInDays,
      );

      setState(() {
        _createdShare = share;
        _isCreating = false;
      });
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sharePrivately() async {
    final emails = _emailsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one email')),
      );
      return;
    }

    setState(() => _isSharingPrivate = true);

    try {
      await ref.read(shareActionsProvider).sharePrivately(
        conversationId: widget.conversationId,
        userEmails: emails,
        canReply: _allowReplies,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared with ${emails.length} user(s)'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSharingPrivate = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _copyShareLink() {
    if (_createdShare?.shareUrl != null) {
      Clipboard.setData(ClipboardData(text: _createdShare!.shareUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_createdShare != null) {
      return _buildShareCreatedView(colorScheme, textTheme);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Drag handle
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Share Conversation',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Mode selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'public',
                  label: Text('Public Link'),
                  icon: Icon(LucideIcons.link),
                ),
                ButtonSegment(
                  value: 'private',
                  label: Text('Private'),
                  icon: Icon(LucideIcons.users),
                ),
              ],
              selected: {_shareMode},
              onSelectionChanged: (selected) {
                setState(() => _shareMode = selected.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _shareMode == 'public'
                  ? _buildPublicShareOptions(colorScheme, textTheme)
                  : _buildPrivateShareOptions(colorScheme, textTheme),
            ),
          ),

          // Action button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: _shareMode == 'public'
                    ? FilledButton.icon(
                        onPressed: _isCreating ? null : _createPublicShare,
                        icon: _isCreating
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(LucideIcons.link),
                        label: Text(_isCreating ? 'Creating...' : 'Create Share Link'),
                      )
                    : FilledButton.icon(
                        onPressed: _isSharingPrivate ? null : _sharePrivately,
                        icon: _isSharingPrivate
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(LucideIcons.send),
                        label: Text(_isSharingPrivate ? 'Sharing...' : 'Share'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicShareOptions(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Anyone with the link can view this conversation',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: AppSpacing.lg),

        // Options
        Text(
          'Options',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Allow replies toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Allow replies'),
          subtitle: Text(
            'Viewers can fork and continue the conversation',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: _allowReplies,
          onChanged: (value) => setState(() => _allowReplies = value),
        ),

        const Divider(),

        // Expiration
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Expires after'),
          trailing: DropdownButton<int?>(
            value: _expiresInDays,
            items: const [
              DropdownMenuItem(value: null, child: Text('Never')),
              DropdownMenuItem(value: 1, child: Text('1 day')),
              DropdownMenuItem(value: 7, child: Text('7 days')),
              DropdownMenuItem(value: 30, child: Text('30 days')),
              DropdownMenuItem(value: 90, child: Text('90 days')),
            ],
            onChanged: (value) => setState(() => _expiresInDays = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateShareOptions(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.lock,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Only specified users can access this conversation',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: AppSpacing.lg),

        // Email input
        Text(
          'Share with',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _emailsController,
          decoration: InputDecoration(
            hintText: 'Enter email addresses (comma-separated)',
            prefixIcon: const Icon(LucideIcons.mail),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          minLines: 1,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Allow replies toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Allow replies'),
          subtitle: Text(
            'Recipients can reply and continue the conversation',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: _allowReplies,
          onChanged: (value) => setState(() => _allowReplies = value),
        ),
      ],
    );
  }

  Widget _buildShareCreatedView(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.check,
              size: 32,
              color: colorScheme.primary,
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Share Link Created!',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Anyone with this link can view the conversation',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.xl),

          // Share link box
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.link,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _createdShare!.shareUrl ?? 'Share link generated',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _copyShareLink,
                  icon: const Icon(LucideIcons.copy),
                  iconSize: 18,
                  tooltip: 'Copy link',
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.xl),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                  label: const Text('Close'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _copyShareLink,
                  icon: const Icon(LucideIcons.copy),
                  label: const Text('Copy Link'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
