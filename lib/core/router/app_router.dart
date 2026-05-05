import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../constants/app_strings.dart';
import 'user_role.dart';

// T-03: hardcoded, replaced in T-07
UserRole _resolveRole() => UserRole.seeker;

final publicRoutes = ['/login', '/register'];

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // ignore: unused_local_variable
    final role = _resolveRole(); // Suppress unused warning while hooked up
    const isLoggedIn = false; // TODO: T-07 replace with real auth
    if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
      return '/login';
    }
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: AppStrings.search),
              BottomNavigationBarItem(icon: Icon(Icons.work), label: AppStrings.applications),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: AppStrings.conversations),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
            ],
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const PlaceholderPage(title: AppStrings.home),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const PlaceholderPage(title: AppStrings.search),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/applications',
              builder: (context, state) => const PlaceholderPage(title: AppStrings.applications),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/conversations',
              builder: (context, state) => const PlaceholderPage(title: AppStrings.conversations),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const PlaceholderPage(title: AppStrings.profile),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PlaceholderPage(title: AppStrings.login),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const PlaceholderPage(title: AppStrings.register),
    ),
  ],
);
