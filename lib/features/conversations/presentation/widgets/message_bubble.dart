import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/entities.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onSourceTap;
  final bool animate;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onSourceTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message.role.isUser) {
      return _UserMessage(message: message, animate: animate);
    } else if (message.role.isAssistant) {
      return _AssistantMessage(
        message: message,
        onSourceTap: onSourceTap,
        animate: animate,
      );
    } else {
      return _SystemMessage(message: message);
    }
  }
}

// ─── User Message ──────────────────────────────────────────────

class _UserMessage extends StatelessWidget {
  final Message message;
  final bool animate;

  const _UserMessage({required this.message, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = Padding(
      padding: const EdgeInsets.only(left: 56, right: 14, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withAlpha(210),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(isDark ? 40 : 28),
                    blurRadius: 10,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.05,
                    ),
                  ),
                  if (message.isPending) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white.withAlpha(170),
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

    if (!animate) return result;
    return result
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─── Assistant Message ─────────────────────────────────────────

class _AssistantMessage extends StatefulWidget {
  final Message message;
  final VoidCallback? onSourceTap;
  final bool animate;

  const _AssistantMessage({
    required this.message,
    this.onSourceTap,
    this.animate = true,
  });

  @override
  State<_AssistantMessage> createState() => _AssistantMessageState();
}

class _AssistantMessageState extends State<_AssistantMessage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = Padding(
      padding: const EdgeInsets.only(left: 14, right: 40, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withAlpha(isDark ? 50 : 30),
                  colorScheme.secondary.withAlpha(isDark ? 40 : 20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const AppLogo(size: 28),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + copy
                Row(
                  children: [
                    Text(
                      'H2M AI',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant.withAlpha(180),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.message.isStreaming)
                      _ActionRow(message: widget.message),
                  ],
                ),
                const SizedBox(height: 6),

                // Message content
                widget.message.isStreaming && widget.message.content.isEmpty
                    ? const _TypingIndicator()
                    : Container(
                        padding: const EdgeInsets.only(right: 4),
                        child: MarkdownBody(
                          data: widget.message.content,
                          selectable: true,
                          styleSheet: _mdStyle(context),
                          builders: {
                            'code': _CodeBlockBuilder(context: context),
                          },
                        ),
                      ),

                // Sources
                if (widget.message.hasSources) ...[
                  const SizedBox(height: 12),
                  _SourcesSection(
                    sources: widget.message.sources,
                    onSourceTap: widget.onSourceTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.animate) return result;
    return result
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.03, end: 0, curve: Curves.easeOutCubic);
  }

  MarkdownStyleSheet _mdStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bodyStyle = TextStyle(
      fontSize: 13.5,
      height: 1.55,
      color: colorScheme.onSurface,
      letterSpacing: 0.05,
    );

    return MarkdownStyleSheet(
      p: bodyStyle,
      h1: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.35,
      ),
      h2: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.35,
      ),
      h3: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.35,
      ),
      code: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        color: colorScheme.primary,
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer.withAlpha(60),
        fontWeight: FontWeight.w500,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B1E) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(40)
              : colorScheme.outline.withAlpha(50),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colorScheme.primary.withAlpha(160), width: 3),
        ),
        color: colorScheme.primaryContainer.withAlpha(20),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      listBullet: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      listIndent: 20,
      a: bodyStyle.copyWith(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: colorScheme.primary.withAlpha(100),
      ),
      strong: bodyStyle.copyWith(fontWeight: FontWeight.w600),
      em: bodyStyle.copyWith(fontStyle: FontStyle.italic),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withAlpha(100), width: 1),
        ),
      ),
    );
  }
}

// ─── System Message ────────────────────────────────────────────

class _SystemMessage extends StatelessWidget {
  final Message message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

// ─── Typing Indicator ──────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(140),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thinking',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 7),
            ...List.generate(3, (i) {
              return Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1.0, 1.0),
                    delay: (i * 180).ms,
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(0.4, 0.4),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  );
            }),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2000.ms, color: colorScheme.primary.withAlpha(20)),
    );
  }
}

// ─── Action Row (copy) ─────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final Message message;

  const _ActionRow({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Clipboard.setData(ClipboardData(text: message.content));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(LucideIcons.check, size: 15, color: colorScheme.onInverseSurface),
                  const SizedBox(width: 8),
                  const Text('Copied', style: TextStyle(fontSize: 13)),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            LucideIcons.copy,
            size: 13,
            color: colorScheme.onSurfaceVariant.withAlpha(120),
          ),
        ),
      ),
    );
  }
}

// ─── Code Block Builder ────────────────────────────────────────

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

    if (!code.contains('\n')) return null;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B1E) : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(40)
              : colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(6) : colorScheme.outline.withAlpha(14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.code2, size: 12, color: colorScheme.onSurfaceVariant.withAlpha(160)),
                const SizedBox(width: 5),
                Text(
                  language ?? 'code',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant.withAlpha(160),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(LucideIcons.check, size: 14, color: colorScheme.onInverseSurface),
                            const SizedBox(width: 8),
                            const Text('Code copied', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.copy, size: 11, color: colorScheme.onSurfaceVariant.withAlpha(140)),
                      const SizedBox(width: 3),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Code
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: Text(
              code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                height: 1.55,
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

// ─── Sources Section ───────────────────────────────────────────

class _SourcesSection extends StatefulWidget {
  final List<SourceCitation> sources;
  final VoidCallback? onSourceTap;

  const _SourcesSection({required this.sources, this.onSourceTap});

  @override
  State<_SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<_SourcesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 100),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(isDark ? 30 : 60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(100),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(LucideIcons.fileText, size: 11, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.sources.length} source${widget.sources.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(LucideIcons.chevronDown, size: 14, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(11, 0, 11, 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.sources.map((source) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.file, size: 11, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            source.displayText,
                            style: TextStyle(
                              fontSize: 11,
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
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
