import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/quiz_provider.dart';
import '../widgets/generate_quiz_sheet.dart';
import 'take_quiz_screen.dart';

/// Quizzes tab inside project detail, showing AI-generated quizzes.
class QuizzesTab extends ConsumerWidget {
  final String projectId;

  const QuizzesTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(quizListNotifierProvider(projectId));

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        final state = notifier.state;

        return Scaffold(
          body: state.isLoading
              ? const ShimmerQuizList()
              : state.error != null
                  ? _ErrorBody(
                      message: state.error!,
                      onRetry: () => notifier.loadQuizzes(refresh: true),
                    )
                  : state.quizzes.isEmpty
                      ? _EmptyBody(
                          onGenerate: () => _generateQuiz(context, ref),
                        )
                      : RefreshIndicator(
                          onRefresh: () => notifier.loadQuizzes(refresh: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.md,
                              bottom: 80,
                            ),
                            itemCount: state.quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = state.quizzes[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                child: _QuizCard(
                                  quiz: quiz,
                                  onTap: () => _takeQuiz(context, quiz),
                                  onDelete: () =>
                                      _confirmDelete(context, ref, quiz),
                                ),
                              ).animate().fadeIn(delay: (index * 50).ms);
                            },
                          ),
                        ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'quiz_fab_$projectId',
            onPressed: () => _generateQuiz(context, ref),
            icon: const Icon(LucideIcons.sparkles),
            label: const Text('Generate Quiz'),
          ),
        );
      },
    );
  }

  Future<void> _generateQuiz(BuildContext context, WidgetRef ref) async {
    final quiz = await GenerateQuizSheet.show(context, projectId);
    if (quiz != null) {
      ref.read(quizListNotifierProvider(projectId)).addQuiz(quiz);
    }
  }

  void _takeQuiz(BuildContext context, Map<String, dynamic> quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TakeQuizScreen(
          quizId: quiz['id'] as String,
          quizTitle: quiz['title'] as String? ?? 'Quiz',
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> quiz,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.alertTriangle, color: colorScheme.error),
        title: const Text('Delete quiz?'),
        content: Text(
          'This will permanently delete "${quiz['title']}" and all attempts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(quizListNotifierProvider(projectId))
                  .deleteQuiz(quiz['id'] as String);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Map<String, dynamic> quiz;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _QuizCard({
    required this.quiz,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = quiz['title'] as String? ?? 'Quiz';
    final difficulty = quiz['difficulty'] as String? ?? 'medium';
    final questionCount = quiz['question_count'] as int? ?? 0;
    final totalPoints = quiz['total_points'] as int? ?? 0;

    Color diffColor;
    switch (difficulty) {
      case 'easy':
        diffColor = Colors.green;
        break;
      case 'hard':
        diffColor = colorScheme.error;
        break;
      default:
        diffColor = Colors.orange;
    }

    return Material(
      color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark
                  ? colorScheme.outlineVariant.withAlpha(51)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  LucideIcons.brainCircuit,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: diffColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            difficulty.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: diffColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '$questionCount Qs · $totalPoints pts',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final VoidCallback onGenerate;

  const _EmptyBody({required this.onGenerate});

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
                color: colorScheme.tertiaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.brainCircuit,
                size: 48,
                color: colorScheme.tertiary,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No quizzes yet',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate an AI-powered quiz from\nyour documents to test your knowledge.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(LucideIcons.sparkles),
              label: const Text('Generate Quiz'),
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
