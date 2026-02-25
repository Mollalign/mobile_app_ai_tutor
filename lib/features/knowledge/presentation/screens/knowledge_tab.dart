import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../providers/knowledge_provider.dart';
import '../widgets/mastery_ring.dart';
import '../widgets/topic_card.dart';

/// Knowledge tab showing extracted topics with mastery progress.
class KnowledgeTab extends ConsumerWidget {
  final String projectId;

  const KnowledgeTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(knowledgeTabNotifierProvider(projectId));

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        final state = notifier.state;

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.topics.isEmpty) {
          return _ErrorBody(
            message: state.error!,
            onRetry: () => notifier.loadAll(refresh: true),
          );
        }

        if (state.topics.isEmpty) {
          return _EmptyBody(
            isExtracting: state.isExtracting,
            onExtract: () => notifier.extractTopics(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notifier.loadAll(refresh: true),
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: 80,
            ),
            children: [
              // Mastery overview header
              _MasteryHeader(state: state),
              const SizedBox(height: AppSpacing.md),

              // Re-extract button
              if (!state.isExtracting)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        notifier.extractTopics(forceRefresh: true),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Re-extract Topics'),
                  ),
                ),
              if (state.isExtracting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text('Extracting topics from documents...'),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Topic list
              ...state.topics.asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value;
                final mastery = state.masteryForTopic(
                    topic['name'] as String? ?? '');
                final status = state.statusForTopic(
                    topic['name'] as String? ?? '');

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: TopicCard(
                    topic: topic,
                    mastery: mastery,
                    status: status,
                  ),
                ).animate().fadeIn(delay: (index * 60).ms);
              }),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Mastery Overview Header
// ============================================================

class _MasteryHeader extends StatelessWidget {
  final KnowledgeTabState state;

  const _MasteryHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withAlpha(isDark ? 100 : 180),
              colorScheme.tertiaryContainer.withAlpha(isDark ? 80 : 140),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 38 : 77),
          ),
        ),
        child: Row(
          children: [
            MasteryRing(
              mastery: state.overallMastery,
              size: 80,
              strokeWidth: 8,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Mastery',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatRow(
                    color: Colors.green,
                    label: 'Mastered',
                    count: state.masteredCount,
                  ),
                  const SizedBox(height: 4),
                  _StatRow(
                    color: Colors.orange,
                    label: 'In progress',
                    count: state.inProgressCount,
                  ),
                  const SizedBox(height: 4),
                  _StatRow(
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                    label: 'Not started',
                    count: state.notStartedCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.05);
  }
}

class _StatRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _StatRow({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall,
          ),
        ),
        Text(
          '$count',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ============================================================
// Empty & Error Bodies
// ============================================================

class _EmptyBody extends StatelessWidget {
  final bool isExtracting;
  final VoidCallback onExtract;

  const _EmptyBody({required this.isExtracting, required this.onExtract});

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
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.bookOpen,
                size: 48,
                color: colorScheme.primary,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No topics extracted',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Extract topics from your documents\nto track your learning progress.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            if (isExtracting)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text('Analyzing documents...'),
                ],
              )
            else
              FilledButton.icon(
                onPressed: onExtract,
                icon: const Icon(LucideIcons.sparkles),
                label: const Text('Extract Topics'),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
