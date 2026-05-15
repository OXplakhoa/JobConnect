import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_deps.dart';
import '../providers/role_selection_state.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref, UserRole role) async {
    ref.read(roleSelectionIsLoadingProvider.notifier).setLoading(true);

    final res = await ref.read(completeOnboardingUseCaseProvider).call(role);

    ref.read(roleSelectionIsLoadingProvider.notifier).setLoading(false);

    res.fold(
      (failure) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        // Router will handle navigation back to home when authProvider updates
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(roleSelectionRoleProvider);
    final isLoading = ref.watch(roleSelectionIsLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chào mừng bạn đến với JobConnect!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn muốn sử dụng ứng dụng với vai trò nào?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    title: 'Ứng viên',
                    icon: Icons.person_search,
                    isSelected: selectedRole == UserRole.seeker,
                    onTap: () => ref.read(roleSelectionRoleProvider.notifier).setRole(UserRole.seeker),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    title: 'Nhà tuyển dụng',
                    icon: Icons.business,
                    isSelected: selectedRole == UserRole.recruiter,
                    onTap: () => ref.read(roleSelectionRoleProvider.notifier).setRole(UserRole.recruiter),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: selectedRole == null || isLoading ? null : () => _submit(context, ref, selectedRole),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Hoàn tất'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
