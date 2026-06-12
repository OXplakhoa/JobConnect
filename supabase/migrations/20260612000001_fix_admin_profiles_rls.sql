-- Fix "permission denied for table users" when an admin bans / unlocks a user.
--
-- The profiles admin SELECT/UPDATE policies (last re-asserted in
-- 20260612000000) authorize via an INLINE subquery against auth.users:
--   (SELECT raw_user_meta_data->>'role' FROM auth.users WHERE id = auth.uid())
-- That subquery is evaluated as the calling `authenticated` role, which has NO
-- SELECT privilege on auth.users -> PostgreSQL raises 42501
-- "permission denied for table users" and aborts the whole statement.
--
-- Why the user LIST still loaded but the BAN failed: SELECT combines the
-- permissive `profiles.authenticated.select USING (true)` policy with the admin
-- one by OR, and the trivially-true policy short-circuits before the auth.users
-- subquery runs. An UPDATE on ANOTHER user's row has no trivially-true policy
-- (`profiles.owner.update` is `id = auth.uid()` = false for someone else), so
-- Postgres is forced to evaluate the admin subquery -> permission denied.
--
-- Fix: authorize via the SECURITY DEFINER is_admin() helper (20260608000005).
-- It runs as the function OWNER (privileged), so it CAN read auth.users, and it
-- reads auth.users — NOT profiles — so it neither hits the permission wall nor
-- recurses on the profiles policies (the original reason inline subqueries were
-- introduced). is_admin() reads the live auth.users row, not the JWT, so a
-- freshly-backfilled admin role takes effect without re-login.

DROP POLICY IF EXISTS "profiles.admin.select" ON public.profiles;
DROP POLICY IF EXISTS "profiles.admin.update" ON public.profiles;

CREATE POLICY "profiles.admin.select" ON public.profiles
  FOR SELECT TO authenticated USING (public.is_admin());

CREATE POLICY "profiles.admin.update" ON public.profiles
  FOR UPDATE TO authenticated USING (public.is_admin());
