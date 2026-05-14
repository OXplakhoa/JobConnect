# Phase 1 — Auth (T-06 → T-09) Implementation Plan

All decisions locked via grill Q1–Q10.

---

## Prerequisites (Manual Steps)

Before running any auth task:

1. **Supabase Dashboard → Authentication → Providers → Email:**
   - Disable "Confirm email" toggle → Save
   - Disable "Secure email change" → Save

2. **Supabase Dashboard → Authentication → URL Configuration → Redirect URLs:**
   - Add `com.jobconnect.job_connect://login-callback`

3. **Supabase Dashboard → Authentication → Providers → Google:**
   - Enable Google provider
   - Add OAuth client ID + secret from Google Cloud Console

4. **New migration file:** `supabase/migrations/20260511000002_auth_trigger.sql`
   (See Section 1 below)

---

## Section 1: Auth Migration (20260511000002_auth_trigger.sql)

### Add `is_onboarding_complete` to profiles

```sql
ALTER TABLE profiles
  ADD COLUMN is_onboarding_complete BOOLEAN NOT NULL DEFAULT false;
```

### Profile creation trigger

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  requested_role TEXT;
BEGIN
  requested_role := NEW.raw_user_meta_data->>'role';

  INSERT INTO public.profiles (id, role, full_name, avatar_url, is_onboarding_complete)
  VALUES (
    NEW.id,
    CASE
      WHEN requested_role IN ('seeker', 'recruiter')
      THEN requested_role
      ELSE 'seeker'  -- safe default, never 'admin'
    END,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',  -- Google OAuth uses 'name'
      ''
    ),
    NEW.raw_user_meta_data->>'avatar_url',  -- populated by Google OAuth
    CASE
      WHEN requested_role IN ('seeker', 'recruiter') THEN true
      ELSE false  -- Google OAuth: role not confirmed yet
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Updated role change prevention trigger

```sql
CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Check 1: admin role can NEVER be self-assigned
  IF NEW.role = 'admin' AND OLD.role != 'admin' THEN
    RAISE EXCEPTION 'Cannot self-assign admin role.';
  END IF;

  -- Check 2: role is immutable after onboarding complete
  IF NEW.role <> OLD.role AND OLD.is_onboarding_complete = true THEN
    RAISE EXCEPTION 'Role changes are not permitted. Contact an administrator.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Section 2: Feature File Structure

```
features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_datasource.dart         ← All Supabase Auth calls
│   ├── mappers/
│   │   └── auth_error_mapper.dart       ← AuthException → Failure
│   ├── models/
│   │   └── profile_model.dart           ← Freezed, maps profiles table
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── auth_state.dart              ← Sealed class (4 states)
│   │   └── user_profile.dart            ← Pure entity
│   ├── repositories/
│   │   └── auth_repository.dart         ← Abstract interface
│   └── usecases/
│       ├── register_usecase.dart         ← T-06
│       ├── login_usecase.dart            ← T-07
│       ├── google_login_usecase.dart     ← T-08
│       ├── complete_onboarding_usecase.dart ← T-08
│       ├── forgot_password_usecase.dart  ← T-09
│       └── logout_usecase.dart           ← T-09
└── presentation/
    ├── pages/
    │   ├── register_page.dart            ← T-06
    │   ├── login_page.dart               ← T-07
    │   ├── role_selection_page.dart       ← T-08 (onboarding)
    │   └── forgot_password_page.dart     ← T-09
    ├── providers/
    │   └── auth_provider.dart            ← Global auth state
    └── widgets/
        ├── auth_text_field.dart           ← Shared input widget
        └── social_login_button.dart       ← Google sign-in button
```

Also creates:
- `core/utils/validators.dart` — shared validation logic

---

## Section 3: Key Types

### AuthState (domain/entities/auth_state.dart)

```dart
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.role,
    required this.isOnboardingComplete,
  });
  final String userId;
  final UserRole role;
  final bool isOnboardingComplete;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;
}
```

### UserProfile (domain/entities/user_profile.dart)

```dart
class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.isOnboardingComplete,
    this.avatarUrl,
    this.headline,
    this.isBanned = false,
  });
  final String id;
  final UserRole role;
  final String fullName;
  final bool isOnboardingComplete;
  final String? avatarUrl;
  final String? headline;
  final bool isBanned;
}
```

### ProfileModel (data/models/profile_model.dart)

```dart
// Freezed model mapping profiles table
// Fields: id, role, full_name, is_onboarding_complete,
//         avatar_url, headline, is_banned
// fromJson maps snake_case → camelCase
// toEntity() → UserProfile
```

### AuthErrorMapper (data/mappers/auth_error_mapper.dart)

```dart
class AuthErrorMapper {
  const AuthErrorMapper._();

  static AuthFailure fromAuthException(AuthException e) =>
      AuthFailure(message: _toVietnamese(e.message), code: e.statusCode);

