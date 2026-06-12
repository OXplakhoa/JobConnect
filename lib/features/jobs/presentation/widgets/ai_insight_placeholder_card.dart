import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../ai_suggestion/domain/entities/ai_embedding_result.dart';
import '../../../ai_suggestion/presentation/providers/ai_suggestion_provider.dart';

class AiInsightPlaceholderCard extends ConsumerWidget {
  const AiInsightPlaceholderCard({
    super.key,
    required this.jobCount,
    this.onPressed,
  });

  final int jobCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentSoftFor(brightness),
        borderRadius: AppRadii.xl,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  'AI Match',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.inkFor(brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Hiện có $jobCount cơ hội đang chờ bạn. JobConnect phân tích hồ sơ để gợi ý những việc làm phù hợp nhất và kỹ năng bạn nên bổ sung. Mở tab AI Match để xem điểm phù hợp cho từng tin.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray600For(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            PremiumButton(
              label: 'Khám phá feed',
              variant: PremiumButtonVariant.secondary,
              onPressed: onPressed,
            ),
            const SizedBox(height: AppSpacing.space3),
            _RefreshAiMatchButton(
              onResult: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshAiMatchButton extends ConsumerStatefulWidget {
  const _RefreshAiMatchButton({required this.onResult});

  final ValueChanged<String> onResult;

  @override
  ConsumerState<_RefreshAiMatchButton> createState() =>
      _RefreshAiMatchButtonState();
}

class _RefreshAiMatchButtonState
    extends ConsumerState<_RefreshAiMatchButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      label: AppStrings.aiMatchRefresh,
      variant: PremiumButtonVariant.secondary,
      isLoading: _isLoading,
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                final result = await ref
                    .read(aiEmbeddingNotifierProvider.notifier)
                    .rebuildProfileEmbedding();

                if (result == null) {
                  widget.onResult(AppStrings.aiMatchError);
                  return;
                }

                final message = switch (result.status) {
                  AiEmbeddingStatus.generated => AppStrings.aiMatchUpdated,
                  AiEmbeddingStatus.unchanged => AppStrings.aiMatchReady,
                  AiEmbeddingStatus.rateLimited =>
                    AppStrings.aiMatchRateLimited,
                  AiEmbeddingStatus.missingData =>
                    AppStrings.aiMatchMissingData,
                  AiEmbeddingStatus.noJobEmbeddings =>
                    AppStrings.aiMatchMissingData,
                  AiEmbeddingStatus.success => AppStrings.aiMatchUpdated,
                  AiEmbeddingStatus.error => result.message.isNotEmpty
                      ? result.message
                      : AppStrings.aiMatchError,
                };

                widget.onResult(message);
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
    );
  }
}
