import 'dart:io';

import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../app/router.dart';
import '../../../../conversations/presentation/providers/providers.dart';
import '../../../../documents/presentation/providers/providers.dart';
import '../../../../quizzes/presentation/widgets/generate_quiz_sheet.dart';
import '../../../../quizzes/presentation/providers/quiz_provider.dart';
import '../../../domain/entities/entities.dart';

class OverviewTab extends ConsumerWidget {
  final Project project;

  const OverviewTab({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsNotifier =
        ref.watch(documentsNotifierProvider(project.id));
    final conversationsNotifier =
        ref.watch(projectConversationsNotifierProvider(project.id));

    return AnimatedBuilder(
      animation:
          Listenable.merge([documentsNotifier, conversationsNotifier]),
      builder: (context, _) {
        final documentCount = documentsNotifier.state.maybeMap(
          loaded: (state) => state.total.toString(),
          orElse: () => '...',
        );

        final conversationCount =
            conversationsNotifier.state.maybeMap(
          loaded: (state) => state.total.toString(),
          orElse: () => '...',
        );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Description
            if (project.hasDescription) ...[
              _DescriptionCard(description: project.description ?? ''),
              const SizedBox(height: 20),
            ],

            // Stats
            Row(
              children: [
                Expanded(
                  child: _GlassStatCard(
                    icon: LucideIcons.fileText,
                    label: 'Documents',
                    value: documentCount,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GlassStatCard(
                    icon: LucideIcons.messageSquare,
                    label: 'Conversations',
                    value: conversationCount,
                    color: Colors.purple,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: 20),

            // Details
            _DetailsCard(project: project),
            const SizedBox(height: 20),

            // Quick Actions
            _SectionLabel(label: 'Quick Actions'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: LucideIcons.upload,
                    label: 'Upload',
                    subtitle: 'Add files',
                    gradient: [Colors.blue, Colors.blue.shade700],
                    onTap: () => _pickAndUploadFiles(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: LucideIcons.messageSquarePlus,
                    label: 'Chat',
                    subtitle: 'Start new',
                    gradient: [Colors.purple, Colors.purple.shade700],
                    onTap: () => _createNewChat(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: LucideIcons.brainCircuit,
                    label: 'Quiz',
                    subtitle: 'Generate',
                    gradient: [Colors.orange, Colors.deepOrange],
                    onTap: () => _generateQuiz(context, ref),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

            const SizedBox(height: 48),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadFiles(
      BuildContext context, WidgetRef ref) async {
    final result = await picker.FilePicker.platform.pickFiles(
      type: picker.FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final uploadNotifier =
          ref.read(uploadStateProvider(project.id));

      for (final file in result.files) {
        if (file.path != null) {
          uploadNotifier.uploadFile(File(file.path!));
        } else if (file.bytes != null) {
          uploadNotifier.uploadBytes(file.bytes!, file.name);
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Uploading ${result.files.length} file(s)...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _generateQuiz(
      BuildContext context, WidgetRef ref) async {
    final quiz =
        await GenerateQuizSheet.show(context, project.id);
    if (quiz != null) {
      ref.read(quizListNotifierProvider(project.id)).addQuiz(quiz);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Quiz generated! Go to the Quizzes tab to take it.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createNewChat(
      BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(createConversationNotifierProvider);
    final conversation = await notifier.createConversation(
      projectId: project.id,
      isSocratic: true,
    );

    if (conversation != null && context.mounted) {
      ref
          .read(projectConversationsNotifierProvider(project.id))
          .addConversation(conversation);
      context
          .push('${AppRoutes.conversations}/${conversation.id}');
    }
  }
}

// ============================================================
// Section Label
// ============================================================

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
    );
  }
}

// ============================================================
// Description Card
// ============================================================

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withAlpha(isDark ? 40 : 100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.alignLeft,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Description',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ============================================================
// Glass Stat Card
// ============================================================

class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _GlassStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(isDark ? 50 : 35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(isDark ? 15 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Details Card
// ============================================================

class _DetailsCard extends StatelessWidget {
  final Project project;

  const _DetailsCard({required this.project});

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withAlpha(isDark ? 40 : 100),
        ),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: LucideIcons.calendar,
            label: 'Created',
            value: _formatDate(project.createdAt),
          ),
          Divider(
            height: 1,
            color:
                colorScheme.outlineVariant.withAlpha(isDark ? 30 : 60),
          ),
          _DetailRow(
            icon: LucideIcons.clock,
            label: 'Last Updated',
            value: project.lastUpdatedRelative,
          ),
          Divider(
            height: 1,
            color:
                colorScheme.outlineVariant.withAlpha(isDark ? 30 : 60),
          ),
          _DetailRow(
            icon: project.isArchived
                ? LucideIcons.archive
                : LucideIcons.folderOpen,
            label: 'Status',
            value: project.isArchived ? 'Archived' : 'Active',
            valueColor: project.isArchived
                ? colorScheme.onSurfaceVariant
                : Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 350.ms);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (valueColor != null && value == 'Active')
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: valueColor,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Action Card (gradient pill)
// ============================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withAlpha(180),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
