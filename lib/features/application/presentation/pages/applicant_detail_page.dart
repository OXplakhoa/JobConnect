import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/application_provider.dart';
import '../widgets/application_status_chip.dart';

class ApplicantDetailPage extends ConsumerStatefulWidget {
  const ApplicantDetailPage({super.key, required this.applicationId});

  final String applicationId;

  @override
  ConsumerState<ApplicantDetailPage> createState() =>
      _ApplicantDetailPageState();
}

class _ApplicantDetailPageState extends ConsumerState<ApplicantDetailPage> {
  final _noteController = TextEditingController();
  bool _didInitNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      applicantDetailProvider(widget.applicationId),
    );
    final actionState = ref.watch(applicationActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.applicantDetail),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        data: (application) {
          if (application == null) {
            return const Center(child: Text(AppStrings.noApplicants));
          }
          if (!_didInitNote) {
            _didInitNote = true;
            _noteController.text = application.internalNote ?? '';
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.seekerName,
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (application.seekerHeadline?.isNotEmpty ==
                                  true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    application.seekerHeadline!,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                '${application.jobTitle} · ${DateFormat('dd/MM/yyyy').format(application.createdAt)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ApplicationStatusChip(status: application.status),
                      ],
                    ),
                    if (application.resumeUrl?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/resumes/preview-path',
                          extra: application.resumeUrl!,
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text(AppStrings.viewResume),
                      ),
                    ],
                  ],
                ),
              ),
              if (application.coverLetter?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.coverLetter,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        application.coverLetter!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.internalNote,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: AppStrings.internalNoteHint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: actionState.isLoading
                            ? null
                            : () => _saveNote(
                                application.id,
                                application.status,
                                application.jobId,
                              ),
                        child: const Text(AppStrings.saveNote),
                      ),
                    ),
                  ],
                ),
              ),
              if (application.interviewSchedule != null) ...[
                const SizedBox(height: 16),
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.interviewSchedule,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy · HH:mm',
                        ).format(application.interviewSchedule!.scheduledAt),
                      ),
                      if (application.interviewSchedule!.location?.isNotEmpty ==
                          true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(application.interviewSchedule!.location!),
                        ),
                      if (application.interviewSchedule!.note?.isNotEmpty ==
                          true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(application.interviewSchedule!.note!),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Action hierarchy (§6): the forward move (Shortlist → Invite)
              // is the single bold primary; Chat is the quiet secondary; Reject
              // is destructive red text — never a competing filled button.
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  PremiumButton(
                    label: AppStrings.chat,
                    variant: PremiumButtonVariant.secondary,
                    expand: false,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    isLoading: actionState.isLoading,
                    onPressed: actionState.isLoading
                        ? null
                        : () async {
                            final result = await ref
                                .read(chatActionNotifierProvider.notifier)
                                .getOrCreateConversation(
                                  seekerId: application.seekerId,
                                  jobId: application.jobId,
                                );
                            if (!context.mounted) return;
                            result.fold(
                              (failure) => ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              ),
                              (conversation) => context.push(
                                '/chat/${conversation.id}',
                                extra: conversation,
                              ),
                            );
                          },
                  ),
                  if (application.canShortlist)
                    PremiumButton(
                      label: AppStrings.shortlist,
                      expand: false,
                      onPressed: actionState.isLoading
                          ? null
                          : () => _updateStatus(
                              application.id,
                              'reviewing',
                              application.jobId,
                              AppStrings.statusReviewing,
                            ),
                    ),
                  if (application.canInvite)
                    PremiumButton(
                      label: AppStrings.invite,
                      expand: false,
                      onPressed: actionState.isLoading
                          ? null
                          : () => context.push(
                              '/recruiter/applications/${application.id}/schedule',
                              extra: application.jobId,
                            ),
                    ),
                  if (application.canHire)
                    PremiumButton(
                      label: AppStrings.hire,
                      expand: false,
                      onPressed: actionState.isLoading
                          ? null
                          : () => _updateStatus(
                              application.id,
                              'accepted',
                              application.jobId,
                              AppStrings.statusAccepted,
                            ),
                    ),
                  if (application.canReject)
                    PremiumButton(
                      label: AppStrings.reject,
                      variant: PremiumButtonVariant.destructive,
                      expand: false,
                      onPressed: actionState.isLoading
                          ? null
                          : () => _updateStatus(
                              application.id,
                              'rejected',
                              application.jobId,
                              AppStrings.statusRejectedApplication,
                            ),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  Future<void> _saveNote(
    String applicationId,
    String status,
    String jobId,
  ) async {
    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .updateWithNote(
          applicationId: applicationId,
          status: status,
          note: _noteController.text.trim(),
          jobId: jobId,
        );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.noteSaved))),
    );
  }

  Future<void> _updateStatus(
    String applicationId,
    String status,
    String jobId,
    String successText,
  ) async {
    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .updateWithNote(
          applicationId: applicationId,
          status: status,
          note: _noteController.text.trim(),
          jobId: jobId,
        );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successText))),
    );
  }
}
