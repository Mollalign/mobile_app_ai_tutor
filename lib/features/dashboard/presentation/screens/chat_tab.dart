import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';

/// Chat tab - shows all conversations.
/// 
/// Features:
/// - Quick chats and project chats
/// - Search conversations
/// - Create new chat
/// 
/// This is a placeholder that will be fully implemented in Feature 4.
class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search conversations
            },
            icon: const Icon(LucideIcons.search),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Center(
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
                  LucideIcons.messageCircle,
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
                'Start a conversation with your AI tutor\nto begin learning.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Start quick chat
                },
                icon: const Icon(LucideIcons.sparkles),
                label: const Text('Start Quick Chat'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: New conversation options
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
