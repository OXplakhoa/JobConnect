# T-11 + T-12: Work Experiences, Educations, Certificates & User Skills — Implementation Plan

All decisions locked via grill Q1–Q9.

---

## Prerequisites

- T-10 complete and committed (profile feature exists with datasource, repository, ProfilePage, EditProfilePage)
- CONTEXT.md updated with Work Experience, Education, Certificate entries ✅ (done during grill)

### CLAUDE.md Additions (do first)

```markdown
## Usecase Exception Rule
Usecases are REQUIRED when a business action involves:
- Multiple steps / orchestration (UploadAvatarUseCase)
- Cross-cutting concerns (auth state changes)
- Non-trivial business rules or validations
- Side effects beyond a single repository call

Usecases MAY BE SKIPPED when the action is pure CRUD:
- Single repository call, no transformation
- No business rules (validation is in Validators, not domain)
- Example: addWorkExperience, deleteEducation, updateCertificate
In these cases, providers call profileRepositoryProvider directly.

## Dialog Styling
Dialogs: always wrap AlertDialog in Theme override with
`backgroundColor: AppColors.surface` and `cardBorderRadius` for shape.
Never use default dialog styling.
```

---

## Section 1: File Structure

### T-11 Files (adds to `features/profile/`)

```
features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_datasource.dart     ← ADD: 9 CRUD methods (3 per table)
│   ├── models/
│   │   ├── work_experience_model.dart  ← NEW: Freezed + fromJson
│   │   ├── education_model.dart        ← NEW: Freezed + fromJson
│   │   └── certificate_model.dart      ← NEW: Freezed + fromJson
│   └── repositories/
│       └── profile_repository_impl.dart ← ADD: 9 methods
├── domain/
│   ├── entities/
│   │   ├── work_experience.dart        ← NEW
│   │   ├── education.dart              ← NEW
│   │   └── certificate.dart            ← NEW
│   └── repositories/
│       └── profile_repository.dart     ← ADD: 9 method signatures
└── presentation/
    ├── pages/
    │   └── profile_page.dart           ← MODIFY: add 3 sections
    ├── providers/
    │   └── profile_provider.dart       ← ADD: 3 new providers
    └── widgets/
        ├── work_experience_card.dart   ← NEW
        ├── education_card.dart         ← NEW
        ├── certificate_card.dart       ← NEW
        ├── work_experience_form_sheet.dart ← NEW
        ├── education_form_sheet.dart   ← NEW
        └── certificate_form_sheet.dart ← NEW

shared/widgets/
    └── section_header.dart             ← NEW: reusable section header
```

### T-12 Files (adds to `features/profile/`)

```
features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_datasource.dart     ← ADD: skill CRUD + skill lookup
│   ├── models/
│   │   ├── skill_model.dart            ← NEW: Freezed + fromJson
│   │   └── user_skill_model.dart       ← NEW: Freezed + fromJson
│   └── repositories/
│       └── profile_repository_impl.dart ← ADD: skill methods
├── domain/
│   ├── entities/
│   │   ├── skill.dart                  ← NEW
│   │   └── user_skill.dart             ← NEW
│   └── repositories/
│       └── profile_repository.dart     ← ADD: skill method signatures
└── presentation/
    ├── providers/
    │   └── profile_provider.dart       ← ADD: 2 providers
    └── widgets/
        └── skill_picker_sheet.dart     ← NEW
```

---

## Section 2: Domain Entities

### Work Experience (`domain/entities/work_experience.dart`)

```dart
class WorkExperience {
  const WorkExperience({
    required this.id,
    required this.userId,
    required this.company,
    required this.role,
    required this.fromDate,
    this.toDate,
    this.description,
    this.isCurrent = false,
  });
  final String id;
  final String userId;
  final String company;    // CONTEXT.md: company, not employer
  final String role;       // CONTEXT.md: role, not position
  final DateTime fromDate;
  final DateTime? toDate;
  final String? description;
  final bool isCurrent;
}
```

### Education (`domain/entities/education.dart`)

```dart
class Education {
  const Education({
    required this.id,
    required this.userId,
    required this.school,
    required this.fromDate,
    this.toDate,
    this.degree,
    this.major,
  });
  final String id;
  final String userId;
  final String school;     // CONTEXT.md: school, not institution
  final DateTime fromDate;
  final DateTime? toDate;
  final String? degree;
  final String? major;
}
```

