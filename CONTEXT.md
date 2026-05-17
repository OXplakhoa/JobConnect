# JobConnect

Nền tảng kết nối Seeker với Recruiter, tích hợp AI embedding similarity để gợi ý việc làm và phân tích skill gap.

> Agent PHẢI dùng đúng thuật ngữ trong file này khi giao tiếp và khi đặt tên biến/class/file.
> Nếu gặp thuật ngữ mới chưa có ở đây, hỏi trước khi tự đặt.

## Language

### Actors

**Seeker**:
Người tìm việc — tạo profile, apply jobs, nhận gợi ý AI. `profiles.role = 'seeker'`
_Avoid_: Job Seeker (dài), Candidate (góc nhìn recruiter), Ứng viên (chỉ dùng khi đã apply)

**Recruiter**:
Nhà tuyển dụng / HR — đăng tin, quản lý ứng viên, phỏng vấn. `profiles.role = 'recruiter'`
_Avoid_: Employer, Hiring manager

**Admin**:
Quản trị viên — kiểm duyệt, thống kê, khóa tài khoản. `profiles.role = 'admin'`
_Avoid_: Moderator, Superuser

### Core entities

**Profile**:
Hồ sơ cá nhân của Seeker (tên, ảnh, headline, bio, location).
_Avoid_: User account (profile ≠ auth account), Hồ sơ (ambiguous — dùng Profile nhất quán)

**Job Post**:
Tin tuyển dụng do Recruiter đăng. Bảng `job_posts`.
_Avoid_: Job (ambiguous — có thể chỉ post hoặc nghề), Listing, Tin (quá ngắn)

**Application**:
Đơn ứng tuyển — Seeker nộp vào 1 Job Post, kèm Resume và optional cover letter. Bảng `applications`.
_Avoid_: App (nhầm phần mềm), Submission, Đơn (quá ngắn)

**Company**:
Hồ sơ công ty của Recruiter — tên, logo, mô tả, quy mô, tỉnh thành. Bảng `companies`.
_Avoid_: Organization, Firm

**Resume**:
Hồ sơ xin việc — JSON (CV Builder) hoặc PDF (upload). Bảng `resumes`.
_Avoid_: CV (dùng Resume cho entity, "CV" chỉ dùng làm UI label)

**Bookmark**:
Seeker lưu Job Post yêu thích. Bảng `bookmarks`.
_Avoid_: Save (action chung), Favorite

**Conversation**:
Phòng chat 1-1 giữa Seeker và Recruiter về 1 Job Post. Bảng `conversations`.
_Avoid_: Chat (chỉ dùng làm UI label), Thread, Room

**Message**:
Tin nhắn trong Conversation. Text only. Bảng `messages`.
_Avoid_: Chat message (redundant)

**Notification**:
Thông báo in-app cho user. Bảng `notifications`.
_Avoid_: Alert (nhầm với Job Alert), Push notification (push là cơ chế gửi, notification là entity)

### Lookup / Catalog

**Category**:
Ngành nghề (IT, Marketing, Finance...). Bảng `job_categories`.
_Avoid_: Industry, Sector

**Skill**:
Kỹ năng (React, SQL, Figma...) thuộc 1 Category. Bảng `skills`.
_Avoid_: Competency, Ability

**User Skill**:
Skill mà Seeker tự khai báo, kèm level (beginner / intermediate / advanced). Bảng `user_skills`.
_Avoid_: My skill, Profile skill

**Required Skill**:
Skill mà Job Post yêu cầu, phân biệt bắt buộc (`is_required = true`) và ưu tiên. Bảng `job_required_skills`.
_Avoid_: Job skill, Desired skill

### AI & Matching

**Embedding**:
Vector 768 chiều, tạo bởi Gemini `text-embedding-004`, lưu dạng `vector(768)` trong pgvector.
_Avoid_: Vector (quá chung), Feature vector

**Profile Embedding**:
Embedding từ profile + skills + experience của Seeker. Bảng `profile_embeddings`.
_Avoid_: User vector, Seeker embedding

**Job Embedding**:
Embedding từ title + description + requirements của Job Post. Bảng `job_embeddings`.
_Avoid_: Post vector, Job vector

**Match Score**:
`1 - (job_embedding <=> profile_embedding)` — cosine similarity, nhân 100 hiển thị dạng %. Giá trị 0.0–1.0.
_Avoid_: Similarity score, Relevance score

**AI Suggestion**:
Kết quả gợi ý: Job Post + Match Score + reason text. Bảng `ai_suggestions`, cache TTL 24h.
_Avoid_: Recommendation, Gợi ý (dùng AI Suggestion cho entity)

**Skill Gap**:
Danh sách Required Skills mà Seeker chưa có User Skill tương ứng. Tính realtime khi xem Job Post detail.
_Avoid_: Missing skills, Skill deficit

**Saved Search**:
Bộ lọc tìm kiếm đã lưu, dùng cho Job Alert tự động. Bảng `saved_searches`.
_Avoid_: Search filter, Alert rule

**Job Alert**:
Push notification khi có Job Post mới khớp Saved Search. Edge Function chạy schedule hàng ngày.
_Avoid_: Notification (đã dùng cho in-app), Search alert

### Recruitment flow

**Apply**:
Seeker nộp đơn ứng tuyển vào Job Post. `applications.status = 'pending'`
_Avoid_: Submit, Ứng tuyển (dùng Apply cho action)

