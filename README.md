# Emora - Understand Without Words

Emora là ứng dụng di động dành cho các cặp đôi giúp xây dựng sự thấu hiểu thông qua việc chia sẻ trạng thái cảm xúc, nhu cầu hỗ trợ và sức khỏe sinh sản một cách riêng tư, tinh tế và không áp lực.

---

## 1. Prerequisites (Yêu cầu hệ thống)
Trước khi khởi chạy dự án, hãy đảm bảo máy tính của bạn đã được cài đặt:
*   **Flutter SDK**: Phiên bản `>=3.0.0`
*   **Dart SDK**: Phiên bản `>=3.0.0 <4.0.0`
*   **Supabase Account**: Dự án sử dụng Supabase làm Backend-as-a-Service (BaaS).

---

## 2. Clone Project (Tải mã nguồn)
Tải mã nguồn dự án về máy tính cá nhân:
```bash
git clone <url-repository-cua-ban>
cd emora
```

---

## 3. Install Dependencies (Cài đặt thư viện)
Chạy lệnh sau tại thư mục gốc của dự án để tải và cài đặt các thư viện Flutter được cấu hình trong `pubspec.yaml`:
```bash
flutter pub get
```

---

## 4. Setup Configurations (Cấu hình kết nối)
Dự án sử dụng các biến môi trường cấu hình tại compile-time để kết nối với Supabase:
1. Sao chép tệp mẫu cấu hình:
   ```bash
   cp .env.example .env
   ```
2. Mở tệp `.env` vừa tạo tại thư mục gốc và điền các thông tin kết nối thực tế của bạn:
   *   `SUPABASE_URL`: Đường dẫn URL API Supabase của dự án (e.g., `https://xxxx.supabase.co`).
   *   `SUPABASE_ANON_KEY`: Mã Anon Key của dự án.
   *   `DATABASE_URL`: Đường dẫn kết nối CSDL PostgreSQL (dùng cho các tool migration hoặc seed scripts).

---

## 5. Setup Database (Thiết lập Cơ sở dữ liệu)
Để tạo các bảng và chính sách bảo mật dữ liệu Row-Level Security (RLS) cho dự án:
1. Đăng nhập vào **Supabase Dashboard** của bạn.
2. Điều hướng đến mục **SQL Editor**.
3. Mở tệp tin **[supabase/init_schema.sql](file:///d:/Workspace/emora/supabase/init_schema.sql)** trong thư mục dự án, sao chép toàn bộ nội dung.
4. Dán vào ô soạn thảo của SQL Editor trên Supabase và bấm **Run**.

---

## 6. Run Project Local (Chạy ứng dụng cục bộ)
Đảm bảo đã kết nối thiết bị di động (hoặc trình giả lập iOS/Android Simulator). Khởi chạy ứng dụng bằng cách tải cấu hình môi trường từ tệp `.env`:
```bash
flutter run --dart-define-from-file=.env
```

---

## 7. Build, Test & Lint Commands (Lệnh hữu ích)

### Định dạng lại toàn bộ code (Format code)
```bash
dart format .
```

### Kiểm tra lỗi cú pháp (Lint & Code Analysis)
```bash
flutter analyze
```

### Chạy các ca kiểm thử tự động (Unit / Widget Tests)
```bash
flutter test
```

---

## 8. Troubleshooting (Lỗi thường gặp)

### Lỗi kết nối Supabase (OAuth Redirect)
*   **Nguyên nhân:** Đăng nhập Google/Apple OAuth thất bại do chưa cấu hình Redirect URL.
*   **Khắc phục:** Đảm bảo bạn đã thêm địa chỉ callback `io.supabase.emora://login-callback` vào cấu hình **Authentication -> Redirect URLs** trên trang Supabase Dashboard của bạn.

### Không tìm thấy file Localization (Đa ngôn ngữ)
*   **Nguyên nhân:** Lỗi thiếu tài nguyên i18n JSON khi build app.
*   **Khắc phục:** Hãy đảm bảo cấu trúc thư mục chứa các tệp ngôn ngữ tồn tại chính xác tại đầu ra: `assets/i18n/vn.json`, `assets/i18n/en.json`, `assets/i18n/ko.json`, `assets/i18n/jp.json` và đã được khai báo trong phần `assets` của tệp `pubspec.yaml`.