  static NetworkFailure fromUnknown(Object e, StackTrace st) =>
      NetworkFailure(message: AppStrings.errorGeneral, stackTrace: st);

  static String _toVietnamese(String message) {
    if (message.contains('already registered')) return 'Email đã được sử dụng';
    if (message.contains('Invalid login credentials')) return 'Email hoặc mật khẩu không đúng';
    if (message.contains('Email not confirmed')) return 'Vui lòng xác nhận email trước khi đăng nhập';
    if (message.contains('Password should be at least')) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (message.contains('security purposes')) return 'Vui lòng chờ trước khi thử lại';
    if (message.contains('User not found')) return 'Email không tồn tại trong hệ thống';
    return AppStrings.errorGeneral;
  }
}
```

### Validators (core/utils/validators.dart)

```dart
class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName không được để trống';
    return null;
  }

  static String? fullName(String? value) {
    final req = required(value, 'Họ tên');
    if (req != null) return req;
    if (value!.trim().length < 2) return 'Họ tên phải có ít nhất 2 ký tự';
    if (value.trim().length > 100) return 'Họ tên không được quá 100 ký tự';
    return null;
  }

  static String? email(String? value) {
    final req = required(value, 'Email');
    if (req != null) return req;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    final req = required(value, 'Mật khẩu');
    if (req != null) return req;
    if (value!.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'Xác nhận mật khẩu');
    if (req != null) return req;
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }
}
```

---

## Section 4: Task-by-Task Implementation Order

### T-06: Email Register + Role Selection

**Creates:**
- `auth_datasource.dart` — `register(email, password, role, fullName)` method
- `auth_error_mapper.dart` — full mapper class
- `profile_model.dart` — Freezed model mapping `profiles` table
- `user_profile.dart` — pure entity
- `auth_repository.dart` — abstract interface (register method)
- `auth_repository_impl.dart` — implementation
- `register_usecase.dart` — `Future<Either<Failure, void>> call(...)`
- `auth_provider.dart` — **skeleton only** (full implementation in T-07)
- `register_page.dart` — form with 5 fields (name, email, password, confirm, role cards)
- `auth_text_field.dart` — shared input widget
- `validators.dart` — in `core/utils/`

**T-06 auth_provider.dart — skeleton scope (do NOT build full provider):**
```dart
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // T-06: stub only — returns initial state
    // T-07 replaces this entirely with onAuthStateChange listener
    return const AuthInitial();
  }
}
```
- No `onAuthStateChange` listener
- No methods (login, logout, etc.)
- T-07 replaces this file entirely with full implementation

**Register flow:**
```
submit form
  → RegisterUseCase.call(email, password, role, fullName)
  → AuthRepository.register(...)
  → AuthDatasource: supabase.auth.signUp(email, password, data: {role, full_name})
  → handle_new_user() trigger → profiles row created
  → onAuthStateChange emits signedIn
  → authProvider fetches profile → emits AuthAuthenticated (isOnboardingComplete = true)
  → router redirects to '/'
```

**Role selection UX:** Two large tappable cards (Seeker / Recruiter). Neither selected by default. Submit button disabled until role != null.

### T-07: Email Login + Session Persistence

**Adds to existing files:**
- `auth_datasource.dart` — `login(email, password)` method
- `auth_repository.dart` — `login()` method signature
- `auth_repository_impl.dart` — `login()` implementation

**Creates:**
- `login_usecase.dart` — `Future<Either<Failure, void>> call(email, password)`
- `login_page.dart` — email + password + "Đăng nhập" button + link to register + link to forgot password
- `auth_provider.dart` — **FULL implementation** with `onAuthStateChange` listener

**Modifies:**
- `core/router/app_router.dart` — replace skeleton guard with real auth:
  ```dart
  UserRole _resolveRole(WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth is AuthAuthenticated ? auth.role : UserRole.seeker;
  }
  ```
- Add `/onboarding` route

**Session persistence:** Handled automatically by `supabase_flutter`. On app restart:
- `supabase_flutter` restores JWT from secure storage
- `onAuthStateChange` emits → `authProvider` fetches profile → `AuthAuthenticated`
- Router redirects based on role

**Router guard:**
```dart
redirect: (context, state) {
  final authState = ref.read(authProvider);
  if (authState is AuthInitial) return null;
  if (authState is AuthUnauthenticated || authState is AuthError) {
    if (publicRoutes.contains(state.matchedLocation)) return null;
    return '/login';
  }
  if (authState is AuthAuthenticated) {
    if (!authState.isOnboardingComplete) return '/onboarding';
    if (publicRoutes.contains(state.matchedLocation)) return '/';
    return null;
  }
  return null;
}
```

Public routes: `['/login', '/register', '/onboarding']`

### T-08: Google OAuth Login

**Adds to existing files:**
- `auth_datasource.dart` — `signInWithGoogle()` and `completeOnboarding(role)` methods
- `auth_repository.dart` — `googleLogin()` and `completeOnboarding()` signatures
- `auth_repository_impl.dart` — implementations

**Modifies:**
- `main.dart` — add PKCE auth options to `Supabase.initialize()`:
  ```dart
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  ```

**Creates:**
- `google_login_usecase.dart` — returns `Either<Failure, void>` (NOT User)
- `complete_onboarding_usecase.dart` — `Future<Either<Failure, void>> call(UserRole role)`
- `role_selection_page.dart` — two role cards + submit
- `social_login_button.dart` — Google sign-in button widget

**Platform config (created during T-08):**

Android `AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="com.jobconnect.job_connect"
        android:host="login-callback" />
