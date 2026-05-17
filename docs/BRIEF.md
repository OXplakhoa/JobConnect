# BRIEF.md — Ứng dụng Hỗ trợ Tuyển dụng & Tìm kiếm Việc làm

## 1. Tổng quan dự án

Ứng dụng mobile kết nối **người tìm việc (Job Seeker)** với **nhà tuyển dụng (Recruiter)**,
tích hợp AI vector search để gợi ý việc làm phù hợp và phân tích skill gap.

| Thuộc tính | Giá trị |
|---|---|
| Tên dự án | JobConnect *(nhóm tự đặt lại nếu muốn)* |
| Loại | Đồ án nhóm (2–3 thành viên) — Môn Lập trình Di động |
| Mục tiêu | Portfolio chất lượng cao, có thể demo cho nhà tuyển dụng |
| Deadline | *(điền vào)* |

---

## 2. Actors (Vai trò người dùng)

| Vai trò | Mô tả ngắn |
|---|---|
| **Job Seeker** | Người tìm việc — tạo hồ sơ, ứng tuyển, nhận gợi ý AI |
| **Recruiter** | Nhà tuyển dụng / HR — đăng tin, quản lý ứng viên |
| **Admin** | Quản trị viên hệ thống — kiểm duyệt nội dung, xem thống kê |

---

## 3. Tính năng (Feature List)

### 3.1 Quản lý tài khoản — tất cả vai trò
- [ ] Đăng ký tài khoản (chọn vai trò Job Seeker hoặc Recruiter)
- [ ] Đăng nhập email/password
- [ ] Đăng nhập Google OAuth (Supabase Auth)
- [ ] Quên mật khẩu / reset qua email
- [ ] Đăng xuất

### 3.2 Job Seeker — Core
- [ ] Tạo & chỉnh sửa hồ sơ cá nhân (tên, ảnh, kỹ năng, kinh nghiệm)
- [ ] Thêm kinh nghiệm làm việc (work_experiences)
- [ ] Thêm học vấn (educations)
- [ ] Thêm chứng chỉ (certificates)
- [ ] CV Builder — tạo CV trực tiếp trong app
- [ ] Upload CV dạng PDF (tối đa 5MB)
- [ ] Xem trước CV trước khi nộp
- [ ] Tìm kiếm việc làm theo từ khóa
- [ ] Lọc việc làm theo: ngành nghề / vị trí / mức lương / địa điểm / hình thức
- [ ] Xem chi tiết tin tuyển dụng
- [ ] Bookmark / lưu tin tuyển dụng yêu thích
- [ ] Nộp hồ sơ ứng tuyển (đính kèm CV)
- [ ] Theo dõi trạng thái đơn ứng tuyển
- [ ] Rút đơn ứng tuyển
- [ ] Chat realtime với Recruiter
- [ ] Nhận push notification khi có cập nhật đơn ứng tuyển

### 3.3 Job Seeker — Stand-out Features ⭐

#### AI Gợi ý việc làm (Vector Search)
> Kỹ thuật: pgvector + embedding similarity — không phải chỉ gọi chatbot
- [ ] Khi cập nhật profile → tự động tạo embedding vector qua Gemini Embedding API → lưu vào `profile_embeddings`
- [ ] Khi có job post mới → tương tự → lưu vào `job_embeddings`
- [ ] Tab "Dành cho bạn" — query cosine similarity giữa profile vector và job vectors trong PostgreSQL
- [ ] Hiển thị match score (%) và top 3 lý do phù hợp (Gemini Flash giải thích)

#### Skill Gap Analysis ⭐
- [ ] Khi xem chi tiết 1 tin → so sánh `job_required_skills` với `user_skills` của ứng viên
- [ ] Hiển thị: kỹ năng đang có ✅ / kỹ năng còn thiếu ❌
- [ ] Gợi ý hướng học để lấp gap (prompt Gemini với context cụ thể)

#### Job Alert thông minh ⭐
- [ ] Lưu bộ lọc tìm kiếm thành "Saved Search" (bảng `saved_searches`)
- [ ] Supabase Edge Function chạy schedule hàng ngày → so khớp tin mới với saved searches
- [ ] Tự động gửi push notification khi có tin khớp bộ lọc

### 3.4 Recruiter
- [ ] Tạo & chỉnh sửa trang hồ sơ công ty
- [ ] Đăng tin tuyển dụng mới (kèm danh sách kỹ năng yêu cầu)
- [ ] Chỉnh sửa / đóng tin tuyển dụng
- [ ] Xem danh sách ứng viên đã apply vào từng tin
- [ ] Xem CV ứng viên (PDF viewer)
- [ ] Cập nhật trạng thái ứng viên: Đang xem xét / Mời phỏng vấn / Từ chối
- [ ] Thêm ghi chú nội bộ về ứng viên (`application_notes`)
- [ ] Đề xuất lịch phỏng vấn (`interview_schedules`)
- [ ] Chat realtime với ứng viên
- [ ] Nhận push notification khi có ứng viên mới

### 3.5 Admin
- [ ] Dashboard thống kê: tổng users, tổng tin, lượt ứng tuyển theo thời gian
- [ ] Xem & tìm kiếm danh sách người dùng
- [ ] Khóa / mở khóa tài khoản người dùng
- [ ] Duyệt / từ chối tin tuyển dụng trước khi publish
- [ ] Xem & xử lý báo cáo vi phạm

---

## 4. Tech Stack

### Mobile (Flutter)

| Package | Version | Mục đích |
|---|---|---|
| `flutter_riverpod` | ^2.5.0 | State management |
| `riverpod_annotation` | ^2.3.0 | Code generation cho provider |
| `go_router` | ^13.0.0 | Navigation, deep link |
| `supabase_flutter` | ^2.5.0 | Backend client |
| `freezed_annotation` | ^2.4.0 | Immutable models |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `dio` | ^5.4.0 | HTTP client (gọi Gemini API) |
| `flutter_secure_storage` | ^9.2.0 | Lưu token an toàn |
| `cached_network_image` | ^3.3.0 | Cache ảnh từ internet |
| `file_picker` | ^8.0.0 | Upload CV PDF |
| `firebase_messaging` | ^14.9.0 | Push notification (FCM) |
| `flutter_local_notifications` | ^17.0.0 | Hiện notification khi foreground |
| `flutter_svg` | ^2.0.0 | Render icon SVG |
| `intl` | ^0.19.0 | Format ngày tháng, tiền tệ |

### Backend

| Thành phần | Lựa chọn | Ghi chú |
|---|---|---|
| BaaS | **Supabase** (free tier) | Auth + DB + Storage + Realtime |
| Database | PostgreSQL + **pgvector extension** | Relational + vector similarity search |
| Auth | Supabase Auth | Email/Password + Google OAuth |
| Chat realtime | Supabase Realtime | Không cần server riêng |
| File storage | Supabase Storage | CV PDF, ảnh đại diện |
| Scheduled jobs | Supabase Edge Functions (Deno) | Job alert hàng ngày |

### Push Notification Flow (Firebase + Supabase)

```
[DB trigger / Edge Function trên Supabase]
        ↓
[Edge Function gọi Firebase Admin SDK]
        ↓
[FCM server của Google]
        ↓
[Thiết bị nhận qua firebase_messaging package]
        ↓
[flutter_local_notifications hiện banner khi app foreground]
```

Lưu FCM token của mỗi device vào bảng `device_tokens` khi user đăng nhập.

### AI — Vector Search (điểm nhấn kỹ thuật)

| Thành phần | Lựa chọn | Ghi chú |
|---|---|---|
| Embedding API | Gemini `text-embedding-004` | 768 chiều, free tier |
| Vector DB | **pgvector** (Supabase extension) | Tích hợp sẵn trong PostgreSQL |
| Similarity | Cosine similarity (`<=>`) | SQL thuần, không cần service riêng |
| LLM explain | Gemini Flash | Giải thích lý do gợi ý bằng tiếng Việt |

```sql
-- Query gợi ý việc làm cho user hiện tại
SELECT
  j.id, j.title, c.name AS company,
  1 - (je.embedding <=> pe.embedding) AS match_score
FROM job_embeddings je
JOIN job_posts j ON j.id = je.job_id
JOIN companies c ON c.id = j.company_id
JOIN profile_embeddings pe ON pe.user_id = $current_user_id
WHERE j.status = 'active'
ORDER BY match_score DESC
LIMIT 20;
```

Cache vào `ai_suggestions`, TTL = 24h. Rate limit: 1 rebuild/user/5 phút.

### Design Tooling — Impeccable (Agent Skill)

**Impeccable** (`impeccable.style`) là AI agent skill cài vào IDE — **không phải Flutter package**.
Hoạt động với Cursor, Claude Code, Antigravity, VS Code Copilot.

```
Cách tích hợp:
1. Cài Impeccable skill vào IDE (theo hướng dẫn tại impeccable.style/docs)
2. /impeccable teach       ← chạy 1 lần, agent học design context của project
3. /impeccable document    ← tạo DESIGN.md (bổ sung cho CLAUDE.md)
4. /impeccable craft [UI]  ← dùng khi build từng component
5. npx impeccable detect src/  ← chạy trước commit để bắt AI anti-patterns
```

`DESIGN.md` đặt trong `docs/` cùng cấp với `BRIEF.md` và `PRODUCT.md`.

---

## 5. Kiến trúc ứng dụng

```
Clean Architecture (simplified)

┌─────────────────────────────────────┐
│  Presentation Layer                 │
│  Pages + Widgets + Riverpod Providers│
├─────────────────────────────────────┤
│  Domain Layer                       │
│  Entities + Use Cases               │
├─────────────────────────────────────┤
│  Data Layer                         │
│  Repositories + Supabase Datasources│
└─────────────────────────────────────┘
```

---

## 6. Cấu trúc thư mục

```
lib/
├── core/
│   ├── constants/        # AppConstants, Env keys, prompt_templates.dart
│   ├── errors/           # Failure classes
│   ├── extensions/       # BuildContext, String extensions
│   ├── router/           # go_router config + route guards
│   ├── theme/            # AppTheme, AppColors, AppTextStyles
│   └── utils/            # Validators, formatters, helpers
├── features/
│   ├── auth/
│   ├── jobs/
│   ├── application/
│   ├── chat/
│   ├── profile/
│   ├── recruiter/
│   ├── admin/
│   ├── ai_suggestion/    # Vector search + gợi ý việc làm
│   ├── skill_gap/        # Skill gap analysis
│   └── job_alert/        # Saved searches + push alert
└── shared/
    ├── providers/
    └── widgets/
```

---

## 7. Database Schema — 22 bảng (Supabase / PostgreSQL + pgvector)

```sql
-- Kích hoạt pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- NHÓM 1: Auth & Profile
profiles             (id, role, full_name, avatar_url, bio, location, headline, created_at)
work_experiences     (id, user_id, company, role, from_date, to_date, description, is_current)
educations           (id, user_id, school, degree, major, from_date, to_date)
certificates         (id, user_id, name, issuer, issued_at, credential_url)

-- NHÓM 2: Danh mục / Lookup
job_categories       (id, name, slug, icon_url)
skills               (id, name, category_id)

-- NHÓM 3: Skills Mapping
user_skills          (user_id, skill_id, level)
job_required_skills  (job_id, skill_id, is_required)

-- NHÓM 4: Công ty & Tin tuyển dụng
companies            (id, recruiter_id, name, logo_url, description, website, size, province)
job_posts            (id, company_id, title, description, requirements,
                      salary_min, salary_max, type, category_id, status, expires_at, created_at)
job_locations        (id, job_id, province, district, address, is_remote)

-- NHÓM 5: Tuyển dụng
resumes              (id, user_id, title, content_json, file_url, is_default, created_at)
applications         (id, job_id, seeker_id, resume_url, cover_letter, status, created_at)
application_notes    (id, application_id, recruiter_id, note, created_at)
interview_schedules  (id, application_id, scheduled_at, location, note, status)

-- NHÓM 6: Chat & Thông báo
conversations        (id, seeker_id, recruiter_id, job_id, created_at)
messages             (id, conversation_id, sender_id, content, created_at, read_at)
notifications        (id, user_id, type, title, body, data_json, read, created_at)
device_tokens        (id, user_id, fcm_token, platform, created_at)

-- NHÓM 7: AI & Vector Search ⭐
profile_embeddings   (user_id PK, embedding vector(768), updated_at)
job_embeddings       (job_id PK, embedding vector(768), updated_at)
ai_suggestions       (id, seeker_id, job_id, score FLOAT, reason TEXT, cached_at)

-- NHÓM 8: Social & Job Alert
bookmarks            (id, seeker_id, job_id, created_at)
saved_searches       (id, user_id, filter_json, name, notify_new BOOLEAN, created_at)
company_reviews      (id, company_id, reviewer_id, rating SMALLINT, content, created_at)
reports              (id, reporter_id, target_type, target_id, reason, status, created_at)
```

> Tổng: **22 bảng** (profiles + 21 bảng) — RLS bật trên tất cả.

---

## 8. Platform Target

| Platform | Build machine | Test device |
|---|---|---|
| Android | Windows (primary) | Physical Android (cả nhóm) |
| iOS | macOS (secondary) | iOS Simulator trên Mac |

---

## 9. File cấu hình project (root level)

```
/
├── CLAUDE.md        ← rules code cho AI agent
├── CONTEXT.md       ← shared domain language (thuật ngữ dự án)
├── TASKS.md         ← checklist feature (tiến độ hiện tại)
├── README.md        ← project overview
│
├── docs/
│   ├── BRIEF.md     ← file này — design doc tổng thể
│   ├── PRODUCT.md   ← user personas + brand personality
│   ├── DESIGN.md    ← rules UI/UX (generate bởi Impeccable)
│   ├── adr/         ← Architecture Decision Records
│   ├── plans/       ← implementation plans theo task batch
│   └── archive/     ← completed reference docs
```

---

## 10. Constraints & Limitations

- Supabase free: 500MB DB · 1GB Storage · 50MB/file
- pgvector: miễn phí, sẵn trong Supabase
- Gemini Embedding API: free tier — 1500 req/ngày
- Gemini Flash: 15 req/min — rate limit 1 rebuild AI/user/5 phút
- CV: PDF only, tối đa 5MB
- Chat: text only
- Không có payment gateway

---

## 11. Out of Scope

- Video call phỏng vấn
- Tích hợp LinkedIn / external job board
- Đa ngôn ngữ (chỉ tiếng Việt)
- Flutter Web
- Subscription / premium plan