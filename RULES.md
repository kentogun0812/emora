# BẮT BUỘC: QUY TẮC PHÁT TRIỂN DỰ ÁN EMORA DÀNH CHO AI AGENTS (RULES.md)
**Ngày lập:** 11/06/2026  
**Dự án:** Emora - Ứng dụng Kết nối và Thấu hiểu Cặp đôi  

---

> [!IMPORTANT]
> **Tuyên bố Quan trọng:**
> Tài liệu **[EMORA_DEV_PLAN.md](file:///d:/Workspace/emora/EMORA_DEV_PLAN.md)** là **Nguồn Sự thật Duy nhất (Single Source of Truth - SSOT)** của dự án này. Mọi AI Agent khi tham gia phát triển dự án bắt buộc phải tuân thủ nghiêm ngặt các quy tắc dưới đây không có ngoại lệ.

---

## 1. Phát triển tuân thủ Tài liệu Đặc tả (MVP Dev Plan Alignment)

*   **Tuân thủ tuyệt đối Scope:** Toàn bộ tính năng phải được thiết kế và triển khai khớp 100% với đặc tả trong [EMORA_DEV_PLAN.md](file:///d:/Workspace/emora/EMORA_DEV_PLAN.md).
*   **Các hành vi nghiêm cấm tự ý thực hiện:**
    *   KHÔNG tự ý thêm tính năng mới hoặc "tiện ích bổ sung" ngoài scope.
    *   KHÔNG thay đổi luồng nghiệp vụ (Business Flow) đã quy định.
    *   KHÔNG thiết kế lại giao diện hoặc cách thức hoạt động của các chức năng khác biệt so với mô tả trong tài liệu.
*   **Xử lý điểm chưa rõ ràng (Ambiguity Resolution):**
    *   Nếu phát hiện tài liệu có điểm mâu thuẫn, chưa rõ ràng hoặc thiếu thông tin kỹ thuật: **Dừng lại, ghi chú lại, và hỏi ý kiến của người dùng để xác nhận.**
    *   Tuyệt đối **KHÔNG tự đưa ra giả định** và tự ý code theo giả định đó.

---

## 2. Theo dõi và Cập nhật Tiến độ (Progress Tracking)

*   **Tạo file theo dõi:** Trước khi bắt tay vào viết bất kỳ dòng code nào, AI Agent bắt buộc phải kiểm tra hoặc tạo mới file **[DEVELOPMENT_TRACKER.md](file:///d:/Workspace/emora/DEVELOPMENT_TRACKER.md)** tại thư mục gốc của dự án.
*   **Cấu trúc bảng theo dõi bắt buộc trong tracker:**
    *   **Feature Name:** Tên tính năng (theo cấu trúc trong tài liệu MVP).
    *   **Status:** Trạng thái phát triển, chỉ được chọn 1 trong 3 nhãn sau:
        *   ⬜ `Not Started` (Chưa bắt đầu)
        *   🟨 `In Progress` (Đang phát triển)
        *   ✅ `Completed` (Đã hoàn thành)
    *   **Updated At:** Ngày/giờ cập nhật trạng thái gần nhất.
    *   **Implementation Notes:** Ghi chú ngắn gọn về các file đã tạo/sửa đổi hoặc lưu ý kỹ thuật quan trọng.
*   **Thời điểm cập nhật:** AI Agent phải cập nhật trạng thái của task trong file tracker **ngay lập tức** trước khi bắt đầu viết code (chuyển sang `In Progress`) và ngay sau khi hoàn thành kiểm thử cục bộ (chuyển sang `Completed`).

---

## 3. Quy tắc Triển khai Mã nguồn (Implementation Rules)

*   **Bảo vệ Kiến trúc:** Tuyệt đối không phá vỡ hoặc làm thay đổi kiến trúc thư mục/hạ tầng đã đề xuất (Flutter Clean/Feature-first Architecture, Supabase Serverless & RLS).
*   **Tái sử dụng tối đa:** Ưu tiên đọc hiểu và tái sử dụng các hàm tiện ích, theme, widget có sẵn trong thư mục `core/`.
*   **Tránh trùng lặp (DRY Principle):** Không viết lại các logic hoặc hàm tương tự đã tồn tại trong dự án.
*   **Giới hạn phạm vi ảnh hưởng:**
    *   Không refactor code nằm ngoài phạm vi yêu cầu của task hiện tại.
    *   Không chỉnh sửa hoặc tác động vào các file/chức năng không liên quan trực tiếp đến task đang làm.

---

## 4. Chuẩn hóa Mã nguồn (Coding Standards & Convention)

*   **Không hardcode text và các giá trị cấu hình:** 
    *   Tuyệt đối **không hardcode** bất kỳ chuỗi văn bản (String) nào hiển thị trên giao diện hoặc các giá trị thiết lập. 
    *   Mọi giá trị text cố định phải được định nghĩa trong hệ thống đa ngôn ngữ (i18n) hoặc các lớp hằng số (Constants).
*   **Đa ngôn ngữ (i18n) đa quốc gia:** 
    *   Bắt buộc hỗ trợ đầy đủ 4 ngôn ngữ trong hệ thống localization/i18n của ứng dụng:
        *   **Tiếng Việt (`vn`)**
        *   **Tiếng Anh (`en`)**
        *   **Tiếng Hàn (`ko`)**
        *   **Tiếng Nhật (`jp`)**
    *   Các bản dịch cho cùng một khóa (key) phải khớp nghĩa và đồng bộ trên cả 4 file ngôn ngữ tương ứng.
*   **Quản lý Constants tập trung:** Bắt buộc khai báo hằng số trong các file constants tương ứng của thư mục `core/constants/` cho:
    *   **Colors & Styles:** Mã màu giao diện (bảo đảm tính thống nhất của thiết kế Glassmorphism).
    *   **Routes:** Tên định tuyến màn hình.
    *   **Keys & Configs:** Khóa API, tên bảng Supabase, khóa cache.
*   **Tính dễ đọc (Readability):** Code phải được định dạng chuẩn (sử dụng `dart format`), bổ sung các comment giải thích đối với các khối logic xử lý chu kỳ hoặc RLS phức tạp.
*   **Ngôn ngữ viết Code, Comment và Log:** 
    *   Bắt buộc sử dụng tiếng Anh ngắn gọn, đủ nghĩa để ghi comment và nội dung log. 
    *   Tên biến và giá trị của các constant cũng bắt buộc sử dụng tiếng Anh.
*   **Ngôn ngữ viết Tài liệu (Documentation):** 
    *   Nội dung các file tài liệu markdown (ví dụ: `RULES.md`, `README.md`, `EMORA_DEV_PLAN.md`, `DEVELOPMENT_TRACKER.md`...) vẫn giữ nguyên sử dụng tiếng Việt để ghi chép như hiện tại.

---

## 5. Quy trình Tự Kiểm tra trước khi bàn giao (Pre-completion Checklist)

Trước khi kết thúc lượt tương tác và thông báo hoàn thành task, AI Agent bắt buộc phải tự tích chọn kiểm tra checklist sau:

- [ ] Tính năng phát triển có khớp hoàn toàn với mô tả trong đặc tả MVP tại [EMORA_DEV_PLAN.md](file:///d:/Workspace/emora/EMORA_DEV_PLAN.md) không?
- [ ] Đã cập nhật đầy đủ trạng thái và thông tin trong tệp [DEVELOPMENT_TRACKER.md](file:///d:/Workspace/emora/DEVELOPMENT_TRACKER.md) chưa?
- [ ] Có phát sinh thêm bất kỳ tính năng hoặc code dư thừa nào ngoài tài liệu không? (Nếu có phải xóa bỏ ngay).
- [ ] Các thay đổi có ảnh hưởng hay gây lỗi đến các tính năng đã hoàn thiện trước đó không? (Phải đảm bảo toàn bộ dự án vẫn build thành công).