</intent-filter>
```

iOS `Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.jobconnect.job_connect</string>
    </array>
  </dict>
</array>
```

**Google OAuth flow:**
```
tap Google button → signInWithOAuth() opens browser
  → user authenticates → browser redirects to deep link
  → supabase_flutter intercepts → onAuthStateChange fires
  → authProvider fetches profile
  → IF is_onboarding_complete = false:
      → emit AuthAuthenticated(isOnboardingComplete: false)
      → router redirects to /onboarding (RoleSelectionPage)
      → user picks role → CompleteOnboardingUseCase
      → UPDATE profiles SET role, is_onboarding_complete = true
      → authProvider re-fetches → isOnboardingComplete = true
      → router redirects to '/'
  → IF is_onboarding_complete = true (returning user):
      → router redirects to '/' directly
```

> [!WARNING]
> `signInWithOAuth()` returns void, NOT a User. Auth state arrives via the stream.
> Do NOT await a user object. Do NOT manually navigate after calling this.

**Onboarding role update (authenticated client, no service_role):**
```dart
await supabase.from('profiles').update({
  'role': selectedRole,
  'is_onboarding_complete': true,
}).eq('id', supabase.auth.currentUser!.id);
```
RLS allows it (`profiles.owner.update`). Trigger allows it (`is_onboarding_complete` was false). CHECK constraint validates role value. Three independent security layers.

### T-09: Forgot Password + Logout

**Adds to existing files:**
- `auth_datasource.dart` — `resetPassword(email)` and `signOut()` methods
- `auth_repository.dart` — method signatures
- `auth_repository_impl.dart` — implementations

**Creates:**
- `forgot_password_usecase.dart` — `Future<Either<Failure, void>> call(email)`
- `logout_usecase.dart` — `Future<Either<Failure, void>> call()`
- `forgot_password_page.dart`

**Adds to `AppStrings`:**
```dart
static const forgotPasswordSuccess =
    'Nếu email này tồn tại trong hệ thống, bạn sẽ nhận '
    'được link đặt lại mật khẩu trong vài phút.';
```

**Forgot password flow:**
Browser-based reset (Option C). No deep link for password reset.

ForgotPasswordPage has 3 UI states:
- `idle`: email field + submit button
- `loading`: CircularProgressIndicator, button disabled
- `success`: **hides form entirely**, shows `forgotPasswordSuccess` message + back-to-login button

Anti-enumeration: `resetPasswordForEmail()` succeeds even if email doesn't exist.

**Logout flow:**
```
tap logout → LogoutUseCase.call()
  → supabase.auth.signOut() clears session
  → onAuthStateChange emits signedOut
  → authProvider emits AuthUnauthenticated
  → all feature providers watching authProvider rebuild with empty state
  → router redirects to /login
```

> [!WARNING]
> Do NOT manually navigate after `signOut()`. The router guard handles redirection.
> Calling `context.go('/login')` after signOut causes double navigation and GoRouter state errors.

---

## Section 5: Provider Pattern for User-Specific Data

Add to CLAUDE.md:

```dart
// ✅ Correct — watches authProvider, auto-rebuilds on auth change
@riverpod
Future<List<Application>> myApplications(MyApplicationsRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return [];
  return ref.watch(applicationRepositoryProvider).getMyApplications(auth.userId);
}

// ❌ Wrong — doesn't react to auth changes, stale data after logout/login
@riverpod
Future<List<Application>> myApplications(MyApplicationsRef ref) async {
  final userId = supabase.auth.currentUser!.id; // NEVER
  return ref.watch(applicationRepositoryProvider).getMyApplications(userId);
}
```

Applies to: T-18 bookmarks, T-21 applications, T-25 aiSuggestions, T-29 conversations, T-31 notifications.

---

## Summary

| Item | Count |
|------|-------|
| New migration file | 1 (`20260511000002_auth_trigger.sql`) |
| Dart files created | 18 |
| Usecases | 6 |
| Pages | 4 + 1 route (`/onboarding`) |
| Shared widgets | 2 (AuthTextField, SocialLoginButton) |
| Core utility | 1 (Validators) |
| Platform config files modified | 2 (AndroidManifest.xml, Info.plist) |
| CLAUDE.md additions | 1 section (provider pattern) |
| AppStrings additions | 1 (forgotPasswordSuccess) |
| Manual Dashboard steps | 4 (email confirm, secure change, redirect URL, Google provider) |
