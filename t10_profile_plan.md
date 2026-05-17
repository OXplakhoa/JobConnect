# T-10: Seeker Profile CRUD + Avatar Upload — Implementation Plan

All decisions locked via grill Q1–Q8.

---

## Prerequisites

### Manual Steps (before implementation)

1. **Supabase Dashboard → Storage → New bucket:**
   - Name: `public-assets`, Public: ON, Max size: 2MB
2. **Supabase Dashboard → Storage → New bucket:**
   - Name: `private-files`, Public: OFF, Max size: 5MB

### New Migration File

`supabase/migrations/20260511000003_storage_policies.sql`

```sql
-- ============================================================
-- STORAGE RLS POLICIES
-- ============================================================

-- public-assets: anyone can read, owner can write
-- Path pattern: {type}/{userId}/{filename}
-- (storage.foldername(name))[2] extracts the userId segment

CREATE POLICY "public_assets_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'public-assets');

CREATE POLICY "public_assets_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

CREATE POLICY "public_assets_update"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

CREATE POLICY "public_assets_delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'public-assets'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

-- private-files: owner only (all operations)
CREATE POLICY "private_files_all"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'private-files'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );
```

### Prerequisite Code Changes (do these FIRST)

1. **Move `UserProfile` to shared layer:**
   - Move `features/auth/domain/entities/user_profile.dart` → `shared/domain/entities/user_profile.dart`
   - Update import in `features/auth/presentation/providers/auth_provider.dart`
   - Run `flutter analyze` to catch any broken imports

2. **Add `image_picker` to pubspec.yaml:**
   ```yaml
   image_picker: ^1.0.0
   ```
   Also add to CLAUDE.md approved packages list.

3. **Add to CLAUDE.md:**
   ```
   ## Shared Domain Entities
   Entities used by 3+ features live in shared/domain/entities/
   NOT in any single feature's domain layer.
   Currently: UserProfile

   ## Bottom Sheet Styling
   // Bottom sheets: always set backgroundColor:
   // AppColors.surfaceVariant. Never use default.

   ## Provider Ownership
   // auth_provider  → authentication state only
   //                  (session, role, onboarding status)
   // currentProfileProvider → full UserProfile data
   //                          (bio, avatar, headline, location)
   // Never put UserProfile fields in AuthAuthenticated
   ```

---

## Section 1: Feature File Structure

```
core/utils/
  └── storage_utils.dart             ← NEW: centralized URL construction

features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_datasource.dart  ← Supabase queries + Storage upload
│   ├── mappers/
│   │   └── profile_error_mapper.dart
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── profile_update.dart      ← Plain data class for write ops
│   ├── repositories/
│   │   └── profile_repository.dart  ← Abstract interface
│   └── usecases/
│       ├── get_profile_usecase.dart
│       ├── update_profile_usecase.dart
│       └── upload_avatar_usecase.dart
└── presentation/
    ├── pages/
    │   ├── profile_page.dart         ← View mode (shell tab)
    │   └── edit_profile_page.dart    ← Edit mode (push route)
    ├── providers/
    │   └── profile_provider.dart     ← currentProfileProvider
    └── widgets/
        └── avatar_picker.dart        ← Camera + gallery bottom sheet
```

---

## Section 2: Key Types

### StorageUtils (core/utils/storage_utils.dart)

```dart
class StorageUtils {
  const StorageUtils._();

  /// Constructs public URL for files in public-assets bucket
  static String publicUrl(String relativePath) =>
      Supabase.instance.client.storage
          .from('public-assets')
          .getPublicUrl(relativePath);

  /// Constructs signed URL for files in private-files bucket
  static Future<String> signedUrl(
    String relativePath, {
    Duration expiry = const Duration(hours: 1),
  }) =>
      Supabase.instance.client.storage
          .from('private-files')
          .createSignedUrl(relativePath, expiry.inSeconds);
}
```

### ProfileUpdate (domain/entities/profile_update.dart)

```dart
class ProfileUpdate {
  const ProfileUpdate({
    this.fullName,
    this.headline,
    this.bio,
    this.location,
    this.avatarUrl,
  });
  final String? fullName;
  final String? headline;
  final String? bio;
  final String? location;
  final String? avatarUrl;

  ProfileUpdate copyWith({
    String? fullName,
    String? headline,
    String? bio,
    String? location,
    String? avatarUrl,
  }) => ProfileUpdate(
    fullName: fullName ?? this.fullName,
    headline: headline ?? this.headline,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
}
```

