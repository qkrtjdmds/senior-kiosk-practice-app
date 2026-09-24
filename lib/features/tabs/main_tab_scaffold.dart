import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  int get _selectedIndex => switch (location) {
    AppRoutes.practice => 1,
    AppRoutes.missions => 2,
    AppRoutes.progress => 3,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFFFFDF7),
        selectedIndex: _selectedIndex,
        height: 76 + (scale - 1).clamp(0, 0.5) * 34,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: const Color(0xFFDFE8DC),
        onDestinationSelected: (index) {
          final route = switch (index) {
            1 => AppRoutes.practice,
            2 => AppRoutes.missions,
            3 => AppRoutes.progress,
            _ => AppRoutes.home,
          };
          context.go(route);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_rounded),
            label: '연습',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: '미션',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
