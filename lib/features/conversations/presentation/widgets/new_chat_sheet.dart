import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../projects/domain/entities/entities.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../domain/entities/entities.dart';

/// Bottom sheet for creating a new conversation.
/// Streamlined, minimal design for quick chat creation.
class NewChatSheet extends ConsumerStatefulWidget {
  final Function(String? projectId, bool isSocratic, String? initialMessage)?
      onCreate;

  const NewChatSheet({
    super.key,
    this.onCreate,
  });

  static Future<NewChatConfig?> show(BuildContext context) {
    return showModalBottomSheet<NewChatConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => const NewChatSheet(),
    );
  }

  @override
  ConsumerState<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<NewChatSheet> {
  ChatType _selectedType = ChatType.quick;
  Project? _selectedProject;
  bool _isSocratic = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final projectsState = ref.read(projectsNotifierProvider);
      if (projectsState is ProjectsInitial || projectsState is ProjectsError) {
        ref.read(projectsNotifierProvider.notifier).loadProjects();
      }
    });
  }

  void _createChat() {
    Navigator.of(context).pop(NewChatConfig(
      projectId: _selectedType.isProject ? _selectedProject?.id : null,
      isSocratic: _isSocratic,
      initialMessage: null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'New Chat',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Chat type selection
              Row(
                children: [
                  Expanded(
                    child: _TypeOption(
                      icon: LucideIcons.sparkles,
                      title: 'Quick Chat',
                      subtitle: 'General questions',
                      isSelected: _selectedType == ChatType.quick,
                      color: colorScheme.secondary,
                      onTap: () => setState(() {
                        _selectedType = ChatType.quick;
                        _selectedProject = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TypeOption(
                      icon: LucideIcons.bookOpen,
                      title: 'Project Chat',
                      subtitle: 'With your docs',
                      isSelected: _selectedType == ChatType.project,
                      color: colorScheme.primary,
                      onTap: () => setState(() => _selectedType = ChatType.project),
                    ),
                  ),
                ],
              ),

              // Project selection (if project chat)
              if (_selectedType.isProject) ...[
                const SizedBox(height: AppSpacing.lg),
                _ProjectSelector(
                  selectedProject: _selectedProject,
                  onChanged: (project) => setState(() => _selectedProject = project),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Socratic mode toggle
              _ModeToggle(
                isSocratic: _isSocratic,
                onChanged: (value) => setState(() => _isSocratic = value),
                ),

              const SizedBox(height: AppSpacing.xl),

              // Create button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedType.isQuick ||
                          (_selectedType.isProject && _selectedProject != null)
                      ? _createChat
                      : null,
                  child: const Text('Start Chat'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}

/// Chat type selection option.
class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected
          ? color.withAlpha(26)
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
          ),
        ),
        child: Column(
          children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(51) : color.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
                title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                  color: isSelected ? color : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
            Text(
                subtitle,
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mode toggle for Socratic/Direct.
class _ModeToggle extends StatelessWidget {
  final bool isSocratic;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({
    required this.isSocratic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              icon: LucideIcons.graduationCap,
              label: 'Socratic',
              description: 'Guides with questions',
              isSelected: isSocratic,
              color: colorScheme.tertiary,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ModeButton(
              icon: LucideIcons.messageSquare,
              label: 'Direct',
              description: 'Straight answers',
              isSelected: !isSocratic,
              color: colorScheme.primary,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mode button within toggle.
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: isSelected ? 1 : 0,
      shadowColor: Colors.black.withAlpha(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child:                   Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

/// Project selector dropdown.
class _ProjectSelector extends ConsumerWidget {
  final Project? selectedProject;
  final ValueChanged<Project?> onChanged;

  const _ProjectSelector({
    required this.selectedProject,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final projectsState = ref.watch(projectsNotifierProvider);

    return projectsState.when(
      initial: () => const _LoadingProjects(),
      loading: () => const _LoadingProjects(),
      loaded: (projects, isLoadingMore, hasMore) {
        if (projects.isEmpty) {
          return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                    'No projects yet. Create one first.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
            ),
          );
        }

        return DropdownButtonFormField<Project>(
          initialValue: selectedProject,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(LucideIcons.folder),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          hint: const Text('Select project'),
          items: projects.map((project) {
            return DropdownMenuItem(
              value: project,
              child: Text(project.name),
            );
          }).toList(),
        );
      },
      error: (message) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(51),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
          child: Row(
            children: [
              Icon(
                LucideIcons.alertCircle,
                color: colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Failed to load projects',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                ref.read(projectsNotifierProvider.notifier).loadProjects(refresh: true);
              },
              child: const Text('Retry'),
          ),
          ],
        ),
      ),
    );
  }
}

class _LoadingProjects extends StatelessWidget {
  const _LoadingProjects();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Loading projects...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Configuration for creating a new chat.
class NewChatConfig {
  final String? projectId;
  final bool isSocratic;
  final String? initialMessage;

  const NewChatConfig({
    this.projectId,
    this.isSocratic = true,
    this.initialMessage,
  });
}
