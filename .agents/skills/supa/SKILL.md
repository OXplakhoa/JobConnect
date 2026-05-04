---
name: supa
description: Use when the user wants to work with Supabase — creating or modifying database tables, writing RLS policies, setting up Edge Functions, configuring Storage buckets, managing Realtime subscriptions, or debugging Supabase-related issues. Covers schema design, SQL migration scripts, RLS policy generation, Edge Function scaffolding (Deno/TypeScript), and Storage rules. Always references BRIEF.md §7 for schema.
---

Manage all Supabase-related tasks for JobConnect — schema, RLS, Edge Functions, Storage, Realtime.

## Rules

1. **BRIEF.md §7 is the schema source of truth.** Don't create tables not defined there without asking.
2. **RLS is ALWAYS ON.** Never suggest disabling it. (CLAUDE.md §Supabase Rules)
3. **Schema changes must update BRIEF.md.** If you modify the schema, update §7 to match.
4. **Use pgvector for AI tables.** `profile_embeddings` and `job_embeddings` use `vector(768)`.
5. **Edge Functions in Deno/TypeScript.** Follow Supabase Edge Function conventions.

## Setup

Before any Supabase work:

1. **Read BRIEF.md §7** — full database schema (22 tables).
2. **Read BRIEF.md §4** — backend stack, constraints.
3. **Read CLAUDE.md §Supabase Rules** — client usage, storage paths, RLS rules.
4. **Check existing migrations** — scan `supabase/migrations/` if it exists.

## Commands

### `/supa schema [table]`
Show or design a table schema.

- If table exists in BRIEF.md: show the full CREATE TABLE with types, constraints, indexes.
- If table is new: design it, show SQL, ask for confirmation, then update BRIEF.md §7.

### `/supa rls [table]`
Generate Row Level Security policies for a table.

Standard RLS pattern for JobConnect:

```sql
-- Example: job_posts
-- Recruiter can CRUD their own company's posts
CREATE POLICY "Recruiters manage own posts" ON job_posts
  FOR ALL USING (
    company_id IN (
      SELECT id FROM companies WHERE recruiter_id = auth.uid()
    )
  );

-- Job Seekers can read active posts
CREATE POLICY "Seekers read active posts" ON job_posts
  FOR SELECT USING (status = 'active');

-- Admin can read all
CREATE POLICY "Admin read all" ON job_posts
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
```

RLS rules by role:
| Role | Default Access |
|---|---|
| Job Seeker | Read active public data. CRUD own profile, applications, bookmarks, saved_searches. |
| Recruiter | CRUD own company + job_posts + applications for own posts. Read applicant profiles. |
| Admin | Read all. Update user status (lock/unlock). Moderate reports, approve posts. |

### `/supa edge [function-name]`
Scaffold a Supabase Edge Function.

```
supabase/functions/{function-name}/
├── index.ts      ← main handler
└── _shared/      ← shared utilities (if needed)
```

Key Edge Functions for JobConnect:
- **job-alert-daily** — scheduled, matches new jobs against saved_searches
- **generate-embedding** — webhook, creates vector embedding via Gemini API
- **send-notification** — triggered by DB events, sends FCM push via Firebase Admin SDK

### `/supa storage`
Configure Storage buckets and policies.

Buckets:
- `resumes` — PDF files, max 5MB, path: `{userId}/{filename}`
- `avatars` — Images, path: `{userId}/avatar.jpg`
- `company-logos` — Images, path: `{companyId}/logo.{ext}`

### `/supa realtime [table]`
Set up Realtime subscription for a table.

Key Realtime tables:
- `messages` — chat between seeker and recruiter
- `notifications` — push updates to user
- `applications` — status changes

### `/supa migrate [description]`
Generate a timestamped migration SQL file.

```
supabase/migrations/{timestamp}_{description}.sql
```

## Output Format

```
## 🗄️ Supabase: {action} — {target}

### SQL
```sql
{generated SQL}
```

### Changes to BRIEF.md
{if schema was modified}

### Next Steps
- Run migration: `supabase db push` or apply via Supabase Dashboard
- `/feature {name}` to implement the Flutter side
- `/supa rls {table}` to add security policies
```

## Constraints (BRIEF.md §10)

- Supabase free tier: 500MB DB, 1GB Storage, 50MB/file
- pgvector: free, included in Supabase
- Edge Functions: Deno runtime
- Gemini Embedding API: 1500 req/day free tier
- Gemini Flash: 15 req/min
