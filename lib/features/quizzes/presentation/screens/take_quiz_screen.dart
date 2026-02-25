import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;

  const TakeQuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      ref.read(takeQuizNotifierProvider).loadQuiz(widget.quizId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(takeQuizNotifierProvider);

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) => _buildBody(context, notifier),
    );
  }

  Widget _buildBody(BuildContext context, TakeQuizNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (notifier.isLoading ||
        (notifier.quiz == null && notifier.error == null)) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const ShimmerQuizList(itemCount: 5),
      );
    }

    if (notifier.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  friendlyErrorMessage(notifier.error!),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => notifier.loadQuiz(widget.quizId),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final questions =
        (notifier.quiz?['questions'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text('No questions found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (notifier.answeredCount) / questions.length,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentPage + 1} of ${questions.length}',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${notifier.answeredCount}/${questions.length} answered',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: questions.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return _QuestionPage(
                  question: questions[index],
                  selectedAnswer: notifier.answers[questions[index]['id']],
                  onAnswer: (answer) {
                    HapticFeedback.lightImpact();
                    notifier.setAnswer(questions[index]['id'], answer);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        icon: const Icon(LucideIcons.arrowLeft),
                        label: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0 &&
                      _currentPage < questions.length - 1)
                    const SizedBox(width: AppSpacing.sm),
                  if (_currentPage < questions.length - 1)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        icon: const Icon(LucideIcons.arrowRight),
                        label: const Text('Next'),
                      ),
                    ),
                  if (_currentPage == questions.length - 1)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: notifier.isSubmitting
                            ? null
                            : () => _submitQuiz(notifier),
                        icon: notifier.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(LucideIcons.checkCircle),
                        label: Text(
                          notifier.isSubmitting ? 'Submitting...' : 'Submit',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz(TakeQuizNotifier notifier) async {
    if (notifier.answeredCount < notifier.totalQuestions) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            LucideIcons.alertTriangle,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          title: const Text('Unanswered questions'),
          content: Text(
            'You have answered ${notifier.answeredCount} of ${notifier.totalQuestions} questions. Submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Go back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final result = await notifier.submitQuiz(widget.quizId);
    if (result != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(result: result),
        ),
      );
    }
  }
}

class _QuestionPage extends StatelessWidget {
  final Map<String, dynamic> question;
  final dynamic selectedAnswer;
  final ValueChanged<String> onAnswer;

  const _QuestionPage({
    required this.question,
    this.selectedAnswer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final questionText = question['question_text'] as String? ?? '';
    final codeSnippet = question['code_snippet'] as String?;
    final options =
        (question['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final points = question['points'] as int? ?? 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '$points pts',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: AppSpacing.md),
          Text(
            questionText,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ).animate().fadeIn(delay: 50.ms),
          if (codeSnippet != null && codeSnippet.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                codeSnippet,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
          ],
          const SizedBox(height: AppSpacing.lg),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final key = option['key'] as String? ?? '';
            final text = option['text'] as String? ?? '';
            final isSelected = selectedAnswer == key;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: isSelected
                    ? colorScheme.primaryContainer
                    : isDark
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  onTap: () => onAnswer(key),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              key,
                              style: textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            text,
                            style: textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.checkCircle2,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (150 + index * 50).ms)
                .slideX(begin: 0.05);
          }),
        ],
      ),
    );
  }
}
