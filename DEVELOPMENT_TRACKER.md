# DEVELOPMENT TRACKER - EMORA

Tài liệu theo dõi tiến độ phát triển dự án Emora theo đúng quy định tại [RULES.md](file:///d:/Workspace/emora/RULES.md).

## Sprint 1: Setup Dự án, Auth & Ghép đôi (Tuần 1)

| Tên tính năng (Feature Name) | Trạng thái (Status) | Ngày cập nhật (Updated At) | Ghi chú (Implementation Notes) |
| :--- | :--- | :--- | :--- |
| **Khởi tạo cấu trúc dự án Flutter** | ✅ Completed | 12/06/2026 | Khởi tạo dự án, config `pubspec.yaml`, constants màu sắc/routing và tích hợp biến môi trường qua `.env`. |
| **Khởi tạo CSDL Supabase (Postgres SQL DDL)** | ✅ Completed | 12/06/2026 | Tạo tệp [init_schema.sql](file:///d:/Workspace/emora/supabase/init_schema.sql) và kết nối CSDL qua `DATABASE_URL` từ tệp `.env`. |
| **Cấu hình Supabase Auth** | ✅ Completed | 11/06/2026 | Đăng nhập Google/Apple tích hợp qua `AuthBloc`. |
| **Màn hình Splash Screen** | ✅ Completed | 11/06/2026 | Tạo hiệu ứng pulse logo và cơ chế check session tự động điều hướng sang Login, Pairing, hoặc Dashboard. |
| **Màn hình Login Screen** | ✅ Completed | 11/06/2026 | Thiết kế giao diện Glassmorphism và liên kết nút nhấn Google/Apple OAuth. |
| **Màn hình Pairing Screen** | ✅ Completed | 11/06/2026 | Giao diện mã kết nối 6 chữ số, mock QR, và màn nhập mã kết nối/disconnect. |

---

## Sprint 2: Đồng bộ Mood & Tương tác Hero Bubble (Tuần 2)

| Tên tính năng (Feature Name) | Trạng thái (Status) | Ngày cập nhật (Updated At) | Ghi chú (Implementation Notes) |
| :--- | :--- | :--- | :--- |
| **Giao diện Dashboard Screen** | ✅ Completed | 13/06/2026 | Thiết kế giao diện Cozy Haven, vẽ Hero Bubble CustomPainter và hạt trái tim bay lên FloatingHearts. |
| **Đồng bộ Mood Sharing** | ✅ Completed | 13/06/2026 | Quản lý trạng thái qua DashboardBloc, tích hợp Bottom Sheet chọn cảm xúc và lắng nghe realtime qua Supabase Postgres Changes. |
| **Tương tác Nudge & Lắc máy** | ✅ Completed | 13/06/2026 | Truyền tín hiệu nudge qua Realtime Broadcast, tích hợp cảm biến ShakeDetector và HapticFeedback rung phản hồi. |

---

## Sprint 3: Lịch chu kỳ & Nhật ký dùng chung (Tuần 3)

| Tên tính năng (Feature Name) | Trạng thái (Status) | Ngày cập nhật (Updated At) | Ghi chú (Implementation Notes) |
| :--- | :--- | :--- | :--- |
| **Calendar Screen / Tab** | ✅ Completed | 13/06/2026 | Tích hợp TableCalendar hiển thị kỳ kinh nguyệt (peach), dự báo (dashed peach), rụng trứng (lavender) và icon quan hệ. |
| **Ghi chép Nhật ký quan hệ (Shared Journal)** | ✅ Completed | 13/06/2026 | Bottom sheet lưu nhật ký quan hệ (Protected / Unprotected) và ghi chú ngắn. |
| **Giao diện Cài đặt & Riêng tư chu kỳ** | ✅ Completed | 13/06/2026 | Cấu hình độ dài chu kỳ/ngày kinh dạng Dropdown, cấu hình riêng tư chu kỳ (Full / Summary / None) và nút hủy ghép đôi. |
| **CalendarBloc & Supabase Sync** | ✅ Completed | 13/06/2026 | Quản lý trạng thái chu kỳ & nhật ký, tự động tính toán dự báo cục bộ, hỗ trợ Supabase realtime sync & mock data bypass. |

---

## Các Sprint Tiếp theo (Phase sau)
*   **Sprint 3: Lịch chu kỳ & Nhật ký dùng chung** ✅ Completed (13/06/2026)
*   **Sprint 4: Care Requests & Couple Widget** ⬜ Not Started
*   **Sprint 5: Push Notifications & Beta Test** ⬜ Not Started
