# Chat Conversation

Note: _This is purely the output of the chat conversation and does not contain any raw data, codebase snippets, etc. used to generate the output._

### User Input

Im about to work on thí batch: T-00, T-01, T-02, T-03 (from @[TASKS.md]).
Before writting code, @[/grill-me]
Context: Read @[BRIEF.md], @[CLAUDE.md], @[DESIGN.md], @[CONTEXT.md]first

### Planner Response

Let me read the grill-me skill and all the context documents first.

*Viewed [SKILL.md](file:///f:/CODE/LTDD/.agents/skills/grill-me/SKILL.md) *

*Viewed [TASKS.md](file:///f:/CODE/LTDD/TASKS.md) *

*Viewed [BRIEF.md](file:///f:/CODE/LTDD/BRIEF.md) *

*Viewed [CLAUDE.md](file:///f:/CODE/LTDD/CLAUDE.md) *

*Viewed [DESIGN.md](file:///f:/CODE/LTDD/DESIGN.md) *

*Viewed [CONTEXT.md](file:///f:/CODE/LTDD/CONTEXT.md) *

### Planner Response

Now let me also check what currently exists in the project directory to understand the starting state:

*Listed directory [LTDD](file:///f:/CODE/LTDD) *

### Planner Response

Good — the project is currently **documentation only**, no Flutter project exists yet. Now I have full context. Let me begin the grilling.

---

Alright, I've absorbed all four context documents and the four tasks. Let's grill.

Here are the tasks we're covering:

| Task | Summary |
|------|---------|
| **T-00** | Flutter project init + all packages + `analysis_options.yaml` + `.env.example` |
| **T-01** | `core/theme/`: `AppColors`, `AppTextStyles`, `AppTheme` (light + dark). `core/constants/`: `AppConstants`, `AppStrings` |
| **T-02** | `core/errors/`: `Failure` sealed class. `core/extensions/`: `BuildContext` extensions, `Either` helpers |
| **T-03** | `core/router/`: `AppRouter` with `go_router`, `ShellRoute` for bottom nav, `AuthGuard` redirect (skeleton). Placeholder pages |

---

## Question 1

**T-00 says to create the Flutter project. Where exactly should it be created?**

Your workspace root is `f:\CODE\LTDD` and it already has documentation files (`BRIEF.md`, `CLAUDE.md`, etc.) at the root. There are two options:

1. **Create the Flutter project *in-place* at `f:\CODE\LTDD`** — meaning `pubspec.yaml`, `lib/`, `android/`, etc. sit alongside your `.md` files at the root. This is common for single-app repos.

2. **Create the Flutter project in a subdirectory** (e.g. `f:\CODE\LTDD\app/`) — keeping docs and Flutter code separated.

**My recommendation:** Option 1 — create in-place at the root. Your `BRIEF.md §6` folder structure shows `lib/` directly (not `app/lib/`), your `CLAUDE.md` references `lib/` paths directly, and `TASKS.md` never mentions a subdirectory. Creating a nested app would break all existing path references and add unnecessary complexity.

Which option do you want?

### User Input

Yes, let's go with option 1

### Planner Response

Got it — Flutter project in-place at `f:\CODE\LTDD`.

## Question 2

**T-00: What should the Flutter project name be?**

`flutter create` requires a valid Dart package name (lowercase, underscores, no hyphens). The folder is `LTDD` but that's not a meaningful package name.

BRIEF.md §1 says the project name is **JobConnect**. That maps to `job_connect` as a Dart package name.

**My recommendation:** `job_connect` — matches the project identity, is a valid Dart package name, and will appear in `pubspec.yaml` as `name: job_connect`.

The `flutter create` command would use `--project-name job_connect` while targeting the current directory `./`.

Agree?

### User Input

yes, job_connect is great name, i also named it as my repo on github

### Planner Response

Perfect — `job_connect` it is.

## Question 3

**T-00: The package list in CLAUDE.md specifies exact versions — but should we pin those exact versions, or use the caret (`^`) ranges as written?**

CLAUDE.md lists versions like `flutter_riverpod: ^2.5.0`, `go_router: ^13.0.0`, etc. These were written months ago. When we run `flutter create` and add these to `pubspec.yaml`, there are two approaches:

1. **Use the exact caret ranges from CLAUDE.md** (e.g. `^2.5.0`) — respects the documented spec, gets latest compatible patches during `pub get`.
2. **Resolve to latest compatible versions first** — run `pub add` with no version constraint, then lock whatever resolves.

**My recommendation:** Option 1 — use the exact caret ranges from CLAUDE.md verbatim. The document is your source of truth, and `^` already allows patch/minor updates. Deviating from documented versions without reason creates drift between docs and code. If any version conflict arises during `pub get`, we deal with it then.

Agree?

### User Input

Things could get wrong from time to time, so i prefer caret range

### Planner Response

Good — caret ranges from CLAUDE.md as-is. Moving on.

## Question 4

**T-00: Should we add ALL packages from CLAUDE.md right now in T-00, or only the ones needed for Phase 0 (T-00 through T-03)?**

CLAUDE.md lists packages like `firebase_messaging`, `file_picker`, `dio`, `cached_network_image` — these won't be used until Phase 5+ (applications, AI, notifications). Adding them now means:

- **Pros:** Single setup, matches the CLAUDE.md spec exactly, no revisiting `pubspec.yaml` later
- **Cons:** Heavier initial project, `firebase_messaging` specifically requires Firebase setup (google-services.json, GoogleService-Info.plist) or the build will fail on Android/iOS

**My recommendation:** Add all packages **except** `firebase_messaging` and `flutter_local_notifications`. Those two require Firebase project configuration that doesn't exist yet (T-30 handles FCM setup). Adding them now will cause build failures. Everything else can sit harmlessly in `pubspec.yaml` until needed.

Agree, or do you want all packages including Firebase ones?

### User Input

Yes as is

### Planner Response

Good — all packages except `firebase_messaging` and `flutter_local_notifications` (deferred to T-30).

## Question 5

**T-00: How should Supabase URL and anon key be configured?**

CLAUDE.md says "Không hardcode Supabase URL và anon key — lấy qua `--dart-define`". T-00 mentions creating `.env.example`. There are two common patterns in Flutter:

1. **`--dart-define` only** — pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` via command line at build time. No `.env` file loaded at runtime. The `.env.example` is just documentation for developers.

2. **`flutter_dotenv` package + `.env` file** — load from a `.env` file at runtime. But this package isn't in the approved list, and CLAUDE.md explicitly says `--dart-define`.

**My recommendation:** Use `--dart-define` as CLAUDE.md specifies. Create `.env.example` as a *documentation template* showing what variables are needed (not loaded at runtime). Access them in code via:

```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

The `.env.example` would list:
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
GEMINI_KEY=AIza...
```

And developers run: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

Agree?

### User Input

Agreed

### Planner Response

Locked in. Moving to T-01.

## Question 6

**T-01: DESIGN.md specifies "Forward Teal" at `oklch ~55% 0.14 175` and warm-tinted neutrals — but all color values are marked `[to be resolved]`. What concrete hex/RGB values should `AppColors` use?**

DESIGN.md gives us the *intent* but not the final values. We need to resolve them now. Based on the design direction (oklch 55% 0.14 hue 175, warm neutrals tinted toward hue 175 at chroma 0.005–0.01), here's what I'd propose:

| Token | Role | Proposed Value | Rationale |
|-------|------|---------------|-----------|
| `primary` (Forward Teal) | CTAs, active states | `#0D9488` (teal-600ish) | oklch ~55% 0.14 175 ≈ this range. Vibrant but not neon |
| `onPrimary` | Text on teal | `#FFFFFF` | High contrast on teal |
| `background` (Warm Stone) | Page canvas | `#F8F7F4` | Off-white with warm tint, not pure white |
| `surface` (Cloud) | Cards, sheets | `#FFFFFF` | Slightly lighter than background for tonal layering |
| `textPrimary` (Deep Ink) | Body text | `#1A1D1E` | Warm near-black, not pure #000 |
| `textSecondary` (Soft Ash) | Metadata, labels | `#6B7280` | Warm gray |
| `success` | Skill match ✅ | `#10B981` | Teal family green |
| `warning` | Skill gap ❌ | `#F59E0B` | Warm amber |
| `error` | Failures | `#DC2626` | Muted red |

**My recommendation:** Use these as starting values. They can be refined during T-38 (UI Polish) with `/impeccable`. Getting exact pixel-perfect oklch conversions isn't critical at the foundation stage — getting the *feel* right is.

Do these values feel right to you, or do you want to adjust any?

### User Input

Almost right — two values conflict with @[DESIGN.md] rules:

1. `surface` (#FFFFFF) — DESIGN.md explicitly says "No pure white 
   backgrounds". Cloud should be slightly lighter than Warm Stone 
   but still tinted. Change to #FDFCFA.

2. `textSecondary` (#6B7280) is too cool/gray — it should lean 
   warm toward hue 175. Change to #6B7272 or #6E7270.

*Edited relevant file*

*Viewed [DESIGN.md](file:///f:/CODE/LTDD/DESIGN.md) *

### Planner Response

Sharp catch — you're right on both. Updated palette:

| Token | Value |
|-------|-------|
| `surface` (Cloud) | **`#FDFCFA`** — tinted, not pure white |
| `textSecondary` (Soft Ash) | **`#6B7272`** — warm-shifted toward hue 175 |

Everything else stays. Moving on.

## Question 7

**T-01: DESIGN.md specifies "Plus Jakarta Sans" as the font, but the type sizes are all `[size to be resolved]`. What concrete sizes should `AppTextStyles` use?**

DESIGN.md gives us weights and line-heights but not sizes. Here's my proposal for a mobile-first scale, respecting the Diacritics Rule (nothing below 12sp):

| Style | Size (sp) | Weight | Line-height | Usage |
|-------|-----------|--------|-------------|-------|
| Display | 28 | 800 (ExtraBold) | 1.1 | Screen hero titles (rare) |
| Headline | 22 | 700 (Bold) | 1.25 | Section headers |
| Title | 16 | 600 (SemiBold) | 1.3 | Card titles, job post titles |
| Body | 14 | 400 (Regular) | 1.5 | Running text, descriptions |
| Label | 12 | 500 (Medium) | 1.4 | Buttons, chips, metadata, timestamps |

**Rationale:** This is a tight mobile scale. The jump from 12→14→16→22→28 gives clear visual hierarchy without wasting screen real estate on a 6-inch Android. Label at 12sp is the absolute floor per DESIGN.md. Body line-height at 1.5 exceeds the 1.4 minimum for Vietnamese diacritics.

Do these sizes work, or do you want to adjust?

### User Input

Agreed

*Viewed [workflow_decision.md](file:///f:/CODE/LTDD/workflow_decision.md) *

### Planner Response

Sizes locked. Next.

## Question 8

**T-01: How should Plus Jakarta Sans be bundled — as a local asset or via Google Fonts package?**

Two options:

1. **Local asset** — download the `.ttf` files, put them in `assets/fonts/`, declare in `pubspec.yaml`. Works offline, no runtime download, deterministic.

2. **`google_fonts` package** — loads at runtime from Google's CDN (with local caching). But this package is **not in the approved list** in CLAUDE.md, and CLAUDE.md explicitly says "KHÔNG thêm package ngoài danh sách này mà không hỏi".

**My recommendation:** Local asset. It avoids adding an unapproved package, works offline (important for demo/defense), and gives deterministic rendering. We download Plus Jakarta Sans (Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800), place in `assets/fonts/`, and register in `pubspec.yaml`.

Agree?

### User Input

Agreed

### Planner Response

Local asset it is. Next.

## Question 9

**T-01: `AppStrings` — should it hold Vietnamese strings, English strings, or both?**

BRIEF.md §10 says "Chỉ tiếng Việt" (Vietnamese only, no i18n). CLAUDE.md forbids hardcoded strings and says to use `AppStrings.login` etc. So we need a centralized string file — but in which language?

Options:

1. **Vietnamese only** — matches the "chỉ tiếng Việt" constraint. `AppStrings.login = 'Đăng nhập'`.
2. **English keys, Vietnamese values** — e.g. `AppStrings.login = 'Đăng nhập'` (same result, but the *variable name* is English while the *value* is Vietnamese).
3. **English strings for now, switch to Vietnamese later** — risks forgetting to switch.

**My recommendation:** Option 2 — English variable names, Vietnamese string values. This is the natural Dart convention (code in English, UI in Vietnamese). The variable name `AppStrings.login` is readable in code, while the user sees `'Đăng nhập'` on screen. We don't need `flutter_localizations` or `.arb` files since there's only one language.

In T-01, we'd only create the *structure* plus strings needed for the placeholder pages (T-03). The full string list grows as features are built.

Agree?

### User Input

Ok i agreed with that

### Planner Response

Good. Moving to T-01's last open question.

## Question 10

**T-01: DESIGN.md is entirely designed around a light theme rationale ("a student on a bus in Saigon afternoon sun"). But T-01 says `AppTheme` should have light + dark. How much effort goes into the dark theme?**

DESIGN.md explicitly justifies light-first and never defines dark mode tokens. Yet T-01 lists "light + dark". Three approaches:

1. **Full dark theme** — invert every token, carefully pick dark surface colors, ensure teal contrast on dark backgrounds. Significant design work with no DESIGN.md guidance.

2. **Skeleton dark theme** — create a `darkTheme` with reasonable inverted values (dark surfaces, light text, same teal accent). Functional but not polished. Refined during T-38 (UI Polish).

3. **Light only** — ignore dark theme until DESIGN.md defines it.

**My recommendation:** Option 2 — skeleton dark theme. We honor the T-01 spec (light + dark) without over-investing in something that has no design guidance yet. The dark theme values would be:

| Token | Dark Value | Rationale |
|-------|-----------|-----------|
| `background` | `#1A1D1E` | Reuse Deep Ink as base |
| `surface` | `#242828` | Slightly lighter, teal-tinted |
| `textPrimary` | `#F0EFED` | Inverted Warm Stone |
| `textSecondary` | `#9CA3A3` | Warm gray, lighter |
| `primary` | `#0D9488` | Same teal — works on dark |
| Semantic colors | Same values | Already vibrant enough for dark |

This gives us a working dark toggle without guessing at design intent. T-38 can refine it.

Agree?

### User Input

Option 2 confirmed — skeleton dark theme only.

Proposed values are good. Two small tweaks:

1. `surface` dark (#242828) — the teal tint is too subtle at this 
   chroma to read as intentional. Use #232827 (nudge hue 175 slightly 
   more visible) or just keep #242828 — not worth overthinking at 
   skeleton stage.

2. `textSecondary` dark (#9CA3A3) — slightly too cool. Use #9CA09E 
   to stay warm-shifted, consistent with the light theme decision 
   from Question 6.

Everything else approved as proposed.

One implementation note: wrap all dark values in a 
`ThemeData.dark()` with `colorScheme.copyWith(...)` — do NOT 
duplicate the entire theme definition. The dark theme should only 
override what changes; everything structural (text styles, shape, 
component themes) inherits from the light theme base.

Mark dark theme as `// TODO: T-38 polish pass` with a comment 
so it's findable later.


### Planner Response

Excellent — dark theme decisions locked in:
- `surface` dark: `#242828` (not overthinking at skeleton stage)
- `textSecondary` dark: `#9CA09E` (warm-shifted)
- Implementation via `ThemeData.dark().copyWith(...)` — no duplication
- `// TODO: T-38 polish pass` comment on dark theme block

Now T-02.

## Question 11

**T-02: The `Failure` sealed class — should it carry a `message` string, an `errorCode`, both, or something else?**

CLAUDE.md shows `Either<Failure, T>` as the return type and lists `NetworkFailure`, `DatabaseFailure`, `AuthFailure`, `UnexpectedFailure`. But it doesn't specify what fields each carries. Options:

1. **`message` only** — simple. `sealed class Failure { String get message; }`
2. **`message` + `code`** — more structured. Useful for mapping Supabase `PostgrestException.code` or auth error codes for conditional handling.
3. **`message` + `stackTrace`** — useful for debugging, but leaking stack traces to the UI is a code smell.

**My recommendation:** Option 2 — `message` + optional `code`. Here's the shape:

```dart
sealed class Failure {
  const Failure({required this.message, this.code});
  final String message;
  final String? code;
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});
}
```

The `code` lets repository/provider layers react to specific error types (e.g. `AuthFailure` with code `'user-not-found'` → show different message than `'invalid-password'`). But it stays optional so simple cases don't need it.

Agree, or different shape?

### User Input

Option 2 approved — message + optional code is the right shape.

One addition: include stackTrace as a third optional field, 
for internal logging only — never surfaced to UI.

Final shape:

sealed class Failure {
  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final StackTrace? stackTrace;
}

Reason: when UnexpectedFailure hits in production, you need the 
trace to debug it. Without it you only have the message string, 
which for Supabase exceptions is often useless ("undefined").

Usage rule (add to CLAUDE.md as a note):
- message → shown to user (or mapped to a user-friendly string)
- code    → used by repository/provider for conditional logic
- stackTrace → passed to debugPrint() or Logger only, never to UI

Also add one more subclass not in CLAUDE.md:

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code, super.stackTrace});
}

Needed for T-10 (avatar upload) and T-19 (CV PDF upload) — 
Supabase Storage errors are distinct from database errors and 
you'll want to handle them separately.

Proceed.

### Planner Response

Locked in — `Failure` with `message` + `code?` + `stackTrace?`, plus 5 subclasses: `NetworkFailure`, `DatabaseFailure`, `AuthFailure`, `StorageFailure`, `UnexpectedFailure`.

## Question 12

**T-02: "Either helpers" — CLAUDE.md uses `Either<Failure, T>` but `Either` isn't a Dart built-in. Which package provides it, and what helpers do we need?**

`Either` comes from functional programming packages. Options:

1. **`dartz`** — the classic Dart FP package. Provides `Either`, `Left`, `Right`, `Option`, etc. Widely used but heavy (lots of FP abstractions you won't use). **Not in the approved package list.**

2. **`fpdart`** — modern alternative, tree-shakeable. Also not in the approved list.

3. **Hand-roll a minimal `Either`** — write our own `Either<L, R>`, `Left`, `Right` in `core/`. ~30 lines of code. No extra dependency. Perfectly adequate since we only use `Either` for `Failure | T` returns.

**My recommendation:** Option 3 — hand-roll it. The project only needs `Either`, `Left`, `Right`, and a `fold` method. Adding a full FP library for one type is overkill, and it avoids adding an unapproved package. The helper file would include:

```dart
// core/utils/either.dart
sealed class Either<L, R> {
  const Either();
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
}

class Left<L, R> extends Either<L, R> { ... }
class Right<L, R> extends Either<L, R> { ... }
```

Plus extension helpers like `.isLeft`, `.isRight`, `.getRight()` in `core/extensions/either_extensions.dart`.

Agree, or do you want to add `dartz`/`fpdart` to the approved list?

### User Input

Hand-roll confirmed. Don't add dartz or fpdart — the project 
only uses Either for one purpose and a full FP library adds 
concepts (Option, Task, IO) the team doesn't need and won't 
understand at Fresher level.

Approve the proposed shape with two additions:

1. Add a `map` method — you'll need it to transform Right values 
   without unwrapping manually:

extension EitherExtensions<L, R> on Either<L, R> {
  Either<L, T> map<T>(T Function(R) f) =>
      fold((l) => Left(l), (r) => Right(f(r)));
}

2. Add a `getOrElse` helper — common pattern in providers:

R getOrElse(R Function(L) orElse) =>
    fold((l) => orElse(l), (r) => r);

Skip `flatMap`/`bind` for now — you won't need monadic chaining 
at this project's complexity. Add it in T-38 if it comes up.

File structure:
- core/utils/either.dart          ← Either, Left, Right classes
- core/extensions/either_ext.dart ← map, getOrElse, isLeft, isRight

Also add a note to CLAUDE.md:
// Either usage: Left = failure path, Right = success path
// Never throw inside a repository — always return Left(Failure)

Proceed.

### Planner Response

Locked — hand-rolled `Either` with `fold`, `map`, `getOrElse`, `isLeft`, `isRight`. No `flatMap`. File split as specified.

## Question 13

**T-02: `BuildContext` extensions — what should they expose?**

T-02 mentions `BuildContext` extensions. These are convenience shortcuts to avoid verbose `Theme.of(context)` calls everywhere. What should be in scope for the foundation layer?

**My recommendation** — keep it minimal, only theme/media shortcuts that every feature will use:

```dart
// core/extensions/build_context_ext.dart
extension BuildContextExt on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  
  // Media query shortcuts
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  
  // Navigation shortcut (go_router)
  GoRouter get router => GoRouter.of(this);
}
```

**What I'm NOT including:**
- `showSnackBar` extension — that's feature-level, not core
- `AppColors` direct access — go through `colorScheme` instead for theme-aware colors
- Localization helpers — no i18n in this project

This keeps the extension focused on things that are stable and universally needed. Feature-specific extensions can live in their own feature folders.

Agree, or want to add/remove anything?

### User Input

Agreed

### Planner Response

Good. Now T-03.

## Question 14

**T-03: The bottom navigation bar — which tabs should it have, and for which role?**

T-03 says `ShellRoute` for bottom nav. But Seeker, Recruiter, and Admin have very different navigation needs. BRIEF.md features suggest:

**Seeker tabs:**
1. **Home** — job feed / "For You" AI tab
2. **Search** — job search + filters
3. **Applications** — my applications tracking
4. **Chat** — conversations
5. **Profile** — my profile

**Recruiter tabs:**
1. **Dashboard** — my job posts overview
2. **Applicants** — incoming applications
3. **Chat** — conversations
4. **Profile** — company profile

**Admin tabs:**
1. **Dashboard** — stats
2. **Users** — user management
3. **Job Review** — pending posts
4. **Reports** — violation reports

**The question:** Should T-03 implement all three shells, or just one placeholder shell?

**My recommendation:** At T-03 we're building a **skeleton** — no auth logic exists yet (that's T-06/T-07). Build **one Seeker shell** with the 5 tabs above as placeholder pages (just a `Scaffold` with centered text saying the page name). The Recruiter and Admin shells get added when those features are built (T-13, T-33).

The `AuthGuard` at this stage simply checks a hardcoded `isLoggedIn = false` and redirects to `LoginPage` — a skeleton placeholder that will be replaced in T-07.

Agree, or do you want all three shells now?

### User Input

Confirmed — Seeker shell only at T-03. One addition on structure:

Build the ShellRoute with a `currentRole` hook point from day one,
even though it's hardcoded now. This prevents a painful refactor 
in T-07 when real auth lands.

Concrete approach — in AppRouter:

// T-03: hardcoded, replaced in T-07
UserRole _resolveRole() => UserRole.seeker;

ShellRoute picks which bottom nav to render based on _resolveRole().
When T-07 ships, this becomes:
UserRole _resolveRole() => ref.read(authProvider).role;

No other file changes needed — the hook point was always there.

Seeker tabs approved as proposed:
1. Home       → HomePage        (placeholder: 'Trang chủ')
2. Search     → SearchPage      (placeholder: 'Tìm việc')
3. Applications → ApplicationsPage (placeholder: 'Đơn ứng tuyển')
4. Chat       → ConversationsPage (placeholder: 'Tin nhắn')
5. Profile    → ProfilePage     (placeholder: 'Hồ sơ')

Each placeholder = Scaffold + Center(child: Text(AppStrings.xxx))
No actual widgets yet — those belong in their feature tasks.

AuthGuard: hardcoded isLoggedIn = false → redirect to LoginPage.
LoginPage = Scaffold + Center(child: Text('Login placeholder'))

Do NOT implement any login form in T-03 — that belongs in T-06.

Proceed.

*Viewed [TASKS.md](file:///f:/CODE/LTDD/TASKS.md) *

### Planner Response

All T-03 decisions locked — Seeker shell, `_resolveRole()` hook, 5 tabs, skeleton guard.

## Question 15

**T-03: Where do the placeholder pages live — in `core/` or in their future `features/` folders?**

This is an architectural question. T-03 creates placeholder pages (`HomePage`, `SearchPage`, `ApplicationsPage`, `ConversationsPage`, `ProfilePage`, `LoginPage`). Each of these will eventually belong to a feature:

- `HomePage` → `features/jobs/presentation/pages/`
- `SearchPage` → `features/jobs/presentation/pages/`
- `ApplicationsPage` → `features/application/presentation/pages/`
- `ConversationsPage` → `features/chat/presentation/pages/`
- `ProfilePage` → `features/profile/presentation/pages/`
- `LoginPage` → `features/auth/presentation/pages/`

Options:

1. **Create them in their final feature locations now** — means creating partial `features/` folder structures in T-03 (before scaffold tasks exist for those features).

2. **Put them in a temporary `core/router/placeholder_pages/` folder** — move them to features when those features are built. Clean, but creates tech debt (file moves = import changes).

3. **Put them in `shared/widgets/placeholder_page.dart`** — a single generic `PlaceholderPage(title: 'Trang chủ')` widget, replaced in-place when each feature lands.

**My recommendation:** Option 3. One reusable `PlaceholderPage` widget in `shared/widgets/`. No premature folder creation, no file moves later. When T-06 ships `LoginPage`, it replaces the route target directly. Zero tech debt.

```dart
// shared/widgets/placeholder_page.dart
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});
  final String title;
  // → Scaffold + Center + Text(title)
}
```

Agree?

### User Input

Option 3 confirmed — single PlaceholderPage widget, no premature 
folder creation.

Approve the proposed shape exactly as written. One small addition:

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: AppTextStyles.headline,
        ),
      ),
    );
  }
}

Use AppTextStyles.headline — not a hardcoded TextStyle. Even 
placeholder pages must follow CLAUDE.md style rules. This also 
validates that AppTextStyles from T-01 is correctly wired.

Router replacement pattern when a real page lands:
// Before (T-03):
GoRoute(path: '/login', builder: (_, __) => 
  const PlaceholderPage(title: 'Đăng nhập'))

// After T-06 ships:
GoRoute(path: '/login', builder: (_, __) => const LoginPage())

One line change, zero import cascades, zero file moves.

Also note: PlaceholderPage stays in the codebase permanently —
it's useful for T-13, T-33 Recruiter/Admin shells when those 
routes are added. Don't delete it after T-06.

Proceed

### Planner Response

Locked — `PlaceholderPage` in `shared/widgets/`, uses `AppTextStyles.headline`, stays permanently. One-line swap when real pages land.

## Question 16

**T-00: `analysis_options.yaml` — use the default `flutter_lints` rules as-is, or customize?**

CLAUDE.md lists `flutter_lints: ^3.0.0` in dev_dependencies. The default `include: package:flutter_lints/flutter.yaml` gives a baseline, but there are rules worth enabling that align with CLAUDE.md's code style mandates:

- `prefer_const_constructors` — CLAUDE.md says "Luôn dùng `const`"
- `prefer_final_locals` — CLAUDE.md says "Ưu tiên `final` hơn `var`"
- `avoid_dynamic_calls` — CLAUDE.md says "Không dùng `dynamic`"
- `always_declare_return_types` — type everything
- `sort_constructors_first` — readability

**My recommendation:** Include `flutter_lints` as the base, then add a small `linter > rules` block enabling the rules above. This makes the linter **enforce** what CLAUDE.md already demands, so violations are caught by `flutter analyze` before review.

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
```

Keep it short — no need for 50 custom rules at foundation stage. Add more during T-39 (final review) if needed.

Agree?

### User Input

Approved — base flutter_lints + the 7 rules proposed.

Add two more that directly enforce CLAUDE.md rules already written:

    avoid_print: true          # CLAUDE.md forbids print() explicitly
    prefer_single_quotes: true # Dart convention, prevents style drift
                               # across 3 team members

Final analysis_options.yaml:

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

`avoid_print` matters because without it a teammate can commit 
print() statements and flutter analyze won't catch it — only 
manual review would. Since CLAUDE.md already mandates debugPrint(),
the linter should enforce it automatically.

`prefer_single_quotes` prevents the situation where one teammate 
writes "Đăng nhập" and another writes 'Đăng nhập' — dart format 
won't fix quote style, only this rule will.

Do NOT add more rules now. T-39 is the right time to evaluate 
stricter rules like `always_use_package_imports` or 
`prefer_relative_imports` after the codebase has real shape.

Proceed

### Planner Response

Locked — 9 lint rules total, no more until T-39.

## Question 17

**T-00: What organization name for `flutter create`?**

`flutter create` accepts `--org` which sets the Android package name (`com.example.job_connect`) and iOS bundle identifier. This is **painful to change later** — it's baked into `AndroidManifest.xml`, `build.gradle`, folder structure, and iOS project files.

`com.example` is the default and is **not valid** for publishing to Play Store or App Store. Since BRIEF.md says this is a portfolio project meant to "demo cho nhà tuyển dụng", you might want a real-ish org name.

**My recommendation:** Use something like `com.jobconnect` or your team's/personal domain reversed. For example:

- `com.jobconnect` — simple, project-focused
- `com.yourname.ltdd` — personal, ties to the course

If you have no preference or no personal domain, `com.jobconnect` works fine for a portfolio project.

What org name do you want?

### User Input

Yeah, i prefer com.jobconnect

### Planner Response

`com.jobconnect` it is. Android package: `com.jobconnect.job_connect`.

## Question 18

**T-01: What goes into `AppConstants` at the foundation stage?**

T-01 mentions `core/constants/`: `AppConstants`, `AppStrings`. We've defined `AppStrings` (Vietnamese UI text). But what belongs in `AppConstants`?

Options for what to include now vs. later:

**Include now (used by T-00 through T-03):**
```dart
class AppConstants {
  const AppConstants._();
  
  // Supabase (accessed via --dart-define, centralized here)
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // App metadata
  static const appName = 'JobConnect';
}
```

**Defer to later tasks:**
- `geminiKey` → T-24 (AI embedding pipeline)
- Storage paths (`avatars/{userId}/`) → T-10 (profile CRUD)
- Rate limits, TTL values → T-24/T-25 (AI features)
- `promptTemplates` → T-24 (separate file per CLAUDE.md)

**My recommendation:** Keep `AppConstants` minimal — only `supabaseUrl`, `supabaseAnonKey`, and `appName` for now. Constants grow organically as features land. An empty-looking constants file is better than speculative constants that might change.

Agree?

### User Input

Confirmed — minimal AppConstants, exactly as proposed.

One addition: include two layout constants that T-03 needs 
immediately for the bottom nav and will be referenced everywhere:

  // Layout
  static const bottomNavHeight = 64.0;
  static const defaultPadding = 16.0;
  static const cardBorderRadius = 12.0;

These are used in PlaceholderPage, ShellRoute, and every screen 
from T-06 onward. Defining them now prevents 3 teammates 
independently hardcoding 16.0, 15.0, and 18.0 in different files.

Final AppConstants for T-01:

class AppConstants {
  const AppConstants._();

  // Environment — via --dart-define
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // App
  static const appName = 'JobConnect';

  // Layout
  static const bottomNavHeight = 64.0;
  static const defaultPadding = 16.0;
  static const cardBorderRadius = 12.0;
}

Everything else (geminiKey, storage paths, rate limits, 
prompt templates) deferred to their respective tasks exactly 
as proposed. Do not pre-fill speculative constants.

Also create .env.example in project root now:
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
GEMINI_KEY=your-gemini-key

And add .env to .gitignore immediately — before first commit.


### Planner Response

Locked — `AppConstants` with 6 constants, `.env.example` at root, `.env` in `.gitignore`.

## Question 19

**T-03: What route paths should the app use?**

`go_router` needs explicit path strings. These become the URL structure and affect deep linking. Let me propose a scheme:

| Route | Path | Page |
|-------|------|------|
| Login | `/login` | PlaceholderPage('Đăng nhập') |
| **Shell (bottom nav)** | | |
| Home | `/` | PlaceholderPage('Trang chủ') |
| Search | `/search` | PlaceholderPage('Tìm việc') |
| Applications | `/applications` | PlaceholderPage('Đơn ứng tuyển') |
| Conversations | `/conversations` | PlaceholderPage('Tin nhắn') |
| Profile | `/profile` | PlaceholderPage('Hồ sơ') |

Key decisions:
- **Home at `/`** — the root route is the default landing for authenticated users
- **Login at `/login`** — outside the shell (no bottom nav)
- All paths are flat (no nesting like `/seeker/home`) — sub-paths come when features add detail pages (e.g. `/search/:jobId` in T-17)

**My recommendation:** Use these flat paths. Nesting by role (`/seeker/`, `/recruiter/`) is tempting but adds complexity for zero benefit — the `_resolveRole()` hook already controls which shell renders, so the URL doesn't need to encode the role.

Agree?

### User Input

Flat paths approved exactly as proposed. No role prefixing.

One addition — register route for new users, outside the shell:

| Register | /register | PlaceholderPage('Đăng ký') |

It's needed in T-03 because the AuthGuard redirects unauthenticated 
users to /login, and /login will have a "Create account" link to 
/register. Without the route defined now, go_router will throw.

Final route table for T-03:
- /           → Home (shell)
- /search     → Search (shell)
- /applications → Applications (shell)
- /conversations → Conversations (shell)
- /profile    → Profile (shell)
- /login      → outside shell
- /register   → outside shell

Sub-routes (/search/:jobId, /profile/edit etc.) added in their 
respective feature tasks. Not now.

Grill is fully done across all tasks in this batch.
Now give me a single implementation prompt covering T-00, T-01, 
T-02, and T-03 together — all decisions are locked, implement 
exactly what was agreed across questions 1–19. No new decisions. 
If anything is ambiguous, use what was decided — do not ask again.

### Planner Response

Grill complete — 19 questions, all decisions locked. Here's the implementation plan:

*Edited relevant file*

### Planner Response

Grill session complete — **19 decisions resolved, zero ambiguity remaining**.

The implementation plan is ready for your review. It covers all four tasks with every decision from our grilling baked in:

- **T-00:** `flutter create`, 15 deps + 5 dev deps (no Firebase yet), 9 lint rules, `.env.example`
- **T-01:** Resolved color palette, 5 type sizes, Plus Jakarta Sans local font, skeleton dark theme, `AppConstants` + `AppStrings`
- **T-02:** Sealed `Failure` (5 subclasses, 3 fields), hand-rolled `Either`, `BuildContext` extensions
- **T-03:** Flat route paths (7 routes), Seeker shell (5 tabs), `_resolveRole()` hook, `PlaceholderPage` in `shared/`

**13 Dart files, 5 font files, 2 config files total.**

Review the plan and approve when ready to execute.

### User Input

Gap 1 — Missing bodySmall text style (decided Q7)
The plan has 5 styles but the grill locked in 6:
bodySmall: 12sp / 400 / 1.4  ← missing from AppTextStyles
Gap 2 — Missing 3 strings from AppStrings (decided Q9)
The plan's AppStrings has 8 strings but the grill explicitly added:
dartstatic const loading = 'Đang tải...';
static const errorGeneral = 'Đã có lỗi xảy ra';
static const retry = 'Thử lại';
Gap 3 — Missing 2 color tokens (decided Q6)
The plan's color table has 9 tokens but is missing:
surfaceVariant → #F1F0ED  (elevated sheets, bottom sheet bg)
divider        → #E8E6E1  (borders, dividers)

*Viewed [implementation_plan.md](file:///C:/Users/Admin/.gemini/antigravity/brain/43e37740-5f9b-40b5-a6d6-5098c9c81ea4/implementation_plan.md) *

*Edited relevant file*

### Planner Response

The implementation plan has been updated with the three gaps you identified:
1. `bodySmall` (12sp / 400 / 1.4) is added to the text styles table.
2. `loading`, `errorGeneral`, and `retry` have been added to `AppStrings`.
3. `surfaceVariant` (`#F1F0ED`) and `divider` (`#E8E6E1`) are now in the `AppColors` table.

Please take a look at the updated plan, and if everything is correct, give me the green light to start the execution phase!

### User Input

Ready to @[/grill-me] T-04 + T-05.

T-04: Supabase schema migration (all 22 tables + pgvector)
T-05: RLS policies for all tables

Read @[BRIEF.md] section 7 (database schema) before asking.
Grill me on every decision that could cause security issues 
or painful migrations later. One question at a time.

### Planner Response

I've got BRIEF.md §7 fresh in mind. Let's grill on the database layer — this is where bad decisions are the most expensive to fix.

---

## Question 1

**T-04: `profiles.id` — should it be a foreign key referencing `auth.users.id`, and should it use the same UUID?**

Supabase Auth creates users in `auth.users` (with a UUID `id`). Your `profiles` table has an `id` column. The critical question is how these link.

**Option A:** `profiles.id` = `auth.users.id` (same UUID, FK reference). The standard Supabase pattern. `profiles.id` is both the PK and an FK to `auth.users.id`. No separate `user_id` column needed.

**Option B:** `profiles.id` is an independent UUID with a separate `user_id` column referencing `auth.users.id`. Adds indirection.

**My recommendation:** Option A. This is the canonical Supabase pattern. Every RLS policy uses `auth.uid()` to get the current user, and if `profiles.id = auth.uid()`, lookups are trivial:

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
  ...
);
```

Every other table that references "a user" (e.g. `work_experiences.user_id`, `applications.seeker_id`) would FK to `profiles.id`, which transitively links to `auth.users.id`.

`ON DELETE CASCADE` means deleting the auth user cleans up the profile automatically.

Agree?

### User Input

Option A confirmed — profiles.id = auth.users.id, same UUID, 
FK with ON DELETE CASCADE. Standard Supabase pattern.

Two additions to the profiles table definition:

1. Add ON DELETE CASCADE to all child tables that reference 
   profiles.id — not just profiles itself. Decide the cascade 
   strategy for each now so we don't patch it per-table later:

   - work_experiences.user_id  → ON DELETE CASCADE (owned data)
   - educations.user_id        → ON DELETE CASCADE (owned data)
   - certificates.user_id      → ON DELETE CASCADE (owned data)
   - user_skills.user_id       → ON DELETE CASCADE (owned data)
   - resumes.user_id           → ON DELETE CASCADE (owned data)
   - applications.seeker_id    → ON DELETE CASCADE (owned data)
   - bookmarks.seeker_id       → ON DELETE CASCADE (owned data)
   - saved_searches.user_id    → ON DELETE CASCADE (owned data)
   - notifications.user_id     → ON DELETE CASCADE (owned data)
   - device_tokens.user_id     → ON DELETE CASCADE (owned data)
   - profile_embeddings.user_id → ON DELETE CASCADE (owned data)
   - conversations.*           → ON DELETE SET NULL (preserve 
                                  chat history for the other party)
   - messages.sender_id        → ON DELETE SET NULL (same reason)
   - company_reviews.reviewer_id → ON DELETE SET NULL (preserve 
                                    reviews for other users to read)

2. Add created_at to profiles with server-side default:
   created_at TIMESTAMPTZ NOT NULL DEFAULT now()
   
   Never let the app set timestamps — always DB-side DEFAULT now().

Proceed to question 2.

### Planner Response

Locked — full cascade strategy documented, server-side `DEFAULT now()` for all timestamps. 

## Question 2

**T-04: `profiles.role` — how should it be enforced, and can a user change their own role?**

CONTEXT.md defines three roles: `seeker`, `recruiter`, `admin`. This column is security-critical — it controls what the user can see and do across the entire app. Three concerns:

### 2a: Storage type

**Option A:** `TEXT` with a `CHECK` constraint — `CHECK (role IN ('seeker', 'recruiter', 'admin'))`. Simple, no custom type to manage.

**Option B:** PostgreSQL `ENUM` type — `CREATE TYPE user_role AS ENUM ('seeker', 'recruiter', 'admin')`. Stricter, but adding a new role later requires `ALTER TYPE ... ADD VALUE` which can't run inside a transaction.

**My recommendation:** Option A — `TEXT` + `CHECK`. Easier to migrate if roles change, no enum hassle, and the CHECK constraint still prevents garbage values.

### 2b: Can a user change their own role via RLS?

This is the real security question. If a Seeker can `UPDATE profiles SET role = 'admin' WHERE id = auth.uid()`, your entire authorization model collapses.

**My recommendation:** The RLS `UPDATE` policy on `profiles` must explicitly **exclude** the `role` column from user-writable fields. Two approaches:

1. RLS policy with `USING (id = auth.uid())` + a separate trigger that prevents `role` changes
2. Use a column-level grant (revoke UPDATE on `profiles.role` from `authenticated`)

Option 1 (trigger) is more common in Supabase since column-level grants can be tricky with the `authenticated` role.

### 2c: Who sets the role initially?

During registration (T-06), the user picks Seeker or Recruiter. The `role` is set when the profile row is created. After that, only an Admin should be able to change it.

**My recommendation:** Allow `INSERT` with role, block `UPDATE` of role via trigger, Admin bypasses via service_role key.

Agree with all three sub-decisions?

### User Input

All three sub-decisions confirmed.

2a: TEXT + CHECK constraint. Approved as proposed.

2b: Use trigger approach (Option 1) to block role updates.
Trigger definition to include in T-04 migration:

CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role <> OLD.role THEN
    RAISE EXCEPTION 'Role changes are not permitted. 
    Contact an administrator.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER enforce_role_immutable
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_role_change();

2c: Confirmed — user sets role on INSERT during registration,
trigger blocks all subsequent UPDATE on role column,
Admin bypasses via service_role key (never via RLS).

One addition: add an index on profiles.role now — RLS policies
will filter by role constantly and a full table scan on every
auth check is expensive at scale:

CREATE INDEX idx_profiles_role ON profiles(role);

Proceed to question 3.

### Planner Response

Locked — TEXT + CHECK, trigger to block role mutation, index on `profiles.role`.

## Question 3

**T-04: Primary key types — UUID everywhere, or serial/bigserial for some tables?**

BRIEF.md shows `id` on most tables but doesn't specify the type. Two approaches:

**Option A: UUID everywhere** — `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`. Consistent, no sequential guessing, safe for client-side generation, standard Supabase pattern.

**Option B: UUID for user-facing entities, serial/bigserial for internal tables.** For example, `messages.id` could be `BIGSERIAL` since messages are never exposed in URLs and a sequential ID is cheaper for sort/range queries on high-volume tables.

**My recommendation:** Option A — UUID everywhere. Reasons:

1. **Consistency** — one pattern for the whole team, no "which tables use which type" confusion
2. **Supabase convention** — Supabase's client library, RLS, and realtime all work naturally with UUIDs
3. **Security** — no enumeration attacks (can't guess `/messages/1`, `/messages/2`)
4. **Scale** — this is a portfolio project, not a billion-row system. The performance difference between UUID and bigserial is irrelevant at this scale

The only exceptions are:
- `profile_embeddings.user_id` — already a UUID (PK = FK to profiles)
- `job_embeddings.job_id` — already a UUID (PK = FK to job_posts)
- `user_skills` and `job_required_skills` — these are junction tables, which brings us to the next question about composite PKs

Agree with UUID everywhere (except junction tables, discussed next)?

### User Input

UUID everywhere confirmed — gen_random_uuid() as default on all 
id columns. No bigserial exceptions, not even for messages.

Rationale locked: consistency over micro-optimization, portfolio 
scale doesn't justify the added mental overhead for the team.

One implementation note for T-04:

Enable the pgcrypto extension alongside pgvector — 
gen_random_uuid() requires it on some Supabase versions:

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

Put both extension statements at the top of the migration 
file before any CREATE TABLE statements.

Junction tables (user_skills, job_required_skills) — 
agree they need separate discussion. Proceed to that next.

### Planner Response

Locked — UUID everywhere, `pgcrypto` + `vector` extensions at top of migration.

## Question 4

**T-04: Junction tables (`user_skills`, `job_required_skills`) — composite PK or separate UUID `id`?**

BRIEF.md shows:
```
user_skills          (user_id, skill_id, level)
job_required_skills  (job_id, skill_id, is_required)
```

No `id` column listed. Two approaches:

**Option A: Composite PK** — `PRIMARY KEY (user_id, skill_id)`. Natural key. Enforces uniqueness automatically (a user can't add the same skill twice). No extra column. Standard relational pattern for many-to-many.

**Option B: UUID `id` PK + unique constraint** — `id UUID PK`, plus `UNIQUE (user_id, skill_id)`. More columns, but consistent with "every table has an `id`" and simpler for Supabase client CRUD (`.delete().eq('id', id)` vs `.delete().eq('user_id', x).eq('skill_id', y)`).

**My recommendation:** Option A — composite PK for both. Reasons:

1. These are pure junction tables with no independent identity — a "user_skill" is meaningless without both `user_id` and `skill_id`
2. Uniqueness is free (PK enforces it)
3. The Supabase client handles composite deletes fine: `.delete().eq('user_id', x).eq('skill_id', y)`
4. Adding a UUID `id` to a junction table is a code smell — it implies the row has an independent lifecycle, which it doesn't

```sql
CREATE TABLE user_skills (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
  level TEXT NOT NULL CHECK (level IN ('beginner', 'intermediate', 'advanced')),
  PRIMARY KEY (user_id, skill_id)
);

CREATE TABLE job_required_skills (
  job_id UUID REFERENCES job_posts(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
  is_required BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (job_id, skill_id)
);
```

Note: `skills ON DELETE CASCADE` means if a skill is removed from the lookup table, all user_skills and job_required_skills referencing it are cleaned up automatically.

Agree?

### User Input

Composite PK confirmed for both junction tables. 
Definitions approved exactly as proposed.

Two additions:

1. Add ON DELETE CASCADE to skills references — approved as 
   proposed. But also think about WHO can delete from the skills 
   lookup table. Since skills is a master list, only Admin should 
   be able to delete skills. If a skill gets deleted carelessly, 
   every user who has that skill silently loses it from their 
   profile with no warning. Add a note in the migration:

   -- WARNING: deleting from skills cascades to user_skills 
   -- and job_required_skills. Admin only via service_role.

2. Add indexes on the FK columns not covered by the composite PK:

   CREATE INDEX idx_user_skills_skill_id 
     ON user_skills(skill_id);
   CREATE INDEX idx_job_required_skills_skill_id 
     ON job_required_skills(skill_id);

   The composite PK (user_id, skill_id) already covers queries 
   like "get all skills for user X". But queries like "find all 
   users who have skill Y" (needed for AI matching) scan skill_id 
   — without an index this is a full table scan.

   Same logic applies to job_required_skills — "find all jobs 
   requiring skill Y" needs the skill_id index.

Proceed to question 5.

### Planner Response

Locked — composite PKs, skill deletion warning, reverse-lookup indexes on `skill_id`.

## Question 5

**T-04: Which tables need unique constraints to prevent duplicate data?**

BRIEF.md and CONTEXT.md describe several business rules that imply uniqueness beyond PKs. Missing unique constraints = duplicate data bugs that are painful to fix retroactively. Let me walk through each:

| Table | Candidate unique constraint | Business rule |
|-------|----------------------------|---------------|
| `

### Planner Response

Locked — composite PKs, skill deletion warning, reverse-lookup indexes on `skill_id`.

## Question 5

**T-04: Which tables need unique constraints to prevent duplicate data?**

Several business rules imply uniqueness beyond PKs. Missing these = duplicate data bugs that are painful to fix after data exists.

[ignoring loop detection]

Here are the candidates I've identified:

1. **`bookmarks(seeker_id, job_id)`** — a Seeker can't bookmark the same Job Post twice. Without this, the toggle logic creates duplicates.

2. **`applications(job_id, seeker_id)`** — BRIEF.md says "Chặn apply trùng". A Seeker can't apply to the same Job Post twice.

3. **`conversations(seeker_id, recruiter_id, job_id)`** — one conversation per Seeker-Recruiter-JobPost tuple. Without this, "create conversation if not exists" creates duplicates under race conditions.

4. **`device_tokens(user_id, fcm_token)`** — same device shouldn't register the same token twice for one user.

5. **`companies(recruiter_id)`** — does one Recruiter own exactly one Company? BRIEF.md shows `companies.recruiter_id` but doesn't clarify cardinality. If 1:1, add `UNIQUE(recruiter_id)`.

**My recommendation:** Add `UNIQUE` constraints on all five. For companies, I assume 1 Recruiter = 1 Company based on the app flow (T-13 shows a single "CompanyProfilePage", not a company list).

```sql
ALTER TABLE bookmarks ADD UNIQUE (seeker_id, job_id);
ALTER TABLE applications ADD UNIQUE (job_id, seeker_id);
ALTER TABLE conversations ADD UNIQUE (seeker_id, recruiter_id, job_id);
ALTER TABLE device_tokens ADD UNIQUE (user_id, fcm_token);
ALTER TABLE companies ADD UNIQUE (recruiter_id);
```

Agree with all five, or should any be dropped/modified?

### User Input

Constraints 1, 2, 4, 5 approved exactly as proposed.

Constraint 3 (conversations) — modify slightly:

UNIQUE (seeker_id, recruiter_id, job_id) assumes every 
conversation is tied to a specific job post. But in T-28, 
a Seeker can also initiate chat from their applications page 
after the job post has expired or been deleted. If job_id is 
part of the unique key and is NOT NULL, this breaks.

Change to:

ALTER TABLE conversations 
  ADD UNIQUE (seeker_id, recruiter_id, job_id);

-- AND make job_id nullable in the table definition:
-- job_id UUID REFERENCES job_posts(id) ON DELETE SET NULL

This way:
- Active job conversation: (seeker_A, recruiter_B, job_123) ✅
- Post-expiry conversation: (seeker_A, recruiter_B, NULL)  ✅
- Two nulls don't collide in PostgreSQL UNIQUE constraints 
  (NULL != NULL in SQL) so multiple NULL job_ids are allowed —
  which is correct behavior.

Final 5 constraints approved with this modification.

Also add one more missed constraint:

6. device_tokens(fcm_token) — token itself must be globally 
   unique, not just per user. Same physical device could 
   theoretically re-register under a different user after 
   logout/login. Add:

   ALTER TABLE device_tokens ADD UNIQUE (fcm_token);

   This also forces cleanup of old tokens on re-login 
   (upsert on conflict fcm_token → update user_id).

Total: 6 unique constraints. Proceed to question 6.

### Planner Response

Locked — 6 unique constraints, `conversations.job_id` nullable with `ON DELETE SET NULL`, `device_tokens.fcm_token` globally unique for upsert on re-login.

## Question 6

**T-04: Which columns need CHECK constraints for valid values?**

BRIEF.md and CONTEXT.md define several columns with finite value sets. Without CHECK constraints, the app can write garbage data that passes RLS but breaks business logic. Here's every column I've identified:

1. **`profiles.role`** — already decided: `CHECK (role IN ('seeker', 'recruiter', 'admin'))`

2. **`user_skills.level`** — already decided: `CHECK (level IN ('beginner', 'intermediate', 'advanced'))`

3. **`job_posts.status`** — CONTEXT.md defines the flow: `CHECK (status IN ('draft', 'pending_review', 'active', 'closed', 'rejected'))`

4. **`job_posts.type`** — employment type. BRIEF.md mentions "full-time/part-time/remote" in T-16 filter: `CHECK (type IN ('full_time', 'part_time', 'contract', 'internship', 'remote'))`

5. **`applications.status`** — CONTEXT.md flow: `CHECK (status IN ('pending', 'reviewing', 'interview', 'accepted', 'rejected', 'withdrawn'))`

6. **`interview_schedules.status`** — needs a status for the interview itself: `CHECK (status IN ('scheduled', 'completed', 'cancelled'))`

7. **`reports.status`** — moderation workflow: `CHECK (status IN ('pending', 'resolved', 'dismissed'))`

8. **`reports.target_type`** — polymorphic reference type: `CHECK (target_type IN ('user', 'job_post', 'company'))`

9. **`notifications.type`** — notification categories: `CHECK (type IN ('application_status', 'new_applicant', 'job_alert', 'interview', 'message', 'system'))`

10. **`device_tokens.platform`** — `CHECK (platform IN ('android', 'ios'))`

**My recommendation:** Add all 10. TEXT + CHECK is consistent with the decision from Q2a (no enums). These constraints are the database's last line of defense — even if the app has a bug, the DB rejects invalid values.

Agree with the value lists, or need to add/remove any values?

### User Input

All 10 CHECK constraints confirmed. Two value list modifications:

1. job_posts.type — add 'hybrid' to the list:

   CHECK (type IN ('full_time', 'part_time', 'contract', 
                   'internship', 'remote', 'hybrid'))

   Hybrid (some days office, some days remote) is now the most 
   common arrangement at Vietnamese tech companies. Without it 
   Recruiters will be forced to pick 'remote' or 'full_time' 
   inaccurately, polluting Seeker search results.

2. applications.status — add 'withdrawn' clarity note but keep 
   the value list exactly as proposed. One implementation note:

   'withdrawn' can only be set by the Seeker, and only when 
   current status = 'pending'. Enforce this in the repository 
   layer (T-20), not via DB constraint — too complex for CHECK.
   Add a comment in the migration:

   -- 'withdrawn' transition: pending → withdrawn only
   -- Enforced at application layer in T-20, not DB level

Everything else approved exactly as proposed.

Final count: 10 CHECK constraints, 12 valid values for 
job_posts.type (6 types), applications.status (6 states).

Proceed to question 7.

### Planner Response

Locked — `hybrid` added to job types, withdrawal transition enforced at app layer with migration comment.

## Question 7

**T-04: Which tables need an `updated_at` column, and how should it auto-update?**

BRIEF.md only shows `created_at` on most tables and `updated_at` on embeddings. But several tables will have mutable rows that benefit from knowing *when* they last changed:

**Tables that get mutated after creation:**
- `profiles` — user edits name, bio, avatar
- `companies` — recruiter edits company info
- `job_posts` — recruiter edits, status changes
- `applications` — status transitions (pending → reviewing → ...)
- `resumes` — user edits CV content
- `interview_schedules` — status changes, rescheduling
- `reports` — status changes (pending → resolved)
- `notifications` — `read` flag changes
- `profile_embeddings` — already has `updated_at`
- `job_embeddings` — already has `updated_at`

**Tables that are insert-only (no update):**
- `work_experiences`, `educations`, `certificates` — CRUD but edits are rare, and these are small per-user sets
- `messages` — immutable once sent (only `read_at` updates)
- `bookmarks`, `saved_searches` — insert/delete, no update
- `application_notes` — insert-only by design

**My recommendation:** Add `updated_at TIMESTAMPTZ DEFAULT now()` to the first group (10 tables), plus a shared trigger to auto-update it:

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Apply this trigger to each table that has `updated_at`. This way the app never has to set `updated_at` manually — the DB handles it.

Skip `updated_at` on insert-only and rarely-mutated tables to keep the schema lean.

Agree with the split, or should any table move between groups?