-- ============================================================
-- RLS POLICIES — JobConnect
-- ============================================================
-- All policies apply to 'authenticated' role only.
-- Anonymous users (anon role) have zero access.
--
-- Banned users: get_user_role() returns NULL → all
-- role-based policies fail automatically.
-- App layer shows suspension message via is_banned check.
--
-- Policy naming: {table}.{role}.{operation}
-- Example: job_posts.seeker.select
--
-- RLS primitives (3 patterns cover 95% of policies):
--   Role check:    get_user_role() = 'seeker'
--   Admin bypass:  is_admin()
--   Owner check:   auth.uid() = user_id
--   Combined:      auth.uid() = user_id OR is_admin()
-- ============================================================

-- 1. Role lookup with ban check (Q10 + Q14a)
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT CASE
    WHEN is_banned THEN NULL
    ELSE role
  END
  FROM profiles WHERE id = auth.uid()
  LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_user_role() TO authenticated;

-- 2. Admin shorthand
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT get_user_role() = 'admin'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- 3. Recruiter's company ID
CREATE OR REPLACE FUNCTION public.get_recruiter_company_id()
RETURNS UUID AS $$
  SELECT id FROM companies WHERE recruiter_id = auth.uid()
  LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_recruiter_company_id() TO authenticated;

-- 4. Recruiter's job post IDs (cached per transaction)
CREATE OR REPLACE FUNCTION public.get_recruiter_job_ids()
RETURNS SETOF UUID AS $$
  SELECT id FROM job_posts
  WHERE company_id = get_recruiter_company_id()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_recruiter_job_ids() TO authenticated;

-- 5. User's conversation IDs (cached per transaction)
CREATE OR REPLACE FUNCTION public.get_user_conversation_ids()
RETURNS SETOF UUID AS $$
  SELECT id FROM conversations
  WHERE seeker_id = auth.uid() OR recruiter_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION public.get_user_conversation_ids() TO authenticated;

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE educations ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_required_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_embeddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_embeddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles.authenticated.select" ON profiles
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "profiles.owner.insert" ON profiles
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

CREATE POLICY "profiles.owner.update" ON profiles
  FOR UPDATE TO authenticated USING (id = auth.uid());

CREATE POLICY "profiles.admin.update" ON profiles
  FOR UPDATE TO authenticated USING (is_admin());

-- work_experiences
CREATE POLICY "work_experiences.authenticated.select" ON work_experiences
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "work_experiences.owner.insert" ON work_experiences
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "work_experiences.owner.update" ON work_experiences
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "work_experiences.owner.delete" ON work_experiences
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- educations
CREATE POLICY "educations.authenticated.select" ON educations
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "educations.owner.insert" ON educations
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "educations.owner.update" ON educations
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "educations.owner.delete" ON educations
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- certificates
CREATE POLICY "certificates.authenticated.select" ON certificates
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "certificates.owner.insert" ON certificates
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "certificates.owner.update" ON certificates
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "certificates.owner.delete" ON certificates
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "job_categories.authenticated.select" ON job_categories
  FOR SELECT TO authenticated USING (true);
-- INSERT/UPDATE/DELETE: Admin via service_role only

CREATE POLICY "skills.authenticated.select" ON skills
  FOR SELECT TO authenticated USING (true);
-- INSERT/UPDATE/DELETE: Admin via service_role only

CREATE POLICY "user_skills.authenticated.select" ON user_skills
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "user_skills.owner.insert" ON user_skills
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "user_skills.owner.delete" ON user_skills
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "job_required_skills.authenticated.select" ON job_required_skills
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "job_required_skills.recruiter.insert" ON job_required_skills
  FOR INSERT TO authenticated
  WITH CHECK (job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));
CREATE POLICY "job_required_skills.recruiter.delete" ON job_required_skills
  FOR DELETE TO authenticated
  USING (job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));

CREATE POLICY "companies.authenticated.select" ON companies
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "companies.recruiter.insert" ON companies
  FOR INSERT TO authenticated
  WITH CHECK (get_user_role() = 'recruiter' AND recruiter_id = auth.uid());
CREATE POLICY "companies.recruiter.update" ON companies
  FOR UPDATE TO authenticated
  USING (recruiter_id = auth.uid());