### Certificate (`domain/entities/certificate.dart`)

```dart
class Certificate {
  const Certificate({
    required this.id,
    required this.userId,
    required this.name,
    this.issuer,
    this.issuedAt,
    this.credentialUrl,
  });
  final String id;
  final String userId;
  final String name;       // CONTEXT.md: name, not title
  final String? issuer;
  final DateTime? issuedAt;
  final String? credentialUrl;
}
```

### Skill (`domain/entities/skill.dart`)

```dart
class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
  });
  final String id;
  final String name;
  final String categoryId;
  final String categoryName; // JOINed from job_categories
}
```

### User Skill (`domain/entities/user_skill.dart`)

```dart
class UserSkill {
  const UserSkill({
    required this.skillId,
    required this.skillName,
    required this.categoryId,
    required this.level,
  });
  final String skillId;
  final String skillName;
  final String categoryId;
  final String level; // 'beginner' | 'intermediate' | 'advanced'

  String get levelLabel => switch (level) {
    'beginner' => 'Cơ bản',
    'intermediate' => 'Trung bình',
    'advanced' => 'Nâng cao',
    _ => level,
  };

  static String levelLabelFor(String level) => switch (level) {
    'beginner'     => 'Cơ bản',
    'intermediate' => 'Trung bình',
    'advanced'     => 'Nâng cao',
    _              => level,
  };
}
```

---

## Section 3: Providers

All in `features/profile/presentation/providers/profile_provider.dart`:

### T-11 Providers

```dart
@riverpod
Future<List<WorkExperience>> workExperiences(WorkExperiencesRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref.watch(profileRepositoryProvider)
      .getWorkExperiences(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

@riverpod
Future<List<Education>> educations(EducationsRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref.watch(profileRepositoryProvider)
      .getEducations(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}

@riverpod
Future<List<Certificate>> certificates(CertificatesRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref.watch(profileRepositoryProvider)
      .getCertificates(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}
```

### T-12 Providers

```dart
@riverpod
Future<List<Skill>> availableSkills(AvailableSkillsRef ref) async {
  // No auth check — skills are public lookup data
  final result = await ref.watch(profileRepositoryProvider)
      .getAvailableSkills();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (skills) => skills,
  );
}

@riverpod
Future<List<UserSkill>> userSkills(UserSkillsRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  final result = await ref.watch(profileRepositoryProvider)
      .getUserSkills(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (list) => list,
  );
}
```

---

## Section 4: Datasource Queries

All added to existing `profile_datasource.dart`:

### T-11 Queries

```dart
// Work Experiences — ORDER BY from_date DESC
Future<List<WorkExperienceModel>> getWorkExperiences(String userId) async {
  final data = await _supabase
      .from('work_experiences')
      .select()
      .eq('user_id', userId)
      .order('from_date', ascending: false);
  return data.map(WorkExperienceModel.fromJson).toList();
}

Future<void> addWorkExperience(WorkExperience entity) async {
  await _supabase.from('work_experiences').insert({
    'user_id': entity.userId,
    'company': entity.company,
    'role': entity.role,
    'from_date': entity.fromDate.toIso8601String().split('T')[0],
    'to_date': entity.toDate?.toIso8601String().split('T')[0],
    'description': entity.description,
    'is_current': entity.isCurrent,
  });
}

Future<void> updateWorkExperience(WorkExperience entity) async {
  await _supabase.from('work_experiences').update({
    'company': entity.company,
    'role': entity.role,
    'from_date': entity.fromDate.toIso8601String().split('T')[0],
    'to_date': entity.toDate?.toIso8601String().split('T')[0],
    'description': entity.description,
    'is_current': entity.isCurrent,
  }).eq('id', entity.id);
}

Future<void> deleteWorkExperience(String id) async {
  await _supabase.from('work_experiences').delete().eq('id', id);
}

// Educations — ORDER BY from_date DESC
// (same pattern: get, add, update, delete)

// Certificates — ORDER BY issued_at DESC NULLS LAST
// (same pattern: get, add, update, delete)
```

### T-12 Queries

