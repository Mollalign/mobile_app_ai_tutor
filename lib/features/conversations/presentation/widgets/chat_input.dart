import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';

/// Modern chat input widget with pill-shaped design.
/// Inspired by ChatGPT's clean, minimal input.
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final bool isSocratic;
  final VoidCallback? onToggleSocratic;
  final String? hintText;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.isSocratic = true,
    this.onToggleSocratic,
    this.hintText,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        // Subtle top shadow
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main input container
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colorScheme.primary.withAlpha(128)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Socratic mode toggle (compact)
                if (widget.onToggleSocratic != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xs,
                      bottom: AppSpacing.xs,
                    ),
                    child: IconButton(
                      onPressed: widget.onToggleSocratic,
                      icon: Icon(
                        LucideIcons.graduationCap,
                        size: 20,
                        color: widget.isSocratic
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      tooltip: widget.isSocratic
                          ? 'Socratic mode (tap to disable)'
                          : 'Direct mode (tap for Socratic)',
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: widget.isSocratic
                            ? colorScheme.tertiaryContainer.withAlpha(77)
                            : Colors.transparent,
                      ),
                    ),
                  ),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isLoading,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    style: textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Message...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(153),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: widget.onToggleSocratic != null ? 0 : AppSpacing.lg,
                        right: AppSpacing.sm,
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send button
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: _SendButton(
                      isEnabled: _hasText && !widget.isLoading,
                      isLoading: widget.isLoading,
                      onPressed: _sendMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mode indicator (subtle, below input)
          if (widget.onToggleSocratic != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.isSocratic
                    ? 'Socratic mode • Guides with questions'
                    : 'Direct mode • Gives straight answers',
                key: ValueKey(widget.isSocratic),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(153),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated send button.
class _SendButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isEnabled ? colorScheme.primary : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isEnabled
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                )
              : Icon(
                  LucideIcons.arrowUp,
                  size: 20,
                  color: isEnabled
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant.withAlpha(128),
                ),
        ),
      ),
    ).animate(target: isEnabled ? 1 : 0).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }
}

/// Simplified chat input for quick use.
class SimpleChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final String? hintText;

  const SimpleChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<SimpleChatInput> createState() => _SimpleChatInputState();
}

class _SimpleChatInputState extends State<SimpleChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !widget.isLoading,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Message...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(153),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _SendButton(
                isEnabled: _hasText && !widget.isLoading,
                isLoading: widget.isLoading,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