### profileRepositoryProvider (presentation/providers/profile_provider.dart)

```dart
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl(
    ProfileDatasourceImpl(Supabase.instance.client),
  );
}
```

### currentProfileProvider (same file)

```dart
@riverpod
Future<UserProfile> currentProfile(CurrentProfileRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) throw Exception('Not authenticated');

  final result = await ref.watch(profileRepositoryProvider)
      .getProfile(auth.userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
}
```

---

## Section 3: Storage Path Conventions

Locked for all features:

| Bucket | Path pattern | Task |
|--------|-------------|------|
| `public-assets` | `avatars/{userId}/avatar.{ext}` | T-10 |
| `public-assets` | `logos/{companyId}/logo.{ext}` | T-13 |
| `private-files` | `resumes/{userId}/{filename}.pdf` | T-19 |

Rules:
- userId/companyId = Supabase UUID (no spaces)
- Avatar always named `avatar` — overwrite on update
- ext: jpg or png only (validate in app)
- Resumes keep original filename for human readability
- `profiles.avatar_url` stores **relative path** only (e.g. `avatars/{userId}/avatar.jpg`)
- Full URL constructed at runtime via `StorageUtils.publicUrl()`

---

## Section 4: Avatar Upload Flow

```
User taps avatar → bottom sheet (gallery / camera)
  → ImagePicker.pickImage(maxWidth: 512, maxHeight: 512, imageQuality: 80)
  → returns XFile or null (cancelled)
  → show local preview immediately (optimistic UI)
  → on Save button:
    Step 1: UploadAvatarUseCase.call(imageBytes, ext)
      → profile_datasource: delete existing files in avatars/{userId}/
      → upload new file to avatars/{userId}/avatar.{ext}
      → return Either<Failure, String> (relative path)
    Step 2: UpdateProfileUseCase.call(profileUpdate.copyWith(avatarUrl: newPath))
      → profile_datasource: single UPDATE on profiles table
      → return Either<Failure, void>
    Step 3: ref.invalidate(currentProfileProvider)
    Step 4: context.pop() → back to ProfilePage
```

> [!WARNING]
> Steps 1 and 2 are sequential, not parallel. Upload first, get path, then update profile with path. If step 2 fails, avatar is uploaded but URL not saved — acceptable (orphaned file, not data corruption). If step 1 fails, no profile update happens.

### Delete-then-upload cleanup

```dart
// In profile_datasource.dart
Future<Either<Failure, String>> uploadAvatar(Uint8List bytes, String ext) async {
  try {
    final userId = _supabase.auth.currentUser!.id;
    final storagePath = 'avatars/$userId/avatar.$ext';

    // 1. Delete existing avatar files
    final existingFiles = await _supabase.storage
        .from('public-assets')
        .list(path: 'avatars/$userId');
    if (existingFiles.isNotEmpty) {
      await _supabase.storage.from('public-assets').remove(
        existingFiles.map((f) => 'avatars/$userId/${f.name}').toList(),
      );
    }

    // 2. Upload new avatar
    await _supabase.storage.from('public-assets').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$ext'),
    );

    return Right(storagePath);
  } on StorageException catch (e) {
    return Left(StorageFailure(message: e.message));
  } catch (e, st) {
    return Left(NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st));
  }
}
```

---

## Section 5: Pages

### ProfilePage (view mode — `/profile` shell tab)

Layout (top to bottom):
1. Avatar (centered, large CircleAvatar)
2. Full name (`AppTextStyles.headline`)
3. Headline (`AppTextStyles.body`, `AppColors.textSecondary`)
4. Location (`AppTextStyles.label`, with pin icon)
5. Bio (`AppTextStyles.body`, multiline)
6. Divider (`AppColors.divider`)
7. "Chỉnh sửa hồ sơ" button (primary teal CTA)
8. "Đăng xuất" button (`AppColors.textSecondary`, NOT teal)

- Watches `currentProfileProvider`
- Handles `AsyncLoading` (shimmer/spinner), `AsyncError` (retry), `AsyncData` (display)
- Logout calls `LogoutUseCase` — do NOT navigate after, router handles it
- Edit button: `context.push('/profile/edit')`

