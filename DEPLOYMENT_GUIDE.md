# System Deployment & Operations Guide

This guide details the requirements, configurations, startup procedures, and backup/recovery strategies for running the **Enterprise Multi-Channel Ecommerce KPI Management System** in production.

---

## 1. System Requirements & Prerequisites

### 1.1. Database (MongoDB)
- **Version**: MongoDB v6.0 or higher.
- **Connection URL**: Standard URI format (`mongodb://username:password@host:port/database`).
- **Required Database Indexes**: The application creates database indexes on startup via context lifespan hooks for:
  - `employees`: `employee_id` (unique index), `email` (unique index).
  - `customer_blacklist`: `customer_phone` (unique index).
  - `orders`: `order_id` (unique index), `employee_id` (search key).

### 1.2. Backend Environment (Python)
- **Version**: Python v3.10 or Python v3.11.
- **Package Installer**: `pip` (packages listed in `requirements.txt`).

### 1.3. Frontend Environment (Node.js)
- **Version**: Node.js v18 or Node.js v20 (LTS).
- **Package Manager**: `npm` (packages listed in `package.json`).

---

## 2. Environment Variables Configuration

Create a `.env` file in the project root (`D:\du_an_tmdt\.env`). Fill in the configurations based on the template below:

```ini
# Core Configuration
PROJECT_NAME="Enterprise Multi-Channel Ecommerce KPI Management System"
APP_NAME="ecommerce_kpi"
ENVIRONMENT="production"      # Switch to "production" to disable debug utilities
DEBUG=false                   # Disable debug logs and traceback exposure in API responses

# Database Configuration
MONGODB_URL="mongodb://adminuser:SecurePassword123@localhost:27017/ecommerce_kpi_system?authSource=admin"
DATABASE_NAME="ecommerce_kpi_system"

# Security Credentials
# Generate a cryptographically secure key: openssl rand -hex 32
JWT_SECRET_KEY="098f6bcd4621d373cade4e832627b4f60a912046340268593450918239012390"
JWT_ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=60
SESSION_EXPIRE_HOURS=24

# Mail Server Configurations (SMTP)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="company-alert-sender@gmail.com"
SMTP_PASSWORD="your-gmail-app-password"
SMTP_FROM_EMAIL="alerts-noreply@company.com"

# Automated Scheduled Tasks Switch
ENABLE_JOBS=true
```

---

## 3. Application Startup Instructions

### 3.1. Database Setup
1. Ensure the MongoDB service is active.
2. In Windows Services, verify `MongoDB Agent` or `MongoDB Server (MongoDB)` status is `Running`.
3. Alternatively, start it via CLI:
   ```powershell
   net start MongoDB
   ```

### 3.2. Backend API Server Startup
1. Open terminal in the project root (`D:\du_an_tmdt`).
2. Create and activate a Python virtual environment (recommended):
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\activate
   ```
3. Install backend dependencies:
   ```powershell
   pip install -r requirements.txt
   ```
4. Start the ASGI application using Uvicorn:
   ```powershell
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
   ```
   *Note: Using `--workers 4` runs the server in multi-process mode for production request loads.*

### 3.3. Frontend Client Startup
1. Open a new terminal in the frontend directory (`D:\du_an_tmdt\frontend`).
2. Install dependencies:
   ```powershell
   npm install
   ```
3. Build the production files:
   ```powershell
   npm run build
   ```
4. Serve the production bundle using a lightweight web server (e.g., Nginx or PM2), or run a preview command locally:
   ```powershell
   npm run preview -- --port 8080 --host
   ```

---

## 4. Production Deployment Checklist
- [ ] **Secret Keys**: Ensure the default `JWT_SECRET_KEY` in `.env` has been changed to a random 64-character hex string.
- [ ] **Debug Switch**: Ensure `DEBUG=false` in the backend environment.
- [ ] **Database Authentication**: MongoDB must require credentials (authentication enabled) and block public host exposures.
- [ ] **CORS Origins**: Restrict `allow_origins=["*"]` in `app/main.py` to only include the company's domain name.
- [ ] **HTTPS Binding**: Bind a reverse proxy (e.g. Nginx) with an SSL certificate (Let's Encrypt) to port `80` / `443` forwarding to Uvicorn on `8000`.
- [ ] **Process Management**: Wrap the backend in a daemon service (like systemd, PM2, or Windows Service Wrapper) to handle restarts on system failures.

---

## 5. Database Backup and Recovery Checklist

### 5.1. Database Backup (Export)
Always back up the MongoDB database daily. Use the `mongodump` utility.

* **Backup Command**:
  ```powershell
  mongodump --uri="mongodb://adminuser:SecurePassword123@localhost:27017/ecommerce_kpi_system?authSource=admin" --out="D:\backup\db_backup_$(Get-Date -Format 'yyyyMMdd')"
  ```
* **Daily Backup Task Automations**:
  Set up a scheduled task in Windows Task Scheduler (or a Cron Job in Linux) to run a batch script:
  ```batch
  @echo off
  set BACKUP_DIR=D:\backup\db_backup_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%
  mongodump --uri="mongodb://localhost:27017/ecommerce_kpi_system" --out="%BACKUP_DIR%"
  echo Backup completed.
  ```

### 5.2. Database Recovery (Import)
If data loss occurs, restore the database collections from a generated backup using `mongorestore`.

* **Recovery Command**:
  ```powershell
  mongorestore --uri="mongodb://adminuser:SecurePassword123@localhost:27017/ecommerce_kpi_system?authSource=admin" --drop "D:\backup\db_backup_20260623\ecommerce_kpi_system"
  ```
  *(Note: The `--drop` flag drops existing collections prior to importing backup files to avoid duplicate key errors).*