CREATE POLICY "companies.admin.update" ON companies
  FOR UPDATE TO authenticated USING (is_admin());

CREATE POLICY "job_posts.seeker.select" ON job_posts
  FOR SELECT TO authenticated
  USING (status = 'active' AND get_user_role() = 'seeker');

CREATE POLICY "job_posts.recruiter.select" ON job_posts
  FOR SELECT TO authenticated
  USING (get_user_role() = 'recruiter' AND company_id = get_recruiter_company_id());

CREATE POLICY "job_posts.admin.select" ON job_posts
  FOR SELECT TO authenticated USING (is_admin());

CREATE POLICY "job_posts.recruiter.insert" ON job_posts
  FOR INSERT TO authenticated
  WITH CHECK (get_user_role() = 'recruiter' AND company_id = get_recruiter_company_id());

CREATE POLICY "job_posts.recruiter.update" ON job_posts
  FOR UPDATE TO authenticated
  USING (get_user_role() = 'recruiter' AND company_id = get_recruiter_company_id());

CREATE POLICY "job_posts.admin.update" ON job_posts
  FOR UPDATE TO authenticated USING (is_admin());

CREATE POLICY "job_locations.authenticated.select" ON job_locations
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "job_locations.recruiter.insert" ON job_locations
  FOR INSERT TO authenticated
  WITH CHECK (job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));
CREATE POLICY "job_locations.recruiter.update" ON job_locations
  FOR UPDATE TO authenticated
  USING (job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));
CREATE POLICY "job_locations.recruiter.delete" ON job_locations
  FOR DELETE TO authenticated
  USING (job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));

CREATE POLICY "resumes.owner.select" ON resumes
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "resumes.owner.insert" ON resumes
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "resumes.owner.update" ON resumes
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "resumes.owner.delete" ON resumes
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "applications.seeker.select" ON applications
  FOR SELECT TO authenticated
  USING (get_user_role() = 'seeker' AND seeker_id = auth.uid());

CREATE POLICY "applications.recruiter.select" ON applications
  FOR SELECT TO authenticated
  USING (get_user_role() = 'recruiter'
    AND job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));

CREATE POLICY "applications.admin.select" ON applications
  FOR SELECT TO authenticated USING (is_admin());

CREATE POLICY "applications.seeker.insert" ON applications
  FOR INSERT TO authenticated
  WITH CHECK (get_user_role() = 'seeker' AND seeker_id = auth.uid());

CREATE POLICY "applications.seeker.update" ON applications
  FOR UPDATE TO authenticated
  USING (get_user_role() = 'seeker' AND seeker_id = auth.uid());

CREATE POLICY "applications.recruiter.update" ON applications
  FOR UPDATE TO authenticated
  USING (get_user_role() = 'recruiter'
    AND job_id = ANY(ARRAY(SELECT get_recruiter_job_ids())));

CREATE POLICY "application_notes.recruiter.select" ON application_notes
  FOR SELECT TO authenticated
  USING (recruiter_id = auth.uid());
CREATE POLICY "application_notes.admin.select" ON application_notes
  FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "application_notes.recruiter.insert" ON application_notes
  FOR INSERT TO authenticated
  WITH CHECK (recruiter_id = auth.uid());
CREATE POLICY "application_notes.recruiter.update" ON application_notes
  FOR UPDATE TO authenticated
  USING (recruiter_id = auth.uid());

CREATE POLICY "interview_schedules.recruiter.select" ON interview_schedules
  FOR SELECT TO authenticated
  USING (application_id IN (
    SELECT id FROM applications
    WHERE job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
  ));
CREATE POLICY "interview_schedules.seeker.select" ON interview_schedules
  FOR SELECT TO authenticated
  USING (application_id IN (
    SELECT id FROM applications WHERE seeker_id = auth.uid()
  ));
CREATE POLICY "interview_schedules.admin.select" ON interview_schedules
  FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "interview_schedules.recruiter.insert" ON interview_schedules
  FOR INSERT TO authenticated
  WITH CHECK (application_id IN (
    SELECT id FROM applications
    WHERE job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
  ));
