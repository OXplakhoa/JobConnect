import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/connection_loop_logo.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../../shared/presentation/widgets/spotlight_search_bar.dart';
import '../../../ai_suggestion/presentation/providers/ai_suggestion_provider.dart';
import '../../../ai_suggestion/presentation/widgets/for_you_feed.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/job_search_result.dart';
import '../providers/job_feed_provider.dart';
import '../widgets/ai_insight_placeholder_card.dart';
import '../widgets/featured_job_card.dart';
import '../widgets/job_card.dart';
import '../widgets/job_card_skeleton.dart';

class JobFeedPage extends ConsumerStatefulWidget {
  const JobFeedPage({super.key});

  @override
  ConsumerState<JobFeedPage> createState() => _JobFeedPageState();
}

enum _FeedTab { forYou, remote, internship, recent }

class _JobFeedPageState extends ConsumerState<JobFeedPage> {
  _FeedTab _selectedTab = _FeedTab.forYou;

  Future<void> _onRefresh() async {
    ref.invalidate(jobFeedProvider);
    final futures = <Future<void>>[ref.read(jobFeedProvider.future)];
    if (_selectedTab == _FeedTab.forYou) {
      ref.invalidate(aiSuggestionsProvider);
      futures.add(ref.read(aiSuggestionsProvider.future));
    }
    try {
      await Future.wait(futures);
    } catch (_) {
      // Errors surface through the AsyncValue states below.
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final jobsAsync = ref.watch(jobFeedProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          // Bouncing physics let the Cupertino refresh control overscroll on
          // both platforms — the branded loop spinner *is* the pull indicator
          // (§9 #4), so there is no stock Material blob/shadow to fight.
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 100,
                refreshIndicatorExtent: 64,
                onRefresh: _onRefresh,
                builder: (
                  context,
                  refreshState,
                  pulledExtent,
                  refreshTriggerPullDistance,
                  refreshIndicatorExtent,
                ) {
                  if (pulledExtent <= 0) return const SizedBox.shrink();
                  final opacity =
                      (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.space3),
                      child: Opacity(
                        opacity: opacity,
                        child: const ConnectionLoopSpinner(size: 32),
                      ),
                    ),
                  );
                },
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space3,
                  AppSpacing.space4,
                  AppSpacing.space8,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _FeedHeader(profileAsync: profileAsync),
                    const SizedBox(height: AppSpacing.space5),
                    SpotlightSearchBar(
                      hintText: 'Spotlight tìm việc, kỹ năng, công ty...',
                      onTap: () => context.go('/search'),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    _FeedTabs(
                      selectedTab: _selectedTab,
                      onTabChanged: (tab) =>
                          setState(() => _selectedTab = tab),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    jobsAsync.when(
                      data: (jobs) => _FeedContent(
                        allJobs: jobs,
                        selectedTab: _selectedTab,
                      ),
                      loading: () => const _FeedLoadingState(),
                      error: (error, _) => _FeedErrorState(
                        onRetry: () => ref.invalidate(jobFeedProvider),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.profileAsync});

  final AsyncValue<UserProfile> profileAsync;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final greetingName =
        profileAsync.valueOrNull?.fullName.split(' ').last ?? 'bạn';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            ConnectionLoopLogo(size: 36, animated: true),
            Spacer(),
            NotificationBell(),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          'Chào $greetingName,',
          style: AppTextStyles.displayHero.copyWith(
            fontFamily: AppTextStyles.lora,
            color: AppColors.inkFor(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          'Hôm nay có nhiều cơ hội đáng chú ý hơn cho hành trình nghề nghiệp của bạn.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.gray600For(brightness),
          ),
        ),
      ],
    );
  }
}

