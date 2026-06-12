-- Make "warn / un-warn a user" a real, reversible admin action — symmetric with
-- ban / unlock (banned_until).
--
-- Before this migration, sendWarning() only INSERTed a notification of
-- type 'warning'. Two problems:
--   1. 'warning' is NOT in the notifications type CHECK constraint, so the
--      INSERT failed with a check violation — warnings never delivered.
--   2. A warning was fire-and-forget — there was no state on the user to
--      display ("Đã cảnh cáo") or to clear, so "gỡ cảnh cáo" had nothing to act on.
--
-- Fix:
--   * Add profiles.warned_at — the warning state. Set on warn, NULL on un-warn.
--   * Allow 'warning' as a notification type so the seeker is actually notified.

-- 1) Warning state on the profile (NULL = not warned).
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS warned_at TIMESTAMPTZ;

-- 2) Permit the 'warning' notification type. Recreate the CHECK to add it.
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    'application_status',
    'new_applicant',
    'job_alert',
    'interview',
    'message',
    'system',
    'warning'
  ));
