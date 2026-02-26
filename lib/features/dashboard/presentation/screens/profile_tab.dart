import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../app/theme_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/providers.dart';
import 'main_shell.dart';

Color _avatarBgColor(String? hex, ColorScheme cs) {
  if (hex != null && hex.length == 7) {
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value != null) return Color(0xFF000000 | value);
  }
  return cs.primary;
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final user = authState.whenOrNull(authenticated: (u) => u);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user),
          ),

          // ── Content ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account
                _SectionLabel(label: 'Account'),
                const SizedBox(height: 6),
                _SettingsGroup(children: [
                  _SettingsTile(
                    icon: LucideIcons.userCog,
                    title: 'Edit Profile',
                    subtitle: 'Name, avatar, preferences',
                    onTap: () => _showEditProfileSheet(context, ref, user),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.shield,
                    title: 'Privacy & Security',
                    subtitle: 'Change password',
                    onTap: () => _showChangePasswordSheet(context, ref),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Reminders and alerts',
                    onTap: () => _showNotificationPreferencesSheet(context),
                  ),
                ]),

                const SizedBox(height: 20),
                _SectionLabel(label: 'Sharing'),
                const SizedBox(height: 6),
                _SettingsGroup(children: [
                  _SettingsTile(
                    icon: LucideIcons.share2,
                    title: 'My Shared Links',
                    subtitle: 'Manage shared conversations',
                    onTap: () => context.push(AppRoutes.myShares),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.search,
                    title: 'Browse Shared',
                    subtitle: 'View by share code',
                    onTap: () => _showEnterShareCodeDialog(context),
                  ),
                ]),

                const SizedBox(height: 20),
                _SectionLabel(label: 'Preferences'),
                const SizedBox(height: 6),
                _ThemeTile(ref: ref),

                const SizedBox(height: 20),
                _SectionLabel(label: 'Support'),
                const SizedBox(height: 6),
                _SettingsGroup(children: [
                  _SettingsTile(
                    icon: LucideIcons.helpCircle,
                    title: 'Help & FAQ',
                    subtitle: 'Get help using the app',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.play,
                    title: 'Replay Tutorial',
                    subtitle: 'See the app walkthrough again',
                    onTap: () {
                      final shellState = context
                          .findAncestorStateOfType<MainShellState>();
                      shellState?.replayTutorial();
                    },
                  ),
                  _SettingsTile(
                    icon: LucideIcons.messageSquare,
                    title: 'Send Feedback',
                    subtitle: 'Tell us what you think',
                    onTap: () {},
                  ),
                ]),

                // ── About the Developer ──────────────────────
                const SizedBox(height: 20),
                _SectionLabel(label: 'About the Developer'),
                const SizedBox(height: 6),
                const _DeveloperCard(),

                const SizedBox(height: 24),

                // Logout
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context, ref),
                      icon: Icon(LucideIcons.logOut,
                          size: 16, color: colorScheme.error),
                      label: Text('Logout',
                          style: TextStyle(
                              color: colorScheme.error, fontSize: 13.5)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: colorScheme.error.withAlpha(80)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'AI Tutor v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withAlpha(100),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs / Sheets ─────────────────────────────────────

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _EditProfileSheet(
        currentName: user?.fullName ?? '',
        currentSocraticMode: user?.defaultSocraticMode ?? false,
        currentAvatarColor: user?.avatarColor,
        initials: user?.initials ?? '?',
        onSave: (name, socratic, avatarColor) async {
          await ref.read(authNotifierProvider.notifier).updateProfile(
                fullName: name,
                defaultSocraticMode: socratic,
                avatarColor: avatarColor,
              );
        },
      ),
    );
  }

  void _showNotificationPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _NotificationPreferencesSheet(),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ChangePasswordSheet(
        onSave: (current, newPw) async {
          await ref.read(authNotifierProvider.notifier).changePassword(
                currentPassword: current,
                newPassword: newPw,
              );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.logOut, color: colorScheme.error, size: 24),
        ),
        title: const Text('Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 13.5, color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Logout', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showEnterShareCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.search, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Browse Shared',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the share code to view a shared conversation:',
              style: TextStyle(
                  fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Paste share code...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(LucideIcons.key, size: 18),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.push(AppRoutes.sharedConversation(v.trim()));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                context.push(AppRoutes.sharedConversation(code));
              }
            },
            child: const Text('View', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Profile Header
// ════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.secondary, 0.5)!,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              // Title
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(200),
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(duration: 200.ms),
              const SizedBox(height: 16),

              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color:
                      _avatarBgColor(user?.avatarColor, colorScheme),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.white.withAlpha(60), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 350.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),

              // Name
              Text(
                user?.fullName ?? 'User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withAlpha(180),
                ),
              ).animate().fadeIn(delay: 140.ms),
              const SizedBox(height: 10),

              // Member since
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(isDark ? 18 : 22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Member since ${_formatDate(user?.createdAt)}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white.withAlpha(160),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '...';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ════════════════════════════════════════════════════════════════
// Section Label
// ════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(130),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Settings Group (card container)
// ════════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withAlpha(120)
            : colorScheme.surfaceContainerHighest.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 25 : 50)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: colorScheme.outlineVariant.withAlpha(isDark ? 20 : 40),
              ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Settings Tile