class _FeedTabs extends StatelessWidget {
  const _FeedTabs({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final _FeedTab selectedTab;
  final ValueChanged<_FeedTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FeedTabChip(
            label: 'Cho bạn',
            selected: selectedTab == _FeedTab.forYou,
            onTap: () => onTabChanged(_FeedTab.forYou),
          ),
          _FeedTabChip(
            label: 'Remote',
            selected: selectedTab == _FeedTab.remote,
            onTap: () => onTabChanged(_FeedTab.remote),
          ),
          _FeedTabChip(
            label: 'Intern',
            selected: selectedTab == _FeedTab.internship,
            onTap: () => onTabChanged(_FeedTab.internship),
          ),
          _FeedTabChip(
            label: 'Mới đăng',
            selected: selectedTab == _FeedTab.recent,
            onTap: () => onTabChanged(_FeedTab.recent),
          ),
        ],
      ),
    );
  }
}

class _FeedTabChip extends StatelessWidget {
  const _FeedTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.space2),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FeedContent extends StatelessWidget {
  const _FeedContent({
    required this.allJobs,
    required this.selectedTab,
  });

  final List<JobSearchResult> allJobs;
  final _FeedTab selectedTab;

  @override
  Widget build(BuildContext context) {
    if (_isAiTab) {
      return const ForYouFeed();
    }

    final jobs = _filterJobs();
    if (jobs.isEmpty) {
      return _FeedEmptyState(selectedTab: selectedTab);
    }

    final featured = jobs.first;
    final rest = jobs.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeaturedJobCard(result: featured),
        const SizedBox(height: AppSpacing.space4),
        AiInsightPlaceholderCard(
          jobCount: jobs.length,
          onPressed: () => context.go('/search'),
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          'Feed tuyển dụng',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          'Lướt nhanh, lưu gọn, apply khi đúng nhịp.',
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        ...List.generate(rest.length, (index) {
          final job = rest[index];
          return _StaggeredFadeIn(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
              child: JobCard(result: job),
            ),
          );
        }),
      ],
    );
  }

  List<JobSearchResult> _filterJobs() {
    final jobs = List<JobSearchResult>.from(allJobs);
    return switch (selectedTab) {
      _FeedTab.forYou => jobs,
      _FeedTab.remote => jobs.where((job) => job.location.isRemote).toList(),
      _FeedTab.internship => jobs
          .where((job) => job.jobPost.type == 'internship')
          .toList(),
      _FeedTab.recent => jobs
        ..sort((a, b) => b.jobPost.createdAt.compareTo(a.jobPost.createdAt)),
    };
  }

  bool get _isAiTab => selectedTab == _FeedTab.forYou;
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        JobCardSkeleton(isFeatured: true),
        SizedBox(height: AppSpacing.space4),
        JobCardSkeleton(),
        SizedBox(height: AppSpacing.space4),
        JobCardSkeleton(),
      ],
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  const _FeedErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: AppRadii.xl,
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Không tải được feed lúc này',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Hãy thử lại để tiếp tục khám phá cơ hội mới.',
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space4),
          PremiumButton(label: 'Tải lại feed', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({required this.selectedTab});

  final _FeedTab selectedTab;

  @override
  Widget build(BuildContext context) {
    final label = switch (selectedTab) {
      _FeedTab.forYou => 'phù hợp',
      _FeedTab.remote => 'remote',
      _FeedTab.internship => 'intern',
      _FeedTab.recent => 'mới đăng',
    };

    return GlassSurface(
      borderRadius: AppRadii.xl,
      child: Column(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 44, color: AppColors.primary),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Chưa có job $label',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Thử chuyển tab hoặc khám phá đầy đủ trong màn hình tìm việc.',
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space4),
          PremiumButton(
            label: 'Mở tìm việc',
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
    );
  }
}
/// First-load stagger (§9): each feed card fades and slides up by a
/// 30ms-per-index delay. Skipped under reduced motion.
class _StaggeredFadeIn extends StatelessWidget {
  const _StaggeredFadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reducedMotion) return child;

    final delayMs = (index * AppDurations.stagger.inMilliseconds)
        .clamp(0, 300)
        .toInt();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + delayMs),
      curve: AppDurations.easing,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
