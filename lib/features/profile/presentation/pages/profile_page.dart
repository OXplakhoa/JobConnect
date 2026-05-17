import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/data/datasources/auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/profile_provider.dart';

/// Read-only profile view (shell tab at `/profile`).
///
/// Layout per plan Section 5:
/// Avatar → Full name → Headline → Location → Bio → Divider → Edit CTA → Logout
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profile,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => _ProfileContent(profile: profile),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: Text(
                  AppStrings.retry,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: _avatarImage(),
            child: _avatarImage() == null
                ? const Icon(
                    Icons.person,
                    size: 56,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Full name
          Text(
            profile.fullName,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Headline
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.headline!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Location
          if (profile.location != null && profile.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  profile.location!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                profile.bio!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          // Edit profile CTA (primary teal)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/profile/edit'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.editProfile,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout (secondary, NOT teal)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _handleLogout(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.logout,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  ImageProvider? _avatarImage() {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return NetworkImage(StorageUtils.publicUrl(profile.avatarUrl!));
    }
    return null;
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final logoutUseCase = LogoutUseCase(
      AuthRepositoryImpl(
        AuthDatasourceImpl(Supabase.instance.client),
      ),
    );
    await logoutUseCase.call();
    // Do NOT navigate — router guard handles redirect to /login
  }
}
