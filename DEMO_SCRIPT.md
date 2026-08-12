# System Demo Script

This script provides step-by-step guidance for testing and validating the core modules of the **Enterprise Multi-Channel Ecommerce KPI Management System**. Follow these instructions to run a complete verification cycle.

---

## Demo Script Parameters
- **System URL**: `http://localhost:5173`
- **Default Accounts**:
  - *Administrator*: Username: `admin` | Password: `admin123456`
- **Active Backend**: `http://localhost:8000/api/v1`

---

## Step-by-Step Validation Script

### Step 1: Secure Login Flow
* **Action**:
  1. Open a web browser and navigate to `http://localhost:5173/login`.
  2. Input username `admin` and password `admin123456`.
  3. Click **Đăng Nhập**.
* **Expected Result**:
  - The login modal validates credentials, stores the JWT access token in `localStorage`, and updates status.
  - Page routes successfully to the primary URL (`/`).
  - The sidebar and header render correctly showing user "admin".

---

### Step 2: Dashboard Overview & Controls
* **Action**:
  1. Inspect the main metrics widgets (Total Revenue, Total Orders, Total Employees, Active Sessions).
  2. Locate the calendar control menu at the top. Click it and switch the range preset to **30 ngày qua (Last 30 Days)**.
  3. Click the **Tải Lại (Reload)** button.
  4. Click the **Excel** button in the header menu.
* **Expected Result**:
  - Summary cards load actual values from `/api/v1/dashboard/summary`.
  - Monthly graphs dynamically re-render based on the selected range.
  - A manual reload updates the "Cập nhật lúc [Time]" timestamp.
  - A formatted CSV document named `dashboard_summary_[Date].csv` is downloaded.

---

### Step 3: Employee CRUD Performance
* **Action**:
  1. Click **Nhân Viên (Employees)** in the sidebar navigation.
  2. Click **Thêm Nhân Viên (Add Employee)** in the top toolbar.
  3. Populate fields:
     - Name: `Nguyễn Văn Thử Nghiệm`
     - Email: `nguyen.test@ecommerce.com`
     - Phone: `0987654321`
     - Role: `Employee`
     - Platforms: Tick `Shopee` and `Lazada`
  4. Click **Lưu (Save)**.
  5. Search for `Nguyễn Văn Thử Nghiệm` in the search bar.
  6. Click **Sửa (Edit)** on their row, update Phone to `0999999999`, and click **Lưu**.
  7. Click **Xóa (Delete)** on their row, and approve the deactivation dialog.
* **Expected Result**:
  - A new employee database document is generated with a sequential employee code (e.g. `EMP00021`).
  - Search filters update the tabular list to show only the matching row.
  - Edit form updates the phone number instantly.
  - Deactivating the employee toggles their status tag to "Ngừng hoạt động (Inactive)" in red, preventing further platform access.

---

### Step 4: Revenue Log Registry & Exports
* **Action**:
  1. Navigate to the **Doanh Thu (Revenues)** tab.
  2. Verify that monthly sales targets graphs render properly.
  3. Click **Thêm Doanh Thu (Add Revenue)**.
  4. Fill out parameters:
     - Select Date: Today
     - Amount: `15000000` (15,000,000 VND)
     - Platform: `Shopee`
     - Responsible Employee: Select `Nguyễn Văn Thử Nghiệm` (or another active staff).
  5. Click **Lưu (Save)**.
  6. Locate the **Xuất Excel (Export Excel)** button and click it.
* **Expected Result**:
  - A new revenue log is stored in the database.
  - The monthly target bar progress increases dynamically.
  - A spreadsheet-compatible CSV containing all database revenue rows downloads successfully.

---

### Step 5: Customer Blacklist & Risk Evaluation
* **Action**:
  1. Open the **Danh Sách Đen (Blacklist)** module from the sidebar.
  2. In the lookup field, enter phone number `0909090909` (or a phone number from test orders) and click **Tìm Kiếm**.
  3. Click the **Đánh giá rủi ro (Evaluate Risk)** button on a customer profile.
  4. Click **Thêm Khách Hàng (Add Customer)**, fill out Name `Bùi Văn Gian Lận`, Phone `0911222333`, Risk Notes `Hoàn hàng 5 lần liên tiếp`, and save.
* **Expected Result**:
  - Search lists customer blacklist metadata (or returns empty if no matching phone number is registered).
  - The risk evaluation API checks customer purchase statistics, flags cancellations/returns ratio, calculates an index, and returns their risk scale (e.g. Medium risk or High risk).
  - Newly added blacklisted buyer appears immediately in the blacklisted directories.

---

### Step 6: Technical Report Generation & Email Dispatch
* **Action**:
  1. Open the **Báo Cáo (Reports)** page.
  2. Inspect the historical report list.
  3. Click **Tạo Báo Cáo (Generate Report)**.
  4. Choose Today's date and select Report Scope (e.g. KPI & Revenues).
  5. Click **Lưu (Save)**.
  6. Click **Gửi Email (Send Email)** on the newly created report item.
* **Expected Result**:
  - System calls `/api/v1/reports` and compiles sales metrics and employee performance rankings.
  - The report dashboard displays the new report metrics immediately.
  - Email action calls `/api/v1/reports/{id}/sent`, flags the database document as sent (`is_sent = true`), and sends an HTML summary email via Gmail SMTP.

---

### Step 7: System Settings Adjustments
* **Action**:
  1. Click **Cài Đặt (Settings)** in the sidebar.
  2. Navigate to the **Cài Đặt Dashboard** sub-tab.
  3. Switch the default dashboard view setting parameter to **Last 7 Days**.
  4. Switch to the **Thông Báo** sub-tab and toggle the "Thông báo khi có khách hàng bị blacklist" switch.
  5. Click **Lưu Cấu Hình (Save Configuration)**.
* **Expected Result**:
  - System issues a `PUT` request to `/api/v1/settings` to persist configs.
  - A green notification banner confirms configurations are successfully stored.

---

### Step 8: Dashboard Verification Check
* **Action**:
  1. Click **Tổng Quan (Dashboard)** in the sidebar navigation.
  2. Inspect the default view range calendar dropdown.
  3. Click the logout icon in the sidebar.
* **Expected Result**:
  - The default date range in the toolbar loads as **Last 7 Days** (retrieved from settings).
  - Logging out clears the access token from `localStorage` and routes the user back to the `/login` screen.
