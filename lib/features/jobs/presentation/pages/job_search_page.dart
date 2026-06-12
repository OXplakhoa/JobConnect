import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../../shared/presentation/widgets/status_chip.dart';
import '../../../recruiter/presentation/providers/job_categories_provider.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';
import '../providers/job_search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/job_card.dart';
import '../widgets/job_card_skeleton.dart';

class JobSearchPage extends ConsumerStatefulWidget {
  const JobSearchPage({super.key});

  @override
  ConsumerState<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends ConsumerState<JobSearchPage> {
  final _searchController = TextEditingController();
  JobFilter _activeFilter = const JobFilter();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && mounted) {
        _initialized = true;
        ref.read(jobSearchNotifierProvider.notifier).loadJobs(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchNotifierProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(context),
              if (_activeFilter.hasFilters) _buildActiveFilterChips(),
              _buildResultsHeader(state),
              Expanded(
                child: state.when(
                  data: (jobs) => _buildJobList(jobs),
                  loading: _buildSkeletonList,
                  error: (error, _) => _buildErrorState(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space3,
        AppSpacing.space4,
        AppSpacing.space2,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    // Input affordance: quiet surfaceVariant fill, no border
                    // (§5 — fields read as fills, cards read as bordered).
                    color: AppColors.surfaceVariantFor(
                      Theme.of(context).brightness,
                    ),
                    borderRadius: AppRadii.button,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref
                          .read(jobSearchNotifierProvider.notifier)
                          .updateSearchQuery(value);
                    },
                    decoration: const InputDecoration(
                      hintText: AppStrings.searchHint,
                      prefixIcon: Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              _HeaderIconButton(
                icon: Icons.tune_rounded,
                isActive: _activeFilter.hasFilters,
                onTap: _openFilterSheet,
              ),
              const SizedBox(width: AppSpacing.space2),
              _HeaderIconButton(
                icon: Icons.bookmark_border_rounded,
                onTap: () => context.push('/search/bookmarks'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space2,
        children: [
          ..._buildFilterChipList(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              AppStrings.clearAll,
              style: AppTextStyles.label.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChipList() {
    final chips = <Widget>[];

    // Resolve category ids to their human-readable names; fall back to the id
    // only if the categories haven't loaded yet.
    final categories = ref.watch(jobCategoriesProvider).valueOrNull ?? const [];
    for (final id in _activeFilter.categoryIds) {
      final matches = categories.where((c) => c.id == id);
      final name = matches.isEmpty ? id : matches.first.name;
      chips.add(
        _FilterChip(
          label: 'Ngành: $name',
          onRemove: () => _removeFilter(_activeFilter.copyWith(categoryIds: [])),
        ),
      );
    }

    for (final province in _activeFilter.provinces) {
      chips.add(
        _FilterChip(
          label: province,
          onRemove: () {
            final updated = _activeFilter.provinces.toList()..remove(province);
            _removeFilter(_activeFilter.copyWith(provinces: updated));
          },
        ),
      );
    }

    for (final type in _activeFilter.jobTypes) {
      final label = kJobTypeLabels[type] ?? type;
      chips.add(
        _FilterChip(
          label: label,
          onRemove: () {
            final updated = _activeFilter.jobTypes.toList()..remove(type);
            _removeFilter(_activeFilter.copyWith(jobTypes: updated));
          },
        ),
      );
    }

    if (_activeFilter.salaryRange != null) {
      chips.add(
        _FilterChip(
          label: _activeFilter.salaryRange!.label,
          onRemove: () => _removeFilter(_activeFilter.copyWith(salaryRange: null)),
        ),
      );
    }

    if (_activeFilter.isRemote != null) {
      chips.add(
        _FilterChip(
          label: 'Từ xa',
          onRemove: () => _removeFilter(_activeFilter.copyWith(isRemote: null)),
        ),
      );
    }

    return chips;
  }

  Widget _buildResultsHeader(AsyncValue<List<JobSearchResult>> state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space2,
        AppSpacing.space4,
        AppSpacing.space3,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: state.maybeWhen(
          data: (jobs) {
            if (jobs.isEmpty) return const SizedBox.shrink();
            return Text(
              '${jobs.length} ${AppStrings.jobResultsCount}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildJobList(List<JobSearchResult> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    final notifier = ref.read(jobSearchNotifierProvider.notifier);
    final showLoadMoreIndicator = notifier.isLoadingMore && jobs.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(jobSearchNotifierProvider.notifier).loadJobs(refresh: true);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notifier.hasMore &&
              notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            ref.read(jobSearchNotifierProvider.notifier).loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space8,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: jobs.length + (showLoadMoreIndicator ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == jobs.length) {
              return const _LoadMoreIndicator();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: JobCard(result: jobs[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.space4),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.space3),
          child: JobCardSkeleton(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: GlassSurface(
          borderRadius: AppRadii.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppStrings.noResults,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space2),
              if (_activeFilter.hasFilters) ...[
                PremiumButton(
                  label: AppStrings.clearFilters,
                  onPressed: _clearAllFilters,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: GlassSurface(
          borderRadius: AppRadii.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppStrings.loadMoreError,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              PremiumButton(
                label: AppStrings.retry,
                onPressed: () {
                  ref.read(jobSearchNotifierProvider.notifier).loadJobs(refresh: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<JobFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: FilterBottomSheet(initialFilter: _activeFilter),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _activeFilter = result;
      });
      ref.read(jobSearchNotifierProvider.notifier).applyFilters(_activeFilter);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilter = const JobFilter();
    });
    ref.read(jobSearchNotifierProvider.notifier).clearFilters();
  }

  void _removeFilter(JobFilter updated) {
    setState(() {
      _activeFilter = updated;
    });
    ref.read(jobSearchNotifierProvider.notifier).applyFilters(_activeFilter);
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: AppRadii.md,
      blurSigma: 12,
      padding: EdgeInsets.zero,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: isActive
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRemove,
        borderRadius: AppRadii.sm,
        child: StatusChip(
          label: label,
          tone: StatusChipTone.primary,
          icon: Icons.close_rounded,
        ),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}