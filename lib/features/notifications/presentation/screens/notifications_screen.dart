import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final client = ApiClient();
      final response = await client.get(ApiConstants.notificationsEndpoint);
      final data = response.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _notifications = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _isLoading = false;
        _errorMessage = 'Could not load notifications. Pull to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const _LoadingBody()
          : _errorMessage != null
              ? _ErrorBody(
                  message: _errorMessage!,
                  onRetry: _loadNotifications,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : _notifications.isEmpty
                  ? _EmptyState(
                      colorScheme: colorScheme, textTheme: textTheme)
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return _NotificationTile(
                            notification: n,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ).animate().fadeIn(
                                delay: Duration(
                                    milliseconds: 50 * index),
                                duration: 300.ms,
                              );
                        },
                      ),
                    ),
    );
  }

  Future<void> _markAllRead() async {
    try {
      final client = ApiClient();
      await client.post(
          '${ApiConstants.notificationsEndpoint}/mark-all-read');
      _loadNotifications();
    } catch (_) {}
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
          ShimmerBox(width: double.infinity, height: 80),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 80),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 80),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 80),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff,
                size: 48, color: colorScheme.error.withAlpha(150)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _EmptyState({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(60),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bellOff,
              size: 48,
              color: colorScheme.primary.withAlpha(150),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see quiz results and study\nreminders here',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isDark;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] as String? ?? 'Notification';
    final body = notification['body'] as String? ?? '';
    final isRead = notification['is_read'] as bool? ?? false;
    final type = notification['type'] as String? ?? 'general';
    final createdAt = notification['created_at'] as String?;

    String timeAgo = '';
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt);
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

    IconData icon;
    Color iconColor;
    switch (type) {
      case 'quiz_result':
        icon = LucideIcons.brainCircuit;
        iconColor = Colors.orange;
        break;
      case 'study_reminder':
        icon = LucideIcons.flame;
        iconColor = Colors.red;
        break;
      default:
        icon = LucideIcons.bell;
        iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead
            ? (isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface)
            : (isDark
                ? colorScheme.primaryContainer.withAlpha(30)
                : colorScheme.primaryContainer.withAlpha(60)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead
              ? (isDark
                  ? colorScheme.outlineVariant.withAlpha(40)
                  : colorScheme.outlineVariant)
              : colorScheme.primary.withAlpha(40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (timeAgo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(160),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
