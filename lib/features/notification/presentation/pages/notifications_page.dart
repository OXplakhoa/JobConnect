import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.notifications,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationListProvider.notifier).markAllRead(),
              child: Text(
                AppStrings.markAllRead,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(notificationListProvider.notifier).refresh(),
        child: notificationsAsync.when(
          data: (notifications) => _NotificationsList(
            notifications: notifications,
            onTap: (notification) => _handleTap(context, ref, notification),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => _EmptyState(
            icon: Icons.error_outline,
            title: AppStrings.errorGeneral,
            subtitle: error.toString(),
            onRetry: () => ref.invalidate(notificationListProvider),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, Notification notification) {
    // Mark as read
    if (!notification.read) {
      ref.read(notificationListProvider.notifier).markRead(notification.id);
    }

    // Navigate based on notification type
    final data = notification.dataJson;
    if (data == null) return;

    // This page is a root-navigator route, so it must push root-level routes —
    // pushing a shell-nested route (/applications/:id, /recruiter/posts/:id/...)
    // re-mounts the StatefulShellRoute and crashes on duplicate branch-navigator
    // GlobalKeys. See app_router.dart for the matching root-level deep-link routes.
    switch (notification.type) {
      case 'application_status':
      case 'interview':
        final applicationId = data['application_id'] as String?;
        if (applicationId != null) {
          context.push('/application/$applicationId');
        }
      case 'new_applicant':
        final jobId = data['job_id'] as String?;
        if (jobId != null) {
          context.push('/applicants/$jobId');
        }
      case 'message':
        final conversationId = data['conversation_id'] as String?;
        if (conversationId != null) {
          context.push('/chat/$conversationId');
        }
      case 'job_alert':
        final jobId = data['job_id'] as String?;
        if (jobId != null) {
          context.push('/job/$jobId');
        }
      default:
        break;
    }
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.notifications,
    required this.onTap,
  });

  final List<Notification> notifications;
  final void Function(Notification) onTap;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _EmptyState(
        icon: Icons.notifications_off_outlined,
        title: AppStrings.noNotifications,
        subtitle: AppStrings.noNotificationsSubtitle,
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () => onTap(notification),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    AppStrings.retry,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
