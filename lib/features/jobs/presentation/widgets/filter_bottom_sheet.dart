import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/vietnam_provinces.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../recruiter/presentation/providers/job_categories_provider.dart';
import '../../domain/entities/job_filter.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key, required this.initialFilter});

  final JobFilter initialFilter;

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late List<String> _selectedCategoryIds;
  late List<String> _selectedProvinces;
  late List<String> _selectedJobTypes;
  SalaryRange? _selectedSalaryRange;
  late bool _isRemote;
  bool _remoteToggled = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List.from(widget.initialFilter.categoryIds);
    _selectedProvinces = List.from(widget.initialFilter.provinces);
    _selectedJobTypes = List.from(widget.initialFilter.jobTypes);
    _selectedSalaryRange = widget.initialFilter.salaryRange;
    _isRemote = widget.initialFilter.isRemote ?? false;
    _remoteToggled = widget.initialFilter.isRemote != null;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return Material(
      color: Theme.of(context).bottomSheetTheme.backgroundColor,
      borderRadius: AppRadii.sheet,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space3,
          AppSpacing.space4,
          AppSpacing.space6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ lọc',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            const _SectionTitle(title: 'Ngành nghề'),
            categoriesAsync.when(
              data: (categories) => _MultiSelectChips(
                options: categories
                    .map((c) => _Option(label: c.name, value: c.id))
                    .toList(),
                selectedValues: _selectedCategoryIds,
                onToggle: _toggleCategory,
              ),
              loading: () => const _LoadingChips(count: 5),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.space4),
            const _SectionTitle(title: 'Tỉnh / Thành phố'),
            _MultiSelectChips(
              options: VietnamProvinces.all
                  .map((p) => _Option(label: p, value: p))
                  .toList(),
              selectedValues: _selectedProvinces,
              onToggle: _toggleProvince,
            ),
            const SizedBox(height: AppSpacing.space4),
            const _SectionTitle(title: 'Loại hình'),
            _MultiSelectChips(
              options: kJobTypeLabels.entries
                  .map((e) => _Option(label: e.value, value: e.key))
                  .toList(),
              selectedValues: _selectedJobTypes,
              onToggle: _toggleJobType,
            ),
            const SizedBox(height: AppSpacing.space4),
            const _SectionTitle(title: 'Mức lương'),
            _SingleSelectChips(
              options: kSalaryRanges
                  .map((r) => _Option(label: r.label, value: r.label))
                  .toList(),
              selectedValue: _selectedSalaryRange?.label,
              onTap: _toggleSalaryRange,
            ),
            const SizedBox(height: AppSpacing.space4),
            const _SectionTitle(title: 'Làm việc từ xa'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isRemote ? 'Chỉ tìm việc từ xa' : 'Tất cả địa điểm',
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              value: _isRemote,
              onChanged: (value) {
                setState(() {
                  _isRemote = value;
                  _remoteToggled = true;
                });
              },
            ),
            const SizedBox(height: AppSpacing.space5),
            PremiumButton(label: 'Áp dụng bộ lọc', onPressed: _applyFilters),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleProvince(String province) {
    setState(() {
      if (_selectedProvinces.contains(province)) {
        _selectedProvinces.remove(province);
      } else {
        _selectedProvinces.add(province);
      }
    });
  }

  void _toggleJobType(String type) {
    setState(() {
      if (_selectedJobTypes.contains(type)) {
        _selectedJobTypes.remove(type);
      } else {
        _selectedJobTypes.add(type);
      }
    });
  }

  void _toggleSalaryRange(String label) {
    setState(() {
      if (_selectedSalaryRange?.label == label) {
        _selectedSalaryRange = null;
      } else {
        _selectedSalaryRange = kSalaryRanges.firstWhere(
          (r) => r.label == label,
        );
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedProvinces.clear();
      _selectedJobTypes.clear();
      _selectedSalaryRange = null;
      _isRemote = false;
      _remoteToggled = false;
    });
  }

  void _applyFilters() {
    final filter = JobFilter(
      categoryIds: List.unmodifiable(_selectedCategoryIds),
      provinces: List.unmodifiable(_selectedProvinces),
      jobTypes: List.unmodifiable(_selectedJobTypes),
      salaryRange: _selectedSalaryRange,
      isRemote: _remoteToggled ? _isRemote : null,
    );
    Navigator.pop(context, filter);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Text(
        title,
        style: AppTextStyles.title.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _Option {
  const _Option({required this.label, required this.value});

  final String label;
  final String value;
}

class _MultiSelectChips extends StatelessWidget {
  const _MultiSelectChips({
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final List<_Option> options;
  final List<String> selectedValues;
  final void Function(String value) onToggle;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        return FilterChip(
          label: Text(
            option.label,
            style: TextStyle(
              color: isSelected ? Colors.white : onSurfaceColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onToggle(option.value),

          // them thuoc tinh mau sac
          selectedColor: primaryColor,
          checkmarkColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        );
      }).toList(),
    );
  }
}

class _SingleSelectChips extends StatelessWidget {
  const _SingleSelectChips({
    required this.options,
    required this.selectedValue,
    required this.onTap,
  });

  final List<_Option> options;
  final String? selectedValue;
  final void Function(String value) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onTap(option.value),
        );
      }).toList(),
    );
  }
}

class _LoadingChips extends StatelessWidget {
  const _LoadingChips({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: List.generate(
        count,
        (_) => const AppSkeleton(width: 84, height: 32),
      ),
    );
  }
}
