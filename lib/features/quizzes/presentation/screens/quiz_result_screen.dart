import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';

/// Screen showing quiz results after submission.
class QuizResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final score = result['score'] as int? ?? 0;
    final maxScore = result['max_score'] as int? ?? 0;
    final percentage = (result['percentage'] as num?)?.toDouble() ?? 0;
    final passed = result['passed'] as bool? ?? false;
    final questions =
        (result['questions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final timeTaken = result['time_taken_seconds'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Score card
          _ScoreCard(
            score: score,
            maxScore: maxScore,
            percentage: percentage,
            passed: passed,
            timeTaken: timeTaken,
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: AppSpacing.xl),

          // Question-by-question review
          Text(
            'Question Review',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),

          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _QuestionReviewCard(question: q, index: index + 1),
            ).animate().fadeIn(delay: (100 + index * 50).ms);
          }),

          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(LucideIcons.arrowLeft),
              label: const Text('Back to project'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int maxScore;
  final double percentage;
  final bool passed;
  final int? timeTaken;

  const _ScoreCard({
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.passed,
    this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resultColor = passed ? Colors.green : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            resultColor,
            resultColor.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Icon(
            passed ? LucideIcons.trophy : LucideIcons.target,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            passed ? 'Great job!' : 'Keep practicing!',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$score / $maxScore points',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(204),
            ),
          ),
          if (timeTaken != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock, size: 16, color: Colors.white.withAlpha(180)),
                const SizedBox(width: 4),
                Text(
                  _formatTime(timeTaken!),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}

class _QuestionReviewCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final int index;

  const _QuestionReviewCard({required this.question, required this.index});

  @override
  State<_QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<_QuestionReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final q = widget.question;
    final isCorrect = q['is_correct'] as bool? ?? false;
    final questionText = q['question_text'] as String? ?? '';
    final explanation = q['explanation'] as String? ?? '';
    final correctAnswer = q['correct_answer']?.toString() ?? '';
    final userAnswer = q['user_answer']?.toString() ?? 'Not answered';
    final pointsEarned = q['points_earned'] as int? ?? 0;
    final points = q['points'] as int? ?? 0;
    final options = (q['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Material(
      color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isCorrect
                  ? Colors.green.withAlpha(100)
                  : colorScheme.error.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withAlpha(30)
                          : colorScheme.error.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? LucideIcons.check : LucideIcons.x,
                      size: 16,
                      color: isCorrect ? Colors.green : colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Q${widget.index}',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$pointsEarned/$points pts',
                    style: textTheme.labelMedium?.copyWith(
                      color: isCorrect ? Colors.green : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                questionText,
                style: textTheme.bodyMedium,
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              if (_expanded) ...[
                const SizedBox(height: AppSpacing.md),
                // Show options with correct/incorrect highlighting
                ...options.map((opt) {
                  final key = opt['key'] as String? ?? '';
                  final text = opt['text'] as String? ?? '';
                  final isUserPick = key == userAnswer;
                  final isCorrectAnswer = key == correctAnswer;

                  Color? bg;
                  Color? border;
                  if (isCorrectAnswer) {
                    bg = Colors.green.withAlpha(20);
                    border = Colors.green.withAlpha(100);
                  } else if (isUserPick && !isCorrect) {
                    bg = colorScheme.error.withAlpha(20);
                    border = colorScheme.error.withAlpha(100);
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: border ?? colorScheme.outlineVariant.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$key. ',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(child: Text(text, style: textTheme.bodyMedium)),
                        if (isCorrectAnswer)
                          const Icon(LucideIcons.check, size: 16, color: Colors.green),
                        if (isUserPick && !isCorrect)
                          Icon(LucideIcons.x, size: 16, color: colorScheme.error),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explanation',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(explanation, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
