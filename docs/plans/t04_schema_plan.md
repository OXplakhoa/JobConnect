# T-04: Supabase Schema Migration — Implementation Plan

All decisions locked via grill Q1–Q13, Q20a.

---

## Migration File

`supabase/migrations/20260511000000_initial_schema.sql`

Run once on Supabase Dashboard SQL Editor.

---

## Section 1: Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;
```

---

## Section 2: Deletion Vocabulary (comment block)

```sql
-- DELETION VOCABULARY:
-- Job Posts:     NEVER deleted → status = 'closed' or 'rejected'
-- Profiles:     NEVER deleted → Admin sets is_banned = true
-- Companies:    NEVER deleted → RESTRICT blocks if posts with applications exist
-- Applications: NEVER deleted → status = 'withdrawn'
-- Messages:     NEVER deleted → immutable once sent
--
-- Hard DELETE valid for:
--   bookmarks, saved_searches, device_tokens, user_skills,
--   job_required_skills, ai_suggestions
```

---

## Section 3: Shared Trigger Functions

```sql
-- Auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Block role changes on profiles (Q2b)
CREATE OR REPLACE FUNCTION prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role <> OLD.role THEN
    RAISE EXCEPTION 'Role changes are not permitted. Contact an administrator.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Snapshot report target before deletion (Q8 — column only, trigger deferred to T-35)
-- CREATE OR REPLACE FUNCTION snapshot_report_target() ... deferred
```

---

## Section 4: Tables

### NHÓM 1: Auth & Profile

**profiles**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('seeker', 'recruiter', 'admin')),
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  location TEXT,
  headline TEXT,
  is_banned BOOLEAN NOT NULL DEFAULT false,
  banned_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER enforce_role_immutable
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_role_change();

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**work_experiences**
```sql
CREATE TABLE work_experiences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  company TEXT NOT NULL,
  role TEXT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE,
  description TEXT,
  is_current BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_work_experiences_updated_at
  BEFORE UPDATE ON work_experiences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**educations**
```sql
CREATE TABLE educations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  school TEXT NOT NULL,
  degree TEXT,
  major TEXT,
  from_date DATE NOT NULL,
  to_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_educations_updated_at
  BEFORE UPDATE ON educations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**certificates**
```sql
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  issuer TEXT,
  issued_at DATE,
  credential_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_certificates_updated_at
  BEFORE UPDATE ON certificates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### NHÓM 2: Lookup / Catalog

**job_categories**
```sql
CREATE TABLE job_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  icon_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**skills**
```sql
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category_id UUID REFERENCES job_categories(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- WARNING: deleting from skills cascades to user_skills
-- and job_required_skills. Admin only via service_role.
```

### NHÓM 3: Skills Mapping (user_skills only — job_required_skills moved to NHÓM 4)

**user_skills**
```sql
CREATE TABLE user_skills (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
  level TEXT NOT NULL CHECK (level IN ('beginner', 'intermediate', 'advanced')),
  PRIMARY KEY (user_id, skill_id)
);
```

### NHÓM 4: Company & Job Posts

**companies**
```sql
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recruiter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  logo_url TEXT,
  description TEXT,
  website TEXT,
  size TEXT,
  province TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (recruiter_id)
);

CREATE TRIGGER set_companies_updated_at
  BEFORE UPDATE ON companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**job_posts**
```sql
CREATE TABLE job_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  requirements TEXT,
  salary_min INTEGER,
  salary_max INTEGER,
  type TEXT NOT NULL CHECK (type IN ('full_time','part_time','contract','internship','remote','hybrid')),
  category_id UUID REFERENCES job_categories(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','pending_review','active','closed','rejected')),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_job_posts_updated_at
  BEFORE UPDATE ON job_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**job_locations**
```sql
CREATE TABLE job_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES job_posts(id) ON DELETE CASCADE,
  province TEXT,
  district TEXT,
  address TEXT,
  is_remote BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**job_required_skills** *(moved here from NHÓM 3 — requires job_posts to exist)*
