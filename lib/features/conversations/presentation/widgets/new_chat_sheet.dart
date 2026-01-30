import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../projects/domain/entities/entities.dart';
import '../../../projects/presentation/providers/project_state.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../../domain/entities/entities.dart';

/// Bottom sheet for creating a new conversation.
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
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure projects are loaded when opening the sheet
    Future.microtask(() {
      final projectsState = ref.read(projectsNotifierProvider);
      // Load projects if they haven't been loaded yet or if there was an error
      if (projectsState is ProjectsInitial || projectsState is ProjectsError) {
        ref.read(projectsNotifierProvider.notifier).loadProjects();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _createChat() {
    Navigator.of(context).pop(NewChatConfig(
      projectId: _selectedType.isProject ? _selectedProject?.id : null,
      isSocratic: _isSocratic,
      initialMessage: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                'New Conversation',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Start a new chat with your AI tutor',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Chat type selection
              Text(
                'Chat Type',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ChatTypeCard(
                      type: ChatType.quick,
                      isSelected: _selectedType == ChatType.quick,
                      onTap: () => setState(() {
                        _selectedType = ChatType.quick;
                        _selectedProject = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ChatTypeCard(
                      type: ChatType.project,
                      isSelected: _selectedType == ChatType.project,
                      onTap: () => setState(() => _selectedType = ChatType.project),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Project selection (if project chat)
              if (_selectedType.isProject) ...[
                Text(
                  'Select Project',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProjectSelector(
                  selectedProject: _selectedProject,
                  onChanged: (project) => setState(() => _selectedProject = project),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Socratic mode toggle
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  value: _isSocratic,
                  onChanged: (value) => setState(() => _isSocratic = value),
                  title: Row(
                    children: [
                      Icon(
                        LucideIcons.graduationCap,
                        size: 20,
                        color: _isSocratic
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Socratic Mode',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _isSocratic
                        ? 'AI guides you with questions'
                        : 'AI gives direct answers',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeTrackColor: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Initial message (optional)
              Text(
                'First Message (Optional)',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your first question...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Create button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedType.isQuick ||
                          (_selectedType.isProject && _selectedProject != null)
                      ? _createChat
                      : null,
                  icon: const Icon(LucideIcons.messageSquarePlus),
                  label: const Text('Start Conversation'),
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

/// Chat type selection card.
class _ChatTypeCard extends StatelessWidget {
  final ChatType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChatTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              type.isQuick ? LucideIcons.sparkles : LucideIcons.bookOpen,
              size: 28,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type.displayName,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.description,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer.withAlpha(179)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                      'No projects found. Create a project first.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
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
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(LucideIcons.folder),
          ),
          hint: const Text('Choose a project'),
          items: projects.map((project) {
            return DropdownMenuItem(
              value: project,
              child: Text(project.name),
            );
          }).toList(),
        );
      },
      error: (message) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
      ),
    );
  }
}

class _LoadingProjects extends StatelessWidget {
  const _LoadingProjects();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
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
