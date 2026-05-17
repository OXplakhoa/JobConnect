# Final Verification — Phase 1 Auth (T-06 → T-09)

Run every check before committing. Tick each box yourself — 
do not trust the agent's self-report.

---

## 1. flutter analyze

```bash
flutter analyze
```
- [ ] Zero issues found

---

## 2. File Existence (all must exist)

### T-06
- [ ] `lib/core/utils/validators.dart`
- [ ] `lib/features/auth/data/datasources/auth_datasource.dart`
- [ ] `lib/features/auth/data/mappers/auth_error_mapper.dart`
- [ ] `lib/features/auth/data/models/profile_model.dart`
- [ ] `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] `lib/features/auth/domain/entities/auth_state.dart`
- [ ] `lib/features/auth/domain/entities/user_profile.dart`
- [ ] `lib/features/auth/domain/repositories/auth_repository.dart`
- [ ] `lib/features/auth/domain/usecases/register_usecase.dart`
- [ ] `lib/features/auth/presentation/pages/register_page.dart`
- [ ] `lib/features/auth/presentation/providers/auth_provider.dart`
- [ ] `lib/features/auth/presentation/widgets/auth_text_field.dart`

### T-07
- [ ] `lib/features/auth/domain/usecases/login_usecase.dart`
- [ ] `lib/features/auth/presentation/pages/login_page.dart`

### T-08
- [ ] `lib/features/auth/domain/usecases/google_login_usecase.dart`
- [ ] `lib/features/auth/domain/usecases/complete_onboarding_usecase.dart`
- [ ] `lib/features/auth/presentation/pages/role_selection_page.dart`
- [ ] `lib/features/auth/presentation/widgets/social_login_button.dart`

### T-09
- [ ] `lib/features/auth/domain/usecases/forgot_password_usecase.dart`
- [ ] `lib/features/auth/domain/usecases/logout_usecase.dart`
- [ ] `lib/features/auth/presentation/pages/forgot_password_page.dart`

### Database
- [ ] `supabase/migrations/20260511000002_auth_trigger.sql`

---

## 3. Code Spot-Checks (open each file manually)

### auth_provider.dart
- [ ] Has `onAuthStateChange` stream listener
- [ ] Has `ref.onDispose(() => subscription.cancel())`
- [ ] Fetches profile from `profiles` table after signedIn event
- [ ] Emits `AuthAuthenticated` with userId, role, isOnboardingComplete
- [ ] Emits `AuthUnauthenticated` on signedOut
- [ ] Emits `AuthError` on profile fetch failure

### auth_state.dart
- [ ] Exactly 4 states: AuthInitial, AuthAuthenticated,
      AuthUnauthenticated, AuthError
- [ ] AuthAuthenticated has: userId, role, isOnboardingComplete
- [ ] AuthError has: message

### google_login_usecase.dart
- [ ] Return type is `Either<Failure, void>` — NOT `Either<Failure, User>`

### complete_onboarding_usecase.dart
- [ ] `call()` takes `UserRole role` only — NO userId parameter
- [ ] userId read from `supabase.auth.currentUser!.id` internally

### forgot_password_page.dart
- [ ] Has exactly 3 UI states: idle / loading / success
- [ ] Success state HIDES the form entirely (not just shows message)
- [ ] Success message contains "Nếu email này tồn tại"
      NOT "Đã gửi link" or "Chúng tôi đã gửi"

### app_router.dart
- [ ] publicRoutes includes '/login', '/register', '/onboarding'
- [ ] redirect checks AuthInitial → null (still loading)
- [ ] redirect checks AuthError → '/login'
- [ ] redirect checks isOnboardingComplete = false → '/onboarding'
- [ ] redirect checks publicRoute + authenticated → '/'
- [ ] `/forgot-password` route exists and is outside shell

### main.dart
- [ ] `authFlowType: AuthFlowType.pkce` inside Supabase.initialize()

### android/app/src/main/AndroidManifest.xml
- [ ] intent-filter with scheme="com.jobconnect.job_connect"
- [ ] host="login-callback"

### ios/Runner/Info.plist
- [ ] CFBundleURLSchemes contains "com.jobconnect.job_connect"

### app_strings.dart
- [ ] forgotPasswordSuccess exists and uses anti-enumeration wording

---

## 4. Architecture Checks (grep or open and scan)

```bash
# No Supabase imports in domain layer
grep -r "supabase" lib/features/auth/domain/ --include="*.dart"
# Must return 0 results

