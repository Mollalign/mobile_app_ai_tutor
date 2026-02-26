import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/smart_tutor_provider.dart';

class SmartStudyScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;
  const SmartStudyScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<SmartStudyScreen> createState() => _SmartStudyScreenState();
}

class _SmartStudyScreenState extends ConsumerState<SmartStudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.projectName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Readiness'),
            Tab(text: 'Study Plan'),
            Tab(text: 'Connections'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReadinessTab(projectId: widget.projectId),
          _StudyPlanTab(
              projectId: widget.projectId,
              projectName: widget.projectName),
          _ConnectionsTab(projectId: widget.projectId),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Readiness Tab
// ════════════════════════════════════════════════════════════════

class _ReadinessTab extends ConsumerWidget {
  final String projectId;
  const _ReadinessTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(examReadinessProvider(projectId));
    final colorScheme = Theme.of(context).colorScheme;

    return readiness.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertTriangle,
                  size: 40, color: colorScheme.error),
              const SizedBox(height: 12),
              Text('Could not load readiness data',
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(examReadinessProvider(projectId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (data) => _ReadinessContent(data: data),
    );
  }
}

class _ReadinessContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReadinessContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = (data['readiness_score'] as num?)?.toDouble() ?? 0;
    final grade = data['grade'] as String? ?? 'N/A';
    final breakdown =
        data['breakdown'] as Map<String, dynamic>? ?? {};
    final recommendations =
        (data['recommendations'] as List?)?.cast<String>() ?? [];
    final weakTopics =
        (data['weak_topics'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final scoreColor = score >= 70
        ? Colors.green
        : score >= 40
            ? Colors.orange
            : colorScheme.error;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Score circle
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scoreColor.withAlpha(25),
                  scoreColor.withAlpha(8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 24),
        const Text('Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Breakdown bars
        ...breakdown.entries.map((e) {
          final label = _formatLabel(e.key);
          final val = (e.value as num?)?.toDouble() ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BreakdownBar(label: label, value: val, colorScheme: colorScheme),
          );
        }),

        if (weakTopics.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Weakest Topics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...weakTopics.map((t) => _WeakTopicChip(
                name: t['topic_name'] as String? ?? '?',
                mastery: (t['mastery'] as num?)?.toDouble() ?? 0,
                colorScheme: colorScheme,
              )),
        ],

        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final double value;
  final ColorScheme colorScheme;
  const _BreakdownBar(
      {required this.label, required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final color = value >= 70
        ? Colors.green
        : value >= 40
            ? Colors.orange
            : colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant)),
            Text('${value.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WeakTopicChip extends StatelessWidget {
  final String name;
  final double mastery;
  final ColorScheme colorScheme;
  const _WeakTopicChip(
      {required this.name, required this.mastery, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.alertCircle, size: 14, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Text('${(mastery * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Study Plan Tab
// ════════════════════════════════════════════════════════════════

class _StudyPlanTab extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;
  const _StudyPlanTab({required this.projectId, required this.projectName});

  @override
  ConsumerState<_StudyPlanTab> createState() => _StudyPlanTabState();
}

class _StudyPlanTabState extends ConsumerState<_StudyPlanTab> {
  DateTime? _examDate;
  double _dailyHours = 2.0;
  bool _generated = false;

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  void _generate() {
    HapticFeedback.mediumImpact();
    setState(() => _generated = true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_generated) {
      return _StudyPlanForm(
        examDate: _examDate,
        dailyHours: _dailyHours,
        onPickDate: _pickDate,
        onHoursChanged: (v) => setState(() => _dailyHours = v),
        onGenerate: _generate,
        colorScheme: colorScheme,
      );
    }

    final dateStr = _examDate != null
        ? '${_examDate!.year}-${_examDate!.month.toString().padLeft(2, '0')}-${_examDate!.day.toString().padLeft(2, '0')}'
        : null;

    final plan = ref.watch(studyPlanProvider((
      projectId: widget.projectId,
      examDate: dateStr,
      dailyHours: _dailyHours,
    )));

    return plan.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating your study plan...',
                style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertTriangle,
                size: 40, color: colorScheme.error),
            const SizedBox(height: 12),
            Text('Failed to generate plan',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => setState(() => _generated = false),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
      data: (data) => _StudyPlanContent(
        data: data,
        onRegenerate: () => setState(() => _generated = false),
      ),
    );
  }
}

class _StudyPlanForm extends StatelessWidget {
  final DateTime? examDate;
  final double dailyHours;
  final VoidCallback onPickDate;
  final ValueChanged<double> onHoursChanged;
  final VoidCallback onGenerate;
  final ColorScheme colorScheme;

  const _StudyPlanForm({
    required this.examDate,
    required this.dailyHours,
    required this.onPickDate,
    required this.onHoursChanged,
    required this.onGenerate,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Icon(LucideIcons.calendarDays,
              size: 48, color: colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Generate Study Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'AI will create a personalized day-by-day plan based on your knowledge gaps.',
            style: TextStyle(
                fontSize: 13.5, color: colorScheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 28),

          // Exam date picker
          Text('Exam Date',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    examDate != null
                        ? '${examDate!.day}/${examDate!.month}/${examDate!.year}'
                        : 'Select exam date (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      color: examDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('Daily Study Hours: ${dailyHours.toStringAsFixed(1)}h',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
          Slider(
            value: dailyHours,
            min: 0.5,
            max: 8,
            divisions: 15,
            onChanged: onHoursChanged,
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(LucideIcons.sparkles, size: 18),
              label: const Text('Generate Plan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyPlanContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRegenerate;
  const _StudyPlanContent({required this.data, required this.onRegenerate});

  List<Map<String, dynamic>> _extractDays(Map<String, dynamic> plan) {
    // Try "days" key first, then "schedule", then "plan"
    for (final key in ['days', 'schedule', 'plan']) {
      final val = plan[key];
      if (val is List && val.isNotEmpty) {
        return val.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  String _extractSummary(Map<String, dynamic> plan) {
    for (final key in ['summary', 'overview', 'description']) {
      final val = plan[key];
      if (val is String && val.isNotEmpty) return val;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final plan = data['plan'] as Map<String, dynamic>? ?? {};
    final days = _extractDays(plan);
    final summary = _extractSummary(plan);
    final daysUntil = data['days_until_exam'] as int? ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$daysUntil days until exam',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  if (summary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(summary,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4)),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRegenerate,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              tooltip: 'Regenerate',
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (days.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.alertCircle,
                    size: 32, color: colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'The AI could not generate a structured plan. '
                  'Try again with fewer days or different parameters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRegenerate,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ],

        // Days
        ...days.asMap().entries.map((entry) {
          final idx = entry.key;
          final day = entry.value;
          return _DayCard(day: day, index: idx, colorScheme: colorScheme)
              .animate()
              .fadeIn(delay: (idx * 60).ms, duration: 300.ms)
              .slideX(begin: 0.05);
        }),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  final int index;
  final ColorScheme colorScheme;
  const _DayCard(
      {required this.day, required this.index, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final dayNum = day['day'] ?? index + 1;
    final focus = day['focus'] as String? ?? '';
    final topics =
        (day['topics'] as List?)?.cast<String>() ?? [];
    final activities =
        (day['activities'] as List?)?.cast<String>() ?? [];
    final hours = (day['hours'] as num?)?.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$dayNum',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(focus,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
              if (hours != null)
                Text('${hours}h',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary)),
            ],
          ),
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: topics
                  .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
          if (activities.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...activities.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Icon(LucideIcons.check,
                          size: 12, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(a,
                            style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Connections Tab
// ════════════════════════════════════════════════════════════════

class _ConnectionsTab extends ConsumerWidget {
  final String projectId;
  const _ConnectionsTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(crossConnectionsProvider(projectId));
    final colorScheme = Theme.of(context).colorScheme;

    return connections.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertTriangle,
                size: 40, color: colorScheme.error),
            const SizedBox(height: 12),
            Text('Could not load connections',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      data: (data) {
        final conns =
            (data['connections'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        if (conns.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.link, size: 48, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text('No cross-topic connections found',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Add topics to multiple projects to discover connections between subjects.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: conns.length,
          itemBuilder: (context, index) {
            final c = conns[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: colorScheme.outlineVariant.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.gitBranch,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c['current_topic'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        Icon(LucideIcons.arrowRight,
                            size: 14, color: colorScheme.outlineVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${c['related_topic'] ?? ''} (${c['related_project'] ?? ''})',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      c['connection_explanation'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms);
          },
        );
      },
    );
  }
}