```sql
CREATE TABLE job_required_skills (
  job_id UUID REFERENCES job_posts(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
  is_required BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (job_id, skill_id)
);
```

### NHÓM 5: Recruitment

**resumes**
```sql
CREATE TABLE resumes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_json JSONB,
  file_url TEXT,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_resumes_updated_at
  BEFORE UPDATE ON resumes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**applications**
```sql
CREATE TABLE applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES job_posts(id) ON DELETE RESTRICT,
  seeker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  resume_url TEXT,
  cover_letter TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','reviewing','interview','accepted','rejected','withdrawn')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (job_id, seeker_id)
);
-- 'withdrawn' transition: pending → withdrawn only
-- Enforced at application layer in T-20, not DB level

CREATE TRIGGER set_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**application_notes**
```sql
CREATE TABLE application_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  recruiter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  note TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**interview_schedules**
```sql
CREATE TABLE interview_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  scheduled_at TIMESTAMPTZ NOT NULL,
  location TEXT,
  note TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled','completed','cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_interview_schedules_updated_at
  BEFORE UPDATE ON interview_schedules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### NHÓM 6: Chat & Notifications

**conversations**
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seeker_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  recruiter_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  job_id UUID REFERENCES job_posts(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (seeker_id, recruiter_id, job_id)
);
```

**messages**
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  read_at TIMESTAMPTZ
);
```

**notifications**
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('application_status','new_applicant','job_alert','interview','message','system')),
  title TEXT NOT NULL,
  body TEXT,
  data_json JSONB,
  read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_notifications_updated_at
  BEFORE UPDATE ON notifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

**device_tokens**
```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, fcm_token),
  UNIQUE (fcm_token)
);
```

### NHÓM 7: AI & Vector Search

**profile_embeddings**
```sql
CREATE TABLE profile_embeddings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  embedding vector(768) NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**job_embeddings**
```sql
CREATE TABLE job_embeddings (
  job_id UUID PRIMARY KEY REFERENCES job_posts(id) ON DELETE CASCADE,
  embedding vector(768) NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**ai_suggestions**
```sql
CREATE TABLE ai_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seeker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES job_posts(id) ON DELETE CASCADE,
  score FLOAT NOT NULL,
  reason TEXT,
  cached_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### NHÓM 8: Social & Job Alert

**bookmarks**
```sql
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seeker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  job_id UUID NOT NULL REFERENCES job_posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (seeker_id, job_id)
);
```

**saved_searches**
```sql
CREATE TABLE saved_searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  filter_json JSONB NOT NULL,
  name TEXT NOT NULL,
  notify_new BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**company_reviews**
```sql
CREATE TABLE company_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  reviewer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**reports**
```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('user', 'job_post', 'company')),
  target_id UUID NOT NULL,
  target_snapshot JSONB,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','resolved','dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## Section 5: Indexes (16 total)

```sql
-- Profiles
CREATE INDEX idx_profiles_role ON profiles(role);

-- Junction table reverse lookups
CREATE INDEX idx_user_skills_skill_id ON user_skills(skill_id);
CREATE INDEX idx_job_required_skills_skill_id ON job_required_skills(skill_id);

-- Job discovery (composite for status + sort)
CREATE INDEX idx_job_posts_status_created ON job_posts(status, created_at DESC);
CREATE INDEX idx_job_posts_category ON job_posts(category_id);
CREATE INDEX idx_job_posts_company ON job_posts(company_id);
CREATE INDEX idx_job_posts_created ON job_posts(created_at DESC);

-- Applications
CREATE INDEX idx_applications_seeker ON applications(seeker_id);
CREATE INDEX idx_applications_job ON applications(job_id);
CREATE INDEX idx_applications_seeker_active ON applications(seeker_id, created_at DESC)
  WHERE status NOT IN ('withdrawn', 'rejected');

-- Chat
CREATE INDEX idx_conversations_seeker ON conversations(seeker_id);
CREATE INDEX idx_conversations_recruiter ON conversations(recruiter_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created ON messages(created_at);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);

-- Bookmarks
CREATE INDEX idx_bookmarks_seeker ON bookmarks(seeker_id);

-- pgvector indexes: deferred to T-24 (HNSW, needs data)
-- CREATE INDEX idx_job_embeddings_vector ON job_embeddings
--   USING hnsw (embedding vector_cosine_ops);
-- CREATE INDEX idx_profile_embeddings_vector ON profile_embeddings
--   USING hnsw (embedding vector_cosine_ops);
```

