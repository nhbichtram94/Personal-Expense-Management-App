# Ứng dụng Quản Lý Thu Chi Cá Nhân (Flutter)
Ứng dụng di động giúp người dùng quản lý tài chính cá nhân bằng cách ghi lại các khoản thu, chi và hiển thị thống kê trực quan.
# Tính năng chính
- Ghi nhận giao dịch thu hoặc chi  
- Phân loại theo danh mục (ăn uống, giải trí, lương, học phí, v.v.)  
- Thống kê theo ngày, tuần, tháng  
- Lọc và tìm kiếm giao dịch theo thời gian  
- Ghi chú cho mỗi giao dịch  
- Quản lý tài khoản người dùng (đăng nhập / đăng ký)  
- Xác thực với Firebase
# Cấu trúc dự án chính
lib/
├── main.dart                # Điểm khởi đầu ứng dụng
├── trangchu.dart            # Trang chủ
├── dangnhap.dart            # Giao diện đăng nhập
├── dangki.dart              # Giao diện đăng ký
├── giaoDich.dart            # Thêm/xem giao dịch
├── thongke.dart             # Thống kê giao dịch
├── thongbao.dart            # Thông báo người dùng
├── category\_screen.dart     # Màn hình chọn danh mục
├── profile.dart             # Trang cá nhân
├── quenmk.dart              # Quên mật khẩu
Ngoài ra:
- `assets/images/` – chứa hình ảnh
- `google-services.json` – cấu hình Firebase
- `pubspec.yaml` – khai báo thư viện
# Công nghệ sử dụng
- Flutter (Dart)  
- Firebase Authentication  
- Cloud Firestore  
- Provider (hoặc Riverpod – nếu bạn dùng)  
- Material Design  
- Biểu đồ (charts_flutter hoặc fl_chart)
# Cài đặt và chạy app
# 1. Clone dự án:
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
# 2. Cài đặt các gói:
flutter pub get
# 3. Chạy ứng dụng:
flutter run
Yêu cầu: đã cài Flutter SDK và cấu hình thiết bị giả lập hoặc điện thoại thật.
# Tác giả
Nguyễn Hoàng Bích Trâm
📧 Email: [nhbichtram94@gmail.com](mailto:nhbichtram94@gmail.com)
🌐 GitHub: [@nhbichtram94](https://github.com/nhbichtram94)
# 📄 License
Dự án sử dụng giấy phép MIT.
Bạn được phép sử dụng, chỉnh sửa và phân phối với điều kiện giữ nguyên thông tin bản quyền.
1. Tạo file `README.md` tại thư mục gốc
2. Dán nội dung trên vào
3. `git add README.md && git commit -m "Add project README"`  
4. `git push`
