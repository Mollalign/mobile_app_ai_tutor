import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/utils/error_utils.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../knowledge/data/datasources/knowledge_remote_datasource.dart';
import '../../../knowledge/presentation/providers/knowledge_provider.dart';
import '../../../knowledge/presentation/widgets/mastery_ring.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late final KnowledgeRemoteDataSource _dataSource;
  Map<String, dynamic>? _stats;
  List<dynamic>? _quizHistory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataSource = ref.read(knowledgeDataSourceProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _dataSource.getProgressStats(),
        _dataSource.getQuizHistory(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _quizHistory = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const _LoadingBody()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.alertCircle, size: 48, color: colorScheme.error),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _ProgressBody(stats: _stats!, quizHistory: _quizHistory!),
                ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ShimmerBox(width: double.infinity, height: 140),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 220),
          SizedBox(height: 20),
          ShimmerBox(width: double.infinity, height: 180),
        ],
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<dynamic> quizHistory;

  const _ProgressBody({required this.stats, required this.quizHistory});

  @override
  Widget build(BuildContext context) {
    final knowledge = stats['knowledge'] as Map<String, dynamic>? ?? {};
    final overallMastery = (knowledge['overall_mastery'] as num?)?.toDouble() ??
        (knowledge['avg_mastery'] as num?)?.toDouble() ??
        0;
    final streak = stats['study_streak'] as int? ?? 0;
    final quizzesThisWeek = stats['quizzes_this_week'] as int? ?? 0;
    final totalAttempts = stats['total_quiz_attempts'] as int? ?? 0;
    final avgScore = (stats['avg_quiz_score'] as num?)?.toDouble() ?? 0;
    final masteryByProject = stats['mastery_by_project'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _OverviewCards(
          streak: streak,
          quizzesThisWeek: quizzesThisWeek,
          totalAttempts: totalAttempts,
          avgScore: avgScore,
          overallMastery: overallMastery,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),
        if (quizHistory.isNotEmpty) ...[
          _ScoreTrendChart(quizHistory: quizHistory)
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),
        ],
        if (masteryByProject.isNotEmpty) ...[
          _MasteryByProject(projects: masteryByProject)
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),
        ],
        if (quizHistory.isNotEmpty)
          _RecentQuizzes(quizHistory: quizHistory)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }
}

// ============================================================
// Overview Cards
// ============================================================

class _OverviewCards extends StatelessWidget {
  final int streak;
  final int quizzesThisWeek;
  final int totalAttempts;
  final double avgScore;
  final double overallMastery;

  const _OverviewCards({
    required this.streak,
    required this.quizzesThisWeek,
    required this.totalAttempts,
    required this.avgScore,
    required this.overallMastery,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak + mastery hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.5)!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              MasteryRing(mastery: overallMastery, size: 72, strokeWidth: 7),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Mastery',
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${overallMastery.round()}%',
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(LucideIcons.flame, color: Colors.orangeAccent, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    '$streak',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'day streak',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stat chips
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: LucideIcons.brainCircuit,
                value: '$totalAttempts',
                label: 'Total Quizzes',
                color: colorScheme.primary,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: LucideIcons.target,
                value: '${avgScore.round()}%',
                label: 'Avg Score',
                color: Colors.orange,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatChip(
                icon: LucideIcons.calendarDays,
                value: '$quizzesThisWeek',
                label: 'This Week',
                color: Colors.green,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final ColorScheme colorScheme;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(60)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Score Trend Chart
// ============================================================

class _ScoreTrendChart extends StatelessWidget {
  final List<dynamic> quizHistory;

  const _ScoreTrendChart({required this.quizHistory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Take the last 10 attempts in chronological order for the chart
    final chartData = quizHistory.reversed.take(10).toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      final pct = (chartData[i]['percentage'] as num?)?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), pct));
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(60)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Trend',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Last ${chartData.length} quizzes',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withAlpha(60),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: colorScheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withAlpha(30),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final title = idx < chartData.length
                            ? (chartData[idx]['quiz_title'] ?? 'Quiz')
                            : 'Quiz';
                        return LineTooltipItem(
                          '$title\n${spot.y.round()}%',
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Mastery by Project
// ============================================================

class _MasteryByProject extends StatelessWidget {
  final List<dynamic> projects;

  const _MasteryByProject({required this.projects});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withAlpha(60)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mastery by Project',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...projects.map((p) {
            final name = p['project_name'] as String? ?? 'Project';
            final mastery = (p['mastery'] as num?)?.toDouble() ?? 0;
            final topics = p['topics_count'] as int? ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${mastery.round()}% · $topics topics',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mastery / 100,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _masteryColor(mastery, colorScheme),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _masteryColor(double mastery, ColorScheme cs) {
    if (mastery >= 80) return Colors.green;
    if (mastery >= 50) return Colors.orange;
    return cs.error;
  }
}

// ============================================================
// Recent Quizzes List
// ============================================================

class _RecentQuizzes extends StatelessWidget {
  final List<dynamic> quizHistory;

  const _RecentQuizzes({required this.quizHistory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Quizzes',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...quizHistory.take(10).map((q) {
          final title = q['quiz_title'] as String? ?? 'Quiz';
          final project = q['project_name'] as String? ?? '';
          final pct = (q['percentage'] as num?)?.toDouble() ?? 0;
          final passed = q['passed'] as bool? ?? false;
          final completedAt = q['completed_at'] as String?;
          final difficulty = q['difficulty'] as String? ?? 'medium';

          String timeAgo = '';
          if (completedAt != null) {
            final dt = DateTime.tryParse(completedAt);
            if (dt != null) {
              final diff = DateTime.now().difference(dt);
              if (diff.inDays > 0) {
                timeAgo = '${diff.inDays}d ago';
              } else if (diff.inHours > 0) {
                timeAgo = '${diff.inHours}h ago';
              } else {
                timeAgo = '${diff.inMinutes}m ago';
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? colorScheme.outlineVariant.withAlpha(50)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (passed ? Colors.green : colorScheme.error)
                          .withAlpha(isDark ? 50 : 25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${pct.round()}%',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: passed ? Colors.green : colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$project · $difficulty',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