CREATE POLICY "interview_schedules.recruiter.update" ON interview_schedules
  FOR UPDATE TO authenticated
  USING (application_id IN (
    SELECT id FROM applications
    WHERE job_id = ANY(ARRAY(SELECT get_recruiter_job_ids()))
  ));

CREATE POLICY "conversations.participant.select" ON conversations
  FOR SELECT TO authenticated
  USING (seeker_id = auth.uid() OR recruiter_id = auth.uid());
CREATE POLICY "conversations.participant.insert" ON conversations
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IN (seeker_id, recruiter_id));
CREATE POLICY "conversations.admin.select" ON conversations
  FOR SELECT TO authenticated USING (is_admin());

CREATE POLICY "messages.participant.select" ON messages
  FOR SELECT TO authenticated
  USING (conversation_id = ANY(ARRAY(SELECT get_user_conversation_ids())));
CREATE POLICY "messages.participant.insert" ON messages
  FOR INSERT TO authenticated
  WITH CHECK (sender_id = auth.uid()
    AND conversation_id = ANY(ARRAY(SELECT get_user_conversation_ids())));
CREATE POLICY "messages.recipient.update" ON messages
  FOR UPDATE TO authenticated
  USING (sender_id != auth.uid()
    AND conversation_id = ANY(ARRAY(SELECT get_user_conversation_ids())));
CREATE POLICY "messages.admin.select" ON messages
  FOR SELECT TO authenticated USING (is_admin());

CREATE POLICY "notifications.owner.select" ON notifications
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications.owner.update" ON notifications
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
-- INSERT: via service_role (triggers/Edge Functions) only

CREATE POLICY "device_tokens.owner.select" ON device_tokens
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "device_tokens.owner.insert" ON device_tokens
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "device_tokens.owner.update" ON device_tokens
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "device_tokens.owner.delete" ON device_tokens
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- profile_embeddings: user reads own, system writes
CREATE POLICY "profile_embeddings.owner.select" ON profile_embeddings
  FOR SELECT TO authenticated USING (user_id = auth.uid());

-- job_embeddings: readable for active posts, system writes
CREATE POLICY "job_embeddings.authenticated.select" ON job_embeddings
  FOR SELECT TO authenticated 
  USING (
    EXISTS (
      SELECT 1 FROM job_posts 
      WHERE job_posts.id = job_embeddings.job_id
    )
  );

-- ai_suggestions: seeker reads own cache, system writes
CREATE POLICY "ai_suggestions.owner.select" ON ai_suggestions
  FOR SELECT TO authenticated USING (seeker_id = auth.uid());
-- ai_suggestions DELETE: via service_role only (cache invalidation in T-25)

CREATE POLICY "bookmarks.owner.select" ON bookmarks
  FOR SELECT TO authenticated USING (seeker_id = auth.uid());
CREATE POLICY "bookmarks.owner.insert" ON bookmarks
  FOR INSERT TO authenticated WITH CHECK (seeker_id = auth.uid());
CREATE POLICY "bookmarks.owner.delete" ON bookmarks
  FOR DELETE TO authenticated USING (seeker_id = auth.uid());

CREATE POLICY "saved_searches.owner.select" ON saved_searches
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "saved_searches.owner.insert" ON saved_searches
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "saved_searches.owner.update" ON saved_searches
  FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "saved_searches.owner.delete" ON saved_searches
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "company_reviews.authenticated.select" ON company_reviews
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "company_reviews.owner.insert" ON company_reviews
  FOR INSERT TO authenticated WITH CHECK (reviewer_id = auth.uid());
CREATE POLICY "company_reviews.owner.update" ON company_reviews
  FOR UPDATE TO authenticated USING (reviewer_id = auth.uid());
CREATE POLICY "company_reviews.owner.delete" ON company_reviews
  FOR DELETE TO authenticated USING (reviewer_id = auth.uid());

CREATE POLICY "reports.authenticated.insert" ON reports
  FOR INSERT TO authenticated WITH CHECK (reporter_id = auth.uid());
CREATE POLICY "reports.admin.select" ON reports
  FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "reports.admin.update" ON reports
  FOR UPDATE TO authenticated USING (is_admin());