# No setState anywhere in auth feature
grep -r "setState" lib/features/auth/ --include="*.dart"  
# Must return 0 results

# No service_role key anywhere
grep -r "service_role" lib/ --include="*.dart"
# Must return 0 results

# No hardcoded Supabase URL
grep -r "supabase.co" lib/ --include="*.dart"
# Must return 0 results (should use AppConstants)

# No manual navigation after auth actions
grep -r "context.go" lib/features/auth/presentation/providers/ --include="*.dart"
# Must return 0 results (router handles navigation)
```

---

## 5. Security Checks

- [ ] `.vscode/launch.json` is in `.gitignore`
      (contains real Supabase credentials via dart-define)
- [ ] No `service_role` key in any Dart file
- [ ] No real Supabase URL hardcoded (uses AppConstants.supabaseUrl)
- [ ] No real anon key hardcoded (uses AppConstants.supabaseAnonKey)

---

## 6. Database Checks (Supabase Dashboard → SQL Editor)

```sql
-- 1. is_onboarding_complete column exists
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'profiles' 
  AND column_name = 'is_onboarding_complete';
-- Must return 1 row

-- 2. Trigger exists
SELECT trigger_name FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
-- Must return 1 row

-- 3. prevent_role_change trigger exists
SELECT trigger_name FROM information_schema.triggers
WHERE trigger_name = 'enforce_role_immutable';
-- Must return 1 row
```

---

## 7. Manual Device Tests

Run on physical Android device (or iOS Simulator on Mac).
Each flow must complete without crashes or errors.

### Register flow
- [ ] Open app → redirects to /login automatically
- [ ] Tap "Đăng ký" → goes to RegisterPage
- [ ] Submit form with role NOT selected → button stays disabled
- [ ] Select Seeker role → button enables
- [ ] Submit valid form → app navigates to home shell
- [ ] Check Supabase Dashboard → profiles table:
      new row exists with correct role + is_onboarding_complete = true

### Login flow
- [ ] Logout (if logged in)
- [ ] Login with registered email/password → home shell
- [ ] Kill app → relaunch → stays logged in (session persists)
- [ ] Wrong password → Vietnamese error message appears

### Forgot password flow
- [ ] Tap "Quên mật khẩu?" on login page
- [ ] Submit any email → form disappears, success message appears
- [ ] Success message starts with "Nếu email này tồn tại"
- [ ] "Quay lại đăng nhập" button works

### Logout flow
- [ ] Logout from profile or wherever logout button is
- [ ] Redirects to /login automatically
- [ ] No double navigation or GoRouter error in console

### Google OAuth flow (requires Supabase Dashboard Google provider enabled)
- [ ] Tap Google button on login page → browser opens
- [ ] Complete Google auth → app receives callback
- [ ] New Google user → redirected to /onboarding (RoleSelectionPage)
- [ ] Select role → home shell
- [ ] Returning Google user → home shell directly (no /onboarding)
- [ ] Check profiles table: Google user has avatar_url populated

---

## 8. Commit (after all boxes ticked)

```bash
git add -A
git commit -m "feat(auth): complete Phase 1 auth (T-06 to T-09)

- Email register with role selection (seeker/recruiter cards)
- Email login with session persistence
- Google OAuth with PKCE deep link + onboarding role selection  
- Forgot password browser-based reset (anti-enumeration)
- Logout via stream, no manual navigation
- AuthState sealed class (4 states), AuthErrorMapper (Vietnamese)
- Validators utility, CLAUDE.md provider pattern documented
- Auth trigger migration: handle_new_user + is_onboarding_complete
- flutter analyze: clean"
```

---

## Next: Phase 2 — Seeker Profile (T-10, T-11 + T-12)

Come back to grill session (Opus) for Phase 2 when ready.