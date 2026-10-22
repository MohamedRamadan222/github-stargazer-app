import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// استدعاء صفحة المحفوظات
import '../../features/github/presentation/pages/saved_page.dart';

final appRouter = GoRouter(
  initialLocation: '/search',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
      branches: [
        // الفرع الأول (Index 0): البحث
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Search Page'))),
            ),
          ],
        ),

        // الفرع الثاني (Index 1): المحفوظات
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedPage(),
            ),
          ],
        ),

        // الفرع الثالث (Index 2): البروفايل
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Profile Page'))),
            ),
          ],
        ),
      ],
    ),
  ],
);
