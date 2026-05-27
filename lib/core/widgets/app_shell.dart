import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../utils/responsive.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const items = [
    _NavItem('Dashboard', Icons.dashboard_rounded, '/dashboard'),
    _NavItem('New Issue', Icons.add_circle_outline_rounded, '/upload'),
    _NavItem('Analysis', Icons.auto_awesome_rounded, '/analysis'),
    _NavItem('Tickets', Icons.confirmation_number_outlined, '/ticket'),
    _NavItem('Release Notes', Icons.article_outlined, '/release-notes'),
    _NavItem('Sprint Insights', Icons.query_stats_rounded, '/sprint-insights'),
    _NavItem('Team Allocation', Icons.groups_2_outlined, '/team-allocation'),
    _NavItem('Settings', Icons.settings_outlined, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Scaffold(
        body: child,
        bottomNavigationBar: const _BottomNavigation(),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const _Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: 264,
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xB20B1020),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: .1)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .08),
                blurRadius: 40,
                offset: const Offset(18, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go('/'),
                child: const Row(
                  children: [
                    _BrandMark(),
                    SizedBox(width: 12),
                    Text(
                      'SprintPilot AI',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              for (final item in AppShell.items)
                _NavTile(item: item, selected: _isSelected(context, item.path)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .14),
                      AppColors.secondary.withValues(alpha: .08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .14),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: const Text(
                  'AI triage engine online\n92% confidence average',
                  style: TextStyle(color: AppColors.mutedText, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || hovered;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go(widget.item.path),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: .14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.selected
                    ? AppColors.primary.withValues(alpha: .28)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.item.icon,
                  color: active ? AppColors.cyan : AppColors.mutedText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.mutedText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    final compactItems = AppShell.items.take(5).toList();
    return NavigationBar(
      backgroundColor: const Color(0xF00F1426),
      indicatorColor: AppColors.primary.withValues(alpha: .18),
      destinations: [
        for (final item in compactItems)
          NavigationDestination(
            icon: Icon(item.icon),
            label: item.label.split(' ').first,
          ),
      ],
      selectedIndex: compactItems
          .indexWhere((item) => _isSelected(context, item.path))
          .clamp(0, compactItems.length - 1),
      onDestinationSelected: (index) => context.go(compactItems[index].path),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .35),
            blurRadius: 22,
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 21),
    );
  }
}

bool _isSelected(BuildContext context, String path) {
  final location = GoRouterState.of(context).uri.toString();
  if (path == '/') return location == '/';
  return location.startsWith(path);
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
