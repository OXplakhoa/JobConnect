import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/auth_state.dart';
import '../providers/auth_provider.dart';

class BannedPage extends ConsumerWidget {
  const BannedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final bannedUntil = auth is AuthAuthenticated ? auth.bannedUntil : null;

    final isPermanent = bannedUntil != null &&
        bannedUntil.year >= 2099;

    String countdownText;
    if (isPermanent) {
      countdownText = 'Vĩnh viễn';
    } else if (bannedUntil != null) {
      final remaining = bannedUntil.difference(DateTime.now());
      if (remaining.isNegative) {
        countdownText = 'Sắp hết hạn khóa';
      } else {
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;
        countdownText = days > 0
            ? '$days ngày $hours giờ'
            : hours > 0
                ? '$hours giờ $minutes phút'
                : '$minutes phút';
      }
    } else {
      countdownText = '';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.block_flipped,
                color: AppColors.error,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Tài khoản bị tạm khóa',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 12),
              Text(
                isPermanent
                    ? 'Tài khoản của bạn đã bị khóa vĩnh viễn bởi Quản trị viên.'
                    : 'Tài khoản của bạn đang bị tạm khóa. Vui lòng chờ hết thời gian khóa.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (!isPermanent) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Thời gian còn lại',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        countdownText,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                // Await sign-out before navigating: go('/login') fired before
                // the auth state flips to Unauthenticated would be bounced back
                // to /banned by the router guard — that was the "tap twice" bug.
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
