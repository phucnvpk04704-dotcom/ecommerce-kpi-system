# Authentication Regression Fix Report

This document reports the diagnostic analysis and remediation of the authentication regression that resulted in `401 Unauthorized` errors on the administrative dashboard page.

---

## 1. Root Cause Diagnostic Analysis

The issue occurred due to an authentication deadlock caused by a stale JSON Web Token (JWT) in the browser's `localStorage` after database cleanup and reseeding:

1. **Database Reseeding / Clearing**: During the demo database seeding process, the `employee_sessions` collection in MongoDB was cleared, which revoked all previously active user session IDs in the database.
2. **Stale Local Storage Token**: The browser retained a stale `access_token` in `localStorage` from a previous session.
3. **Authentication Bypass on Init**: On page refresh, the frontend initialized the React state `isAuthenticated = true` solely because `localStorage.getItem('access_token')` was present. This bypassed the `/login` route and rendered the protected dashboard layout.
4. **Backend Token Validation Rejection**: The dashboard component made initial API calls to the `/dashboard/*` endpoints. The backend validated the JWT token but found that the `session_id` stored in the token's claims no longer existed in the MongoDB `employee_sessions` collection. The backend correctly responded with `401 Unauthorized`.
5. **Deadlock State**:
   - The frontend Axios calls failed with a 401 error.
   - The UI caught the error and displayed a generic network/connection failure banner.
   - Because `isAuthenticated` remained `true` in the React context, accessing `/login` redirected the user back to the dashboard.
   - Because there was no global response interceptor on the frontend to handle 401 errors, the invalid token was never cleared from `localStorage`, locking the user in a permanent error loop.

---

## 2. Implemented Remediation

We performed the following modifications:

### A. Centralized API Client Interceptor
We modified [apiClient.ts](file:///d:/du_an_tmdt/frontend/src/services/apiClient.ts) to intercept all API responses. If an API call returns `401 Unauthorized`, the client automatically clears the credentials and redirects to the login page:
```typescript
// Auto-intercept 401 Unauthorized to clear stale credentials and force redirect to login
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('access_token');
      localStorage.removeItem('logged_username');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### B. Consolidated Dashboard API Calls
We modified [dashboard.ts](file:///d:/du_an_tmdt/frontend/src/api/dashboard.ts) to import and use the central `apiClient` instance instead of creating a duplicate axios instance. This ensures that dashboard requests share the exact same request/response interceptor logic.

---

## 3. Verification Results

We verified the authentication flow using the automated test suite and manual browser subagent steps:

1. **Automated Integration Tests**:
   - Ran `pytest` and confirmed that all 17 integration tests (including auth login, failure, validate token, and logout) pass successfully.
2. **Browser Flow Verification**:
   - Verified that clicking the "Đăng Xuất" (Logout) button clears the local storage token and redirects the user to `/login`.
   - Logging in with credentials `admin` / `admin123456` successfully calls `POST /auth/login` (status `200 OK`) and retrieves a new valid session token.
   - The dashboard page loads and renders all metrics successfully:
     - **Cumulative Revenue**: `6,021,561,504 ₫`
     - **Total Orders**: `5,000`
     - **Seeded Employees**: `20`
     - **Active Sessions**: `2`
     - **Blacklisted Customers**: `100`
   - Checked the console logs and verified that no `401` errors or unhandled network errors remain.
