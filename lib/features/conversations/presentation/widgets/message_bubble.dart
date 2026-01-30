import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';

/// Message bubble widget for displaying chat messages.
/// Clean, minimal design inspired by ChatGPT.
class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onSourceTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.role.isUser) {
      return _UserMessage(message: message);
    } else if (message.role.isAssistant) {
      return _AssistantMessage(
        message: message,
        onSourceTap: onSourceTap,
      );
    } else {
      return _SystemMessage(message: message);
    }
  }
}

/// User message - right-aligned bubble.
class _UserMessage extends StatelessWidget {
  final Message message;

  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: AppSpacing.xxl),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (message.isPending) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: colorScheme.onPrimary.withAlpha(179),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Assistant message - left-aligned, clean text without bubble.
class _AssistantMessage extends StatefulWidget {
  final Message message;
  final VoidCallback? onSourceTap;

  const _AssistantMessage({
    required this.message,
    this.onSourceTap,
  });

  @override
  State<_AssistantMessage> createState() => _AssistantMessageState();
}

class _AssistantMessageState extends State<_AssistantMessage> {
  bool _isHovered = false;
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onLongPress: () => setState(() => _showActions = !_showActions),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI indicator
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'AI Tutor',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Message content
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxl),
                child: widget.message.isStreaming && widget.message.content.isEmpty
                    ? const _TypingIndicator()
                    : MarkdownBody(
                        data: widget.message.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: colorScheme.onSurface,
                          ),
                          h1: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          h2: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          h3: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          code: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: colorScheme.primary,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          codeblockPadding: const EdgeInsets.all(AppSpacing.md),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          blockquotePadding: const EdgeInsets.only(
                            left: AppSpacing.md,
                          ),
                          listBullet: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
              ),

              // Sources
              if (widget.message.hasSources) ...[
                const SizedBox(height: AppSpacing.md),
                _SourcesSection(
                  sources: widget.message.sources,
                  onSourceTap: widget.onSourceTap,
                ),
              ],

              // Actions (copy, etc.) - show on hover or tap
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: (_isHovered || _showActions) && !widget.message.isStreaming
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: _MessageActions(
                          message: widget.message,
                          onDismiss: () => setState(() => _showActions = false),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// System message - centered, subtle.
class _SystemMessage extends StatelessWidget {
  final Message message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Text(
          message.content,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Typing indicator animation (three dots).
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(179),
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .fadeIn(delay: (index * 200).ms)
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(0.6, 0.6),
              duration: 500.ms,
              curve: Curves.easeInOut,
            );
      }),
    );
  }
}

/// Message action buttons.
class _MessageActions extends StatelessWidget {
  final Message message;
  final VoidCallback? onDismiss;

  const _MessageActions({
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: LucideIcons.copy,
          label: 'Copy',
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
            onDismiss?.call();
          },
        ),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// Individual action button.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sources section with collapsible list.
class _SourcesSection extends StatefulWidget {
  final List<SourceCitation> sources;
  final VoidCallback? onSourceTap;

  const _SourcesSection({
    required this.sources,
    this.onSourceTap,
  });

  @override
  State<_SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<_SourcesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.sources.length} source${widget.sources.length > 1 ? 's' : ''}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: widget.sources.map((source) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.fileText,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                source.displayText,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
