# Implementation Plan: T-00 → T-03 (Phase 0 Foundation)

All decisions locked via grill session (Q1–Q19). No ambiguity remains.

---

## T-00: Flutter Project Init + Packages

### Step 1: Create Flutter project

```bash
flutter create --project-name job_connect --org com.jobconnect --platforms android,ios ./
```

> [!IMPORTANT]
> Run in-place at `f:\CODE\LTDD`. Existing `.md` files and `.agents/` stay untouched.

### Step 2: `pubspec.yaml` — dependencies

Caret ranges from CLAUDE.md. **Exclude** `firebase_messaging` and `flutter_local_notifications` (deferred to T-30).

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  supabase_flutter: ^2.5.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  dio: ^5.4.0
  flutter_secure_storage: ^9.2.0
  cached_network_image: ^3.3.0
  file_picker: ^8.0.0
  flutter_svg: ^2.0.0
  intl: ^0.19.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
```

### Step 3: `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_locals: true
    avoid_dynamic_calls: true
    always_declare_return_types: true
    sort_constructors_first: true
    unawaited_futures: true
    avoid_print: true
    prefer_single_quotes: true
```

### Step 4: `.env.example` + `.gitignore`

`.env.example` at project root:
```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
GEMINI_KEY=your-gemini-key
```

Add to `.gitignore`: `.env`, `*.jks`, `GoogleService-Info.plist`, `google-services.json`

### Step 5: Run `flutter pub get`

Verify all packages resolve.

---

## T-01: Core — Theme + Design System

### Files to create

#### [NEW] `lib/core/theme/app_colors.dart`

Light theme colors:

| Token | Hex | Role |
|-------|-----|------|
| `primary` | `#0D9488` | Forward Teal — CTAs, active states |
| `onPrimary` | `#FFFFFF` | Text on teal |
| `background` | `#F8F7F4` | Warm Stone — page canvas |
| `surface` | `#FDFCFA` | Cloud — cards, sheets |
| `surfaceVariant` | `#F1F0ED` | Elevated sheets, bottom sheet bg |
| `divider` | `#E8E6E1` | Borders, dividers |
| `textPrimary` | `#1A1D1E` | Deep Ink — body text |
| `textSecondary` | `#6B7272` | Soft Ash — metadata, warm-shifted |
| `success` | `#10B981` | Skill match ✅ |
| `warning` | `#F59E0B` | Warm amber |
| `error` | `#DC2626` | Muted red |

Dark theme colors (skeleton — `// TODO: T-38 polish pass`):

| Token | Hex |
|-------|-----|
| `background` | `#1A1D1E` |
| `surface` | `#242828` |
| `textPrimary` | `#F0EFED` |
| `textSecondary` | `#9CA09E` |
| `primary` | `#0D9488` (same) |
| Semantic | Same values |

#### [NEW] `lib/core/theme/app_text_styles.dart`

Font: **Plus Jakarta Sans** (local asset). 5 weights: 400, 500, 600, 700, 800.

| Style | Size (sp) | Weight | Line-height |
|-------|-----------|--------|-------------|
| `display` | 28 | 800 ExtraBold | 1.1 |
| `headline` | 22 | 700 Bold | 1.25 |
| `title` | 16 | 600 SemiBold | 1.3 |
| `body` | 14 | 400 Regular | 1.5 |
| `bodySmall` | 12 | 400 Regular | 1.4 |
| `label` | 12 | 500 Medium | 1.4 |

#### [NEW] `lib/core/theme/app_theme.dart`

- `AppTheme.light` — full `ThemeData` with `colorScheme`, `textTheme`, component themes
- `AppTheme.dark` — `ThemeData.dark().copyWith(colorScheme: ...)` overriding only colors. **Do NOT duplicate** structural theme. Mark with `// TODO: T-38 polish pass`

#### [NEW] `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  const AppConstants._();

  // Environment — via --dart-define
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // App
  static const appName = 'JobConnect';

  // Layout
  static const bottomNavHeight = 64.0;
  static const defaultPadding = 16.0;
  static const cardBorderRadius = 12.0;
}
```

#### [NEW] `lib/core/constants/app_strings.dart`

English variable names, Vietnamese string values. Only strings needed for T-03 placeholders + bottom nav:

```dart
class AppStrings {
  const AppStrings._();

  static const appName = 'JobConnect';
  static const home = 'Trang chủ';
  static const search = 'Tìm việc';
  static const applications = 'Đơn ứng tuyển';
  static const conversations = 'Tin nhắn';
  static const profile = 'Hồ sơ';
  static const login = 'Đăng nhập';
  static const register = 'Đăng ký';
  static const loading = 'Đang tải...';
  static const errorGeneral = 'Đã có lỗi xảy ra';
  static const retry = 'Thử lại';
}
```

#### Font assets

Download Plus Jakarta Sans (400, 500, 600, 700, 800) → `assets/fonts/`

Register in `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/PlusJakartaSans-ExtraBold.ttf
          weight: 800
