import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/github/presentation/pages/explore_page.dart';
import '../../features/github/presentation/pages/profile_page.dart';
import '../../features/github/presentation/pages/repo_details_page.dart';
import '../../features/github/presentation/pages/saved_page.dart';
import '../domain/entities/github_repo.dart';

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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const ExplorePage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              // غير 'MohamedRamadan222' لليوزرنيم الحقيقي بتاعك
              builder: (context, state) =>
                  const ProfilePage(username: 'MohamedRamadan222'),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) =>
          RepoDetailsPage(repo: state.extra as GithubRepo),
    ),
  ],
);
