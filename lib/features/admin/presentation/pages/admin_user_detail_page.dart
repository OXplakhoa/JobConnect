import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/admin_users_provider.dart';

class AdminUserDetailPage extends ConsumerWidget {
  const AdminUserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: usersAsync.when(
        data: (users) {
          final user = users.firstWhere(
            (u) => u['id'] == userId,
            orElse: () => <String, dynamic>{},
          );
          if (user.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy người dùng',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _UserDetailContent(user: user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Lỗi: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _UserDetailContent extends ConsumerWidget {
  const _UserDetailContent({required this.user});

  final Map<String, dynamic> user;

  Future<void> _showBanDialog(
    BuildContext context,
    WidgetRef ref, {
    bool permanent = false,
  }) async {
    if (permanent) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Xóa tài khoản?'),
          content: Text(
            'Tài khoản ${user['full_name'] ?? 'này'} sẽ bị khóa vĩnh viễn (xóa mềm). Bạn có chắc?',
          ),
          // §6: destructive choice = red text; the safe action (Hủy) is the
          // bolder default — never a filled red button.
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Xóa'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final repo = ref.read(adminRepositoryProvider);
      await repo.banUser(
        userId: user['id'] as String,
        bannedUntil: DateTime(2099, 12, 31),
      );
    } else {
      final hours = await showDialog<int>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tạm khóa'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DurationOption(label: '1 giờ', hours: 1),
              _DurationOption(label: '24 giờ', hours: 24),
              _DurationOption(label: '7 ngày', hours: 168),
            ],
          ),
        ),
      );
      if (hours == null) return;

      final repo = ref.read(adminRepositoryProvider);
      await repo.banUser(
        userId: user['id'] as String,
        bannedUntil: DateTime.now().add(Duration(hours: hours)),
      );
    }

    if (context.mounted) {
      ref.invalidate(adminUsersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái người dùng')),
      );
    }
  }

  Future<void> _sendWarning(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cảnh cáo'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nội dung cảnh cáo...',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
    if (message == null || message.isEmpty) return;

    final repo = ref.read(adminRepositoryProvider);
    await repo.sendWarning(user['id'] as String, message);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gửi cảnh cáo')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = user['role'] as String? ?? 'seeker';
    final bannedUntil = user['banned_until'] != null
        ? DateTime.tryParse(user['banned_until'].toString())
        : null;
    final isBanned =
        bannedUntil != null && DateTime.now().isBefore(bannedUntil);
    final isPermanent = isBanned && bannedUntil.year >= 2099;

    final createdAt = user['created_at'] != null
        ? DateTime.tryParse(user['created_at'].toString())
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: user['avatar_url'] != null
                  ? CachedNetworkImageProvider(user['avatar_url'] as String)
                  : null,
              backgroundColor: AppColors.surfaceVariant,
              child: user['avatar_url'] == null
                  ? const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user['full_name'] ?? 'Không tên',
            textAlign: TextAlign.center,
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: 4),
          Text(
            user['email'] ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Chip(
                label: Text(switch (role) {
                  'admin' => 'Admin',
                  'recruiter' => 'Nhà tuyển dụng',
                  _ => 'Người kiếm việc',
                }),
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              if (isBanned)
                Chip(
                  label: Text(isPermanent ? 'Đã xóa' : 'Tạm khóa'),
                  backgroundColor: AppColors.error.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tham gia: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Divider(color: AppColors.outline),
          const SizedBox(height: 16),
          const Text('Hành động', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.warning_amber,
            label: 'Cảnh cáo',
            onTap: () => _sendWarning(context, ref),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.timer_off,
            label: 'Tạm khóa',
            destructive: true,
            onTap: () => _showBanDialog(context, ref),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.delete_forever,
            label: 'Xóa tài khoản',
            destructive: true,
            onTap: () => _showBanDialog(context, ref, permanent: true),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.switch_account,
            label: 'Thay đổi vai trò',
            onTap: () async {
              final currentRole = user['role'] as String? ?? 'seeker';
              final newRole = await showDialog<String>(
                context: context,
                builder: (_) => _RoleChangeDialog(currentRole: currentRole),
              );
              if (newRole == null || newRole == currentRole) return;

              final repo = ref.read(adminRepositoryProvider);
              final result = await repo.changeUserRole(
                userId: user['id'] as String,
                role: newRole,
              );
              if (!context.mounted) return;

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message)));
                },
                (_) {
                  ref.invalidate(adminUsersProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã đổi vai trò thành ${switch (newRole) {
                          'admin' => 'Quản trị viên',
                          'recruiter' => 'Nhà tuyển dụng',
                          _ => 'Người kiếm việc',
                        }}',
                      ),
                    ),
                  );
                  context.pop();
                },
              );
            },
          ),
          if (isBanned)
            _ActionButton(
              icon: Icons.lock_open,
              label: 'Mở khóa',
              onTap: () async {
                final repo = ref.read(adminRepositoryProvider);
                await repo.banUser(
                  userId: user['id'] as String,
                  bannedUntil: DateTime(2000, 1, 1),
                );
                if (context.mounted) {
                  ref.invalidate(adminUsersProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã mở khóa người dùng')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Admin action row (§6, utility tier): a quiet hairline-bordered row where
/// the color lives in the text/icon, never the fill. Destructive actions are
/// red text; everything else is neutral ink.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = destructive
        ? AppColors.errorFor(brightness)
        : AppColors.inkFor(brightness);
    final iconColor = destructive ? fg : AppColors.gray600For(brightness);

    return Material(
      color: AppColors.surfaceFor(brightness),
      borderRadius: AppRadii.button,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadii.button,
            border: Border.all(color: AppColors.hairlineFor(brightness)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.label.copyWith(color: fg)),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.gray400For(brightness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({required this.label, required this.hours});

  final String label;
  final int hours;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () => Navigator.pop(context, hours),
    );
  }
}

class _RoleChangeDialog extends StatefulWidget {
  const _RoleChangeDialog({required this.currentRole});

  final String currentRole;

  @override
  State<_RoleChangeDialog> createState() => _RoleChangeDialogState();
}

class _RoleChangeDialogState extends State<_RoleChangeDialog> {
  late String _selected = widget.currentRole;

  final _roles = [
    ('seeker', 'Người kiếm việc', Icons.person_search),
    ('recruiter', 'Nhà tuyển dụng', Icons.business),
    ('admin', 'Quản trị viên', Icons.admin_panel_settings),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Thay đổi vai trò'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _roles.map((r) {
          final isSelected = _selected == r.$1;
          return ListTile(
            leading: Icon(
              r.$3,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            title: Text(r.$2),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : null,
            onTap: () => setState(() => _selected = r.$1),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
