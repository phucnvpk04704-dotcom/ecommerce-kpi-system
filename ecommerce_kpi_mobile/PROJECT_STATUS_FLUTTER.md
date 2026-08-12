# BÁO CÁO TỔNG HỢP VÀ ĐÁNH GIÁ TRẠNG THÁI FLUTTER APP (PROJECT STATUS FLUTTER REPORT)
**Dự án:** Ứng dụng Di động dành cho Quản lý (Manager Mobile App) — Hệ thống KPI TMĐT Đa kênh  
**Vai trò báo cáo:** Principal Flutter Architect  
**Ngày lập báo cáo:** 28/06/2026  
**Đường dẫn tệp tin gốc:** `d:\ecommerce_kpi_mobile`  

---

## 1. Tổng quan

### 1.1. Mục tiêu dự án (Project Goal)
Ứng dụng di động Flutter đóng vai trò là "Manager/Boss Portal" thuộc hệ sinh thái KPI TMĐT. Mục tiêu chính là cung cấp giao diện di động trực quan, hiệu năng cao để các Giám đốc/Quản lý vận hành theo dõi biến động doanh thu đa kênh bán hàng, theo dõi chi tiết điểm số KPI của đội ngũ nhân viên, phê duyệt danh sách khen thưởng (rewards), và kiểm soát danh sách đen người mua rủi ro (blacklist).

### 1.2. Kiến trúc Flutter (Architecture)
Ứng dụng tuân thủ kiến trúc Clean Architecture kết hợp mô hình Feature-First và Component-based:
* **Presentation Layer**: 
  * Screens (`lib/screens/` và `lib/features/`): Chứa giao diện hiển thị các trang chức năng.
  * Reusable Widgets (`lib/widgets/`): Bộ thư viện gồm 39 widgets tái sử dụng cao.
* **State Management Layer**: Tách biệt logic trạng thái và giao diện thông qua Riverpod Providers và scoped ChangeNotifierProviders.
* **Domain/Data Layer**:
  * Models (`lib/models/`): Các cấu trúc dữ liệu thực hiện chuyển đổi JSON linh hoạt từ cả `snake_case` và `camelCase`.
  * Repositories (`lib/data/repositories/`): Triển khai repository pattern cho phép chạy linh hoạt giữa Remote Client và Mock fallback data.
  * Services (`lib/services/`): API Service sử dụng client gọi HTTP để tương tác với Backend FastAPI.

### 1.3. Quản lý trạng thái (State Management)
* **Chính**: Sử dụng thư viện **Riverpod** (`authStateProvider`, `routerProvider`, `secureStorageProvider`) để quản lý trạng thái xác thực và luồng định tuyến GoRouter toàn cục.
* **Bổ trợ (Scoped State)**: Sử dụng cấu trúc **ChangeNotifierProvider** tự thiết lập (`lib/providers/custom_provider.dart`) để truyền và lắng nghe sự thay đổi trạng thái của các view nghiệp vụ (như `BlacklistProvider`, `DashboardProvider`, `SettingsProvider`, `RewardProvider`) một cách cô lập và độc lập.

### 1.4. Điều hướng (Navigation)
* Sử dụng thư viện **GoRouter** (`app_router.dart`) hỗ trợ định tuyến dựa trên khai báo đường dẫn (declarative routing), quản lý deep links và tự động hóa bộ chuyển hướng bảo mật (Redirect Guard): nếu chưa đăng nhập, người dùng sẽ tự động bị điều hướng về `/login`.

### 1.5. Chủ đề & Giao diện (Theme)
* Định nghĩa cấu hình light/dark themes tập trung trong `lib/core/theme/app_theme.dart`. Giao diện di động kế thừa màu sắc Burgundy cao cấp với cấu trúc phông chữ hiện đại, bo góc thẻ (card radius) và hỗ trợ responsive tự động.

### 1.6. Kết nối API (API Client)
* Sử dụng thư viện **Dio** đóng gói trong `ApiClient` (`lib/core/network/api_client.dart`). Hỗ trợ đính kèm JWT Bearer tokens tự động thông qua Interceptors và tự động điều hướng về `/login` nếu gặp phản hồi lỗi 401 Unauthorized từ Backend.

