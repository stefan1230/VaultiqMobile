import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/portfolio_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'services/cloud_sync.dart';
import 'services/local_store.dart';
import 'theme/app_theme.dart';
import 'widgets/fade_slide.dart';

class VaultiqApp extends StatelessWidget {
  const VaultiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => PortfolioProvider(
            LocalStore(),
            CloudSync(client),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Vaultiq',
            debugShowCheckedModeBanner: false,
            themeMode: theme.mode,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            home: const _Root(),
          );
        },
      ),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _offline = false;
  bool _showAuth = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        final user = session?.user;

        if (_showAuth && user == null) {
          return const AuthScreen();
        }

        if (user != null || _offline) {
          return HomeShell(
            user: user,
            onRequestAuth: () => setState(() => _showAuth = true),
            onSignedOut: () => setState(() {
              _offline = false;
              _showAuth = false;
            }),
          );
        }

        return _Welcome(
          onSignIn: () => setState(() => _showAuth = true),
          onOffline: () => setState(() {
            _offline = true;
            _showAuth = false;
          }),
        );
      },
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onSignIn, required this.onOffline});

  final VoidCallback onSignIn;
  final VoidCallback onOffline;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                FadeSlide(
                  child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lime,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lime.withValues(alpha: 0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 56,
                      color: AppColors.onLime,
                    ),
                  ),
                ),
                ),
                const SizedBox(height: 28),
                FadeSlide(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                  'Vaultiq',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                ),
                const SizedBox(height: 12),
                FadeSlide(
                  delay: const Duration(milliseconds: 180),
                  child: Text(
                  'Track credit cards, loans, and savings goals — with clarity and confidence.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                ),
                ),
                const Spacer(),
                FadeSlide(
                  delay: const Duration(milliseconds: 280),
                  child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onSignIn,
                    icon: const Icon(Icons.cloud_sync_rounded, size: 20),
                    label: const Text('Sign in with cloud sync'),
                  ),
                ),
                ),
                const SizedBox(height: 12),
                FadeSlide(
                  delay: const Duration(milliseconds: 360),
                  child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOffline,
                    icon: const Icon(Icons.offline_bolt_rounded, size: 20),
                    label: const Text('Continue offline'),
                  ),
                ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
      ),
    );
  }
}
