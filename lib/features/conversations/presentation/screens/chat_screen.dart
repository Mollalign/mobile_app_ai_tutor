import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../sharing/presentation/widgets/share_conversation_sheet.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Chat screen for a single conversation.
/// Clean, minimal design focused on the conversation.
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
                debugPrint('ChatScreen: Loading chat...');
                chatNotifier.loadChat();
              }
            });
          },
        );

        // Scroll to bottom when new messages arrive or during streaming
        if (chatState is ChatLoaded) {
          if (chatState.isStreaming) {
            debugPrint('ChatScreen: Streaming - content length: ${chatState.streamingContent?.length ?? 0}');
          }
          
          if (chatState.messages.length > _lastMessageCount || chatState.isStreaming) {
            if (chatState.messages.length > _lastMessageCount) {
              _lastMessageCount = chatState.messages.length;
            }
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
            debugPrint('ChatScreen: Loaded - messages: ${messages.length}, streaming: $isStreaming');
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
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
                'Something went wrong',
                style: textTheme.titleMedium?.copyWith(
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
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Try again'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: () => _showConversationInfo(context, conversation),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Chat type indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: conversation.isProjectChat
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                ),
              const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                  conversation.displayTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: colorScheme.onSurfaceVariant,
            ),
          ],
          ),
        ),
        actions: [
          // More options
          IconButton(
            onPressed: () => _showOptionsMenu(context, conversation),
            icon: const Icon(LucideIcons.moreHorizontal),
            tooltip: 'Options',
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
                      top: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        key: ValueKey('${message.id}-${message.content.length}'),
                        message: message,
                      );
                    },
                  ),
          ),

          // Chat input
          ChatInput(
            onSend: (content, {attachment}) => _sendMessage(content, attachment: attachment),
            isLoading: isLoading,
            isSocratic: conversation.isSocratic,
            onToggleSocratic: () => ref
                .read(chatNotifierProvider(widget.conversationId))
                .toggleSocraticMode(),
            hintText: conversation.isProjectChat
                ? 'Ask about your documents...'
                : 'Ask anything...',
            enableImageAttachment: true,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content, {ChatAttachment? attachment}) {
    ref
        .read(chatNotifierProvider(widget.conversationId))
        .sendMessageStreaming(
          content,
          imageBase64: attachment?.imageBase64,
          imageUrl: attachment?.imageUrl,
        );
  }

  void _showConversationInfo(BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;
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
              conversation.displayTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _InfoChip(
                  icon: conversation.isProjectChat
                      ? LucideIcons.bookOpen
                      : LucideIcons.sparkles,
                  label: conversation.isProjectChat ? 'Project Chat' : 'Quick Chat',
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                if (conversation.isSocratic)
                  _InfoChip(
                    icon: LucideIcons.graduationCap,
                    label: 'Socratic',
                    color: colorScheme.tertiary,
                  ),
              ],
            ),
            if (conversation.isProjectChat && conversation.projectName != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    LucideIcons.folder,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      conversation.projectName!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, conversation);
              },
            ),
            ListTile(
              leading: Icon(
                LucideIcons.share2,
                color: colorScheme.primary,
              ),
              title: const Text('Share conversation'),
              onTap: () {
                Navigator.pop(context);
                _showShareSheet(context, conversation);
              },
            ),
            ListTile(
              leading: Icon(
                conversation.isSocratic
                    ? LucideIcons.graduationCap
                    : LucideIcons.messageSquare,
                color: colorScheme.tertiary,
              ),
              title: Text(conversation.isSocratic
                  ? 'Switch to Direct mode'
                  : 'Switch to Socratic mode'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(chatNotifierProvider(widget.conversationId))
                    .toggleSocraticMode();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(LucideIcons.trash2, color: colorScheme.error),
              title: Text(
                'Delete conversation',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, conversation);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, ConversationDetail conversation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ShareConversationSheet(
        conversationId: conversation.id,
        conversationTitle: conversation.displayTitle,
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ConversationDetail conversation) {
    final controller = TextEditingController(text: conversation.title ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
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
        title: const Text('Delete conversation?'),
        content: const Text(
          'This will permanently delete this conversation and all messages.',
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

/// Info chip for conversation details.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state with welcoming prompts.
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
            'Summarize the key concepts',
            'What are the main topics?',
            'Quiz me on this material',
          ]
        : [
            'Explain recursion simply',
            'What is Big O notation?',
            'Difference between stack & queue',
          ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 36,
                color: Colors.white,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),

            // Welcome text
            Text(
              'How can I help you?',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              conversation.isSocratic
                  ? "I'll guide your learning with questions"
                  : "I'll answer your questions directly",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),

            // Suggested prompts
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final prompt = entry.value;
                return _SuggestionChip(
                  text: prompt,
                  onTap: () => onSendMessage(prompt),
                ).animate().fadeIn(delay: (300 + index * 100).ms).slideY(
                      begin: 0.2,
                      duration: 300.ms,
                    );
              }).toList(),
                    ),
          ],
        ),
      ),
    );
  }
}

/// Suggestion chip button.
class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