```dart
// Available skills — JOINed with job_categories
Future<List<SkillModel>> getAvailableSkills() async {
  final data = await _supabase
      .from('skills')
      .select('*, job_categories(name)')
      .order('name');
  return data.map(SkillModel.fromJson).toList();
}

// User's skills — JOINed with skills table
Future<List<UserSkillModel>> getUserSkills(String userId) async {
  final data = await _supabase
      .from('user_skills')
      .select('*, skills(name, category_id)')
      .eq('user_id', userId);
  // Sort in Dart — .order('skills(name)') is unreliable across supabase_flutter versions
  data.sort((a, b) =>
    ((a['skills']['name'] as String?) ?? '')
        .compareTo((b['skills']['name'] as String?) ?? ''));
  return data.map(UserSkillModel.fromJson).toList();
}

Future<void> addUserSkill(String userId, String skillId, String level) async {
  await _supabase.from('user_skills').insert({
    'user_id': userId,
    'skill_id': skillId,
    'level': level,
  });
}

Future<void> updateUserSkillLevel(String userId, String skillId, String level) async {
  await _supabase.from('user_skills').update({
    'level': level,
  }).eq('user_id', userId).eq('skill_id', skillId);
}

Future<void> deleteUserSkill(String userId, String skillId) async {
  await _supabase.from('user_skills')
      .delete()
      .eq('user_id', userId)
      .eq('skill_id', skillId);
}
```

---

## Section 5: CRUD Call Chain (No Usecases)

Per Usecase Exception Rule:

```
FormSheet save handler
  → ref.read(profileRepositoryProvider).addWorkExperience(entity)
  → ProfileRepositoryImpl.addWorkExperience(entity)
  → ProfileDatasource.addWorkExperience(entity)
  → Supabase INSERT

After success:
  → ref.invalidate(workExperiencesProvider)
  → Navigator.pop(context)  ← bottom sheet dismissal
```

Same pattern for all 12 CRUD operations (3 entities × add/update/delete + skill add/update/delete).

---

## Section 6: ProfilePage Section Layout

```
┌──────────────────────────────────────────┐
│ [Avatar]  Full Name  Headline  Location  │  ← currentProfileProvider
│ Bio                                      │
├──────────────────────────────────────────┤
│ ─── Edit Profile button ───              │
│ ─── Logout button ───                    │
├──────────────────────────────────────────┤
│ Kinh nghiệm làm việc              [+]   │  ← SectionHeader
│ ┌─ Flutter Developer     2022–Hiện tại ┐ │  ← WorkExperienceCard
│ │  Công ty ABC                         │ │
│ └──────────────────────────────────────┘ │
│ (empty: "Chưa có thông tin")             │
├──────────────────────────────────────────┤
│ Học vấn                            [+]   │  ← SectionHeader
│ ┌─ ĐH Bách Khoa           2018–2022 ──┐ │  ← EducationCard
│ │  Cử nhân · KHMT                     │ │
│ └──────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│ Chứng chỉ                         [+]   │  ← SectionHeader
│ ┌─ AWS Solutions Architect ────────────┐ │  ← CertificateCard
│ │  Amazon · 03/2023                    │ │
│ └──────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│ Kỹ năng                           [+]   │  ← SectionHeader (T-12)
│ [Flutter · Nâng cao] [Dart · Trung bình] │  ← skill chips in Wrap
│ [React · Cơ bản]                         │
└──────────────────────────────────────────┘
```

### SectionHeader (`shared/widgets/section_header.dart`)

```dart
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onAdd,
    super.key,
  });
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        IconButton(
          icon: Icon(Icons.add, color: AppColors.primary),
          onPressed: onAdd,
        ),
      ],
    );
  }
}
```

### Card Widgets

All use Container + InkWell (NOT Card widget — no shadows per DESIGN.md):

```dart
decoration: BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
  border: Border.all(color: AppColors.divider),
),
```

Tap → opens edit bottom sheet (pre-populated).

---

## Section 7: T-11 Form Sheets

### Common pattern for all three sheets

- `DraggableScrollableSheet` inside `showModalBottomSheet`
- `backgroundColor: AppColors.surfaceVariant` (CLAUDE.md rule)
- Form fields match validation table below
- Save button calls repository directly (no usecase)
- Edit mode: pre-populate from existing entity
- Add mode: empty fields
- Delete button (edit mode only): `AppColors.error`, triggers confirmation dialog

