import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';

/// Bottom sheet with project actions.
class ProjectActionsSheet extends ConsumerWidget {
  final Project project;

  const ProjectActionsSheet({
    super.key,
    required this.project,
  });

  static void show(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ProjectActionsSheet(project: project),
      showDragHandle: true,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final container = ProviderScope.containerOf(context, listen: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project name
            Text(
              project.name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Actions
            _ActionTile(
              icon: LucideIcons.pencil,
              label: 'Edit Project',
              onTap: () {
                Navigator.of(context).pop();
                _showEditDialog(context, container);
              },
            ),
            _ActionTile(
              icon: project.isArchived ? LucideIcons.folderOpen : LucideIcons.archive,
              label: project.isArchived ? 'Unarchive Project' : 'Archive Project',
              onTap: () {
                Navigator.of(context).pop();
                _toggleArchive(context, container);
              },
            ),
            _ActionTile(
              icon: LucideIcons.trash2,
              label: 'Delete Project',
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, container);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProviderContainer container) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Edit Project'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter project description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                await container
                    .read(projectDetailNotifierProvider(project.id))
                    .updateProject(
                      name: nameController.text,
                      description: descriptionController.text.isEmpty 
                          ? null 
                          : descriptionController.text,
                    );
                // Refresh projects list
                container.invalidate(projectsNotifierProvider);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleArchive(BuildContext context, ProviderContainer container) async {
    await container
        .read(projectDetailNotifierProvider(project.id))
        .updateProject(isArchived: !project.isArchived);
    // Refresh projects list
    container.invalidate(projectsNotifierProvider);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project.isArchived 
                ? 'Project unarchived' 
                : 'Project archived',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, ProviderContainer container) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        icon: Icon(
          LucideIcons.alertTriangle,
          color: colorScheme.error,
        ),
        title: const Text('Delete Project?'),
        content: Text(
          'This will permanently delete "${project.name}" and all its documents and conversations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await container
                  .read(projectDetailNotifierProvider(project.id))
                  .deleteProject();
              // Refresh projects list and navigate back
              container.invalidate(projectsNotifierProvider);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusSm,
      ),
    );
  }
}
