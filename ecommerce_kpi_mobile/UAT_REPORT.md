# User Acceptance Testing (UAT) Report

This report documents the User Acceptance Testing (UAT) outcomes for the Manager Mobile Application. All validation checks were performed locally using the Chrome DevTools runner against the live FastAPI development backend.

---

## 1. Screens Tested & Results

| Screen | Route Path | Primary Functionality | Status |
| :--- | :--- | :--- | :--- |
| **Login** | `/login` | Authentication form submission | **PASSED** |
| **Dashboard** | `/dashboard` | Today's Revenue, Team Stats, KPI Averages | **PASSED** |
| **Team (Performance)** | `/employees` | Read-only listing, individual stats metrics dialog | **PASSED** |
| **Revenue** | `/revenue` | Charts, sales trend analysis, platform breakdown | **PASSED** |
| **Notifications** | `/notifications` | List of alerts, warnings, and achievements | **PASSED** |
| **Profile** | `/profile` | User detail display, preferences, logout actions | **PASSED** |

---

## 2. State Validations

* **Loading States**:
  - **Verification**: Verified using synthetic network throttling (Fast 3G). Screen displays a central, themed `CircularProgressIndicator` spinner while Riverpod asynchronously retrieves backend records (tested on the Team Performance tab and Dashboard chart components).
  - **Status**: **PASSED**
* **Empty States**:
  - **Verification**: Simulated blank queries. The search bar filters in the Team Performance screen and Profile screen return clear, user-friendly empty state cards containing descriptive icons (e.g. `Icons.people_outline` / `Icons.settings_suggest_outlined`) and matching labels ("No employees found matching the filters").
  - **Status**: **PASSED**
* **Error States**:
  - **Verification**: Simulated database downtime. When the backend service is offline, the screens catch the exception via Riverpod's `AsyncValue.error` handlers, displaying readable error banners without freezing the viewport.
  - **Status**: **PASSED**
* **Unauthorized States**:
  - **Verification**: Forced invalid JWT token state. When requests return an HTTP `401 Unauthorized` status (due to token expiration or invalid token data), the `ApiClient` interceptor invalidates local storage caches and resets the Riverpod `authStateProvider` to `false`. GoRouter redirects the viewport back to the `/login` screen immediately.
  - **Status**: **PASSED**

---

## 3. UAT Execution Evidence

* **Active Browser Page**: `http://localhost:60921/?enable-semantics=true#/dashboard`
* **Backend Data Integrity**: Verified Dashboard successfully fetched and displayed actual values from the MongoDB database (`$6,021,561,504` total revenue across 2 active employees).
* **Console Health**: Verified clean execution, with no CORS warnings or connection exceptions remaining.
