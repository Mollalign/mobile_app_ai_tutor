import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';

/// Projects tab - shows all user projects.
/// 
/// Features:
/// - Grid/List view toggle
/// - Create project button
/// - Search/filter projects
/// 
/// This is a placeholder that will be fully implemented in Feature 2.
class ProjectsTab extends ConsumerStatefulWidget {
  const ProjectsTab({super.key});

  @override
  ConsumerState<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends ConsumerState<ProjectsTab> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          // View toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
            ),
            tooltip: _isGridView ? 'List view' : 'Grid view',
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
                  color: colorScheme.primaryContainer.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.folderOpen,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No projects yet',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create your first project to organize\nyour study materials and conversations.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Create project dialog
                },
                icon: const Icon(LucideIcons.plus),
                label: const Text('Create Project'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create project dialog
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
