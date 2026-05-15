ALTER TABLE profiles
  ADD COLUMN is_onboarding_complete BOOLEAN NOT NULL DEFAULT false;

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
