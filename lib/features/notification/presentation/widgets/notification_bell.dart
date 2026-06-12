import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/notification_provider.dart';

/// Circular bell button for the home headers (seeker + recruiter).
///
/// Opens the notifications page and shows an unread dot in accent orange —
/// per the Light Minimal system the unread bell is one of the few places
/// orange is allowed to appear.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final hasUnread = (ref.watch(unreadCountProvider).valueOrNull ?? 0) > 0;
    final surfaceVariant = AppColors.surfaceVariantFor(brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/notifications'),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: size * 0.52,
                color: AppColors.inkFor(brightness),
              ),
            ),
            if (hasUnread)
              Positioned(
                top: size * 0.21,
                right: size * 0.24,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: surfaceVariant, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
