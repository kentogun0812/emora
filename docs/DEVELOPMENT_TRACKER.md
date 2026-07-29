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

## Sprint 4: Yêu cầu Chăm sóc & Couple Widget (Tuần 4)

| Tên tính năng (Feature Name) | Trạng thái (Status) | Ngày cập nhật (Updated At) | Ghi chú (Implementation Notes) |
| :--- | :--- | :--- | :--- |
| **Ngăn kéo Care Requests** | ✅ Completed | 13/06/2026 | Grid sheet chứa 6 mẫu yêu cầu chăm sóc hoạt họa hỗ trợ gửi nhanh bằng 1 chạm từ Hero Bubble. |
| **Danh sách Yêu cầu Hoạt động** | ✅ Completed | 13/06/2026 | Hiển thị realtime các yêu cầu, cho phép Nhận việc (Accept), Hoàn thành (Complete) hoặc Hủy/Trả việc (Reset/Cancel). |
| **Giả lập Couple Widget** | ✅ Completed | 13/06/2026 | Component Widget Preview hiển thị avatar đối phương, mood hiện tại và yêu cầu chăm sóc mới nhất trên Dashboard. |
| **Đồng bộ hóa Realtime** | ✅ Completed | 13/06/2026 | Tích hợp realtime listener vào DashboardBloc, tự động cập nhật yêu cầu chăm sóc, hỗ trợ lọc tự động sau 24h và Mock Data bypass. |

---

## Các Sprint Tiếp theo (Phase sau)
*   **Phase 1: MVP Setup** | Trạng thái: ✅ Completed (Bypass Sprint 5)
    *   **Sprint 5: Push Notifications & Beta Test** | Trạng thái: ⚠️ Pending (Dời sang Phase 5)
*   **Phase 2: Playful Venting (Chăm sóc vui vẻ)** | Trạng thái: ✅ Completed (Xem chi tiết tại [phase_2_proposal.md](file:///C:/Users/Admin/.gemini/antigravity-ide/brain/a8e0cbf7-826d-4f3a-a54a-ceacc24c715e/phase_2_proposal.md))
    *   **Sprint 6: The Vent Room & Pillow Fight Interactions** | Trạng thái: ✅ Completed (13/06/2026)
    *   **Sprint 7: Real-time WebSocket Messaging & Interactive Animations** | Trạng thái: ✅ Completed (13/06/2026)
*   **Phase 3: Family Assistant (Trợ lý gia đình)** | Trạng thái: ✅ Completed
    *   **Sprint 8: Baby Vaccination Tracker** | Trạng thái: ✅ Completed (13/06/2026)
*   **Phase 4: Premium & Dynamic Themes** | Trạng thái: ✅ Completed
    *   **Sprint 9: Dynamic Themes, custom stickers and Payment Integration** | Trạng thái: ✅ Completed (13/06/2026) | Định nghĩa 4 bộ màu theme, xây dựng BLoC tự động lưu trữ cấu hình qua `HydratedBloc`, thiết kế nền động hạt chuyển động CustomPainter, paywall chào hàng Premium kèm cổng thanh toán giả lập (Mock Checkout) 1.5s, và áp dụng hạn mức 5 lượt/ngày cho Phòng Vui Vẻ.
*   **Phase 5: Final Integrations (Push Notifications & Cổng thanh toán thật)** | Trạng thái: ⚠️ Pending
    *   **Sprint 10: FCM Push Notifications & Real In-App Purchase Billing** | Trạng thái: ⚠️ Pending (Thực hiện cuối cùng) | Tích hợp Firebase Cloud Messaging (FCM) thông báo đẩy realtime và kết nối cổng thanh toán thật Google Play Billing / App Store IAP qua RevenueCat SDK.
