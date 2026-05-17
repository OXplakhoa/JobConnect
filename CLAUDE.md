# CLAUDE.md — AI Agent Rules for JobConnect

> Đọc file này TRƯỚC KHI làm bất kỳ thay đổi nào trong project.
> Mọi code sinh ra phải tuân theo rules trong file này.

---

## Project Snapshot

| Key | Value |
|---|---|
| App | Ứng dụng Tuyển dụng & Tìm kiếm Việc làm |
| Framework | Flutter 3.x (Dart 3.x) |
| State | Riverpod 2.x + code generation (`@riverpod`) |
| Navigation | go_router 13.x |
| Backend | Supabase (Auth + DB + Storage + Realtime) |
| AI | Google Gemini API |
| Architecture | Clean Architecture (simplified 3-layer) |
| Target | Android + iOS |

Xem chi tiết tại `docs/BRIEF.md`.

---

## Code Style — Dart

- Luôn dùng `const` constructor khi có thể
- Ưu tiên `final` hơn `var`
- Không dùng `dynamic` — type everything
- Dart 3.x patterns: dùng `sealed class`, `switch expression`, `records` khi phù hợp
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Variables / functions: `camelCase`
- Constants: `kCamelCase` (prefix `k`)
- Private members: `_camelCase`

---

## Architecture Rules

### Layer separation — KHÔNG được vi phạm

```
Presentation → Domain → Data
```

- Widget / Provider KHÔNG được gọi Supabase trực tiếp
- Data layer KHÔNG được import Flutter widget
- Domain layer KHÔNG được biết Supabase hay Riverpod tồn tại

### Riverpod — cách dùng đúng

```dart
// ✅ Đúng — dùng annotation
@riverpod
Future<List<Job>> jobList(JobListRef ref) async { ... }

// ❌ Sai — không khởi tạo provider thủ công
final jobListProvider = FutureProvider<List<Job>>((ref) => ...);
```

- Dùng `@riverpod` annotation (code generation) — KHÔNG khởi tạo `Provider()` thủ công
- Dùng `AsyncNotifierProvider` cho data load từ API
- Dùng `NotifierProvider` cho state thuần (không async)
- KHÔNG `ref.read()` bên trong `build()` — chỉ dùng `ref.watch()`
- Mỗi provider file = một concept: `job_list_provider.dart`, `auth_provider.dart`

### Repository pattern

```dart
// domain/repositories/job_repository.dart
abstract class JobRepository {
  Future<Either<Failure, List<Job>>> getJobs(JobFilter filter);
  Future<Either<Failure, Job>> getJobById(String id);
}

// data/repositories/job_repository_impl.dart
class JobRepositoryImpl implements JobRepository {
  final JobDatasource _datasource;
  // ... impl
}
```

- Repository trả về `Either<Failure, T>` — KHÔNG throw exception
- Supabase calls chỉ nằm trong `datasources/` — không ở nơi khác

---

## Folder & File Conventions

```
features/xxx/
├── data/
│   ├── datasources/    ← Supabase calls. File: xxx_datasource.dart
│   ├── models/         ← Freezed models. File: xxx_model.dart
│   └── repositories/   ← Impl. File: xxx_repository_impl.dart
├── domain/
│   ├── entities/       ← Pure Dart. File: xxx.dart (không suffix)
│   ├── repositories/   ← Abstract. File: xxx_repository.dart
│   └── usecases/       ← File: get_xxx_usecase.dart (động từ trước)
└── presentation/
    ├── pages/          ← File: xxx_page.dart
    ├── widgets/        ← File: xxx_widget.dart hoặc xxx_card.dart
    └── providers/      ← File: xxx_provider.dart
```

---

## Naming Conventions

| Type | Convention | Ví dụ |
|---|---|---|
| Page | `XxxPage` | `LoginPage`, `JobDetailPage` |
| Widget | `XxxWidget` / `XxxCard` | `JobCard`, `FilterBottomSheet` |
| Provider | `xxxProvider` | `jobListProvider` |
| Notifier | `XxxNotifier` | `JobListNotifier` |
| Repository (abstract) | `XxxRepository` | `JobRepository` |
| Repository (impl) | `XxxRepositoryImpl` | `JobRepositoryImpl` |
| Datasource | `XxxDatasource` | `JobDatasource` |
| Use case | `XxxUseCase` | `ApplyJobUseCase`, `GetJobsUseCase` |
| Model | `XxxModel` | `JobModel` |
| Entity | `Xxx` (không suffix) | `Job`, `UserProfile` |
| Failure | `XxxFailure` | `NetworkFailure`, `AuthFailure` |
| Route | `AppRoute.xxx` | `AppRoute.jobDetail` |

---

## Architecture Term Glossary

> Quick reference cho các thuật ngữ kiến trúc dùng trong project.

| Term | Meaning | Layer |
|---|---|---|
| **Datasource** | Class gọi Supabase trực tiếp — chỉ nằm trong `data/datasources/` | Data |
| **Model** | Freezed class + `fromJson`/`toJson` — mapping DB ↔ Dart | Data |
| **Repository (abstract)** | Interface khai báo contract — KHÔNG biết Supabase tồn tại | Domain |
| **Repository (impl)** | Implement abstract repo, dùng Datasource, trả `Either<Failure, T>` | Data |
| **Entity** | Pure Dart class — domain object, KHÔNG có json annotation | Domain |
| **Use Case** | 1 class = 1 hành động business (GetJobsUseCase, ApplyJobUseCase) | Domain |
| **Provider** | Riverpod `@riverpod` annotation — expose state cho UI | Presentation |
| **Notifier** | Riverpod `@riverpod` class có methods mutate state | Presentation |
| **Page** | Widget full-screen, là route destination | Presentation |
| **Failure** | Sealed class cho error types — KHÔNG dùng exception | Domain |

