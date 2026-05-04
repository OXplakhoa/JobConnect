# CONTEXT.md — JobConnect Shared Language

> Agent PHẢI dùng đúng thuật ngữ trong file này khi giao tiếp và khi đặt tên biến/class/file.
> Nếu gặp thuật ngữ mới chưa có ở đây, hỏi trước khi tự đặt.

---

## Actors (Vai trò)

| Term | Meaning | DB column |
|---|---|---|
| **Seeker** | Người tìm việc (Job Seeker) — tạo profile, apply jobs, nhận gợi ý AI | `profiles.role = 'seeker'` |
| **Recruiter** | Nhà tuyển dụng / HR — đăng tin, quản lý ứng viên, phỏng vấn | `profiles.role = 'recruiter'` |
| **Admin** | Quản trị viên — kiểm duyệt, thống kê, khóa tài khoản | `profiles.role = 'admin'` |

---

## Core Domain Terms

| Term | Meaning | KHÔNG nhầm với |
|---|---|---|
| **Profile** | Hồ sơ cá nhân của Seeker (tên, ảnh, headline, bio, location) | "User account" — profile ≠ auth account |
| **Job Post** (hoặc **Post**) | Tin tuyển dụng do Recruiter đăng. Bảng `job_posts` | "Job" có thể chỉ post hoặc nghề — luôn dùng "Job Post" |
| **Application** | Đơn ứng tuyển — Seeker nộp vào 1 Job Post. Bảng `applications` | "App" (phần mềm) — KHÔNG viết tắt Application thành App |
| **Company** | Hồ sơ công ty của Recruiter. Bảng `companies` | — |
| **Resume / CV** | Hồ sơ xin việc — JSON (CV Builder) hoặc PDF (upload). Bảng `resumes` | — |
| **Bookmark** | Seeker lưu Job Post yêu thích. Bảng `bookmarks` | "Save" — dùng "bookmark" nhất quán |
| **Conversation** | Phòng chat 1-1 giữa Seeker và Recruiter về 1 Job Post | "Chat" — dùng "conversation" cho entity, "chat" cho UI label |
| **Message** | Tin nhắn trong Conversation. Text only | — |
| **Notification** | Thông báo in-app. Bảng `notifications` | "Push notification" — push là cơ chế gửi, notification là entity |

---

## Lookup / Catalog Terms

| Term | Meaning | Bảng |
|---|---|---|
| **Category** | Ngành nghề (IT, Marketing, Finance...) | `job_categories` |
| **Skill** | Kỹ năng (React, SQL, Figma...) thuộc 1 Category | `skills` |
| **User Skill** | Skill mà Seeker tự khai báo, kèm level | `user_skills` |
| **Required Skill** | Skill mà Job Post yêu cầu, phân biệt bắt buộc/ưu tiên | `job_required_skills` |

---

## AI / Vector Search Terms

| Term | Meaning | Chi tiết |
|---|---|---|
| **Embedding** | Vector 768 chiều, tạo bởi Gemini `text-embedding-004` | Lưu dạng `vector(768)` trong pgvector |
| **Profile Embedding** | Embedding từ profile + skills + experience của Seeker | Bảng `profile_embeddings` |
| **Job Embedding** | Embedding từ title + description + requirements của Job Post | Bảng `job_embeddings` |
| **Match Score** | `1 - (job_embedding <=> profile_embedding)` — cosine similarity, hiển thị dạng % | Giá trị 0.0–1.0, nhân 100 khi hiển thị |
| **AI Suggestion** | Kết quả gợi ý: Job Post + Match Score + reason text | Bảng `ai_suggestions`, cache TTL 24h |
| **Skill Gap** | Danh sách Required Skills mà Seeker chưa có User Skill tương ứng | Tính realtime khi xem Job Post detail |
| **Saved Search** | Bộ lọc tìm kiếm đã lưu, dùng cho Job Alert tự động | Bảng `saved_searches` |
| **Job Alert** | Push notification khi có Job Post mới khớp Saved Search | Edge Function chạy schedule hàng ngày |

---

## Recruitment Flow Terms

| Term | Meaning | `applications.status` |
|---|---|---|
| **Apply** | Seeker nộp đơn ứng tuyển vào Job Post | `pending` |
| **Withdraw** | Seeker rút đơn (chỉ khi status = pending) | `withdrawn` |
| **Shortlist** | Recruiter đang xem xét ứng viên | `reviewing` |
| **Invite** | Recruiter mời phỏng vấn | `interview` |
| **Reject** | Recruiter từ chối | `rejected` |
| **Hire** | Recruiter chấp nhận (out of scope cho MVP) | — |

---

## Application Status Flow

```
pending → reviewing → interview → (accepted / rejected)
pending → withdrawn (by Seeker)
```

---

## Job Post Status Flow

| Status | Meaning |
|---|---|
| `draft` | Recruiter tạo nhưng chưa submit |
| `pending_review` | Đã submit, chờ Admin duyệt |
| `active` | Đã duyệt, đang hiển thị cho Seeker |
| `closed` | Recruiter đóng tin hoặc hết hạn |
| `rejected` | Admin từ chối |

---

## Architecture Terms

| Term | Meaning | Layer |
|---|---|---|
| **Datasource** | Class gọi Supabase trực tiếp — chỉ nằm trong `data/datasources/` | Data |
| **Model** | Freezed class + `fromJson`/`toJson` — mapping DB ↔ Dart | Data |
| **Repository (abstract)** | Interface khai báo contract — KHÔNG biết Supabase tồn tại | Domain |
| **Repository (impl)** | Implement abstract repo, dùng Datasource, trả `Either<Failure, T>` | Data |
| **Entity** | Pure Dart class — domain object, KHÔNG có json annotation | Domain |
| **Use Case** | 1 class = 1 hành động business (GetJobsUseCase, ApplyJobUseCase) | Domain |
| **Provider** | Riverpod `@riverpod` annotation — expose state cho UI | Presentation |
| **Notifier** | Riverpod `@riverpod` class có methods mutate state | Presentation |
| **Page** | Widget full-screen, là route destination | Presentation |
| **Failure** | Sealed class cho error types — KHÔNG dùng exception | Domain |

---

## File / Folder Naming Quick-Ref

| Concept | File name pattern | Example |
|---|---|---|
| Datasource | `{feature}_datasource.dart` | `job_datasource.dart` |
| Model | `{feature}_model.dart` | `job_model.dart` |
| Entity | `{name}.dart` (không suffix) | `job.dart` |
| Repository (abstract) | `{feature}_repository.dart` | `job_repository.dart` |
| Repository (impl) | `{feature}_repository_impl.dart` | `job_repository_impl.dart` |
| Use Case | `{verb}_{noun}_usecase.dart` | `get_jobs_usecase.dart` |
| Provider | `{feature}_provider.dart` | `job_list_provider.dart` |
| Page | `{feature}_page.dart` | `job_detail_page.dart` |
| Widget | `{name}_widget.dart` hoặc `{name}_card.dart` | `job_card.dart` |

---

## Storage Paths

| Resource | Supabase Storage Path |
|---|---|
| Avatar | `avatars/{userId}/avatar.jpg` |
| Resume PDF | `resumes/{userId}/{filename}` |
| Company Logo | `logos/{companyId}/logo.jpg` |

---

## Abbreviation Rules

- **KHÔNG** viết tắt domain terms (dùng `application` không dùng `app`, dùng `notification` không dùng `noti`)
- **OK** viết tắt kỹ thuật chuẩn: `auth`, `repo`, `impl`, `UI`, `DB`, `RLS`, `FCM`, `PDF`, `CV`