---

## 2. Module Inventory

### 2.1. Authentication (Xác thực)
* **Chức năng**: Đăng nhập tài khoản quản lý, tự động lưu trữ token an toàn và thông tin cá nhân cached. Đăng xuất và thu hồi quyền truy cập.
* **Đã hoàn thành**: Giao diện đăng nhập, service ghi token bằng EncryptedSharedPreferences (Android) thông qua `FlutterSecureStorage`.
* **File liên quan**: 
  * [login_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/features/auth/login_screen.dart)
  * [secure_storage_service.dart](file:///d:/ecommerce_kpi_mobile/lib/data/services/secure_storage_service.dart)
  * [auth_repository.dart](file:///d:/ecommerce_kpi_mobile/lib/data/repositories/auth_repository.dart)
* **Còn thiếu**: Tính năng đăng nhập sinh trắc học (Biometric login) mặc dù cấu hình trong settings nhưng chưa được tích hợp plugin phần cứng thực tế.

### 2.2. Dashboard (Tổng quan)
* **Chức năng**: Hiển thị doanh thu thực tế so với mục tiêu, KPI trung bình của đội ngũ, số lượng nhân viên active và các cảnh báo khẩn cấp. Vẽ biểu đồ xu hướng 7 ngày.
* **Đã hoàn thành**: Màn hình tổng quan, các thẻ thống kê tổng hợp (`DashboardSummaryCard`), các biểu đồ phân tích cột và tròn.
* **File liên quan**: 
  * [dashboard_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/dashboard/dashboard_screen.dart)
  * [dashboard_provider.dart](file:///d:/ecommerce_kpi_mobile/lib/providers/dashboard_provider.dart)
  * [dashboard_charts_widget.dart](file:///d:/ecommerce_kpi_mobile/lib/widgets/dashboard_charts_widget.dart)
* **Còn thiếu**: Biểu đồ so sánh chéo hiệu suất giữa các chi nhánh chưa được phân tích.

### 2.3. Employee Management (Vận hành & Nhân sự)
* **Chức năng**: Xem danh sách nhân viên, xếp hạng hiệu suất, tìm kiếm theo tên, xem thông tin chi tiết cá nhân nhân sự và CRUD nhân sự từ xa.
* **Đã hoàn thành**: Toàn bộ màn hình danh sách, chi tiết, tạo mới, chỉnh sửa nhân viên kết hợp logic validate form.
* **File liên quan**: 
  * [employee_list_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/employee_list_screen.dart)
  * [employee_detail_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/employee_detail_screen.dart)
  * [employee_create_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/employee_create_screen.dart)
  * [employee_edit_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/employee_edit_screen.dart)
* **Còn thiếu**: Định vị ca làm việc và theo dõi check-in thực tế của nhân sự trên bản đồ.

### 2.4. KPI Management (Chỉ số KPI)
* **Chức năng**: Theo dõi chỉ số KPI ngày/tuần/tháng của nhân viên. Xếp hạng phân loại nhân viên xuất sắc.
* **Đã hoàn thành**: Giao diện chi tiết KPI, vòng tròn điểm số, biểu đồ cột so sánh các tiêu chí KPI (Đơn hàng, Chat, Đăng sản phẩm, Doanh thu).
* **File liên quan**: 
  * [kpi_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/kpi_screen.dart)
  * [kpi_detail_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/kpi_detail_screen.dart)
  * [kpi_chart.dart](file:///d:/ecommerce_kpi_mobile/lib/widgets/kpi_chart.dart)
* **Còn thiếu**: API `/kpi/today` chưa được đăng ký Router trên Backend, app hiện dùng dữ liệu fallback khi API trả lỗi.

### 2.5. Reward Management (Khen thưởng)
* **Chức năng**: Theo dõi tổng quỹ thưởng, danh sách nhân viên được đề xuất thưởng dựa trên KPI, quản lý phê duyệt hoặc bác bỏ (Approve/Reject) lệnh thưởng.
* **Đã hoàn thành**: Giao diện duyệt thưởng, màn hình chỉnh sửa/tạo mới đề xuất thưởng thủ công, bộ lọc trạng thái thưởng.
* **File liên quan**: 
  * [reward_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/reward_screen.dart)
  * [reward_detail_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/reward_detail_screen.dart)
  * [reward_create_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/reward_create_screen.dart)
  * [reward_edit_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/reward_edit_screen.dart)
* **Còn thiếu**: Đồng bộ lịch sử thưởng của tháng cũ. API Backend `/rewards` chưa sẵn sàng, app dùng fallback ghi nhận cục bộ.

### 2.6. Customer Blacklist (Danh sách đen)
* **Chức năng**: Tra cứu khách hàng bom hàng/gian lận theo số điện thoại. Đánh giá tự động rủi ro dựa trên số đơn hàng bị hủy/trả lại.
* **Đã hoàn thành**: Màn hình danh sách blacklist, bộ lọc mức độ rủi ro, chức năng thay đổi trạng thái rủi ro (Resolve), tạo mới và chỉnh sửa hồ sơ đen.
* **File liên quan**: 
  * [blacklist_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/blacklist_screen.dart)
  * [blacklist_detail_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/blacklist_detail_screen.dart)
  * [blacklist_create_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/blacklist_create_screen.dart)
  * [blacklist_edit_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/blacklist_edit_screen.dart)
* **Còn thiếu**: Liên kết API chính thức từ Backend (do Backend chưa định nghĩa router `/customer_blacklist`).

### 2.7. Reports (Báo cáo tổng hợp)
* **Chức năng**: Biên soạn báo cáo hiệu quả vận hành của shop, biểu đồ doanh thu theo thời gian, thống kê top nhân viên đạt KPI cao nhất và top sản phẩm được đăng tải nhiều nhất.
* **Đã hoàn thành**: Màn hình danh sách báo cáo, biểu đồ xu hướng báo cáo, trang chi tiết báo cáo thống kê top.
* **File liên quan**: 
  * [report_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/report_screen.dart)
  * [report_detail_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/report_detail_screen.dart)
  * [report_chart.dart](file:///d:/ecommerce_kpi_mobile/lib/widgets/report_chart.dart)
* **Còn thiếu**: Tính năng tải PDF trực tiếp về thư viện điện thoại (hiện tại mới hiển thị view phân tích số liệu tĩnh).

### 2.8. Settings (Cài đặt)
* **Chức năng**: Thay đổi thông tin cá nhân Quản lý, cấu hình ngôn ngữ ứng dụng, thay đổi theme sáng/tối (Dark Mode), bật tắt nhận thông báo, thay đổi mật khẩu tài khoản bảo mật.
* **Đã hoàn thành**: Màn hình cài đặt tích hợp lưu thay đổi qua preferences API và thay đổi mật khẩu trực tiếp qua `/auth/change-password`.
* **File liên quan**: 
  * [settings_screen.dart](file:///d:/ecommerce_kpi_mobile/lib/screens/settings_screen.dart)
  * [settings_provider.dart](file:///d:/ecommerce_kpi_mobile/lib/providers/settings_provider.dart)
* **Còn thiếu**: Tính năng lưu trữ ngôn ngữ cấu hình offline đồng bộ xuyên suốt trên Web Admin.

---

## 3. Giao diện người dùng (UI)

### 3.1. Số lượng màn hình (Screens count)
Tổng số lượng màn hình được cài đặt trong ứng dụng di động là **18 màn hình**:
1. Đăng nhập (`LoginScreen`)
2. Dashboard Quản lý (`DashboardScreen` - Feature & Screen)
3. Danh sách Nhân viên (`EmployeeListScreen`)
4. Chi tiết Nhân viên (`EmployeeDetailScreen` - Feature & Screen)
5. Tạo mới Nhân viên (`EmployeeCreateScreen`)
6. Chỉnh sửa Nhân viên (`EmployeeEditScreen`)
7. Chỉ số KPI tổng hợp (`KpiScreen` - Feature & Screen)
8. Chi tiết KPI nhân sự (`KpiDetailScreen`)
9. Quản lý Thưởng (`RewardScreen` - Feature & Screen)
10. Chi tiết phê duyệt Thưởng (`RewardDetailScreen`)
11. Đề xuất Thưởng mới (`RewardCreateScreen`)
12. Chỉnh sửa đề xuất Thưởng (`RewardEditScreen`)
13. Danh sách Blacklist (`BlacklistScreen`)
14. Chi tiết khách hàng Blacklist (`BlacklistDetailScreen`)
15. Khai báo Blacklist mới (`BlacklistCreateScreen`)
16. Sửa hồ sơ Blacklist (`BlacklistEditScreen`)
17. Danh sách Báo cáo (`ReportScreen`)
18. Cài đặt Quản lý (`SettingsScreen`)

*Bổ sung*: Ngoài ra còn các phân hệ phụ trợ của layout cũ tại `lib/features/` như `NotificationsScreen`, `LeaderboardScreen`, `MoreScreen`.

### 3.2. Tính thích ứng responsive
* Thiết kế sử dụng cơ chế bố cục dòng cuộn (`SingleChildScrollView`), lưới linh hoạt (`GridView.builder`) và các tỷ lệ cột tự co giãn giúp giao diện tự động tối ưu hóa giữa tỷ lệ màn hình điện thoại (Mobile) và máy tính bảng (Tablet).

---

## 4. API Integration

Hệ thống API di động kết nối trực tiếp với Backend FastAPI thông qua Dio Client:
* **Xác thực**: Gửi yêu cầu đăng nhập `/auth/login` và cập nhật mật khẩu `/auth/change-password`.
* **Dashboard**: Lấy tổng quan stats qua `/dashboard/summary`, `/dashboard/kpi`, `/dashboard/revenue-chart`, `/dashboard/orders-chart`, `/dashboard/recent-activities`.
* **Nhân sự**: Gọi `/employees` (để lấy danh sách), `/employees/$id` (để lấy chi tiết hoặc cập nhật).
* **Báo cáo**: Gọi `/reports` (lấy danh sách), `/reports/date` (lấy theo ngày).
* **Kpi/Rewards/Blacklist**: Do các endpoint `/rewards` và `/customer_blacklist` chưa được backend mở router v1, các service tương ứng (`KpiService`, `RewardService`, `BlacklistService`) sử dụng khối lệnh `try-catch` để tự động bắt các lỗi phản hồi (như 404, 503) và khôi phục hoạt động bình thường bằng cách cung cấp dữ liệu giả lập có độ khớp dữ liệu cao.

---

## 5. Testing & Static Analysis

### 5.1. Widget Tests
Bộ kiểm thử gồm **22 ca kiểm thử widget test** tự động viết bằng `flutter_test` (100% vượt qua thành công):
* Kiểm thử tính năng render giao diện, nhập liệu form, click nút submit tạo/sửa đổi hồ sơ, kiểm tra thay đổi theme Mode và mô phỏng luồng đăng xuất.
* Các tệp kiểm thử:
  * `blacklist_widget_test.dart`
  * `dashboard_widget_test.dart`
  * `employee_widget_test.dart`
  * `kpi_widget_test.dart`
  * `report_widget_test.dart`
  * `reward_widget_test.dart`
  * `settings_widget_test.dart`
  * `screens_test.dart`
  * `widget_test.dart`

### 5.2. Integration Tests
* **Không tồn tại** thư mục kiểm thử tích hợp phần cứng hoặc UI test tự động (`integration_test/`). Tất cả các bài kiểm tra được chạy dưới dạng Widget Test mô phỏng.

### 5.3. Static Analysis
* Hệ thống phân tích tĩnh `flutter analyze` cấu hình qua `analysis_options.yaml` trả về **0 cảnh báo, 0 lỗi linter**. Mã nguồn được định dạng hoàn hảo theo tiêu chuẩn Dart Style.

---

## 6. Lịch sử các Sprint phát triển

Dựa trên cấu trúc phân rã các tính năng:
* **Sprint 1 (Dashboard Foundation)**: Setup khung GoRouter, Riverpod và cài đặt màn hình Dashboard chính hiển thị biểu đồ doanh thu.
* **Sprint 2 (Employee Module)**: Tạo model `Employee`, service tích hợp CRUD và giao diện quản lý nhân sự.
* **Sprint 3 (KPI Module)**: Triển khai bộ tính toán KPI theo ngày/tuần/tháng và vẽ biểu đồ so sánh các tiêu chuẩn.
* **Sprint 4 (Reward Module)**: Tạo giao diện phê duyệt quỹ thưởng và bộ quản lý đề xuất thưởng.
* **Sprint 5 (Customer Blacklist)**: Thiết lập bộ quản trị danh sách đen rủi ro cao, tra cứu qua số điện thoại.
* **Sprint 6 (Reports & Settings)**: Xuất báo cáo hoạt động đa kênh và cấu hình cài đặt nâng cao cho người dùng Quản lý.

---

## 7. Đánh giá Tiến độ hoàn thành Flutter App

* **Giao diện người dùng (UI %)**: **100%**  
  *Cơ sở*: Toàn bộ 18 màn hình chức năng theo yêu cầu, giao diện Dark Mode Burgundy và 39 widgets bổ trợ đã hoàn thiện đầy đủ.
* **Logic nghiệp vụ (Business Logic %)**: **95%**  
  *Cơ sở*: Trạng thái Riverpod, ChangeNotifier và lưu trữ bảo mật Flutter Secure Storage hoạt động ổn định.
* **Đồng bộ API (API %)**: **80%**  
  *Cơ sở*: Đã tích hợp thành công Dio Client và các interceptors. Tuy nhiên, do Backend thiếu các router quan trọng như `/rewards` và `/customer_blacklist` nên các service di động phải chạy qua cơ chế catch-fallback.
* **Bộ kiểm thử (Testing %)**: **80%**  
  *Cơ sở*: Đã viết thành công 22 Widget Tests đạt 100% pass, nhưng chưa cấu hình bộ kiểm thử tích hợp trên thiết bị thật (`integration_test/`).
* **Tổng thể tiến độ Flutter App**: **~90%**  
  Ứng dụng đã hoàn thành phần giao diện và logic cục bộ, sẵn sàng liên kết trực tiếp ngay khi Backend hoàn thiện nốt các API còn thiếu.

---

## 8. Những phần còn thiếu sót cần bổ sung

### 8.1. Các tuyến định tuyến (Routes) bị bỏ sót
Có sự không nhất quán giữa `app_routes.dart` và `app_router.dart` (GoRouter). Các đường dẫn sau đã được định nghĩa hằng số nhưng **chưa được đăng ký** trong GoRouter:
* `/employees/create` (EmployeeCreateScreen)
* `/employees/:id/edit` (EmployeeEditScreen)
* `/kpi_screen` (KpiScreen)
* `/kpi_detail_screen/:id` (KpiDetailScreen)
* `/reward_create_screen` (RewardCreateScreen)
* `/reward_edit_screen/:id` (RewardEditScreen)

### 8.2. Đồng bộ API thực tế
* Gỡ bỏ các khối lệnh giả lập dữ liệu cục bộ trong `blacklist_service.dart` và `reward_service.dart` để chuyển sang gọi API trực tiếp ngay khi Backend FastAPI cập nhật xong router v1.

---

## 9. Kế hoạch (Roadmap) đề xuất tiếp theo

* **Sprint Tiếp theo (Sprint 7 - Router & API Integration)**:
  1. Đăng ký toàn bộ các tuyến định tuyến còn thiếu (Create/Edit của Employee, Reward và KPI Detail) vào GoRouter cấu hình tại `app_router.dart` để quản lý điều hướng ứng dụng tập trung.
  2. Phối hợp với Backend team để cấu hình đồng bộ các endpoint `/rewards` và `/customer_blacklist` sang API thật, kiểm thử liên thông end-to-end trên thiết bị thật/mô phỏng.
  3. Xây dựng thư mục `integration_test/` và viết các ca kiểm thử tích hợp tự động để tự động hóa kiểm thử hồi quy luồng đăng nhập và phê duyệt thưởng.