```

---

## T-02: Core — Error Handling + Failure Classes

### Files to create

#### [NEW] `lib/core/utils/either.dart`

Hand-rolled `Either<L, R>` sealed class with `Left`, `Right`, and `fold` method. No external FP library.

```dart
sealed class Either<L, R> {
  const Either();
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
}

class Left<L, R> extends Either<L, R> { ... }
class Right<L, R> extends Either<L, R> { ... }
```

#### [NEW] `lib/core/extensions/either_ext.dart`

Extensions: `map`, `getOrElse`, `isLeft`, `isRight`. **No `flatMap`** — defer to T-38 if needed.

#### [NEW] `lib/core/errors/failure.dart`

```dart
sealed class Failure {
  const Failure({required this.message, this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;
}

class NetworkFailure extends Failure { ... }
class DatabaseFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class StorageFailure extends Failure { ... }
class UnexpectedFailure extends Failure { ... }
```

Usage rules:
- `message` → shown to user (or mapped to user-friendly string)
- `code` → conditional logic in repository/provider
- `stackTrace` → `debugPrint()` / Logger only, **never to UI**

#### [NEW] `lib/core/extensions/build_context_ext.dart`

```dart
extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  GoRouter get router => GoRouter.of(this);
}
```

---

## T-03: Core — Router Shell + Auth Guard

### Files to create

#### [NEW] `lib/core/router/app_router.dart`

Route table (flat paths, no role prefixing):

| Path | Target | Shell? |
|------|--------|--------|
| `/` | PlaceholderPage('Trang chủ') | ✅ Tab 0 |
| `/search` | PlaceholderPage('Tìm việc') | ✅ Tab 1 |
| `/applications` | PlaceholderPage('Đơn ứng tuyển') | ✅ Tab 2 |
| `/conversations` | PlaceholderPage('Tin nhắn') | ✅ Tab 3 |
| `/profile` | PlaceholderPage('Hồ sơ') | ✅ Tab 4 |
| `/login` | PlaceholderPage('Đăng nhập') | ❌ |
| `/register` | PlaceholderPage('Đăng ký') | ❌ |

Role hook (replaceable in T-07):
```dart
// T-03: hardcoded, replaced in T-07
UserRole _resolveRole() => UserRole.seeker;
```

AuthGuard:
```dart
// T-03: skeleton — hardcoded, replaced in T-07
redirect: (context, state) {
  const isLoggedIn = false; // TODO: T-07 replace with real auth
  if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
    return '/login';
  }
  return null;
}
```

#### [NEW] `lib/core/router/user_role.dart`

```dart
enum UserRole { seeker, recruiter, admin }
```

#### [NEW] `lib/shared/widgets/placeholder_page.dart`

```dart
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: AppTextStyles.headline),
      ),
    );
  }
}
```

Stays permanently in codebase — reused for Recruiter/Admin shells.

#### [MODIFY] `lib/main.dart`

Wire up `ProviderScope` → `MaterialApp.router` → `AppTheme.light` / `AppTheme.dark` → `AppRouter`.

---

## File Tree Summary

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── errors/
│   │   └── failure.dart
│   ├── extensions/
│   │   ├── build_context_ext.dart
│   │   └── either_ext.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── user_role.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/
│       └── either.dart
├── shared/
│   └── widgets/
│       └── placeholder_page.dart
└── main.dart

assets/
└── fonts/
    ├── PlusJakartaSans-Regular.ttf
    ├── PlusJakartaSans-Medium.ttf
    ├── PlusJakartaSans-SemiBold.ttf
    ├── PlusJakartaSans-Bold.ttf
    └── PlusJakartaSans-ExtraBold.ttf

.env.example
analysis_options.yaml
```

Total: **13 Dart files** + **5 font files** + **2 config files**

---

## Verification Plan

### Automated
1. `flutter pub get` — all packages resolve
2. `flutter analyze` — zero warnings/errors with 9 custom lint rules
3. `flutter run` — app launches, shows login placeholder (AuthGuard redirects), bottom nav visible after bypassing guard temporarily

### Manual
- Verify Plus Jakarta Sans renders Vietnamese diacritics correctly
- Verify light theme colors match the resolved palette
- Verify dark theme toggles without crash
- Tap each bottom nav tab → correct placeholder title shown
- Navigate to `/login` and `/register` → no bottom nav shown
