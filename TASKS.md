# TASKS.md — JobConnect Feature Checklist

> Mỗi task = 1 lần chạy agent. Thứ tự từ trên xuống — KHÔNG làm task sau khi task trước chưa xong.
> Workflow: Pick task → Grill (hỏi edge cases) → /supa (nếu cần) → /scaffold → /feature → /review → manual check → commit → tick ☑.

---

## Phase 0 — Foundation (core/, shared/, Supabase setup)

> Chưa có feature nào — chỉ setup nền tảng để mọi feature sau đều dùng lại.

- [X] **T-00: Flutter project init + packages**
  Tạo Flutter project, thêm toàn bộ dependencies/dev_dependencies từ CLAUDE.md, cấu hình `analysis_options.yaml`, tạo `.env.example`.

- [X] **T-01: Core — Theme + Design System**
  `core/theme/`: `AppColors`, `AppTextStyles`, `AppTheme` (light + dark). `core/constants/`: `AppConstants`, `AppStrings`.

- [X] **T-02: Core — Error handling + Failure classes**
  `core/errors/`: `Failure` sealed class (`NetworkFailure`, `DatabaseFailure`, `AuthFailure`, `UnexpectedFailure`). `core/extensions/`: `BuildContext` extensions, `Either` helpers.

- [X] **T-03: Core — Router shell + Auth guard**
  `core/router/`: `AppRouter` với `go_router`, `ShellRoute` cho bottom nav, `AuthGuard` redirect (chưa có logic auth thật — chỉ skeleton guard). Placeholder `HomePage`, `LoginPage`.

- [X] **T-04: Supabase — Schema migration (toàn bộ 22 bảng)**
  Tạo SQL migration script theo BRIEF.md §7. Bật pgvector extension. Chạy trên Supabase Dashboard. KHÔNG tạo RLS ở bước này.

- [X] **T-05: Supabase — RLS policies (toàn bộ bảng)**
  Viết RLS policies cho tất cả 22 bảng. Nguyên tắc: Seeker chỉ read/write data của mình, Recruiter chỉ manage company + jobs của mình, Admin read all.

---

## Phase 1 — Auth (feature: `auth`)

> Dependency: Phase 0 hoàn thành. Mọi feature sau đều cần auth.

- [ ] **T-06: Auth — Email register + role selection**
  Đăng ký tài khoản (email/password), chọn role Seeker hoặc Recruiter. Tạo row trong `profiles` sau khi register. Bao gồm: datasource → model → entity → repository → usecase → provider → `RegisterPage`.

- [ ] **T-07: Auth — Email login + session persistence**
  Đăng nhập email/password. Persist session qua Supabase Auth. Redirect theo role (Seeker → Home, Recruiter → Dashboard). Bao gồm: `LoginPage`, auth state provider, router guard thật.

- [ ] **T-08: Auth — Google OAuth login**
  Đăng nhập Google qua Supabase Auth. Xử lý: user mới → chọn role → tạo profile; user cũ → redirect theo role.

- [ ] **T-09: Auth — Forgot password + Logout**
  Quên mật khẩu (gửi email reset qua Supabase). Đăng xuất (clear session, redirect login). `ForgotPasswordPage`.

---

## Phase 2 — Seeker Profile (features: `profile`)

> Dependency: Auth hoàn thành. Profile là nền tảng cho Apply, AI Suggestion, Skill Gap.

- [ ] **T-10: Profile — CRUD hồ sơ cá nhân**
  Tạo & chỉnh sửa profile (full_name, avatar, headline, bio, location). Upload avatar lên Supabase Storage `avatars/{userId}/`. `ProfilePage` + `EditProfilePage`.

- [ ] **T-11: Profile — Work Experiences + Educations + Certificates**
  CRUD cho 3 bảng phụ: `work_experiences`, `educations`, `certificates`. Hiển thị dạng list trong `ProfilePage`. Thêm/sửa/xóa qua bottom sheet hoặc dialog.

- [ ] **T-12: Profile — User Skills management**
  Seeker thêm/xóa skills từ bảng `skills` lookup. Chọn level (beginner/intermediate/advanced). Hiển thị skill tags trong profile. Bảng: `user_skills`.

---

## Phase 3 — Recruiter Setup (features: `recruiter`)

> Dependency: Auth hoàn thành. Company + Job Post cần có trước khi Seeker tìm việc.

- [ ] **T-13: Company — CRUD hồ sơ công ty**
  Recruiter tạo & chỉnh sửa company (name, logo, description, website, size, province). Upload logo lên Storage. `CompanyProfilePage` + `EditCompanyPage`. Bảng: `companies`.

- [ ] **T-14: Job Post — Đăng tin tuyển dụng**
  Recruiter tạo Job Post mới (title, description, requirements, salary range, type, category, required skills). Status mặc định = `draft`. `CreateJobPostPage`. Bảng: `job_posts`, `job_locations`, `job_required_skills`.

- [ ] **T-15: Job Post — Chỉnh sửa + đóng tin + danh sách tin đã đăng**
  Recruiter xem danh sách Job Posts của mình, chỉnh sửa, thay đổi status (draft → pending_review, active → closed). `MyJobPostsPage` + `EditJobPostPage`.

---

## Phase 4 — Job Discovery (features: `jobs`)

> Dependency: Có Job Post data (Phase 3). Seeker bắt đầu tìm việc.

- [ ] **T-16: Job Search — Danh sách + tìm kiếm + lọc**
  Seeker xem danh sách Job Posts (`status = active`). Tìm kiếm theo từ khóa. Lọc theo: category, salary range, location, type (full-time/part-time/remote). `JobSearchPage` + `JobCard` widget + `FilterBottomSheet`.

- [ ] **T-17: Job Detail — Xem chi tiết tin tuyển dụng**
  Seeker xem full detail Job Post: company info, description, requirements, required skills, salary, location. Nút Bookmark + Apply. `JobDetailPage`.

- [ ] **T-18: Bookmark — Lưu tin yêu thích**
  Toggle bookmark trên `JobCard` và `JobDetailPage`. Xem danh sách bookmarks trong `BookmarksPage`. Bảng: `bookmarks`.

---

## Phase 5 — Application Flow (features: `application`)

> Dependency: Profile (Phase 2) + Job Discovery (Phase 4). Seeker cần profile + có job để apply.

- [ ] **T-19: Resume — CV Builder + Upload PDF**
  Seeker tạo CV qua builder (JSON template) hoặc upload PDF (≤ 5MB). Xem trước CV. Chọn CV mặc định. Bảng: `resumes`. Storage: `resumes/{userId}/`.

- [ ] **T-20: Apply — Nộp đơn ứng tuyển**
  Seeker chọn CV, viết cover letter (optional), nộp vào Job Post. Tạo `application` với status `pending`. Chặn apply trùng. `ApplyPage` hoặc `ApplyBottomSheet`.

- [ ] **T-21: Application Tracking — Xem trạng thái + rút đơn**
  Seeker xem danh sách applications đã nộp, filter theo status. Rút đơn (chỉ khi `pending`). `MyApplicationsPage`.

- [ ] **T-22: Recruiter — Quản lý ứng viên**
  Recruiter xem danh sách ứng viên đã apply vào từng Job Post. Xem CV (PDF viewer). Cập nhật status (reviewing → interview → rejected). Thêm ghi chú nội bộ (`application_notes`). `ApplicantsPage` + `ApplicantDetailPage`.

- [ ] **T-23: Recruiter — Đề xuất lịch phỏng vấn**
  Khi status = `interview`, Recruiter tạo `interview_schedule` (ngày giờ, địa điểm, ghi chú). Seeker nhận notification + xem trong Application detail. `ScheduleInterviewPage`.

---

## Phase 6 — AI Features ⭐ (features: `ai_suggestion`, `skill_gap`)

> Dependency: Profile + Skills (Phase 2) + Job Posts (Phase 3). Embedding cần data từ cả 2.

- [ ] **T-24: AI — Embedding pipeline (profile + job)**
  Khi Seeker cập nhật profile/skills → gọi Gemini `text-embedding-004` → lưu vào `profile_embeddings`. Khi Job Post status = `active` → tương tự → `job_embeddings`. Edge Function hoặc datasource level. `core/constants/prompt_templates.dart` cho prompt format.

- [ ] **T-25: AI — Tab "Dành cho bạn" (cosine similarity)**
  Query pgvector cosine similarity → hiển thị top 20 Job Posts + Match Score (%). Cache vào `ai_suggestions` (TTL 24h). Rate limit: 1 rebuild/user/5 phút. `ForYouPage` hoặc tab trong `HomePage`.

- [ ] **T-26: AI — Match explanation (Gemini Flash)**
  Khi Seeker xem AI suggestion detail → gọi Gemini Flash giải thích top 3 lý do phù hợp bằng tiếng Việt. Hiển thị trong `JobDetailPage` khi truy cập từ AI tab.

- [ ] **T-27: Skill Gap — Phân tích kỹ năng còn thiếu**
  Trong `JobDetailPage`: so sánh `job_required_skills` vs `user_skills`. Hiển thị ✅ có / ❌ thiếu. Gợi ý hướng học (Gemini Flash prompt). `SkillGapWidget`.

---

## Phase 7 — Chat Realtime (feature: `chat`)

