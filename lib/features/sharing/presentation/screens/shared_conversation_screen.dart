import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/sharing_models.dart';
import '../providers/sharing_providers.dart';

/// Screen for viewing a shared conversation via public link.
class SharedConversationScreen extends ConsumerWidget {
  final String shareToken;

  const SharedConversationScreen({
    super.key,
    required this.shareToken,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedConversation = ref.watch(shareViewProvider(shareToken));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Conversation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: sharedConversation.when(
        data: (conversation) => _SharedConversationContent(
          conversation: conversation,
          shareToken: shareToken,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(shareViewProvider(shareToken)),
        ),
      ),
    );
  }
}

class _SharedConversationContent extends ConsumerStatefulWidget {
  final SharedConversationFullModel conversation;
  final String shareToken;

  const _SharedConversationContent({
    required this.conversation,
    required this.shareToken,
  });

  @override
  ConsumerState<_SharedConversationContent> createState() =>
      _SharedConversationContentState();
}

class _SharedConversationContentState
    extends ConsumerState<_SharedConversationContent> {
  bool _isForking = false;

  Future<void> _forkConversation() async {
    setState(() => _isForking = true);

    try {
      final fork = await ref.read(shareActionsProvider).forkSharedConversation(
            token: widget.shareToken,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation forked successfully!')),
        );
        context.go('/conversations/${fork.conversationId}');
      }
    } catch (e) {
      setState(() => _isForking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fork: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final conversation = widget.conversation;

    return Column(
      children: [
        // Header info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (conversation.title != null) ...[
                Text(
                  conversation.title!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Row(
                children: [
                  Icon(
                    LucideIcons.user,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Shared by ${conversation.sharedByName}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    LucideIcons.messageSquare,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${conversation.messageCount} messages',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(),

        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) {
              final message = conversation.messages[index];
              return _SharedMessageBubble(message: message);
            },
          ),
        ),

        // Fork button
        if (conversation.allowReplies)
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withAlpha(77),
                  ),
                ),
              ),
              child: FilledButton.icon(
                onPressed: _isForking ? null : _forkConversation,
                icon: _isForking
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(LucideIcons.gitFork),
                label: Text(
                  _isForking ? 'Creating your copy...' : 'Continue this conversation',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SharedMessageBubble extends StatelessWidget {
  final SharedMessageModel message;

  const _SharedMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: isUser
            ? Text(
                message.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  code: textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: colorScheme.surfaceContainerHigh,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, duration: 200.ms);
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 32,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unable to load shared conversation',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