// ════════════════════════════════════════════════════════════════

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(isDark ? 22 : 14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        )),
                    const SizedBox(height: 1),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant.withAlpha(160),
                        )),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  size: 15,
                  color: colorScheme.onSurfaceVariant.withAlpha(100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Theme Tile
// ════════════════════════════════════════════════════════════════

class _ThemeTile extends StatelessWidget {
  final WidgetRef ref;
  const _ThemeTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withAlpha(120)
            : colorScheme.surfaceContainerHighest.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 25 : 50)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showThemeSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(isDark ? 22 : 14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(themeMode.icon, size: 16, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appearance',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          )),
                      const SizedBox(height: 1),
                      Text(themeMode.displayName,
                          style: TextStyle(
                            fontSize: 11.5,
                            color:
                                colorScheme.onSurfaceVariant.withAlpha(160),
                          )),
                    ],
                  ),
                ),
                _ThemeModeSelector(
                  currentMode: themeMode,
                  onChanged: (mode) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(mode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...ThemeMode.values.map((mode) => RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: currentMode,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(v);
                      Navigator.pop(context);
                    }
                  },
                  title: Text(mode.displayName, style: const TextStyle(fontSize: 14)),
                  secondary: Icon(mode.icon, size: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withAlpha(180)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ThemeMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                mode.icon,
                size: 14,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Developer Card
// ════════════════════════════════════════════════════════════════

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  static const _links = [
    ('GitHub', LucideIcons.github, 'https://github.com/Mollalign/'),
    ('LinkedIn', LucideIcons.linkedin, 'https://www.linkedin.com/in/mollalign-daniel-ba88aa387/'),
    ('Portfolio', LucideIcons.globe, 'https://mollalign.vercel.app/'),
    ('Telegram', LucideIcons.send, 'https://t.me/mdevstudio_1'),
    ('LeetCode', LucideIcons.code, 'https://leetcode.com/u/molle_ex/'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest.withAlpha(140),
                  colorScheme.surfaceContainerHighest.withAlpha(80),
                ]
              : [
                  colorScheme.surfaceContainerHighest.withAlpha(200),
                  colorScheme.surfaceContainerHighest.withAlpha(120),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 25 : 50)),
      ),
      child: Column(
        children: [
          // Top info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dev avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(isDark ? 30 : 20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('MD',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mollalign Daniel',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'molledan26@gmail.com',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant.withAlpha(160),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          _RolePill(
                              label: 'Full Stack Developer',
                              color: colorScheme.primary),
                          _RolePill(
                              label: 'AI/ML Engineer',
                              color: colorScheme.tertiary),
                          _RolePill(
                              label: 'CS Student · 4th Year',
                              color: colorScheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(isDark ? 20 : 40),
          ),

          // Social links
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _links.map((link) {
                final (label, icon, url) = link;
                return _SocialButton(
                    icon: icon, label: label, url: url);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final Color color;
  const _RolePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.selectionClick();
          try {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {
            if (context.mounted) {
              showAppSnackBar(context,
                  message: 'Could not open link',
                  type: SnackBarType.error);
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(isDark ? 20 : 12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 14, color: colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant.withAlpha(140),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Edit Profile Sheet
// ════════════════════════════════════════════════════════════════

class _EditProfileSheet extends StatefulWidget {
  final String currentName;
  final bool currentSocraticMode;
  final String? currentAvatarColor;
  final String initials;
  final Future<void> Function(String name, bool socratic, String? avatarColor)
      onSave;

  const _EditProfileSheet({
    required this.currentName,
    required this.currentSocraticMode,
    required this.initials,
    required this.onSave,
    this.currentAvatarColor,
  });

  static const _presetColors = [
    '#4CAF50', '#2196F3', '#9C27B0', '#FF9800',
    '#E91E63', '#00BCD4', '#FF5722', '#607D8B',
    '#3F51B5', '#795548',
  ];

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late bool _socraticMode;
  late String? _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _socraticMode = widget.currentSocraticMode;
    _selectedColor = widget.currentAvatarColor;
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.length != 7) return null;
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 2 characters')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSave(name, _socraticMode, _selectedColor);
      if (mounted) {
        Navigator.pop(context);
        showAppSnackBar(context,
            message: 'Profile updated successfully',
            type: SnackBarType.success);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Edit Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _parseColor(_selectedColor) ?? colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  widget.initials,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Avatar Color',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _EditProfileSheet._presetColors.map((hex) {
              final isSelected = _selectedColor == hex;
              final color = _parseColor(hex) ?? colorScheme.primary;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: colorScheme.onSurface, width: 2.5)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withAlpha(80), blurRadius: 6)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Full Name',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(LucideIcons.user, size: 18),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Socratic Mode',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
            subtitle: Text(
              'AI guides you with questions',
              style: TextStyle(
                  fontSize: 11.5, color: colorScheme.onSurfaceVariant),
            ),
            value: _socraticMode,
            onChanged: (v) => setState(() => _socraticMode = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Change Password Sheet
// ════════════════════════════════════════════════════════════════

class _ChangePasswordSheet extends StatefulWidget {
  final Future<void> Function(String current, String newPw) onSave;
  const _ChangePasswordSheet({required this.onSave});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentController.text;
    final newPw = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')));
      return;
    }
    if (newPw.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('New password must be at least 8 characters')));
      return;
    }
    if (newPw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(current, newPw);
      if (mounted) {
        Navigator.pop(context);
        showAppSnackBar(context,
            message: 'Password changed successfully',
            type: SnackBarType.success);
      }
    } catch (e) {
      if (mounted) {
        String message = 'Failed to change password';
        final eStr = e.toString();
        if (eStr.contains('incorrect')) {
          message = 'Current password is incorrect';
        } else if (eStr.contains('Google')) {
          message = 'This account uses Google Sign-In and has no password';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Change Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          _buildPasswordField(_currentController, 'Current Password',
              _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
          const SizedBox(height: 10),
          _buildPasswordField(_newController, 'New Password',
              _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
          const SizedBox(height: 10),
          _buildPasswordField(_confirmController, 'Confirm Password',
              _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Change Password',
                      style: TextStyle(fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(LucideIcons.lock, size: 18),
        suffixIcon: IconButton(
          icon: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
          onPressed: toggle,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Notification Preferences Sheet
// ════════════════════════════════════════════════════════════════

class _NotificationPreferencesSheet extends StatefulWidget {
  const _NotificationPreferencesSheet();

  @override
  State<_NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends State<_NotificationPreferencesSheet> {
  bool _studyReminders = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _quizResults = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final client = ApiClient();
      final response = await client.get(ApiConstants.notificationPreferences);
      final data = response.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _studyReminders = data['study_reminders_enabled'] ?? false;
        _quizResults = data['quiz_results_enabled'] ?? true;
        final timeStr = data['reminder_time'] as String?;
        if (timeStr != null && timeStr.contains(':')) {
          final parts = timeStr.split(':');
          _reminderTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final client = ApiClient();
      await client.patch(
        ApiConstants.notificationPreferences,
        data: {
          'study_reminders_enabled': _studyReminders,
          'reminder_time':
              '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
          'quiz_results_enabled': _quizResults,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification preferences saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save preferences. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Notification Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Study Reminders',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              subtitle: Text('Daily reminder to keep up your streak',
                  style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant)),
              value: _studyReminders,
              onChanged: (v) => setState(() => _studyReminders = v),
            ),
            if (_studyReminders) ...[
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(LucideIcons.clock, color: colorScheme.primary, size: 18),
                title: const Text('Reminder Time',
                    style: TextStyle(fontSize: 13.5)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                    }
                  },
                  child: Text(_reminderTime.format(context),
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
            Divider(
                color: colorScheme.outlineVariant.withAlpha(60), height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quiz Results',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              subtitle: Text('Get notified when quiz results are ready',
                  style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant)),
              value: _quizResults,
              onChanged: (v) => setState(() => _quizResults = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _savePreferences,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Preferences',
                        style: TextStyle(fontSize: 13.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
