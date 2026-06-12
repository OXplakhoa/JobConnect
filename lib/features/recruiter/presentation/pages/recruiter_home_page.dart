import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';

import '../../domain/entities/recruiter_stats.dart';
import '../../presentation/providers/company_provider.dart';
import '../../presentation/providers/recruiter_stats_provider.dart';

class RecruiterHomePage extends ConsumerWidget {
  const RecruiterHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final companyAsync = ref.watch(currentCompanyProvider);
    final statsAsync = ref.watch(recruiterStatsProvider);
    final unreadAsync = ref.watch(conversationUnreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

    final name = auth is AuthAuthenticated
        ? (companyAsync.valueOrNull?.name ?? 'Recruiter')
        : 'Recruiter';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào,',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: AppTextStyles.headline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const NotificationBell(),
                          const SizedBox(width: 12),
                          if (companyAsync.valueOrNull?.logoUrl != null)
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: CachedNetworkImageProvider(
                                companyAsync.valueOrNull!.logoUrl!,
                              ),
                            )
                          else
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.business,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick actions
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.add,
                              label: 'Đăng tin mới',
                              onTap: () => context.push('/recruiter/posts/new'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.chat_bubble_outline,
                              label: 'Xem tin nhắn',
                              badge: unreadCount > 0 ? unreadCount.toString() : null,
                              onTap: () => context.go('/recruiter/conversations'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats
                      statsAsync.when(
                        data: (stats) => Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Tin đang tuyển',
                                value: stats.activePosts,
                                icon: Icons.article_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Only the stat that needs attention is orange
                            // (§ one-color rule); the rest stay ink/gray.
                            Expanded(
                              child: _StatCard(
                                label: 'Ứng viên mới',
                                value: stats.pendingApplications,
                                icon: Icons.people_outline,
                                highlight: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'Phỏng vấn',
                                value: stats.upcomingInterviews,
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const Row(
                          children: [
                            Expanded(child: _StatSkeleton()),
                            SizedBox(width: 10),
                            Expanded(child: _StatSkeleton()),
                            SizedBox(width: 10),
                            Expanded(child: _StatSkeleton()),
                          ],
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 28),
                      // Recent applicants
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ứng viên gần đây',
                              style: AppTextStyles.sectionTitle),
                          TextButton(
                            onPressed: () => context.go('/recruiter/posts'),
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              // Recent applicants list
              statsAsync.when(
                data: (stats) {
                  final applicants = stats.recentApplicants;
                  if (applicants.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Chưa có ứng viên mới',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: applicants.length,
                    itemBuilder: (context, index) {
                      final a = applicants[index];
                      return _ApplicantTile(
                        applicant: a,
                        onTap: () => context.push(
                          '/recruiter/applications/${a.id}',
                          extra: a.jobId,
                        ),
                      );
                    },
                  );
                },
                loading: () => SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (_, __) => const _ApplicantSkeleton(),
                ),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              // Active posts
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tin tuyển dụng', style: AppTextStyles.sectionTitle),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              statsAsync.when(
                data: (stats) {
                  final posts = stats.activeJobPosts;
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Chưa có tin tuyển dụng nào',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final p = posts[index];
                      return _JobPostTile(
                        post: p,
                        onTap: () => context.push(
                          '/recruiter/posts/${p.id}/applicants',
                        ),
                      );
                    },
                  );
                },
                loading: () => SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (_, __) => const _JobPostSkeleton(),
                ),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badge != null
                ? Badge(
                    label: Text(badge!),
                    child: Icon(icon, color: AppColors.primary),
                  )
                : Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final accent = highlight ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(height: 10),
          // Stat figures are a Lora moment — quiet display serif (§ typography).
          // The attention stat tints its number orange; the rest stay ink.
          Text(
            value.toString(),
            style: AppTextStyles.display.copyWith(
              fontSize: 26,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({required this.applicant, required this.onTap});

  final RecentApplicant applicant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final createdAt = applicant.createdAt;
    final avatarUrl = applicant.avatarUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 20, color: AppColors.textSecondary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant.fullName,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    applicant.jobTitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (createdAt != null)
              Text(
                DateFormat('dd/MM').format(createdAt),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantSkeleton extends StatelessWidget {
  const _ApplicantSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _JobPostTile extends StatelessWidget {
  const _JobPostTile({required this.post, required this.onTap});

  final ActiveJobPostSummary post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final applicantCount = post.applicantCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title.isEmpty ? 'Tin tuyển dụng' : post.title,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        '$applicantCount ứng viên',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _JobPostSkeleton extends StatelessWidget {
  const _JobPostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
