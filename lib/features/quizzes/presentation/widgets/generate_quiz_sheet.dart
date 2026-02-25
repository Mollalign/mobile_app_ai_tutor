import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../providers/quiz_provider.dart';

class GenerateQuizSheet extends ConsumerStatefulWidget {
  final String projectId;

  const GenerateQuizSheet({super.key, required this.projectId});

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    String projectId,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => GenerateQuizSheet(projectId: projectId),
    );
  }

  @override
  ConsumerState<GenerateQuizSheet> createState() => _GenerateQuizSheetState();
}

class _GenerateQuizSheetState extends ConsumerState<GenerateQuizSheet> {
  int _numQuestions = 5;
  String _difficulty = 'medium';
  final _topicController = TextEditingController();
  final _questionTypes = <String>{'multiple_choice', 'true_false'};

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.watch(generateQuizNotifierProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Quiz',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'AI will create questions from your project documents',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Number of questions
            Text('Number of questions', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [3, 5, 10, 15].map((n) {
                final selected = _numQuestions == n;
                return ChoiceChip(
                  label: Text('$n'),
                  selected: selected,
                  onSelected: (_) => setState(() => _numQuestions = n),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Difficulty
            Text('Difficulty', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'easy', label: Text('Easy')),
                ButtonSegment(value: 'medium', label: Text('Medium')),
                ButtonSegment(value: 'hard', label: Text('Hard')),
              ],
              selected: {_difficulty},
              onSelectionChanged: (s) => setState(() => _difficulty = s.first),
            ),
            const SizedBox(height: AppSpacing.md),

            // Question types
            Text('Question types', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ('multiple_choice', 'Multiple Choice'),
                ('true_false', 'True / False'),
                ('code_output', 'Code Output'),
              ].map((type) {
                final selected = _questionTypes.contains(type.$1);
                return FilterChip(
                  label: Text(type.$2),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _questionTypes.add(type.$1);
                      } else if (_questionTypes.length > 1) {
                        _questionTypes.remove(type.$1);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Topic focus (optional)
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic focus (optional)',
                hintText: 'e.g. "data structures" or "chapter 3"',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: notifier.isGenerating ? null : _generate,
                icon: notifier.isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.sparkles),
                label: Text(
                  notifier.isGenerating ? 'Generating...' : 'Generate Quiz',
                ),
              ),
            ),

            if (notifier.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                notifier.error!,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final notifier = ref.read(generateQuizNotifierProvider);
    final quiz = await notifier.generateQuiz(
      widget.projectId,
      numQuestions: _numQuestions,
      difficulty: _difficulty,
      questionTypes: _questionTypes.toList(),
      topicFocus: _topicController.text.trim().isEmpty
          ? null
          : _topicController.text.trim(),
    );
    if (quiz != null && mounted) {
      Navigator.of(context).pop(quiz);
    }
  }
}
