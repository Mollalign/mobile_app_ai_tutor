import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/smart_tutor_provider.dart';

class LearningStyleScreen extends ConsumerWidget {
  const LearningStyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(learningStyleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Style',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: style.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertTriangle,
                  size: 40, color: colorScheme.error),
              const SizedBox(height: 12),
              const Text('Could not analyze learning style'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(learningStyleProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _LearningStyleContent(data: data),
      ),
    );
  }
}

class _LearningStyleContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LearningStyleContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = data['primary_style'] as String? ?? 'unknown';
    final description = data['description'] as String? ?? '';
    final traits = (data['traits'] as List?)?.cast<String>() ?? [];
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final perfByDiff =
        (stats['performance_by_difficulty'] as Map<String, dynamic>?) ?? {};

    final icon = _styleIcon(primary);
    final color = _styleColor(primary, colorScheme);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(25), color.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                _styleName(primary),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 24),

        // Traits
        if (traits.isNotEmpty) ...[
          const Text('Your Traits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...traits.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.sparkle, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],

        // Stats
        const Text('Activity Stats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _StatRow('Conversations', '${stats['total_conversations'] ?? 0}',
            LucideIcons.messageCircle, colorScheme),
        _StatRow('Quizzes Taken', '${stats['total_quizzes'] ?? 0}',
            LucideIcons.clipboardCheck, colorScheme),
        _StatRow(
            'Avg Message Length',
            '${stats['avg_message_length'] ?? 0} chars',
            LucideIcons.type,
            colorScheme),
        _StatRow('Socratic Chats', '${stats['socratic_conversations'] ?? 0}',
            LucideIcons.helpCircle, colorScheme),
        _StatRow('Direct Chats', '${stats['direct_conversations'] ?? 0}',
            LucideIcons.messageSquare, colorScheme),

        if (perfByDiff.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Quiz Performance by Difficulty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...perfByDiff.entries.map(
            (e) => _StatRow(
              _capitalize(e.key),
              '${(e.value as num?)?.toStringAsFixed(1) ?? 0}%',
              LucideIcons.barChart3,
              colorScheme,
            ),
          ),
        ],
      ],
    );
  }

  IconData _styleIcon(String style) {
    switch (style) {
      case 'practical':
        return LucideIcons.wrench;
      case 'reflective':
        return LucideIcons.brainCircuit;
      case 'theoretical':
        return LucideIcons.bookOpen;
      default:
        return LucideIcons.sparkles;
    }
  }

  Color _styleColor(String style, ColorScheme cs) {
    switch (style) {
      case 'practical':
        return Colors.orange;
      case 'reflective':
        return Colors.purple;
      case 'theoretical':
        return Colors.blue;
      default:
        return cs.primary;
    }
  }

  String _styleName(String style) {
    switch (style) {
      case 'practical':
        return 'Practical Learner';
      case 'reflective':
        return 'Reflective Learner';
      case 'theoretical':
        return 'Theoretical Learner';
      case 'balanced':
        return 'Balanced Learner';
      default:
        return 'Getting to Know You';
    }
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;
  const _StatRow(this.label, this.value, this.icon, this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary.withAlpha(180)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant)),
          ),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
