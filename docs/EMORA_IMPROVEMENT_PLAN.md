# EMORA IMPROVEMENT PLAN - ĐỊNH HƯỚNG PHÁT TRIỂN SAU MVP

Tài liệu định hướng phát triển và tối ưu hóa trải nghiệm cặp đôi cho ứng dụng Emora trong các giai đoạn tiếp theo (sau MVP).

---

## 1. MVP Gap Analysis (Phân tích khoảng trống của MVP)

Qua quá trình đánh giá kiến trúc và trải nghiệm người dùng hiện tại, một số khoảng trống, hạn chế và rủi ro trong phiên bản MVP đã được xác định cần được khắc phục:

### 1.1 Hạn chế về Trải nghiệm Người dùng (UX Constraints)
*   **Bong bóng Đơn độc (Single Bubble Layout):** Giao diện trung tâm của Dashboard hiện chỉ hiển thị một bong bóng duy nhất đại diện cho cảm xúc của đối phương. Người dùng không thấy được biểu tượng cảm xúc của chính mình hiển thị song song, làm giảm cảm giác về một không gian chung của cả hai người.
*   **Thiếu danh xưng cá nhân hóa:** Ứng dụng vẫn sử dụng các đại từ xưng hô mặc định, khô cứng như "Bạn", "Đối phương" hoặc "Partner". Điều này thiếu đi sự ngọt ngào, thân mật vốn có trong giao tiếp thường ngày của các cặp đôi.

### 1.2 Hạn chế về Mức độ Gắn kết (Engagement Constraints)
*   **Khoảng trống kết nối khi tắt Ứng dụng (Offline Connection Gap):** Do các tính năng thông báo đẩy thực tế (FCM Push Notifications) đang ở trạng thái pending (hoãn sang Phase 5), hệ thống realtime hiện tại chỉ hoạt động khi cả hai người dùng cùng mở ứng dụng. Khi một bên tắt app, vòng lặp tương tác (feedback loop) bị đứt gãy.
*   **Mất cân bằng tương tác (One-sided Engagement):** Dễ xảy ra hiện tượng tương tác một chiều khi một người tích cực cập nhật trạng thái còn người kia lười mở app hoặc chỉ xem thụ động mà không phản hồi.
*   **Hạn chế tương tác tĩnh trên Widget (Static Widget Limitation):** Widget của MVP chỉ có nhiệm vụ hiển thị thông tin tĩnh mang tính một chiều (chỉ đọc). Người dùng bắt buộc phải mở ứng dụng để thực hiện bất kỳ hành động phản hồi nào (như cập nhật mood của mình hoặc nhận/hoàn thành Care Request), làm tăng số bước thao tác và giảm tính tức thời của điểm chạm hàng ngày.

### 1.3 Hạn chế về Tương tác Cặp đôi (Couple Interaction Gaps)
*   **Trùng lặp & Xung đột Quyền hạn Lịch (Shared Calendar Collision):** Hệ thống MVP chưa có cơ chế phân biệt giới tính hoặc vai trò sinh học cụ thể của từng tài khoản. Điều này dẫn đến việc tài khoản Nam vẫn có thể ghi chép ngày chu kỳ kinh nguyệt trên thiết bị của mình, gây xung đột và làm sai lệch dữ liệu/thuật toán dự đoán chu kỳ của bạn Nữ.
*   **Thiếu ngữ cảnh thấu hiểu chủ động:** Mặc dù bạn Nam có thể xem tóm tắt chu kỳ của đối phương, hệ thống vẫn chưa cung cấp các hướng dẫn hoặc mẹo chăm sóc tinh tế (chẳng hạn như gợi ý tặng đồ ngọt hoặc chủ động làm việc nhà khi bạn Nữ đang ở giai đoạn PMS).

---

## 2. Improvement Backlog (Danh sách các hạng mục Cải tiến)

Dưới đây là danh sách các tính năng và cải tiến kỹ thuật đề xuất phát triển sau MVP nhằm giải quyết triệt để các khoảng trống nêu trên:

### Hạng mục 1: Thiết kế Giao diện Bong bóng đôi (Dual Bubble Layout)
*   **Mô tả:** Thiết kế lại phần visual trung tâm của Dashboard. Ngoài bong bóng lớn hiển thị cảm xúc đối phương, bổ sung thêm một bong bóng nhỏ hơn đại diện cho cảm xúc của chính mình nằm tựa vào hoặc bay quanh bong bóng lớn.
*   **Tác động UX:** Trực quan hóa không gian chung của cặp đôi, giúp người dùng dễ dàng chạm vào bong bóng của mình để cập nhật mood nhanh mà không cần mở bottom sheet riêng.

### Hạng mục 2: Tích hợp Hệ thống Vai trò Sinh học & Danh xưng Linh hoạt (Bio-Role & Custom Call Signs)
*   **Mô tả:** Bổ sung màn hình thiết lập nhanh (1-tap setup) ngay sau khi ghép đôi thành công để thu thập thông tin vai trò:
    - **Vai trò sinh học (Bio-Role):** Xác định tài khoản có nhu cầu ghi nhận chu kỳ kinh nguyệt hay không (Có -> `Female`, Không -> `Male`).
    - **Danh xưng xưng hô (Call-sign):** Cho phép tự chọn hoặc nhập danh xưng thân mật (Anh, Em, Vợ, Chồng, Bé yêu,...).
