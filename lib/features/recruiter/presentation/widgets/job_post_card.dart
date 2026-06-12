import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/entities/job_post.dart';

/// Card widget for displaying a job post in the recruiter's list.
/// Shows title, status badge, created date, and action buttons.
class JobPostCard extends StatelessWidget {
  const JobPostCard({
    super.key,
    required this.jobPost,
    this.onEdit,
    this.onPublish,
    this.onClose,
    this.onDiscard,
    this.onResubmit,
    this.onViewApplicants,
    this.applicantCount,
  });

  final JobPost jobPost;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final VoidCallback? onDiscard;
  final VoidCallback? onResubmit;
  final VoidCallback? onViewApplicants;
  final int? applicantCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    jobPost.title,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),

            // Created date
            Text(
              _formatDate(jobPost.createdAt),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            // Applicant count (only for active posts)
            if (jobPost.status == 'active' && applicantCount != null) ...[
              const SizedBox(height: 4),
              Text(
                '$applicantCount ${AppStrings.applicants}',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],

            // Rejected banner
            if (jobPost.status == 'rejected') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppStrings.removedByAdmin,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // Action buttons
            if (_hasActions) ...[
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasActions {
    return onEdit != null ||
        onPublish != null ||
        onClose != null ||
        onDiscard != null ||
        onResubmit != null ||
        onViewApplicants != null;
  }

  Widget _buildStatusBadge() {
    final (label, color) = switch (jobPost.status) {
      'draft' => (AppStrings.statusDraft, AppColors.textSecondary),
      'active' => (AppStrings.statusActive, AppColors.success),
      'closed' => (AppStrings.statusClosed, AppColors.textSecondary),
      'rejected' => (AppStrings.statusRejected, AppColors.error),
      _ => (jobPost.status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Action hierarchy (§6): the forward move (Đăng lại/Đăng tin) is the single
  /// bold primary; coexisting actions (Sửa, Xem ứng viên, Đóng) are quiet
  /// secondaries; Xóa is destructive red text on its own line — never a
  /// competing filled or bordered button.
  ///
  /// The coexisting actions sit in a [Wrap] of content-sized buttons: they
  /// share one row when they fit and flow onto a second row when they don't,
  /// so long Vietnamese labels (e.g. "Xem ứng viên" in the active state's
  /// three-button row) never overflow a fixed equal-width slot.
  Widget _buildActions(BuildContext context) {
    final onPrimary = onPublish ?? onResubmit;
    final main = <Widget>[
      if (onEdit != null)
        PremiumButton(
          label: 'Sửa',
          variant: PremiumButtonVariant.secondary,
          expand: false,
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
      if (onViewApplicants != null)
        PremiumButton(
          label: AppStrings.viewApplicants,
          variant: PremiumButtonVariant.secondary,
          expand: false,
          icon: const Icon(Icons.people_outline),
          onPressed: onViewApplicants,
        ),
      if (onClose != null)
        PremiumButton(
          label: 'Đóng',
          variant: PremiumButtonVariant.secondary,
          expand: false,
          icon: const Icon(Icons.lock_outline),
          onPressed: onClose,
        ),
      if (onPrimary != null)
        PremiumButton(
          label: jobPost.status == 'rejected'
              ? AppStrings.resubmit
              : AppStrings.publish,
          expand: false,
          icon: const Icon(Icons.publish_outlined),
          onPressed: onPrimary,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (main.isNotEmpty)
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: main,
          ),
        if (onDiscard != null) ...[
          if (main.isNotEmpty) const SizedBox(height: AppSpacing.space2),
          PremiumButton(
            label: 'Xóa',
            variant: PremiumButtonVariant.destructive,
            expand: false,
            icon: const Icon(Icons.delete_outline),
            onPressed: onDiscard,
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
