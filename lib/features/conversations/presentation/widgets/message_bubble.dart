import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/entities.dart';

/// Message bubble widget for displaying chat messages.
/// Modern, beautiful design with subtle animations.
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

/// User message - Beautiful gradient bubble, right-aligned.
class _UserMessage extends StatelessWidget {
  final Message message;

  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        left: 48,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                // Beautiful gradient for user messages
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          colorScheme.primary,
                          colorScheme.primary.withAlpha(230),
                        ]
                      : [
                          colorScheme.primary,
                          Color.fromRGBO(
                            (colorScheme.primary.r * 255.0).round().clamp(0, 255),
                            (colorScheme.primary.g * 255.0).round().clamp(0, 255),
                            ((colorScheme.primary.b * 255) * 0.85).round().clamp(0, 255),
                            1,
                          ),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(6),
                ),
                // Subtle glow effect in dark mode
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(51),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(38),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (message.isPending) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withAlpha(179),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

/// Assistant message - Clean, elegant design with markdown support.
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
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        if (_showActions) {
          setState(() => _showActions = false);
        }
      },
      onLongPress: () => setState(() => _showActions = !_showActions),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 48,
          top: 12,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Avatar & Label
            Row(
              children: [
                const AppLogo(size: 32),
                const SizedBox(width: 12),
                Text(
                  'AI Tutor',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Action button (always visible, subtle)
                if (!widget.message.isStreaming)
                  _CopyButton(
                    message: widget.message,
                    isVisible: true,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Message content with beautiful markdown
            widget.message.isStreaming && widget.message.content.isEmpty
                ? const _TypingIndicator()
                : Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: MarkdownBody(
                      data: widget.message.content,
                      selectable: true,
                      styleSheet: _buildMarkdownStyleSheet(context),
                      builders: {
                        'code': _CodeBlockBuilder(context: context),
                      },
                    ),
                  ),

            // Sources section
            if (widget.message.hasSources) ...[
              const SizedBox(height: 16),
              _SourcesSection(
                sources: widget.message.sources,
                onSourceTap: widget.onSourceTap,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MarkdownStyleSheet(
      // Paragraph
      p: textTheme.bodyLarge?.copyWith(
        height: 1.7,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
      ),
      
      // Headers
      h1: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      h2: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      h3: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      
      // Code styling - Modern look
      code: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        color: colorScheme.primary,
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer.withAlpha(77),
        fontWeight: FontWeight.w500,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E) // VS Code dark background
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant
              : colorScheme.outline.withAlpha(77),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      
      // Blockquote - Elegant left border
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colorScheme.primary,
            width: 4,
          ),
        ),
        color: colorScheme.primaryContainer.withAlpha(26),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      
      // Lists
      listBullet: textTheme.bodyLarge?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      listIndent: 24,
      
      // Links
      a: textTheme.bodyLarge?.copyWith(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: colorScheme.primary.withAlpha(128),
      ),
      
      // Emphasis
      strong: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      em: textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
        color: colorScheme.onSurface,
      ),
      
      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// System message - Subtle, centered.
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
          horizontal: 32,
          vertical: 16,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.content,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Beautiful thinking indicator with animated gradient dots and shimmer.
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(179),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thinking',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(3, (index) {
                  return Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        delay: (index * 200).ms,
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(0.4, 0.4),
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      );
                }),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(
                duration: 2000.ms,
                color: colorScheme.primary.withAlpha(26),
              ),
        ],
      ),
    );
  }
}

/// Compact copy button.
class _CopyButton extends StatelessWidget {
  final Message message;
  final bool isVisible;

  const _CopyButton({
    required this.message,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      opacity: isVisible ? 0.6 : 0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      LucideIcons.check,
                      size: 18,
                      color: colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: 8),
                    const Text('Copied to clipboard'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              LucideIcons.copy,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sources section with modern expandable design.
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

/// Custom code block builder with header (language label + copy button).
class _CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  _CodeBlockBuilder({required this.context});

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final code = element.textContent.trimRight();

    String? language;
    if (element.attributes.containsKey('class')) {
      language = element.attributes['class']?.replaceFirst('language-', '');
    }

    // Only custom-render fenced code blocks (multi-line)
    if (!code.contains('\n')) return null;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colorScheme.outlineVariant : colorScheme.outline.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language label + copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : colorScheme.outline.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.code2,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  language ?? 'code',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(LucideIcons.check, size: 16, color: colorScheme.onInverseSurface),
                            const SizedBox(width: 8),
                            const Text('Code copied'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.copy,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Text(
              code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                height: 1.6,
                color: isDark ? const Color(0xFFD4D4D4) : colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesSectionState extends State<_SourcesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(128),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.fileText,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${widget.sources.length} source${widget.sources.length > 1 ? 's' : ''}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.sources.map((source) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.file,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            source.displayText,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
