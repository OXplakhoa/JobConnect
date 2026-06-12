import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../shared/presentation/widgets/scroll_aware_bottom_nav_scaffold.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/recruiter_shell.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../constants/app_strings.dart';
import '../../features/auth/presentation/pages/banned_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/recruiter/presentation/pages/company_profile_page.dart';
import '../../features/recruiter/presentation/pages/edit_company_page.dart';
import '../../features/recruiter/presentation/pages/create_job_post_page.dart';
import '../../features/recruiter/presentation/pages/my_job_posts_page.dart';
import '../../features/recruiter/presentation/pages/edit_job_post_page.dart';
import '../../features/recruiter/presentation/pages/recruiter_home_page.dart';
import '../../features/recruiter/presentation/providers/company_provider.dart';
import '../../features/jobs/presentation/pages/job_feed_page.dart';
import '../../features/jobs/presentation/pages/job_search_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../features/jobs/presentation/pages/bookmarks_page.dart';
import '../../features/application/domain/entities/resume.dart';
import '../../features/application/presentation/pages/application_detail_page.dart';
import '../../features/application/presentation/pages/applicant_detail_page.dart';
import '../../features/application/presentation/pages/applicants_page.dart';
import '../../features/application/presentation/pages/apply_page.dart';
import '../../features/application/presentation/pages/my_applications_page.dart';
import '../../features/application/presentation/pages/resume_builder_page.dart';
import '../../features/application/presentation/pages/resume_preview_page.dart';
import '../../features/application/presentation/pages/resumes_page.dart';
import '../../features/application/presentation/pages/schedule_interview_page.dart';
import '../../features/ai_suggestion/domain/entities/ai_suggestion.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_user_detail_page.dart';
import '../../features/admin/presentation/pages/admin_reports_page.dart';
import '../../features/admin/presentation/pages/admin_report_detail_page.dart';
import '../../features/admin/presentation/pages/admin_profile_page.dart';
import 'user_role.dart';

part 'app_router.g.dart';

final publicRoutes = [
  '/login',
  '/register',
  '/forgot-password',
  '/onboarding',
  '/splash',
  '/banned',
];