---

## Approved Packages

KHÔNG thêm package ngoài danh sách này mà không hỏi:

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  supabase_flutter: ^2.5.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  dio: ^5.4.0                      # Chỉ dùng gọi Gemini API
  flutter_secure_storage: ^9.2.0
  cached_network_image: ^3.3.0
  file_picker: ^8.0.0
  firebase_messaging: ^14.9.0
  flutter_local_notifications: ^17.0.0
  flutter_svg: ^2.0.0
  intl: ^0.19.0
  equatable: ^2.0.5
  image_picker: ^1.0.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  flutter_lints: ^3.0.0
```

---

## Forbidden Patterns ❌

```dart
// ❌ setState — dùng Riverpod
setState(() { _isLoading = true; });

// ❌ Navigator.push — dùng go_router
Navigator.push(context, MaterialPageRoute(...));

// ❌ Business logic trong Widget
onPressed: () async {
  final result = await supabase.from('jobs').select(); // KHÔNG
}

// ❌ Supabase trực tiếp ngoài datasource
final supabase = Supabase.instance.client; // Chỉ dùng trong datasources/

// ❌ Hardcode màu sắc
color: Color(0xFF1976D2) // Dùng AppColors.primary

// ❌ Hardcode string
Text('Đăng nhập') // Dùng AppStrings.login (hoặc const string)

// ❌ print() trong production code
print('debug'); // Dùng debugPrint() hoặc Logger

// ❌ Commit API key
const geminiKey = 'AIza...'; // Dùng --dart-define hoặc .env
```

---

## Error Handling

```dart
// datasource — bắt exception, map thành Failure
Future<Either<Failure, List<Job>>> getJobs() async {
  try {
    final data = await _supabase.from('job_posts').select();
    return Right(data.map(JobModel.fromJson).toList());
  } on PostgrestException catch (e) {
    return Left(DatabaseFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}

// provider — dùng AsyncValue để handle loading/error/data tự động
final jobs = ref.watch(jobListProvider);
return jobs.when(
  data: (list) => JobListView(jobs: list),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorWidget(message: e.toString()),
);
```

---

## Supabase Rules

- Lấy current user: `Supabase.instance.client.auth.currentUser` — KHÔNG tự store userId
- Realtime chat: subscribe trong provider, `ref.onDispose` để cancel subscription
- Storage paths: `avatars/{userId}/avatar.jpg` · `logos/{companyId}/logo.jpg` · `resumes/{userId}/{filename}`
- **Row Level Security (RLS): LUÔN bật trên tất cả bảng** — không tắt để debug
- Không hardcode Supabase URL và anon key — lấy qua `--dart-define`

---

## AI Feature Rules (Gemini API)

- API key KHÔNG được commit vào git — dùng `--dart-define=GEMINI_KEY=...`
- Gọi Gemini chỉ qua `AiSuggestionDatasource` — không gọi từ Provider hay Widget
- Cache kết quả vào bảng `ai_suggestions`, TTL = 24h
- Rate limit: tối đa 1 request AI/user/5 phút — implement ở repository level
- Prompt template phải nằm trong `core/constants/prompt_templates.dart`

---

## Provider Pattern for User-Specific Data

```dart
// ✅ Correct — watches authProvider, auto-rebuilds on auth change
@riverpod
Future<List<Application>> myApplications(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  return ref.watch(applicationRepositoryProvider).getMyApplications(auth.userId);
}

// ❌ Wrong — doesn't react to auth changes, stale data after logout/login
@riverpod
Future<List<Application>> myApplications(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id; // NEVER
  return ref.watch(applicationRepositoryProvider).getMyApplications(userId);
}
```

Applies to: bookmarks, applications, aiSuggestions, conversations, notifications.

---

## Shared Domain Entities

Entities used by 3+ features live in `shared/domain/entities/`, NOT in any single feature's domain layer.
Currently: `UserProfile`

---

## Bottom Sheet Styling

Bottom sheets: always set `backgroundColor: AppColors.surfaceVariant`. Never use default.

---

## Provider Ownership

- `auth_provider` → authentication state only (session, role, onboarding status)
- `currentProfileProvider` → full `UserProfile` data (bio, avatar, headline, location)
- Never put `UserProfile` fields in `AuthAuthenticated`

---

## Git Convention (Conventional Commits)

```
feat(jobs): add job search filter by location and salary
fix(auth): resolve Google OAuth not redirecting correctly
chore(deps): update supabase_flutter to 2.5.1
refactor(jobs): extract JobCard into shared widget
docs: update BRIEF.md with Gemini rate limit constraint
test(auth): add unit test for LoginUseCase
```

- Branch: `feature/job-search` · `fix/auth-google-redirect` · `chore/update-deps`
- **1 commit = 1 thay đổi logic** — không commit nhiều feature cùng lúc
- Không commit file: `.env`, `*.jks`, `GoogleService-Info.plist`, `google-services.json`

---

## Abbreviation Rules

- **KHÔNG** viết tắt domain terms: dùng `application` không dùng `app`, dùng `notification` không dùng `noti`
- **OK** viết tắt kỹ thuật chuẩn: `auth`, `repo`, `impl`, `UI`, `DB`, `RLS`, `FCM`, `PDF`, `CV`

---

## DO NOT

- Tạo file ngoài cấu trúc thư mục đã định trong docs/BRIEF.md
- Thay đổi database schema mà không cập nhật `docs/BRIEF.md` phần Schema
- Implement feature chưa có trong `TASKS.md`
- Merge code chưa có người review (dù là nhóm nhỏ)
- Bỏ qua linter errors — fix trước khi commit (`flutter analyze`)