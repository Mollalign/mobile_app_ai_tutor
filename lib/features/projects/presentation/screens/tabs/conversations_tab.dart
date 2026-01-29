import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/constants/app_spacing.dart';

/// Conversations tab - placeholder until Feature 4 is implemented.
/// Will show list of conversations related to this project.
class ConversationsTab extends ConsumerWidget {
  final String projectId;

  const ConversationsTab({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // TODO: Replace with actual conversations provider
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.messageSquare,
                size: 48,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No conversations yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a conversation to ask questions\nabout your documents.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                // TODO: Start new conversation
              },
              icon: const Icon(LucideIcons.messageSquarePlus),
              label: const Text('Start Conversation'),
            ),
          ],
        ),
      ),
    );
  }
}
