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
      SyncStatus.error => 'Error',
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

    final titles = ['', 'Debts', 'Funds', 'Insights', 'More'];
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      extendBody: true,
      appBar: _index == 0
          ? null
          : AppBar(
              title: Text(titles[_index]),
              actions: [
                if (_userId != null) _SyncBadge(portfolio: portfolio, label: syncLabel),
              ],
            ),
      body: Padding(
        padding: EdgeInsets.only(
          top: _index == 0 ? MediaQuery.paddingOf(context).top : 0,
          bottom: shellBottomClearance(context),
        ),
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
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? AppColors.surfaceDarkElevated : AppColors.cardLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: dark ? AppColors.cardDarkBorder : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.lime.withValues(alpha: 0.15),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.credit_card_outlined),
                  selectedIcon: Icon(Icons.credit_card_rounded),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.portfolio, required this.label});

  final PortfolioProvider portfolio;
  final String label;

  @override
  Widget build(BuildContext context) {
    final synced = portfolio.syncStatus == SyncStatus.synced;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: synced
              ? AppColors.lime.withValues(alpha: 0.12)
              : AppColors.cardDarkElevated,
          borderRadius: BorderRadius.circular(20),
          border: synced
              ? Border.all(color: AppColors.lime.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (portfolio.syncStatus == SyncStatus.syncing)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.lime,
                ),
              )
            else
              Icon(
                synced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                size: 14,
                color: synced ? AppColors.lime : AppColors.textMuted,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: synced ? AppColors.lime : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
