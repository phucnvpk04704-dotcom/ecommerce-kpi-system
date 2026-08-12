# API URL Report

## 1. Search Results inside Flutter Project

A project-wide search was performed for keys relating to the backend host settings:

- **Search Query `127.0.0.1`**:
  - Found in `lib/core/constants/api_constants.dart` on line 4:
    ```dart
    static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
    ```
- **Search Query `baseUrl`**:
  - Found in `lib/core/constants/api_constants.dart`:
    ```dart
    static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
    ```
  - Found in `lib/core/network/api_client.dart`:
    ```dart
    this.dio.options
      ..baseUrl = ApiConstants.baseUrl
    ```

---

## 2. API Base URL and Verification

The actual backend API base URL configured in the Flutter client:
- **`http://127.0.0.1:8000/api/v1`**

### Backend Verification:
- The backend FastAPI runs successfully on `http://127.0.0.1:8000`.
- The prefix configured for API endpoints in the backend router is `/api/v1` (e.g. `application.include_router(api_router, prefix="/api/v1")`).
- The health check resides at `/health`, and other REST endpoints are under `/api/v1/...` (e.g. login is `/api/v1/auth/login`).

Therefore, the Flutter client's `baseUrl` **correctly matches** the active backend service port and path prefix. No adjustment is required.
