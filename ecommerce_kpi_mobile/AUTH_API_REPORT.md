# Authentication API Report

## 1. Request Body Schema

The login endpoint `POST /api/v1/auth/login` accepts a JSON body with the following structure:

```json
{
  "username": "string",
  "password": "string"
}
```

### Schema Validation Constraints (from `app/schemas/auth.py`):
- **`username`**:
  - Type: `string`
  - Min Length: 3 characters
  - Max Length: 50 characters
  - Required: Yes
- **`password`**:
  - Type: `string`
  - Min Length: 6 characters
  - Max Length: 100 characters
  - Required: Yes

---

## 2. Field Names

- Username field name: **`username`**
- Password field name: **`password`**

---

## 3. Example Credentials

Seeded in the database (`d:\du_an_tmdt\scripts\seed_data.py`):

1. **Administrator Account**:
   - Username: `admin`
   - Password: `admin123456`
   - Role: `Admin` (code: `NV001`)

2. **Standard Employee Account**:
   - Username: `testuser`
   - Password: `testpassword`
   - Role: `Employee` (code: `NV002`)

---

## 4. JWT Response Structure

Upon successful authentication, the API returns a `200 OK` status with the following response body schema:

```json
{
  "access_token": "string",
  "token_type": "bearer",
  "employee_id": "string",
  "employee_code": "string",
  "full_name": "string",
  "role": "string",
  "session_id": "string"
}
```

### Response Example:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "employee_id": "6a3aa376ce9e223c9389d2e4",
  "employee_code": "NV001",
  "full_name": "Nguyễn Văn Trị",
  "role": "Admin",
  "session_id": "8bd99c62-f68b-43aa-89f8-3317a7bf155f"
}
```

### Token Payload Details (`TokenPayload` schema):
- `sub`: Subject (corresponds to the MongoDB `employee_id` string).
- `role`: Role associated with the employee (e.g. `Admin`, `Employee`).
- `session_id`: Unique identifier tracking this specific active login session.
- `exp`: Timestamp representing token expiration time.
