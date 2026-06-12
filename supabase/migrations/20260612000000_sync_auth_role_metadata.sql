-- Sync auth.users.raw_user_meta_data 'role' from public.profiles.role.
--
-- Root cause of "admin ban / warn silently does nothing":
-- The profiles admin UPDATE policy (20260608000005) and the notifications
-- admin/recruiter INSERT policies (20260530000002) all authorize via
--   (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid())
-- i.e. the role stored in AUTH metadata, NOT public.profiles.role.
--
-- The app, however, decides a user's role from public.profiles.role. Any
-- account whose role was set only in profiles (seeded rows, accounts promoted
-- via SQL before the secure RPCs existed, etc.) has a stale or missing auth
-- metadata role. RLS then treats that admin as a non-admin, so:
--   * banUser's UPDATE on another user's profiles row affects 0 rows — and
--     Supabase does NOT throw on a 0-row UPDATE (PostgREST silent-UPDATE rule),
--     so the ban never persists; the user keeps logging in and the user list
--     keeps showing "Đang hoạt động".
--   * sendWarning's INSERT into notifications is rejected (42501).
--
-- Backfilling auth metadata to match profiles makes is_admin() /
-- get_user_role() agree with the app's notion of role. Idempotent.

UPDATE auth.users AS u
SET raw_user_meta_data =
      COALESCE(u.raw_user_meta_data, '{}'::jsonb)
      || jsonb_build_object('role', p.role)
FROM public.profiles AS p
WHERE p.id = u.id
  AND p.role IS NOT NULL
  AND COALESCE(u.raw_user_meta_data->>'role', '') IS DISTINCT FROM p.role;

-- Re-assert the admin policies so this migration is self-contained and the
-- intended authorization is explicit (no-op if already present from ...005).
DROP POLICY IF EXISTS "profiles.admin.select" ON public.profiles;
DROP POLICY IF EXISTS "profiles.admin.update" ON public.profiles;

CREATE POLICY "profiles.admin.select" ON public.profiles
  FOR SELECT TO authenticated USING (
    (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "profiles.admin.update" ON public.profiles
  FOR UPDATE TO authenticated USING (
    (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );
