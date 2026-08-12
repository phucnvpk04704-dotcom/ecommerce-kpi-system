# Pre-Fix CORS and API Audit

## 1. Exact CORS Middleware Configuration from FastAPI

- **File Path**: [main.py](file:///d:/du_an_tmdt/app/main.py#L53-L61)
- **Code Snippet**:
  ```python
  # Mount Cross-Origin Resource Sharing (CORS) Middleware
  application.add_middleware(
      CORSMiddleware,
      allow_origins=settings.CORS_ORIGINS,
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"]
  )
  ```
- **Current `allow_origins`**: Loaded from `settings.CORS_ORIGINS` which defaults to:
  `["http://localhost:5173", "http://127.0.0.1:5173", "http://localhost:8080", "http://127.0.0.1:8080"]`
- **Current `allow_methods`**: `["*"]` (all methods)
- **Current `allow_headers`**: `["*"]` (all headers)

---

## 2. Actual Response of `OPTIONS /api/v1/auth/login`

- **Status Code**: `400 Bad Request`
- **Response Headers**:
  ```http
  HTTP/1.1 400 Bad Request
  date: Wed, 24 Jun 2026 03:39:32 GMT
  server: uvicorn
  vary: Origin
  access-control-allow-methods: DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT
  access-control-max-age: 600
  access-control-allow-credentials: true
  access-control-allow-headers: content-type
  content-length: 22
  content-type: text/plain; charset=utf-8
  ```
- **Response Body**:
  `Disallowed CORS origin`

---

## 3. Actual Response of `POST /api/v1/auth/login` (Using Swagger payload)

- **Request Payload**:
  ```json
  {
    "username": "admin",
    "password": "admin123456"
  }
  ```
- **Status Code**: `200 OK`
- **Response Body**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YTNhYTM3NmNlOWUyMjNjOTM4OWQyZTQiLCJyb2xlIjoiQWRtaW4iLCJzZXNzaW9uX2lkIjoiMTM1YjI2YTMtYzI3YS00OTg3LWJkNWItZGFiNjAxYTdjYWM5IiwiZXhwIjoxNzgyMjc1OTgyfQ.Vvf4TeS2f9xUx3KdjfDfh9YChrH4-aYG7ZnuFYxXoh8",
    "token_type": "bearer",
    "employee_id": "6a3aa376ce9e223c9389d2e4",
    "employee_code": "NV001",
    "full_name": "Nguyễn Văn Trị",
    "role": "Admin",
    "session_id": "135b26a3-c27a-4987-bd5b-dab601a7cac9"
  }
  ```

---

## 4. Flutter API Configuration

- **Exact File Path**: [api_constants.dart](file:///d:/ecommerce_kpi_mobile/lib/core/constants/api_constants.dart)
- **Exact Base URL Currently Used**:
  ```dart
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  ```
- **All References to `localhost` / `127.0.0.1` inside Flutter codebase**:
  - `lib/core/constants/api_constants.dart` (Line 4):
    ```dart
    static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
    ```
  - `IMPLEMENTATION_REPORT.md` (Line 74):
    `3. lib/core/constants/api_constants.dart: Holds target environment options (BASE_URL set to http://127.0.0.1:8000/api/v1).`
  - `API_INTEGRATION_REPORT.md` (Line 3):
    `We connected the E-Commerce KPI Mobile app features to the real FastAPI backend running at http://127.0.0.1:8000/api/v1.`

---

## 5. Origin Verification

- **Browser/Frontend Origin**: `http://localhost:60921` (port assigned dynamically by Flutter Chrome runner)
- **Backend Origin**: `http://127.0.0.1:8000`
- **Verdict**: **Not the same origin**. Hostnames (`localhost` vs `127.0.0.1`) and Ports (`60921` vs `8000`) differ, forcing the browser to perform cross-origin resource sharing (CORS) preflight checks.

---

## 6. Root Cause

1. The browser initiates a preflight `OPTIONS` request to `http://127.0.0.1:8000/api/v1/auth/login` from the origin `http://localhost:60921`.
2. Starlette's `CORSMiddleware` in FastAPI receives the `Origin` header `http://localhost:60921`.
3. It cross-references `http://localhost:60921` against `settings.CORS_ORIGINS` (`["http://localhost:5173", "http://127.0.0.1:5173", "http://localhost:8080", "http://127.0.0.1:8080"]`).
4. Since `http://localhost:60921` is not present in the allowed origins list, the middleware rejects the request, returning `400 Bad Request` with the body `Disallowed CORS origin`.
5. Because the preflight fails, the browser blocks the actual `POST` request, throwing a connection error callback error in the Flutter web app console.

---

## Final Verdict

**A. Backend CORS problem**
