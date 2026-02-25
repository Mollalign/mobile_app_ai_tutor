import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import 'mastery_ring.dart';

/// Expandable card showing a topic with subtopics and mastery.
class TopicCard extends StatefulWidget {
  final Map<String, dynamic> topic;
  final double mastery;
  final String status;

  const TopicCard({
    super.key,
    required this.topic,
    required this.mastery,
    required this.status,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = widget.topic['name'] as String? ?? 'Topic';
    final description = widget.topic['description'] as String?;
    final subtopics = (widget.topic['subtopics'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: subtopics.isNotEmpty
            ? () => setState(() => _expanded = !_expanded)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(51)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    MasteryRing(
                      mastery: widget.mastery,
                      size: 48,
                      strokeWidth: 5,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _StatusBadge(status: widget.status),
                              if (subtopics.isNotEmpty) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${subtopics.length} subtopics',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (subtopics.isNotEmpty)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          LucideIcons.chevronDown,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // Description (always visible if present)
              if (description != null && description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: _expanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Expanded subtopics
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withAlpha(77),
                    ),
                    ...subtopics.asMap().entries.map((entry) {
                      final i = entry.key;
                      final sub = entry.value;
                      return _SubtopicRow(
                        subtopic: sub,
                        isLast: i == subtopics.length - 1,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Status Badge
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'mastered':
        color = Colors.green;
        label = 'Mastered';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150);
        label = 'Not Started';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

// ============================================================
// Subtopic Row
// ============================================================

class _SubtopicRow extends StatelessWidget {
  final Map<String, dynamic> subtopic;
  final bool isLast;

  const _SubtopicRow({required this.subtopic, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = subtopic['name'] as String? ?? '';
    final description = subtopic['description'] as String?;
    final objectives =
        (subtopic['learning_objectives'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withAlpha(38),
                ),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.cornerDownRight,
                size: 14,
                color: colorScheme.onSurfaceVariant.withAlpha(128),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 2),
              child: Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (objectives.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: objectives.take(3).map((obj) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      obj,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms);
  }
}