### Date picker (shared across Work Experience + Education)

```dart
Future<void> _pickDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1970),
    lastDate: DateTime.now(),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppColors.primary,
        ),
      ),
      child: child!,
    ),
  );
}
```

Date displayed as tappable field styled like TextFormField. Date stored as `YYYY-MM-DD` via `toIso8601String().split('T')[0]`.

### `is_current` toggle (Work Experience only)

- `Switch` widget
- ON: disable `to_date` field, clear value
- Label: `AppStrings.currentlyWorking` → "Đang làm việc tại đây"

### Cross-field validation (to_date ≥ from_date)

Handled at form level, NOT in Validators:

```dart
if (toDate != null && toDate!.isBefore(fromDate!)) {
  setState(() => _toDateError = AppStrings.toDateError);
}
```

### Validation table

| Entity | Field | Validation |
|--------|-------|------------|
| Work Experience | company | `Validators.required(value, 'Tên công ty')` |
| Work Experience | role | `Validators.required(value, 'Vị trí')` |
| Work Experience | from_date | `Validators.fromDate(value)` |
| Work Experience | to_date | If set, must be ≥ from_date (form level) |
| Work Experience | description | Optional, max 500 chars (`Validators.bio()` reuse) |
| Education | school | `Validators.required(value, 'Trường')` |
| Education | from_date | `Validators.fromDate(value)` |
| Education | degree | Optional |
| Education | major | Optional |
| Certificate | name | `Validators.required(value, 'Tên chứng chỉ')` |
| Certificate | issuer | Optional |
| Certificate | issued_at | Optional date |
| Certificate | credential_url | `Validators.url(value)` |

### Delete confirmation dialog

DESIGN.md-compliant dialog (Theme override, `AppColors.surface`, `cardBorderRadius`):

```dart
showDialog(
  context: context,
  builder: (_) => Theme(
    data: Theme.of(context).copyWith(
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
    ),
    child: AlertDialog(
      title: Text(AppStrings.confirmDelete, style: AppTextStyles.title),
      content: Text(AppStrings.confirmDeleteMessage, style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel,
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () { Navigator.pop(context); _performDelete(); },
          child: Text(AppStrings.delete,
              style: AppTextStyles.label.copyWith(color: AppColors.error)),
        ),
      ],
    ),
  ),
);
```

---

## Section 8: T-12 Skill Picker Sheet

### Flow

```
Tap "+" on Kỹ năng section header
  → showModalBottomSheet (surfaceVariant, DraggableScrollableSheet)
  → Search TextField at top (filters availableSkillsProvider)
  → Skills grouped by categoryName, sorted alphabetically
  → Already-added skills filtered out:
      availableSkills.where((s) => !userSkillIds.contains(s.id))
  → Tap a skill → inline ChoiceChips appear below:
      [Cơ bản] [Trung bình] [Nâng cao]
  → Tap level → calls repository.addUserSkill(userId, skillId, level)
  → ref.invalidate(userSkillsProvider)
  → Sheet stays open for more skill additions
  → User dismisses sheet when done
```

### Skill chip display (ProfilePage)

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: userSkills.map((skill) => GestureDetector(
    onTap: () => _showEditLevelSheet(skill),
    child: Chip(
      label: Text('${skill.skillName} · ${skill.levelLabel}'),
      backgroundColor: _chipColor(skill.level),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _confirmDeleteSkill(skill),
    ),
  )).toList(),
)
```

### Chip color by level

```dart
Color _chipColor(String level) => switch (level) {
  'beginner'     => AppColors.surface,
  'intermediate' => AppColors.primary.withOpacity(0.12),
  'advanced'     => AppColors.primary.withOpacity(0.25),
  _              => AppColors.surface,
};
```

### Tap-to-edit level

Tap existing chip → small bottom sheet with 3 ChoiceChips:

```dart
showModalBottomSheet(
  backgroundColor: AppColors.surfaceVariant,
  builder: (_) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${skill.skillName} — Chọn trình độ', style: AppTextStyles.title),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['beginner', 'intermediate', 'advanced'].map((level) =>
            ChoiceChip(
              label: Text(UserSkill.levelLabelFor(level)),
              selected: skill.level == level,
              onSelected: (_) {
                ref.read(profileRepositoryProvider).updateUserSkillLevel(...);
                ref.invalidate(userSkillsProvider);
                Navigator.pop(context);
              },
            ),
          ).toList(),
        ),
      ],
    ),
  ),
);
```

### Delete skill confirmation

Uses same DESIGN.md-compliant dialog pattern as T-11. Message: `AppStrings.deleteSkillMessage`.

---

## Section 9: Validators Additions

Add to `core/utils/validators.dart`:

```dart
static String? fromDate(DateTime? value) {
  if (value == null) return 'Vui lòng chọn ngày bắt đầu';
  return null;
}