**Withdraw**:
Seeker rút đơn — chỉ khi status = `pending`. `applications.status = 'withdrawn'`
_Avoid_: Cancel, Revoke

**Shortlist**:
Recruiter đang xem xét ứng viên. `applications.status = 'reviewing'`
_Avoid_: Review (nhầm code review), Screen

**Invite**:
Recruiter mời phỏng vấn. `applications.status = 'interview'`
_Avoid_: Schedule (Invite là action, schedule là chi tiết)

**Reject**:
Recruiter từ chối. `applications.status = 'rejected'`
_Avoid_: Decline, Turn down

**Hire**:
Recruiter chấp nhận. `applications.status = 'accepted'` (out of scope cho MVP)
_Avoid_: Accept (dùng Hire cho domain action, `accepted` cho DB status)

### Job Post lifecycle

**Draft**:
Recruiter tạo nhưng chưa submit. `job_posts.status = 'draft'`

**Pending Review**:
Đã submit, chờ Admin duyệt. `job_posts.status = 'pending_review'`

**Active**:
Đã duyệt, đang hiển thị cho Seeker. `job_posts.status = 'active'`

**Closed**:
Recruiter đóng tin hoặc hết hạn. `job_posts.status = 'closed'`

**Rejected**:
Admin từ chối. `job_posts.status = 'rejected'`

## Relationships

- A **Seeker** has exactly one **Profile**
- A **Seeker** declares zero or more **User Skills**
- A **Seeker** submits zero or more **Applications** to **Job Posts**
- An **Application** carries exactly one **Resume**
- An **Application** follows the flow: **Apply** → **Shortlist** → **Invite** → **Hire** / **Reject** (or **Withdraw** from `pending`)
- A **Job Post** belongs to exactly one **Company**
- A **Job Post** requires zero or more **Required Skills**
- A **Job Post** follows the lifecycle: **Draft** → **Pending Review** → **Active** → **Closed** (or **Rejected** by Admin)
- A **Company** belongs to exactly one **Recruiter**
- A **Recruiter** can have at most one **Company**
- A **Skill** belongs to one **Category**
- A **Match Score** connects one **Profile Embedding** to one **Job Embedding**
- A **Conversation** links exactly one **Seeker**, one **Recruiter**, and one **Job Post**
- A **Conversation** contains zero or more **Messages**
- A **Saved Search** can trigger zero or more **Job Alerts**
- A **Seeker** can create zero or more **Bookmarks** for **Job Posts**

## Example dialogue

> **Dev:** "Khi Seeker apply, chuyện gì xảy ra với Application?"
> **Domain expert:** "Nó bắt đầu ở `pending`. Recruiter có thể chuyển sang `reviewing` (**Shortlist**), rồi `interview` (**Invite**), cuối cùng `accepted` hoặc `rejected`."

> **Dev:** "Seeker có thể hủy không?"
> **Domain expert:** "Chỉ khi còn `pending` — đó là **Withdraw**. Sau khi Recruiter bắt đầu **Shortlist** thì chỉ Recruiter quyết định."

> **Dev:** "Match Score hiển thị thế nào?"
> **Domain expert:** "Là cosine similarity giữa **Profile Embedding** và **Job Embedding**, nhân 100 hiển thị dạng %. Trên 70% là khá phù hợp."

> **Dev:** "Khi Seeker update profile, embedding có tự cập nhật không?"
> **Domain expert:** "Có — mỗi lần profile hoặc **User Skills** thay đổi, hệ thống tạo **Profile Embedding** mới. **AI Suggestions** cũ bị invalidate."

> **Dev:** "Job Post mới đăng có hiện cho Seeker ngay không?"
> **Domain expert:** "Không — nó bắt đầu ở **Draft**. Recruiter submit thì chuyển sang **Pending Review**. Admin duyệt thì mới **Active** và hiện cho Seeker."

> **Dev:** "Nếu Seeker lưu tin, dùng từ gì?"
> **Domain expert:** "**Bookmark**. Không gọi là 'save' vì save là action chung. UI có thể hiện icon bookmark, nhưng entity luôn là **Bookmark**."

## Flagged ambiguities

- "App" — dùng cho cả Application (đơn ứng tuyển) và phần mềm. **Đã giải quyết**: KHÔNG viết tắt Application thành App.
- "Chat" vs "Conversation" — **Đã giải quyết**: Conversation là entity (bảng DB), "chat" chỉ dùng làm UI label.
- "Job" — ambiguous giữa Job Post (tin tuyển dụng) và nghề nghiệp. **Đã giải quyết**: luôn dùng "Job Post" cho entity.
- "Profile" vs "Account" — **Đã giải quyết**: Profile là hồ sơ cá nhân (domain), account là auth identity (technical).
- "Bookmark" vs "Save" — **Đã giải quyết**: dùng "Bookmark" nhất quán, "save" là action chung.
- "CV" vs "Resume" — **Đã giải quyết**: Resume là entity, "CV" chỉ dùng làm UI label (ví dụ: "CV Builder").
- "Notification" vs "Alert" — **Đã giải quyết**: Notification là entity in-app chung, Job Alert là loại push notification riêng cho Saved Search matches.
- "Hire" vs "Accept" — **Đã giải quyết**: Hire là domain action (Recruiter hires Seeker), `accepted` là DB status value.