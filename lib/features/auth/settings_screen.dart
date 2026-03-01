import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/providers/sync_provider.dart';
import 'package:study_notebook/core/providers/theme_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/auth/auth_provider.dart';
import 'package:study_notebook/features/auth/auth_state.dart';

/// User profile and settings screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final email = switch (authState) {
      AuthAuthenticated(user: final u) => u.email,
      AuthDemo(email: final e) => e,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person,
                        size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email ?? 'Not signed in',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.appTitle,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Appearance section.
          const _SectionHeader(title: 'Appearance'),
          _ThemeTile(),

          // Sync section — only for authenticated (non-demo) users.
          if (authState is AuthAuthenticated) ...[
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Sync'),
            _SyncTile(),
          ],

          const SizedBox(height: 24),

          // App info section.
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.appTitle,
            subtitle: 'Version 1.0.0',
          ),

          const SizedBox(height: 24),

          // Account section.
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.logout,
            title: AppStrings.logout,
            titleColor: AppColors.error,
            onTap: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text(AppStrings.logout,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: titleColor),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, size: 20)
            : null,
        onTap: onTap,
      ),
    );
  }
}

/// Shows sync status and exposes a manual sync button for authenticated users.
class _SyncTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);
    final notifier = ref.read(syncProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, iconColor, statusText) = switch (sync.status) {
      SyncStatus.syncing => (
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          colorScheme.primary,
          'Syncing…',
        ),
      SyncStatus.success => (
          const Icon(Icons.cloud_done_outlined, size: 20),
          Colors.green,
          sync.lastSyncedAt != null
              ? 'Last synced ${_formatTime(sync.lastSyncedAt!)}'
              : 'Up to date',
        ),
      SyncStatus.error => (
          const Icon(Icons.cloud_off_outlined, size: 20),
          colorScheme.error,
          sync.errorMessage ?? 'Sync failed',
        ),
      _ => (
          const Icon(Icons.cloud_upload_outlined, size: 20),
          colorScheme.onSurfaceVariant,
          sync.pendingCount > 0
              ? '${sync.pendingCount} item${sync.pendingCount == 1 ? '' : 's'} pending'
              : 'Up to date',
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(color: iconColor, size: 20),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cloud Sync',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: iconColor),
                  ),
                ],
              ),
            ),
            if (sync.status != SyncStatus.syncing)
              TextButton(
                onPressed: notifier.sync,
                child: const Text('Sync now'),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m == 1 ? '' : 's'} ago';
    }
    final h = diff.inHours;
    return '$h hr${h == 1 ? '' : 's'} ago';
  }
}

/// Segmented-button tile that lets the user pick Light / System / Dark theme.
class _ThemeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeSettingProvider);
    final notifier = ref.read(themeSettingProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.palette_outlined),
            const SizedBox(width: 16),
            const Expanded(child: Text('Theme')),
            SegmentedButton<ThemeMode>(
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12),
              ),
              selected: {current},
              onSelectionChanged: (set) => notifier.setMode(set.first),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 16),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined, size: 16),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 16),
                  label: Text('Dark'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
