import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ai_suggestion/presentation/providers/ai_suggestion_provider.dart';
import '../../domain/entities/job_post.dart';
import '../providers/job_post_provider.dart';
import '../widgets/job_post_card.dart';

/// Page displaying all job posts for the current company.
/// Organized into 3 tabs: Draft, Active, Closed.
class MyJobPostsPage extends ConsumerStatefulWidget {
  const MyJobPostsPage({super.key});

  @override
  ConsumerState<MyJobPostsPage> createState() => _MyJobPostsPageState();
}

class _MyJobPostsPageState extends ConsumerState<MyJobPostsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobPostsAsync = ref.watch(myJobPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.myJobPostsTitle,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: AppStrings.tabDraft),
            Tab(text: AppStrings.tabActive),
            Tab(text: AppStrings.tabClosed),
          ],
        ),
      ),
      body: jobPostsAsync.when(
        data: (jobPosts) => _buildTabViews(jobPosts),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Lỗi: ${error.toString()}',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(myJobPostsProvider),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recruiter/posts/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildTabViews(List<JobPost> jobPosts) {
    final draftPosts = jobPosts.where((p) => p.status == 'draft').toList();
    final activePosts = jobPosts.where((p) => p.status == 'active').toList();
    final closedPosts = jobPosts
        .where((p) => p.status == 'closed' || p.status == 'rejected')
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildJobPostList(
          posts: draftPosts,
          emptyMessage: AppStrings.emptyDraft,
          showDiscard: true,
          showPublish: true,
        ),
        _buildJobPostList(
          posts: activePosts,
          emptyMessage: AppStrings.emptyActive,
          showClose: true,
        ),
        _buildJobPostList(
          posts: closedPosts,
          emptyMessage: AppStrings.emptyClosed,
          showResubmitForRejected: true,
        ),
      ],
    );
  }

  Widget _buildJobPostList({
    required List<JobPost> posts,
    required String emptyMessage,
    bool showDiscard = false,
    bool showPublish = false,
    bool showClose = false,
    bool showResubmitForRejected = false,
  }) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myJobPostsProvider);
        // Wait for the provider to refresh
        await ref.read(myJobPostsProvider.future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final jobPost = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: JobPostCard(
              jobPost: jobPost,
              onEdit: jobPost.isEditable
                  ? () => _navigateToEdit(jobPost.id)
                  : null,
              onPublish: showPublish && jobPost.canPublish
                  ? () => _confirmPublish(jobPost)
                  : null,
              onClose: showClose && jobPost.canClose
                  ? () => _confirmClose(jobPost)
                  : null,
              onDiscard: showDiscard ? () => _confirmDiscard(jobPost) : null,
              onResubmit:
                  showResubmitForRejected && jobPost.status == 'rejected'
                  ? () => _confirmResubmit(jobPost)
                  : null,
              onViewApplicants: jobPost.status == 'active'
                  ? () => context.push(
                      '/recruiter/posts/${jobPost.id}/applicants',
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _navigateToEdit(String jobId) {
    context.push('/recruiter/posts/$jobId/edit');
  }

  Future<void> _confirmPublish(JobPost jobPost) async {
    final confirmed = await _showConfirmDialog(
      title: AppStrings.publishConfirmTitle,
      message: AppStrings.publishConfirmMessage,
    );
    if (confirmed == true && mounted) {
      await _updateStatus(jobPost.id, 'active', AppStrings.jobPostPublished);
    }
  }

  Future<void> _confirmClose(JobPost jobPost) async {
    final confirmed = await _showConfirmDialog(
      title: AppStrings.closeConfirmTitle,
      message: AppStrings.closeConfirmMessage,
    );
    if (confirmed == true && mounted) {
      await _updateStatus(jobPost.id, 'closed', AppStrings.jobPostClosed);
    }
  }

  Future<void> _confirmDiscard(JobPost jobPost) async {
    final confirmed = await _showConfirmDialog(
      title: AppStrings.discardConfirmTitle,
      message: AppStrings.discardConfirmMessage,
    );
    if (confirmed == true && mounted) {
      await _updateStatus(jobPost.id, 'closed', AppStrings.jobPostDiscarded);
    }
  }

  Future<void> _confirmResubmit(JobPost jobPost) async {
    final confirmed = await _showConfirmDialog(
      title: AppStrings.resubmit,
      message: 'Tin sẽ được đăng lại và hiển thị cho ứng viên.',
    );
    if (confirmed == true && mounted) {
      await _updateStatus(jobPost.id, 'active', AppStrings.jobPostResubmitted);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: AlertDialog(
          title: Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                // The global theme stretches buttons full-width
                // (minimumSize.width == infinity); shrink to content so the
                // safe/confirm pair sits inline instead of overflowing into
                // a stacked full-width bar.
                minimumSize: const Size(96, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(AppStrings.confirm),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    String jobId,
    String newStatus,
    String successMessage,
  ) async {
    final result = await ref
        .read(jobPostNotifierProvider.notifier)
        .updateStatus(jobId, newStatus);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
        ref.invalidate(myJobPostsProvider);

        // T-24: Non-blocking job embedding generation on activation
        if (newStatus == 'active') {
          _triggerJobEmbedding(jobId);
        }
      },
    );
  }

  void _triggerJobEmbedding(String jobId) {
    // Fire-and-forget; do not block activation or show errors
    ref.read(aiEmbeddingNotifierProvider.notifier).rebuildJobEmbedding(jobId);
  }
}
