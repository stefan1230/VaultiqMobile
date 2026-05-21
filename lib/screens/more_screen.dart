import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/portfolio_provider.dart';
import '../providers/theme_provider.dart';

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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'More',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Cloud sync'),
                subtitle: Text(_syncLabel(portfolio.syncStatus)),
                trailing: userId != null
                    ? IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () => portfolio.syncToCloud(userId!),
                      )
                    : null,
              ),
              if (userId == null && onContinueOffline != null)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Sign in for cloud sync'),
                  onTap: onContinueOffline,
                ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(
                  theme.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Dark mode'),
                value: theme.isDark,
                onChanged: (_) => theme.toggle(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export backup'),
                onTap: () => _export(context),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Import backup'),
                onTap: () => _import(context),
              ),
            ],
          ),
        ),
        if (userId != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign out'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                onSignOut();
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Vaultiq mobile · data stored on device',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