---

## Section 6: Seed Data (CTE approach)

```sql
WITH cats AS (
  INSERT INTO job_categories (id, name, slug) VALUES
    (gen_random_uuid(), 'IT / Phần mềm', 'it-phan-mem'),
    (gen_random_uuid(), 'Thiết kế / UI-UX', 'thiet-ke-ui-ux'),
    (gen_random_uuid(), 'Marketing / Truyền thông', 'marketing-truyen-thong'),
    (gen_random_uuid(), 'Tài chính / Kế toán', 'tai-chinh-ke-toan'),
    (gen_random_uuid(), 'Nhân sự / Hành chính', 'nhan-su-hanh-chinh'),
    (gen_random_uuid(), 'Kinh doanh / Bán hàng', 'kinh-doanh-ban-hang'),
    (gen_random_uuid(), 'Vận hành / Logistics', 'van-hanh-logistics'),
    (gen_random_uuid(), 'Giáo dục / Đào tạo', 'giao-duc-dao-tao'),
    (gen_random_uuid(), 'Y tế / Sức khỏe', 'y-te-suc-khoe'),
    (gen_random_uuid(), 'Khác', 'khac')
  RETURNING id, slug
)
INSERT INTO skills (id, name, category_id)
SELECT gen_random_uuid(), s.skill_name, cats.id
FROM (VALUES
  -- Mobile & Frontend
  ('Flutter', 'it-phan-mem'), ('Dart', 'it-phan-mem'),
  ('React Native', 'it-phan-mem'), ('Swift', 'it-phan-mem'),
  ('Kotlin', 'it-phan-mem'), ('JavaScript', 'it-phan-mem'),
  ('TypeScript', 'it-phan-mem'), ('React', 'it-phan-mem'),
  ('Vue.js', 'it-phan-mem'), ('HTML/CSS', 'it-phan-mem'),
  -- Backend & Infra
  ('Python', 'it-phan-mem'), ('Java', 'it-phan-mem'),
  ('Node.js', 'it-phan-mem'), ('SQL', 'it-phan-mem'),
  ('PostgreSQL', 'it-phan-mem'), ('REST API', 'it-phan-mem'),
  ('Docker', 'it-phan-mem'), ('Git', 'it-phan-mem'),
  ('Firebase', 'it-phan-mem'), ('Supabase', 'it-phan-mem'),
  -- Data & AI
  ('Machine Learning', 'it-phan-mem'), ('Data Analysis', 'it-phan-mem'),
  ('TensorFlow', 'it-phan-mem'), ('Power BI', 'it-phan-mem'),
  ('Excel', 'khac'),
  -- Design
  ('Figma', 'thiet-ke-ui-ux'), ('Adobe XD', 'thiet-ke-ui-ux'),
  ('Photoshop', 'thiet-ke-ui-ux'), ('Illustrator', 'thiet-ke-ui-ux'),
  ('UI/UX Design', 'thiet-ke-ui-ux'),
  -- Soft & Business
  ('Project Management', 'khac'), ('Agile/Scrum', 'khac'),
  ('Content Writing', 'marketing-truyen-thong'),
  ('SEO', 'marketing-truyen-thong'),
  ('Microsoft Office', 'khac')
) AS s(skill_name, cat_slug)
JOIN cats ON cats.slug = s.cat_slug;
```

---

## Summary

| Item | Count |
|------|-------|
| Tables | 22 |
| Triggers | 12 (11 updated_at + 1 role immutable) |
| Functions | 2 (update_updated_at, prevent_role_change) |
| Indexes | 16 (+2 pgvector deferred to T-24) |
| Unique constraints | 6 |
| CHECK constraints | 10 |
| Seed rows | 10 categories + 35 skills |