### EditProfilePage (edit mode — `/profile/edit`)

- `ConsumerStatefulWidget` with `TextEditingController`s
- Read `currentProfileProvider` ONCE on mount for initial values (`ref.read()`, NOT `ref.watch()`)
- Form fields:

| Field | Widget | Validation |
|-------|--------|------------|
| Avatar | `AvatarPicker` (tap to change) | jpg/png, ≤2MB |
| Full name | `TextFormField` | `Validators.fullName()` (2-100 chars) |
| Headline | `TextFormField` | `Validators.headline()` (optional, max 120) |
| Bio | `TextFormField` (multiline, maxLines: 5) | `Validators.bio()` (optional, max 500) |
| Location | `TextFormField` | `Validators.location()` (optional, max 100) |

- Save handler: trim all values → upload avatar if changed → update profile → invalidate → pop
- All field values trimmed before passing to `UpdateProfileUseCase`

---

## Section 6: AvatarPicker Widget

```dart
// Tap handler
void _showImageSourceSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceVariant,  // DESIGN.md compliance
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library, color: AppColors.primary),
            title: Text(AppStrings.chooseFromGallery, style: AppTextStyles.body),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: AppColors.primary),
            title: Text(AppStrings.takePhoto, style: AppTextStyles.body),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
          ),
        ],
      ),
    ),
  );
}

// Image picker with permission handling
Future<void> _pickImage(ImageSource source) async {
  try {
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image == null) return; // user cancelled
    // Pass image bytes to parent via callback
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.errorGeneral)),
      );
    }
  }
}
```

- Error handling at widget level: try/catch + SnackBar (NOT Either/Failure)
- Shows local file preview immediately after pick (before upload)
- Parent receives `Uint8List` + extension string via callback

---

## Section 7: Platform Config

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>JobConnect cần truy cập thư viện ảnh để cập nhật ảnh đại diện</string>
<key>NSCameraUsageDescription</key>
<string>JobConnect cần truy cập camera để chụp ảnh đại diện</string>
```

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

---

## Section 8: Validators Additions

Add to `core/utils/validators.dart`:

```dart
static String? headline(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > 120) return 'Tiêu đề không được quá 120 ký tự';
  return null;
}

static String? bio(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > 500) return 'Giới thiệu không được quá 500 ký tự';
  return null;
}

static String? location(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > 100) return 'Địa điểm không được quá 100 ký tự';
  return null;
}
```

---

## Section 9: AppStrings Additions

```dart
static const chooseFromGallery = 'Chọn từ thư viện';
static const takePhoto = 'Chụp ảnh';
static const changeAvatar = 'Thay đổi ảnh đại diện';
static const editProfile = 'Chỉnh sửa hồ sơ';
static const saveChanges = 'Lưu thay đổi';
```

---

## Section 10: Router Changes

**Update shell tab** — replace PlaceholderPage with real ProfilePage:

```dart
// BEFORE (T-03):
GoRoute(path: '/profile', builder: (_, __) => const PlaceholderPage(title: 'Hồ sơ'))

// AFTER (T-10):
GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())
```

**Add edit route** to `app_router.dart`:

```dart
GoRoute(
  path: '/profile/edit',
  builder: (_, __) => const EditProfilePage(),
),
```

This is a top-level route (NOT nested under shell) so it pushes over the bottom nav. Use `context.push('/profile/edit')` from ProfilePage.

---

## Summary

| Item | Count |
|------|-------|
| New migration file | 1 (`20260511000003_storage_policies.sql`) |
| Dart files created | 11 |
| Usecases | 3 (get, update, upload avatar) |
| Pages | 2 (ProfilePage, EditProfilePage) |
| Widgets | 1 (AvatarPicker) |
| Core utilities | 1 (StorageUtils) |
| Platform configs modified | 2 (Info.plist, AndroidManifest.xml) |
| CLAUDE.md additions | 3 sections (shared entities, bottom sheet, provider ownership) |
| AppStrings additions | 5 |
| Validators additions | 3 (headline, bio, location) |
| Manual Dashboard steps | 2 (create storage buckets) |
| Files moved | 1 (UserProfile → shared/) |
