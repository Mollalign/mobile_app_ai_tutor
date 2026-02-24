import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
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
  ChatChangeNotifier? _notifier;
  Type? _lastStateType;
  String? _lastConversationTitle;
  bool? _lastIsSocratic;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _notifier = ref.read(chatNotifierProvider(widget.conversationId));
      _notifier!.addListener(_onNotifierChanged);
      _notifier!.loadChat();
    });
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChanged);
    _scrollController.dispose();
    super.dispose();
  }

  /// Only triggers a top-level rebuild when the state TYPE changes
  /// or conversation metadata (title/socratic) changes — not on every
  /// streaming chunk. This keeps the Scaffold and AppBar stable.
  void _onNotifierChanged() {
    if (!mounted || _notifier == null) return;
    final state = _notifier!.state;
    final newType = state.runtimeType;

    if (newType != _lastStateType) {
      _lastStateType = newType;
      if (state is ChatLoaded) {
        _lastConversationTitle = state.conversation.title;
        _lastIsSocratic = state.conversation.isSocratic;
      }
      setState(() {});
      return;
    }

    if (state is ChatLoaded) {
      if (state.conversation.title != _lastConversationTitle ||
          state.conversation.isSocratic != _lastIsSocratic) {
        _lastConversationTitle = state.conversation.title;
        _lastIsSocratic = state.conversation.isSocratic;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatNotifier = ref.watch(chatNotifierProvider(widget.conversationId));
    final state = chatNotifier.state;

    if (state is ChatLoaded) {
      return _buildLoadedScaffold(context, chatNotifier, state);
    }
    if (state is ChatError) {
      return _buildErrorScaffold(context, state.message);
    }
    return _buildLoadingScaffold(context);
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const ShimmerChatMessages(),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ErrorState(
        message: message,
        onRetry: () => ref
            .read(chatNotifierProvider(widget.conversationId))
            .loadChat(),
      ),
    );
  }

  Widget _buildLoadedScaffold(
    BuildContext context,
    ChatChangeNotifier chatNotifier,
    ChatLoaded state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final conversation = state.conversation;

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
          IconButton(
            onPressed: () => _showOptionsMenu(context, conversation),
            icon: const Icon(LucideIcons.moreHorizontal),
            tooltip: 'Options',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _ChatMessagesList(
              chatNotifier: chatNotifier,
              scrollController: _scrollController,
              conversation: conversation,
              onSendMessage: _sendMessage,
            ),
          ),
          _ChatInputWrapper(
            chatNotifier: chatNotifier,
            conversation: conversation,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content, {ChatAttachment? attachment}) {
    HapticFeedback.lightImpact();
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

/// Scoped messages list — only this subtree rebuilds during streaming.
class _ChatMessagesList extends StatefulWidget {
  final ChatChangeNotifier chatNotifier;
  final ScrollController scrollController;
  final ConversationDetail conversation;
  final void Function(String, {ChatAttachment? attachment}) onSendMessage;

  const _ChatMessagesList({
    required this.chatNotifier,
    required this.scrollController,
    required this.conversation,
    required this.onSendMessage,
  });

  @override
  State<_ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<_ChatMessagesList> {
  int _lastMessageCount = 0;

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.chatNotifier,
      builder: (context, _) {
        final state = widget.chatNotifier.state;
        if (state is! ChatLoaded) return const SizedBox.shrink();

        final messages = state.messages;

        if (messages.length > _lastMessageCount || state.isStreaming) {
          if (messages.length > _lastMessageCount) {
            _lastMessageCount = messages.length;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToBottom();
          });
        }

        if (messages.isEmpty) {
          return _EmptyChat(
            conversation: widget.conversation,
            onSendMessage: (msg) => widget.onSendMessage(msg),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return RepaintBoundary(
              child: MessageBubble(
                key: ValueKey(message.id),
                message: message,
                animate: !message.isStreaming,
              ),
            );
          },
        );
      },
    );
  }
}

/// Scoped input bar — rebuilds only when isLoading changes.
class _ChatInputWrapper extends StatelessWidget {
  final ChatChangeNotifier chatNotifier;
  final ConversationDetail conversation;
  final void Function(String, {ChatAttachment? attachment}) onSendMessage;

  const _ChatInputWrapper({
    required this.chatNotifier,
    required this.conversation,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatNotifier,
      builder: (context, _) {
        final state = chatNotifier.state;
        final isLoading =
            state is ChatLoaded && (state.isSending || state.isStreaming);

        return ChatInput(
          onSend: (content, {attachment}) =>
              onSendMessage(content, attachment: attachment),
          isLoading: isLoading,
          isSocratic: conversation.isSocratic,
          onToggleSocratic: () => chatNotifier.toggleSocraticMode(),
          hintText: conversation.isProjectChat
              ? 'Ask about your documents...'
              : 'Ask anything...',
          enableImageAttachment: true,
        );
      },
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
            const AppLogo(size: 72)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
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
