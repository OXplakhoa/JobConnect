import 'package:flutter/material.dart' hide Notification;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final Notification notification;
  final VoidCallback onTap;

  /// AI-sourced notifications (job matches, suggestions) earn the one
  /// recognised accent treatment — ✦ glyph on an accent-soft bubble (§9).
  bool get _isAi => switch (notification.type) {
        'ai_suggestion' || 'ai_match' || 'ai' => true,
        _ => false,
      };

  IconData _iconForType(String type) => switch (type) {
        'application_status' => Icons.assignment_outlined,
        'new_applicant' => Icons.person_add_outlined,
        'job_alert' => Icons.notifications_active_outlined,
        'interview' => Icons.event_available_outlined,
        'message' => Icons.chat_bubble_outline_rounded,
        'warning' => Icons.warning_amber_rounded,
        'system' => Icons.info_outline_rounded,
        'ai_suggestion' || 'ai_match' || 'ai' => Icons.auto_awesome,
        _ => Icons.notifications_outlined,
      };

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} tuần trước';
    return '${diff.inDays ~/ 30} tháng trước';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.read;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.surface : AppColors.background,
          border: Border(
            bottom: BorderSide(color: AppColors.divider.withAlpha(50)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiet type icon — one-color system (§1): gray icon on a
            // surfaceVariant bubble; orange is reserved for the unread dot.
            // The single exception: AI notifications get ✦ on accent-soft.
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isAi ? AppColors.accentSoft : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(
                  AppConstants.cardBorderRadius,
                ),
              ),
              child: Icon(
                _iconForType(notification.type),
                color: _isAi ? AppColors.accent : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null && notification.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
