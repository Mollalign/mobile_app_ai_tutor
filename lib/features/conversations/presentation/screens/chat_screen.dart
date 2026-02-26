import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../../sharing/presentation/widgets/share_conversation_sheet.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

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

  void _popAndRefresh() {
    ref.read(conversationsNotifierProvider).loadConversations(refresh: true);
    context.pop();
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChanged);
    _scrollController.dispose();
    super.dispose();
  }

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
    final chatNotifier =
        ref.watch(chatNotifierProvider(widget.conversationId));
    final state = chatNotifier.state;

    if (state is ChatLoaded) {
      return _buildLoaded(context, chatNotifier, state);
    }
    if (state is ChatError) {
      return _buildError(context, state.message);
    }
    return _buildLoading(context);
  }

  // ── Loading ────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _minimalAppBar(context),
      body: const ShimmerChatMessages(),
    );
  }

  // ── Error ──────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _minimalAppBar(context),
      body: ErrorState(
        message: message,
        onRetry: () =>
            ref.read(chatNotifierProvider(widget.conversationId)).loadChat(),
      ),
    );
  }

  AppBar _minimalAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  // ── Loaded ─────────────────────────────────────────────────

  Widget _buildLoaded(
    BuildContext context,
    ChatChangeNotifier chatNotifier,
    ChatLoaded state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversation = state.conversation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popAndRefresh();
      },
      child: Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: colorScheme.primary.withAlpha(20),
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: _popAndRefresh,
          icon: Icon(
            LucideIcons.chevronLeft,
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
        title: GestureDetector(
          onTap: () => _showConversationInfo(context, conversation),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status dot
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: conversation.isProjectChat
                        ? [colorScheme.primary, colorScheme.primary.withAlpha(180)]
                        : [colorScheme.secondary, colorScheme.secondary.withAlpha(180)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (conversation.isProjectChat
                              ? colorScheme.primary
                              : colorScheme.secondary)
                          .withAlpha(isDark ? 60 : 40),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  conversation.displayTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                LucideIcons.chevronDown,
                size: 13,
                color: colorScheme.onSurfaceVariant.withAlpha(130),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showOptionsMenu(context, conversation),
            icon: Icon(
              LucideIcons.moreHorizontal,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Options',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _ChatMessagesList(
                  chatNotifier: chatNotifier,
                  scrollController: _scrollController,
                  conversation: conversation,
                  onSendMessage: _sendMessage,
                ),
                _ScrollToBottomFab(scrollController: _scrollController),
              ],
            ),
          ),
          _ChatInputWrapper(
            chatNotifier: chatNotifier,
            conversation: conversation,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
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

  // ── Info Sheet ─────────────────────────────────────────────

  void _showConversationInfo(
      BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.displayTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: conversation.isProjectChat
                      ? LucideIcons.bookOpen
                      : LucideIcons.sparkles,
                  label: conversation.isProjectChat
                      ? 'Project Chat'
                      : 'Quick Chat',
                  color: colorScheme.primary,
                ),
                if (conversation.isSocratic)
                  _InfoChip(
                    icon: LucideIcons.graduationCap,
                    label: 'Socratic',
                    color: colorScheme.tertiary,
                  ),
                _InfoChip(
                  icon: LucideIcons.messageCircle,
                  label: '${conversation.messageCount} messages',
                  color: colorScheme.secondary,
                ),
              ],
            ),
            if (conversation.isProjectChat &&
                conversation.projectName != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(LucideIcons.folder,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      conversation.projectName!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Options Menu ───────────────────────────────────────────

  void _showOptionsMenu(
      BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              icon: LucideIcons.pencil,
              label: 'Rename',
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, conversation);
              },
            ),
            _OptionTile(
              icon: LucideIcons.share2,
              label: 'Share conversation',
              color: colorScheme.primary,
              onTap: () {
                Navigator.pop(context);
                _showShareSheet(context, conversation);
              },
            ),
            _OptionTile(
              icon: conversation.isSocratic
                  ? LucideIcons.graduationCap
                  : LucideIcons.messageSquare,
              label: conversation.isSocratic
                  ? 'Switch to Direct mode'
                  : 'Switch to Socratic mode',
              color: colorScheme.tertiary,
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(chatNotifierProvider(widget.conversationId))
                    .toggleSocraticMode();
              },
            ),
            Divider(
              color: colorScheme.outlineVariant.withAlpha(60),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            _OptionTile(
              icon: LucideIcons.trash2,
              label: 'Delete conversation',
              color: colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, conversation);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(
      BuildContext context, ConversationDetail conversation) {
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

  void _showRenameDialog(
      BuildContext context, ConversationDetail conversation) {
    final controller =
        TextEditingController(text: conversation.title ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename conversation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter a title'),
          autofocus: true,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(chatNotifierProvider(widget.conversationId))
                  .updateTitle(controller.text.trim());
            },
            child: const Text('Save', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ConversationDetail conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.alertTriangle,
            color: colorScheme.error, size: 28),
        title: const Text('Delete conversation?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'This will permanently delete this conversation and all messages.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(conversationsNotifierProvider)
                  .deleteConversation(widget.conversationId);
              if (context.mounted) context.pop();
            },
            style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error),
            child: const Text('Delete', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Messages List ─────────────────────────────────────────────

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
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 6, bottom: 6),
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

// ─── Input Wrapper ─────────────────────────────────────────────

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

// ─── Info Chip ─────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option Tile ───────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, size: 18, color: c),
      title: Text(label, style: TextStyle(fontSize: 14, color: c)),
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}

// ─── Empty Chat ────────────────────────────────────────────────

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

    final prompts = conversation.isProjectChat
        ? [
            ('Summarize the key concepts', LucideIcons.listChecks),
            ('What are the main topics?', LucideIcons.bookOpen),
            ('Quiz me on this material', LucideIcons.brain),
          ]
        : [
            ('Help me understand a concept', LucideIcons.lightbulb),
            ('Prepare me for an exam', LucideIcons.graduationCap),
            ('Explain something step by step', LucideIcons.listChecks),
          ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 56)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'How can I help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 6),
            Text(
              conversation.isSocratic
                  ? "I'll guide your learning with questions"
                  : "I'll answer your questions directly",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),

            // Suggestion chips
            ...prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final (text, icon) = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SuggestionCard(
                  text: text,
                  icon: icon,
                  onTap: () => onSendMessage(text),
                ),
              )
                  .animate()
                  .fadeIn(delay: (280 + index * 80).ms)
                  .slideY(begin: 0.12, duration: 280.ms, curve: Curves.easeOutCubic);
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Suggestion Card ───────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest.withAlpha(140)
          : colorScheme.surfaceContainerHighest.withAlpha(180),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(isDark ? 25 : 50),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(isDark ? 25 : 15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 14, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: colorScheme.onSurfaceVariant.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Scroll to Bottom FAB
// ════════════════════════════════════════════════════════════════

class _ScrollToBottomFab extends StatefulWidget {
  final ScrollController scrollController;
  const _ScrollToBottomFab({required this.scrollController});

  @override
  State<_ScrollToBottomFab> createState() => _ScrollToBottomFabState();
}

class _ScrollToBottomFabState extends State<_ScrollToBottomFab> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final show = widget.scrollController.offset > 200;
    if (show != _showButton) setState(() => _showButton = show);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      bottom: _showButton ? 12 : -48,
      right: 12,
      child: Material(
        color:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(isDark ? 40 : 80),
              ),
            ),
            child: Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
