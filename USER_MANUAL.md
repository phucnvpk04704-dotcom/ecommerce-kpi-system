# User Manual

Welcome to the **Enterprise Multi-Channel Ecommerce KPI Management System**. This user manual is designed for managers, administrators, and non-technical business users. It outlines step-by-step instructions on how to use each module of the platform.

---

## 1. Getting Started: Logging In
1. Open your web browser and navigate to the application URL (e.g., `http://localhost:5173/login`).
2. You will be presented with a dark, modern login interface.
3. Enter your assigned credentials:
   - **Tài khoản (Username)**: E.g., `admin`
   - **Mật khẩu (Password)**: Enter your secure password (e.g. default developer credentials `admin123456`).
4. Click the **Đăng Nhập (Login)** button.
5. Upon successful authentication, you will be redirected to the main dashboard interface.

---

## 2. Dashboard Usage
The Dashboard is the operational control center of the business. It visualizes total sales, sessions, active employee metrics, and system status feed logs.

### 2.1. Reading Metrics Cards
- **Tổng Doanh Thu (Total Revenue)**: The total cumulative money processed across all sales channels.
- **Tổng Đơn Hàng (Total Orders)**: Total volume of finalized orders.
- **Tổng Nhân Viên (Total Employees)**: Number of staff registered in the platform.
- **Active Sessions**: Number of current active connections.
- **KPI Metrics (Daily KPIs)**: Daily tracking cards showing today's sales growth rates and active staff.

### 2.2. Filtering Data
1. Find the calendar selection dropdown marked **Thời Gian (Time Range)** on the top right.
2. Select a preset: **Tháng này (This Month)**, **30 ngày qua (Last 30 Days)**, etc.
3. To view a specific range, choose **Tự chọn khoảng... (Custom Range)**, then select starting and ending dates in the calendars that appear.
4. The line graphs for Revenue and Bar chart for Orders will dynamically update to display data within the selected dates.

### 2.3. Refreshing Data
- The dashboard automatically updates its numbers every 30 seconds.
- You can manually sync at any time by clicking the **Tải Lại (Reload)** button in the top menu.

### 2.4. Exporting Data
- **Excel Export**: Click **Excel** to download a CSV format document compiling all current summary numbers and KPIs.
- **PDF Export**: Click **PDF (Print)**. Your browser's printer preview panel will open, allowing you to save the page layout directly as a clean PDF document.

---

## 3. Employee Management (Quản Lý Nhân Viên)
This section allows managers to review profiles, create accounts, adjust platform roles, and toggle working statuses.

### 3.1. Navigating the Employee Directory
- Select **Nhân Viên (Employees)** in the left sidebar menu.
- Use the search bar at the top to type in an employee name or email.
- Toggle the status dropdown to filter staff by **Hoạt động (Active)** or **Ngừng hoạt động (Inactive)**.

### 3.2. Registering a New Employee
1. Click the **Thêm Nhân Viên (Add Employee)** button in the top right.
2. Complete the form parameters in the pop-up modal:
   - **Họ và Tên (Full Name)**
   - **Email**
   - **Số điện thoại (Phone Number)**
   - **Vai trò (Role)**: Select Admin, Manager, or Employee.
   - **Nền tảng phụ trách (Platforms)**: Tick target channels (e.g. Shopee, Lazada, TikTok Shop).
3. Click **Lưu (Save)**. A new profile will be added to the registry, and a unique employee sequence code (e.g., `EMP00001`) will generate automatically.

### 3.3. Modifying an Employee Profile
1. Find the target employee row in the list.
2. Click **Sửa (Edit)**.
3. Update the parameters (Role, Phone, or toggles).
4. Click **Lưu (Save)** to finalize changes.

### 3.4. Deactivating an Employee
1. To disable a user's login access, locate their entry.
2. Click **Xóa (Delete)**.
3. A confirmation dialog will appear. Confirm the deletion.
4. The system will soft-deactivate the profile and toggle their status to **Inactive (Ngừng hoạt động)**, revoking all active sessions immediately.

---

## 4. Revenue Management (Quản Lý Doanh Thu)
The Revenue management console is used to inspect monthly sales target progress and platform growth vectors.

### 4.1. Reading Revenue Analytics
- Navigate to the **Doanh Thu (Revenues)** tab.
- Observe the **Doanh Thu Theo Tháng (Monthly Revenue)** graph and growth performance ratios.
- The metrics table lists individual daily revenue collections, platforms, and responsible employee markers.

### 4.2. Adding a Daily Revenue Record
1. Click **Thêm Doanh Thu (Add Revenue)**.
2. Specify the target **Ngày (Date)**, the **Số tiền (Amount)**, the **Nền tảng (Platform)**, and the **Nhân viên (Employee)** responsible.
3. Click **Lưu (Save)** to update the database.

### 4.3. Exporting Records
- Click the **Xuất Excel (Export Excel)** button at the top of the revenue module to download a formatted sheet of all listed sales.

---

## 5. Blacklist Management (Danh Sách Đen)
Designed to protect the company from high-risk customers or potential transaction threats.

### 5.1. Searching a Customer
1. Select **Danh Sách Đen (Blacklist)**.
2. Enter the customer's phone number in the search bar and press **Tìm Kiếm (Search)**.
3. The system will load their risk level and tell you whether they are blocked.

### 5.2. Running an Automatic Risk Evaluation
1. Click the **Đánh giá rủi ro (Evaluate Risk)** button.
2. Select the customer or enter details.
3. The system automatically fetches their historical orders, counts canceled or returned items, generates a risk index, and flags them accordingly:
   - **Low (Thấp)**: Trusted buyer.
   - **Medium (Trung bình)** / **High (Cao)**: Warn managers of high return rates.
   - **Blacklist (Danh sách đen)**: Blocked from ordering.

### 5.3. Manually Blacklisting/Removing a Customer
- To add a threat contact: Click **Thêm Khách Hàng (Add Customer)**, fill in the name, phone number, and hazard notes, then save.
- To whitelist a customer: Locate their row in the checklist and click **Xóa (Remove)**. Confirm the removal to restore their trusted status.

---

## 6. Reports Management (Trung Tâm Báo Cáo)
Used to compile executive summaries, review KPI performance trends, and trigger manual reports.

### 6.1. Reviewing Reports
1. Go to **Báo Cáo (Reports)**.
2. Filter generated reports by date or reference name.
3. Click any report to view its compiled KPIs, total revenue charts, and employee ranking charts.

### 6.2. Triggering and Dispatching a Report
1. Click **Tạo Báo Cáo (Generate Report)**.
2. Input the reference **Ngày (Reference Date)** and choose the report scope.
3. Click **Lưu (Save)**.
4. Once generated, click the **Gửi Email (Send Email)** option. The report summary will be packaged and sent to target administrators via the configured mail server.

---

## 7. Settings Management (Cài Đặt Hệ Thống)
Allows managers to customize interface visuals, general layouts, and notification parameters.

### 7.1. General Settings (Cài Đặt Chung)
- Update system name, select default operating currency, or toggle platform maintenance mode.

### 7.2. Dashboard Configuration (Cài Đặt Dashboard)
- Change default dashboard calendars range options (e.g. set default view to "Last 7 Days" instead of "Last 30 Days").

### 7.3. Notification Preferences (Cài Đặt Thông Báo)
- Tick checkboxes to determine what events trigger push alerts (e.g. alert when a user is blacklisted, alert when a high-value order is created).
- Click the **Lưu Cấu Hình (Save Configuration)** button at the bottom of the form to apply changes instantly across the entire platform.
