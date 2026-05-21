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
          return AuthScreen();
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.account_balance_wallet,
                  size: 72, color: AppColors.teal),
              const SizedBox(height: 16),
              Text(
                'Vaultiq',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track credit cards, loans, and savings goals in one place.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onSignIn,
                child: const Text('Sign in with cloud sync'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onOffline,
                child: const Text('Continue offline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
