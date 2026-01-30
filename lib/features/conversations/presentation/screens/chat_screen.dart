import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Chat screen for a single conversation.
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatNotifier = ref.watch(chatNotifierProvider(widget.conversationId));
    
    return AnimatedBuilder(
      animation: chatNotifier,
      builder: (context, _) {
        final chatState = chatNotifier.state;

        // Load chat if in initial state
        chatState.whenOrNull(
          initial: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                chatNotifier.loadChat();
              }
            });
          },
        );

        // Scroll to bottom when new messages arrive
        if (chatState is ChatLoaded) {
          if (chatState.messages.length > _lastMessageCount) {
            _lastMessageCount = chatState.messages.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _scrollToBottom();
              }
            });
          }
        }

        return chatState.when(
          initial: () => _buildLoadingScaffold(context),
          loading: () => _buildLoadingScaffold(context),
          loaded: (conversation, messages, isSending, isStreaming, streamingContent, pendingSources) {
            return _buildLoadedScaffold(
              context,
              conversation,
              messages,
              isSending || isStreaming,
            );
          },
          error: (message) => _buildErrorScaffold(context, message),
        );
      },
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
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
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Failed to load conversation',
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
                onPressed: () => ref
                    .read(chatNotifierProvider(widget.conversationId))
                    .loadChat(),
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedScaffold(
    BuildContext context,
    ConversationDetail conversation,
    List<Message> messages,
    bool isLoading,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.displayTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  conversation.isProjectChat
                      ? LucideIcons.bookOpen
                      : LucideIcons.sparkles,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    conversation.isProjectChat
                        ? conversation.projectName ?? 'Project Chat'
                        : 'Quick Chat',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Socratic mode toggle
          IconButton(
            onPressed: () => ref
                .read(chatNotifierProvider(widget.conversationId))
                .toggleSocraticMode(),
            icon: Icon(
              LucideIcons.graduationCap,
              color: conversation.isSocratic
                  ? colorScheme.tertiary
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: conversation.isSocratic
                ? 'Socratic mode on'
                : 'Socratic mode off',
          ),
          // More options
          PopupMenuButton(
            icon: const Icon(LucideIcons.moreVertical),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _showRenameDialog(context, conversation),
                child: const Row(
                  children: [
                    Icon(LucideIcons.pencil, size: 18),
                    SizedBox(width: 12),
                    Text('Rename'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _confirmDelete(context, conversation),
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 18, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(
                    conversation: conversation,
                    onSendMessage: (message) => _sendMessage(message),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                      );
                    },
                  ),
          ),

          // Chat input
          ChatInput(
            onSend: _sendMessage,
            isLoading: isLoading,
            isSocratic: conversation.isSocratic,
            onToggleSocratic: () => ref
                .read(chatNotifierProvider(widget.conversationId))
                .toggleSocraticMode(),
            hintText: conversation.isProjectChat
                ? 'Ask about your documents...'
                : 'Ask anything...',
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    // Use streaming for better UX
    ref
        .read(chatNotifierProvider(widget.conversationId))
        .sendMessageStreaming(content);
  }

  void _showRenameDialog(BuildContext context, ConversationDetail conversation) {
    final controller = TextEditingController(text: conversation.title ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Enter a title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(chatNotifierProvider(widget.conversationId))
                      .updateTitle(controller.text.trim());
                },
                child: const Text('Save'),
              ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.alertTriangle, color: colorScheme.error),
        title: const Text('Delete Conversation?'),
        content: const Text(
          'This will permanently delete this conversation and all its messages. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(conversationsNotifierProvider)
                  .deleteConversation(widget.conversationId);
              if (context.mounted) {
                context.pop();
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
}

/// Empty state with suggested prompts.
class _EmptyChat extends StatelessWidget {
  final ConversationDetail conversation;
  final Function(String) onSendMessage;

  const _EmptyChat({
    required this.conversation,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final prompts = conversation.isProjectChat
        ? [
            'Summarize the key concepts from my documents',
            'What are the main topics covered?',
            'Help me understand the relationship between...',
            'Quiz me on the material',
          ]
        : [
            'Explain how recursion works',
            'What is the difference between a stack and a queue?',
            'Help me understand Big O notation',
            'Write a simple sorting algorithm',
          ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                conversation.isProjectChat
                    ? LucideIcons.bookOpen
                    : LucideIcons.sparkles,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              conversation.isProjectChat
                  ? 'Ask about your documents'
                  : 'Start a conversation',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              conversation.isSocratic
                  ? "I'll guide your learning with thoughtful questions"
                  : "I'll help answer your questions directly",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),

            // Suggested prompts
            Text(
              'Try asking:',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppSpacing.md),

            ...prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final prompt = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SuggestedPrompt(
                  text: prompt,
                  onTap: () => onSendMessage(prompt),
                ).animate().fadeIn(delay: (400 + index * 100).ms).slideY(
                      begin: 0.2,
                      duration: 300.ms,
                    ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Suggested prompt chip.
class _SuggestedPrompt extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestedPrompt({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: AppRadius.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.messageSquare,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