@riverpod
GoRouter appRouter(Ref ref) {
  final listenable = ValueNotifier<bool>(false);
  ref.listen(authProvider, (_, __) => listenable.value = !listenable.value);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;
      final authState = ref.read(authProvider);
      if (authState is AuthInitial) return null;
      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (publicRoutes.contains(state.matchedLocation)) return null;
        return '/login';
      }
      if (authState is AuthAuthenticated) {
        // Ban check
        if (authState.isBanned) {
          if (state.matchedLocation == '/banned') return null;
          return '/banned';
        }
        if (!authState.isOnboardingComplete) return '/onboarding';
        if (publicRoutes.contains(state.matchedLocation)) {
          // Redirect to role-appropriate home
          return switch (authState.role) {
            UserRole.recruiter => '/recruiter/home',
            UserRole.admin => '/admin/dashboard',
            _ => '/',
          };
        }
        // Company guard for job post creation
        if (state.matchedLocation == '/recruiter/posts/new') {
          final companyAsync = ref.read(currentCompanyProvider);
          if (companyAsync.hasValue && companyAsync.valueOrNull == null) {
            return '/recruiter/company/edit?onboarding=true';
          }
        }
        return null;
      }
      return null;
    },
    routes: [
      // ─── Splash ────────────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      // ─── Banned ──────────────────────────────────────────────────────
      GoRoute(path: '/banned', builder: (context, state) => const BannedPage()),

      // ─── Seeker Shell ──────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScrollAwareBottomNavScaffold(
            currentIndex: navigationShell.currentIndex,
            body: navigationShell,
            bottomNavigationBar: _SeekerBottomNav(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const JobFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const JobSearchPage(),
                routes: [
                  GoRoute(
                    path: 'bookmarks',
                    builder: (context, state) => const BookmarksPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final aiSuggestion = state.extra as AiSuggestion?;
                      return JobDetailPage(
                        jobPostId: id,
                        aiSuggestion: aiSuggestion,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'apply',
                        builder: (context, state) =>
                            ApplyPage(jobId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/applications',
                builder: (context, state) => const MyApplicationsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ApplicationDetailPage(
                      applicationId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/conversations',
                builder: (context, state) => const ConversationsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ChatPage(
                      conversationId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Recruiter Shell ───────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RecruiterShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/home',
                builder: (context, state) => const RecruiterHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/posts',
                builder: (context, state) => const MyJobPostsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CreateJobPostPage(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EditJobPostPage(jobId: id);
                    },
                  ),
                  GoRoute(
                    path: ':id/applicants',
                    builder: (context, state) =>
                        ApplicantsPage(jobId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/conversations',
                builder: (context, state) => const ConversationsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ChatPage(
                      conversationId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recruiter/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Admin Shell ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                builder: (context, state) => const AdminUsersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/reports',
                builder: (context, state) => const AdminReportsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) => const AdminProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Admin push routes ─────────────────────────────────────────
      GoRoute(
        path: '/admin/users/:id',
        builder: (context, state) => AdminUserDetailPage(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin/reports/:id',
        builder: (context, state) => AdminReportDetailPage(
          reportId: state.pathParameters['id']!,
        ),
      ),

      // ─── Auth routes (outside shell) ─────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // ─── Seeker push routes ─────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),

      // ─── Recruiter push routes ──────────────────────────────────
      GoRoute(
        path: '/recruiter/company',
        builder: (context, state) => const CompanyProfilePage(),
      ),
      GoRoute(
        path: '/recruiter/company/edit',
        builder: (context, state) => const EditCompanyPage(),
      ),
      GoRoute(
        path: '/recruiter/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/resumes',
        builder: (context, state) => const ResumesPage(),
        routes: [
          GoRoute(
            path: 'builder',
            builder: (context, state) =>
                ResumeBuilderPage(initialResume: state.extra as Resume?),
          ),
          GoRoute(
            path: 'preview',
            builder: (context, state) {
              final resume = state.extra! as Resume;
              return ResumePreviewPage(
                resumePath: resume.fileUrl!,
                title: resume.title,
              );
            },
          ),
          GoRoute(
            path: 'preview-path',
            builder: (context, state) {
              final resumePath = state.extra! as String;
              return ResumePreviewPage(resumePath: resumePath);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/recruiter/applications/:id',
        builder: (context, state) =>
            ApplicantDetailPage(applicationId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'schedule',
            builder: (context, state) => ScheduleInterviewPage(
              applicationId: state.pathParameters['id']!,
              jobId: state.extra! as String,
            ),
          ),
        ],
      ),
      // Root-level chat route. Opening a conversation from a root-navigator page
      // (e.g. the applicant detail screen) must NOT push the shell-nested
      // /recruiter/conversations/:id route — re-mounting the StatefulShellRoute
      // duplicates its branch navigator GlobalKeys and crashes with a red
      // "Multiple widgets used the same GlobalKey" screen. This route renders
      // ChatPage directly on the root navigator instead.
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      // Root-level deep-link targets for notification taps. The notifications
      // page is itself a root-navigator route, so it hits the same crash as
      // /chat above if it pushes a shell-nested route (/applications/:id,
      // /recruiter/posts/:id/applicants, /search/:id). These render the same
      // destination pages directly on the root navigator instead.
      GoRoute(
        path: '/application/:id',
        builder: (context, state) => ApplicationDetailPage(
          applicationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/applicants/:jobId',
        builder: (context, state) =>
            ApplicantsPage(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) => JobDetailPage(
          jobPostId: state.pathParameters['id']!,
          aiSuggestion: state.extra as AiSuggestion?,
        ),
      ),
    ],
  );
}

// ─── Bottom nav with notification badge ───────────────────────────────────

class _SeekerBottomNav extends ConsumerWidget {
  const _SeekerBottomNav({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(conversationUnreadCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: AppStrings.home,
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_rounded),
          selectedIcon: Icon(Icons.search_off_rounded),
          label: AppStrings.search,
        ),
        const NavigationDestination(
          icon: Icon(Icons.work_outline_rounded),
          selectedIcon: Icon(Icons.work_rounded),
          label: 'Ứng tuyển',
        ),
        NavigationDestination(
          icon: _BadgedIcon(
            icon: Icons.chat_bubble_outline_rounded,
            hasBadge: unreadCount > 0,
          ),
          selectedIcon: const Icon(Icons.chat_bubble_rounded),
          label: AppStrings.conversations,
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.hasBadge});

  final IconData icon;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    if (!hasBadge) return Icon(icon);
    return Badge(
      smallSize: 8,
      backgroundColor: Colors.red,
      child: Icon(icon),
    );
  }
}
