# Product

## Register

product

## Users

**Primary: Job Seeker (Seeker)**
Vietnamese university student or fresh graduate, 21–26 tuổi. Dùng Android là chính. Lướt app lúc rảnh, trên đường đi học hoặc đi làm. Đọc tiếng Việt, không quen UI phức tạp. Cần thấy kết quả ngay; không chịu được loading kéo dài hay form nhiều bước. Mục tiêu: tìm việc phù hợp nhanh, biết mình thiếu gì (skill gap), được notify khi có tin mới khớp — không cần chủ động refresh.

**Secondary: Recruiter**
HR hoặc người phụ trách tuyển dụng tại công ty. Đăng tin, quản lý ứng viên, theo dõi pipeline, chat với candidate. Cần efficiency — xem nhiều hồ sơ nhanh, ra quyết định trên từng ứng viên.

**Tertiary: Admin**
Quản trị viên hệ thống. Kiểm duyệt tin tuyển dụng, xem thống kê, xử lý báo cáo. Frequency thấp, priority thấp cho design.

## Product Purpose

Kết nối người tìm việc với nhà tuyển dụng thông qua AI vector search. Gợi ý việc làm phù hợp, phân tích skill gap, thông báo proactive khi có tin mới khớp profile. Thành công = Seeker tìm được việc phù hợp mà không phải duyệt hàng trăm tin, Recruiter tiếp cận đúng ứng viên mà không phải đọc CV rác.

## Brand Personality

**Clear, Confident, Warm.**

Clear: user không bao giờ confused ở bất kỳ bước nào. Confident: app làm user cảm thấy họ đang tiến về phía trước trong career journey. Warm: approachable cho sinh viên Việt Nam — không lạnh như corporate tool, không khô như form điền hồ sơ.

Emotional goals: "Tôi biết mình đang ở đâu trong hành trình tìm việc" (confident) + "App này trông legit, không phải job board rác" (professional trust). Tránh: overwhelmed (quá nhiều thứ một lúc) và generic (clone của TopCV hay LinkedIn).

## Anti-references

- **TopCV** — banner quảng cáo chen giữa content, màu cam/đỏ saturated quá mức, quá nhiều text block trên một màn hình, CTA button bị lạc giữa đống thông tin.
- **LinkedIn** — feed-based mental model (JobConnect không phải social network), corporate blue #0A66C2 monotony, notification badge spam, feature bloat khiến user không biết bắt đầu từ đâu.
- **VietnamWorks / Tuyển dụng 123** — layout trông như web desktop thu nhỏ vào mobile, typography quá nhỏ, card design generic không có identity riêng.

## Design Principles

1. **Earn every element.** Nothing on screen that doesn't serve the current task. If removing it doesn't hurt, it shouldn't exist. Inspired by Linear's restraint.
2. **Instant clarity.** User knows what to do within 2 seconds of any screen. CTA luôn rõ ràng và ở đúng chỗ. Inspired by Grab's task-first UX.
3. **Show progress, not noise.** Every interaction should make the user feel they're moving forward in their career journey — not drowning in options or lost in a feed.
4. **Proactive, not passive.** The app brings opportunities to the user (AI suggestions, job alerts, skill gap insights). The user should never feel like they need to refresh or hunt.
5. **Warm confidence.** Professional enough to trust with career decisions, approachable enough to not intimidate a 21-year-old opening it for the first time.

## Accessibility & Inclusion

- **WCAG AA** — target standard for all screens.
- **Contrast**: text contrast ratio ≥ 4.5:1 (enforced).
- **Reduced motion**: respect `prefers-reduced-motion` / `AccessibilityFeatures.reduceMotion` in Flutter. Critical for Android low-end devices where heavy animation causes jank.
- **Color blindness**: best-effort — don't rely on color alone for status indicators; pair with icons or labels.
- **Screen reader**: best-effort — use semantic widgets and proper labels, but not a hard requirement for this academic project.