*   **Tác động UX & Kỹ thuật:**
    - Chỉ mở quyền ghi chép chu kỳ kinh nguyệt chi tiết cho tài khoản có vai trò `Female` để bảo vệ tính toàn vẹn dữ liệu chu kỳ.
    - Tự động thay đổi ngôn ngữ hiển thị và nội dung các câu thông báo đẩy theo danh xưng cặp đôi đã chọn để tạo sự thân thiết.

### Hạng mục 3: Triển khai Kênh thông báo đẩy FCM & Thanh toán thực (Phase 5)
*   **Mô tả:** Tích hợp Firebase Cloud Messaging (FCM) ở tầng client và Supabase Edge Functions ở tầng database để gửi thông báo tức thì khi tắt app. Tích hợp cổng thanh toán RevenueCat SDK thay thế cho cổng giả lập.
*   **Tác động kỹ thuật:** Giải quyết triệt để việc đứt gãy tương tác khi người dùng offline và kích hoạt mô hình Premium thương mại.

### Hạng mục 4: Tái khởi động tính năng "Love Note Wheel" (Phase 6)
*   **Mô tả:** Xây dựng vòng quay chứa 8 mẫu lời khen ngợi/cảm ơn nhanh (1-tap appreciation notes) giúp người dùng gửi đi những thông điệp ngọt ngào tức thời mà không cần soạn tin nhắn.
*   **Tác động Engagement:** Khuyến khích cặp đôi bày tỏ lòng biết ơn thường xuyên hơn, nâng cao chỉ số giữ chân người dùng (Retention Rate).

### Hạng mục 5: Gợi ý Thấu hiểu Chủ động (AI-Driven Empathy Hints)
*   **Mô tả:** Tự động gửi gợi ý hành động cụ thể cho đối phương khi phát hiện tín hiệu:
    - Bạn Nữ chuẩn bị bước vào chu kỳ PMS (cảnh báo tinh tế kèm gợi ý chăm sóc).
    - Đối phương duy trì tâm trạng tiêu cực (`Tired`, `Irritated`) quá 48 giờ.
*   **Tác động UX:** Thể hiện đúng triết lý sản phẩm **"Understand Without Words"** bằng các hành động thực tế, ấm áp.

### Hạng mục 6: Tối ưu hóa Tương tác trên Widget (Widget Interaction Enhancement)
*   **Mục tiêu:**
    - Tăng tần suất tương tác giữa cặp đôi mà không cần mở ứng dụng.
    - Tận dụng Widget như một điểm chạm hằng ngày (daily touchpoint).
*   **Đề xuất:**
    1.  **Care Requests Widget Actions (Phản hồi Yêu cầu Chăm sóc nhanh):**
        - Hiển thị danh sách các yêu cầu chăm sóc đang chờ xử lý trực tiếp trên Widget.
        - Cho phép thực hiện nhanh các hành động như **Chấp nhận (Accept)**, **Hoàn thành (Complete)**, hoặc **Đánh dấu là Xong (Mark as Done)** trực tiếp bằng cách gõ chạm ngay trên Widget.
        - Giảm số bước thao tác, loại bỏ hoàn toàn việc bắt buộc phải mở ứng dụng để xử lý các yêu cầu đơn giản.
    2.  **Quick Mood Update (Cập nhật Cảm xúc nhanh):**
        - Cho phép thay đổi nhanh cảm xúc của bản thân trực tiếp trên Widget thông qua các nút emoji tích hợp.
        - Hiển thị song song trạng thái cảm xúc hiện tại của bản thân và đối phương trên giao diện Widget.
        - Đồng bộ dữ liệu realtime trực tiếp lên database và hiển thị phản hồi trên thiết bị của đối phương.
*   **Đánh giá:**
    -  **Giá trị mang lại cho user:** Giảm thiểu ma sát thao tác xuống gần bằng 0; người dùng có thể phản hồi yêu cầu hoặc cập nhật cảm xúc chỉ trong 1 chạm từ màn hình chính.
    -  **Tác động đến engagement và retention:** Sự hiện diện thường trực và khả năng tương tác nhanh của Widget giúp kích hoạt thói quen truy cập, tăng mức độ gắn kết hàng ngày (Daily Active Users) và nâng cao tỷ lệ giữ chân lâu dài.
    -  **Độ phức tạp triển khai:** *Cao*. Đòi hỏi cấu hình chuyên sâu vào mã nguồn Native của từng hệ điều hành (Interactive Widgets trên iOS 17+ sử dụng Swift/AppIntents và Android AppWidgets sử dụng Kotlin/RemoteViews) kết hợp đồng bộ dữ liệu local cache thông qua các thư viện Bridge của Flutter (như MethodChannels/EventChannels).
