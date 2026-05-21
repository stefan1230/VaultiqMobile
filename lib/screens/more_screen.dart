import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/portfolio_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/fintech_ui.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.userId,
    required this.onSignOut,
    this.onContinueOffline,
  });

  final String? userId;
  final VoidCallback onSignOut;
  final VoidCallback? onContinueOffline;

  String _syncLabel(SyncStatus s) => switch (s) {
        SyncStatus.idle => 'Local only',
        SyncStatus.syncing => 'Syncing…',
        SyncStatus.synced => 'Cloud synced',
        SyncStatus.error => 'Sync error',
      };

  Future<void> _export(BuildContext context) async {
    final json = context.read<PortfolioProvider>().exportJson();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/vaultiq_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'Vaultiq backup');
  }

  Future<void> _import(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    final content = await File(result.files.single.path!).readAsString();
    if (!context.mounted) return;
    try {
      await context.read<PortfolioProvider>().importJson(
            content,
            userId: userId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to parse backup file')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final theme = context.watch<ThemeProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.meshBackground(dark)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SectionHeader(
            title: 'More',
            subtitle: 'Sync, appearance, and data',
          ),
          FadeSlide(
            child: GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.cloud_rounded,
                    iconColor: AppColors.teal,
                    title: 'Cloud sync',
                    subtitle: _syncLabel(portfolio.syncStatus),
                    trailing: userId != null
                        ? IconButton(
                            icon: const Icon(Icons.sync_rounded),
                            onPressed: () => portfolio.syncToCloud(userId!),
                          )
                        : null,
                  ),
                  if (userId == null && onContinueOffline != null)
                    _SettingsTile(
                      icon: Icons.login_rounded,
                      iconColor: AppColors.violet,
                      title: 'Sign in for cloud sync',
                      onTap: onContinueOffline,
                    ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        theme.isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.amber,
                        size: 22,
                      ),
                    ),
                    title: const Text('Dark mode'),
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: const Duration(milliseconds: 100),
            child: GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.upload_file_rounded,
                    iconColor: AppColors.emerald,
                    title: 'Export backup',
                    onTap: () => _export(context),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    iconColor: AppColors.violet,
                    title: 'Import backup',
                    onTap: () => _import(context),
                  ),
                ],
              ),
            ),
          ),
          if (userId != null) ...[
            const SizedBox(height: 12),
            FadeSlide(
              delay: const Duration(milliseconds: 160),
              child: GlassCard(
                child: _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.coral,
                  title: 'Sign out',
                  titleColor: AppColors.coral,
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    onSignOut();
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          FadeSlide(
            delay: const Duration(milliseconds: 220),
            child: Text(
              'Vaultiq mobile · data stored on device',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: titleColor != null
            ? TextStyle(color: titleColor, fontWeight: FontWeight.w600)
            : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