static String? url(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
    return 'URL không hợp lệ (cần bắt đầu bằng http/https)';
  }
  return null;
}
```

---

## Section 10: AppStrings Additions

```dart
static const workExperience = 'Kinh nghiệm làm việc';
static const education = 'Học vấn';
static const certificate = 'Chứng chỉ';
static const skills = 'Kỹ năng';
static const noData = 'Chưa có thông tin';
static const currentlyWorking = 'Đang làm việc tại đây';
static const currently = 'Hiện tại';
static const toDateError = 'Ngày kết thúc phải sau ngày bắt đầu';
static const confirmDelete = 'Xác nhận xóa';
static const confirmDeleteMessage = 'Bạn có chắc muốn xóa mục này?';
static const deleteSkillMessage = 'Bạn có chắc muốn xóa kỹ năng này?';
static const delete = 'Xóa';
static const cancel = 'Hủy';
static const selectLevel = 'Chọn trình độ';
static const levelBeginner = 'Cơ bản';
static const levelIntermediate = 'Trung bình';
static const levelAdvanced = 'Nâng cao';
static const searchSkill = 'Tìm kỹ năng...';
```

---

## Section 11: Implementation Order

### T-11 (do first)

1. Add CLAUDE.md sections (usecase exception, dialog styling)
2. Create `shared/widgets/section_header.dart`
3. Create 3 entity files + 3 model files
4. Add 9 CRUD methods to `profile_datasource.dart`
5. Add 9 method signatures to `profile_repository.dart`
6. Add 9 implementations to `profile_repository_impl.dart`
7. Add 3 providers to `profile_provider.dart`
8. Create 3 card widgets + 3 form sheet widgets
9. Modify `profile_page.dart` — add 3 sections below edit/logout buttons
10. Add `Validators.fromDate()` + `Validators.url()` to `core/utils/validators.dart`
11. Add AppStrings
12. Run `dart run build_runner build` → `flutter analyze`

### T-12 (after T-11 committed)

1. Create 2 entity files + 2 model files
2. Add skill CRUD + lookup methods to `profile_datasource.dart`
3. Add method signatures to `profile_repository.dart`
4. Add implementations to `profile_repository_impl.dart`
5. Add 2 providers to `profile_provider.dart`
6. Create `skill_picker_sheet.dart`
7. Modify `profile_page.dart` — add Kỹ năng section with chips BELOW the Chứng chỉ section added in T-11. Do NOT re-add the T-11 sections.
8. Add remaining AppStrings
9. Run `dart run build_runner build` → `flutter analyze`

---

## Summary

| Item | T-11 | T-12 | Total |
|------|------|------|-------|
| Entity files | 3 | 2 | 5 |
| Model files | 3 | 2 | 5 |
| Datasource methods added | 9 | 5 | 14 |
| Repository methods added | 9 | 5 | 14 |
| Usecases | 0 | 0 | 0 |
| Providers | 3 | 2 | 5 |
| Page widgets | 0 (modify ProfilePage) | 0 (modify ProfilePage) | 0 |
| Card/display widgets | 3 | 0 (chips inline) | 3 |
| Form sheet widgets | 3 | 1 | 4 |
| Shared widgets | 1 (SectionHeader) | 0 | 1 |
| Validators added | 2 (fromDate, url) | 0 | 2 |
| AppStrings added | 11 | 7 | 18 |
| CLAUDE.md additions | 2 sections | 0 | 2 |
| CONTEXT.md updates | 3 entities + 3 relationships | 0 | 6 |
