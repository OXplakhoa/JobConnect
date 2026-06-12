import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/application_status_filter.dart';
import '../providers/application_provider.dart';
import '../widgets/application_status_chip.dart';

class MyApplicationsPage extends ConsumerStatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  ConsumerState<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends ConsumerState<MyApplicationsPage> {
  ApplicationStatusFilter _filter = ApplicationStatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(myApplicationsProvider(_filter));

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space3,
                  AppSpacing.space4,
                  AppSpacing.space2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.myApplications,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    GlassSurface(
                      borderRadius: AppRadii.md,
                      padding: EdgeInsets.zero,
                      blurSigma: 12,
                      child: IconButton(
                        onPressed: () => context.push('/resumes'),
                        icon: const Icon(Icons.description_outlined),
                        tooltip: AppStrings.resumeManager,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 56,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space2,
                  ),
                  scrollDirection: Axis.horizontal,
                  children: ApplicationStatusFilter.values
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.space2),
                          child: ChoiceChip(
                            label: Text(_labelFor(filter)),
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: applicationsAsync.when(
                  data: (applications) {
                    if (applications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          child: GlassSurface(
                            borderRadius: AppRadii.xl,
                            child: Text(
                              AppStrings.noApplications,
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(myApplicationsProvider(_filter)),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space4,
                          AppSpacing.space4,
                          AppSpacing.space4,
                          AppSpacing.space8,
                        ),
                        itemCount: applications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.space3),
                        itemBuilder: (context, index) {
                          final application = applications[index];
                          return _ApplicationCard(
                            application: application,
                            onTap: () => context.push('/applications/${application.id}'),
                            onWithdraw: application.canWithdraw
                                ? () => _confirmWithdraw(application)
                                : null,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space8),
                      child: GlassSurface(
                        borderRadius: AppRadii.xl,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              error.toString(),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmWithdraw(Application application) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.xl),
          title: const Text(AppStrings.withdrawConfirmTitle),
          content: const Text(AppStrings.withdrawConfirmMessage),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            // Destructive choice = red text; the safe action (Cancel) is the
            // bolder default per §6 / CLAUDE.md dialog rule.
            TextButton(
              onPressed: () => dialogContext.pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text(AppStrings.withdrawApplication),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(false),
              // Shrink from the theme's full-width default so the safe/destructive
              // pair sits inline instead of overflowing into a stacked bar.
              style: FilledButton.styleFrom(
                minimumSize: const Size(96, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .withdraw(seekerId: auth.userId, applicationId: application.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.applicationWithdrawn)),
      ),
    );
  }

  String _labelFor(ApplicationStatusFilter filter) => switch (filter) {
    ApplicationStatusFilter.all => AppStrings.all,
    ApplicationStatusFilter.pending => AppStrings.statusPending,
    ApplicationStatusFilter.reviewing => AppStrings.statusReviewing,
    ApplicationStatusFilter.interview => AppStrings.statusInterview,
    ApplicationStatusFilter.rejected => AppStrings.statusRejectedApplication,
    ApplicationStatusFilter.withdrawn => AppStrings.statusWithdrawn,
  };
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.onTap,
    this.onWithdraw,
  });

  final Application application;
  final VoidCallback onTap;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.xl,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadii.xl,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CompanyLogo(
                    logoUrl: application.companyLogoUrl,
                    companyName: application.companyName,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: AppTextStyles.title.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.companyName,
                          style: AppTextStyles.body.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ApplicationStatusChip(status: application.status),
                      if (application.isJobPostClosed) ...[
                        const SizedBox(height: 6),
                        const _ClosedBadge(),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Text(
                DateFormat('dd/MM/yyyy · HH:mm').format(application.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (application.interviewSchedule != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadii.md,
                  ),
                  child: Text(
                    '${AppStrings.interviewSchedule}: ${DateFormat('dd/MM/yyyy · HH:mm').format(application.interviewSchedule!.scheduledAt)}${application.interviewSchedule!.location?.isNotEmpty == true ? ' · ${application.interviewSchedule!.location}' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              if (onWithdraw != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Align(
                  alignment: Alignment.centerRight,
                  child: PremiumButton(
                    label: AppStrings.withdrawApplication,
                    variant: PremiumButtonVariant.destructive,
                    expand: false,
                    icon: const Icon(Icons.undo_rounded),
                    onPressed: onWithdraw,
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

class _ClosedBadge extends StatelessWidget {
  const _ClosedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.14),
        borderRadius: AppRadii.sm,
      ),
      child: Text(
        AppStrings.jobPostClosed,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.logoUrl, required this.companyName});

  final String? logoUrl;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(companyName.isEmpty ? '?' : companyName[0].toUpperCase()),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(StorageUtils.publicUrl(logoUrl!)),
    );
  }
}