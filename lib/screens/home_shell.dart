import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'debts_screen.dart';
import 'insights_screen.dart';
import 'more_screen.dart';
import 'savings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.user,
    required this.onRequestAuth,
    this.onSignedOut,
  });

  final User? user;
  final VoidCallback onRequestAuth;
  final VoidCallback? onSignedOut;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _initData();
    }
  }

  Future<void> _initData() async {
    final portfolio = context.read<PortfolioProvider>();
    if (widget.user != null) {
      await portfolio.initFromCloud(widget.user!.id);
      await portfolio.syncToCloud(widget.user!.id);
    } else {
      await portfolio.initLocal();
    }
  }

  String? get _userId => widget.user?.id;

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    if (!portfolio.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final insights = portfolio.insights;
    final syncLabel = switch (portfolio.syncStatus) {
      SyncStatus.idle => 'Local',
      SyncStatus.syncing => 'Syncing',
      SyncStatus.synced => 'Synced',
      SyncStatus.error => 'Sync error',
    };

    final screens = [
      DashboardScreen(
        insights: insights,
        onNavigate: (i) => setState(() => _index = i),
      ),
      DebtsScreen(userId: _userId),
      SavingsScreen(userId: _userId),
      const InsightsScreen(),
      MoreScreen(
        userId: _userId,
        onSignOut: widget.onSignedOut ?? () {},
        onContinueOffline: widget.onRequestAuth,
      ),
    ];

    const titles = ['Vaultiq', 'Debts', 'Funds', 'Insights', 'More'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_userId != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  syncLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: portfolio.syncStatus == SyncStatus.synced
                        ? AppColors.teal
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Debts',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Funds',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