> Dependency: Auth + có Seeker + Recruiter accounts. Chat cần cả 2 roles.

- [ ] **T-28: Chat — Conversation list + tạo conversation**
  Seeker bắt đầu chat từ `JobDetailPage` hoặc `ApplicantDetailPage`. Tạo conversation nếu chưa tồn tại. Hiển thị danh sách conversations. `ConversationsPage`. Bảng: `conversations`.

- [ ] **T-29: Chat — Realtime messaging**
  Gửi/nhận tin nhắn realtime qua Supabase Realtime. Hiển thị messages, đánh dấu read. Auto-scroll. `ChatPage`. Bảng: `messages`. Provider subscribe → `ref.onDispose` cancel.

---

## Phase 8 — Notifications (feature: `notification`)

> Dependency: Auth + FCM setup. Push notification cần device token.

- [ ] **T-30: Notification — FCM setup + device token**
  Cấu hình `firebase_messaging` + `flutter_local_notifications`. Lưu FCM token vào `device_tokens` khi login. Xóa khi logout. Foreground notification banner.

- [ ] **T-31: Notification — In-app notification list**
  Hiển thị danh sách notifications từ bảng `notifications`. Đánh dấu read. Navigate đến target khi tap. `NotificationsPage`.

- [ ] **T-32: Notification — Triggers (Application status + new applicant)**
  Supabase trigger/Edge Function: khi `applications.status` thay đổi → tạo notification + gửi push cho Seeker. Khi có application mới → push cho Recruiter.

---

## Phase 9 — Admin (feature: `admin`)

> Dependency: Toàn bộ Phase 1–5. Admin quản lý data do các role khác tạo.

- [ ] **T-33: Admin — Dashboard thống kê**
  Tổng users, tổng Job Posts, lượt ứng tuyển theo thời gian (chart). `AdminDashboardPage`. Query aggregate trực tiếp hoặc Supabase RPC.

- [ ] **T-34: Admin — Quản lý người dùng + duyệt tin**
  Xem danh sách users, tìm kiếm, khóa/mở khóa tài khoản. Xem Job Posts `pending_review`, duyệt (→ `active`) hoặc từ chối (→ `rejected`). `AdminUsersPage` + `AdminJobReviewPage`.

- [ ] **T-35: Admin — Xử lý báo cáo vi phạm**
  Xem danh sách reports. Xử lý: dismiss hoặc take action (khóa user/ẩn post). `AdminReportsPage`. Bảng: `reports`.

---

## Phase 10 — Job Alert + Social (features: `job_alert`)

> Dependency: Job Search (Phase 4) + Notification (Phase 8).

- [ ] **T-36: Saved Search — Lưu bộ lọc tìm kiếm**
  Seeker lưu filter hiện tại thành Saved Search (đặt tên, toggle notify). Xem/xóa saved searches. `SavedSearchesPage`. Bảng: `saved_searches`.

- [ ] **T-37: Job Alert — Edge Function schedule**
  Supabase Edge Function chạy hàng ngày: so khớp Job Posts mới (`created_at > last_check`) với `saved_searches.filter_json`. Gửi push notification khi có match.

---

## Phase 11 — Polish & Ship 🚀

- [ ] **T-38: UI Polish pass**
  `/impeccable critique` toàn bộ pages → fix UX issues. Consistent spacing, typography, colors. Empty states, loading states, error states cho mọi page.

- [ ] **T-39: Final review + flutter analyze**
  `/review lib/` toàn bộ. Fix mọi linter warnings. Kiểm tra architecture boundaries. Test trên physical device.

---

## Summary

| Phase | Tasks | Nội dung |
|---|---|---|
| 0 — Foundation | T-00 → T-05 | Project init, core/, Supabase schema + RLS |
| 1 — Auth | T-06 → T-09 | Register, login, OAuth, forgot password |
| 2 — Seeker Profile | T-10 → T-12 | Profile CRUD, experiences, skills |
| 3 — Recruiter Setup | T-13 → T-15 | Company, post job, manage posts |
| 4 — Job Discovery | T-16 → T-18 | Search, detail, bookmark |
| 5 — Application | T-19 → T-23 | Resume, apply, tracking, recruiter manage |
| 6 — AI ⭐ | T-24 → T-27 | Embedding, suggestions, skill gap |
| 7 — Chat | T-28 → T-29 | Conversation, realtime messaging |
| 8 — Notification | T-30 → T-32 | FCM, in-app, triggers |
| 9 — Admin | T-33 → T-35 | Dashboard, user management, reports |
| 10 — Job Alert | T-36 → T-37 | Saved search, scheduled Edge Function |
| 11 — Polish | T-38 → T-39 | UI polish, final review |
| **Total** | **40 tasks** | |
