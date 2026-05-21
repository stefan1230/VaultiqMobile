import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fintech_ui.dart';
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
      return const FintechLoader();
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Text(
            titles[_index],
            key: ValueKey(_index),
          ),
        ),
        actions: [
          if (_userId != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: portfolio.syncStatus == SyncStatus.synced
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (portfolio.syncStatus == SyncStatus.syncing)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.teal,
                          ),
                        )
                      else
                        Icon(
                          portfolio.syncStatus == SyncStatus.synced
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          size: 14,
                          color: portfolio.syncStatus == SyncStatus.synced
                              ? AppColors.teal
                              : null,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        syncLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: portfolio.syncStatus == SyncStatus.synced
                              ? AppColors.teal
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: shellBottomClearance(context)),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: screens[_index],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.credit_card_outlined),
                  selectedIcon: Icon(Icons.credit_card_rounded),
                  label: 'Debts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.savings_outlined),
                  selectedIcon: Icon(Icons.savings_rounded),
                  label: 'Funds',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Insights',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz_rounded),
                  selectedIcon: Icon(Icons.more_horiz_rounded),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
