# Automated Testing Guide

This guide provides instructions on how to run, write, and maintain automated tests for the Ecommerce KPI System backend.

## Test Infrastructure

The automated testing setup is built on **pytest** and **pytest-asyncio** to support asynchronous integration testing of the FastAPI backend. It interacts with an isolated test database.

### Core Technologies
- **pytest**: Core testing framework.
- **pytest-asyncio**: Asynchronous testing support for Python `asyncio`.
- **httpx**: For sending asynchronous HTTP requests to the FastAPI application.
- **pytest-cov**: For coverage tracking.

---

## Configuration & Loop Isolation

### 1. The Asynchronous Event Loop Policy
When running asynchronous integration tests with Motor and HTTPX, the FastAPI endpoint dependencies (e.g. repositories, services) are resolved within worker threads by FastAPI's dependency injection system if they are synchronous functions. This can lead to the following error:
`RuntimeError: Task got Future attached to a different loop`

To guarantee that database clients and repository collections resolve under the same thread-safe event loop, the test infrastructure implements:
- A custom `TestEventLoopPolicy` registered in `tests/conftest.py` that redirects all thread loop queries to the active test loop.
- `async def` overrides for all database and repository dependency endpoints registered in the FastAPI app's `dependency_overrides` map during test session boot.

### 2. MongoDB Decimal Handling
MongoDB does not natively encode/decode Python `decimal.Decimal` objects. To prevent `bson.errors.InvalidDocument: cannot encode object: Decimal` exceptions, a custom `DecimalCodec` is registered on the client connections in both `app/db/client.py` and `tests/conftest.py` which transparently maps `Decimal` properties to BSON `Decimal128` values.

---

## How to Run Tests

### Prerequisites
Make sure your python virtual environment is active and all dependencies are installed.

```bash
pip install -r requirements.txt
pip install pytest-cov
```

### Running the Test Suite
To run the full test suite in verbose mode:

```bash
pytest -v
```

### Running with Code Coverage
To run the tests and generate a detailed code coverage report in the terminal:

```bash
pytest --cov=app --cov-report=term-missing
```

Coverage options are configured in the `.coveragerc` file in the root directory.

---

## Directory Structure

All tests are placed inside the `tests/` directory:
- `tests/conftest.py`: Contains test database configuration, mock authentication helpers, loop safety implementations, and shared fixtures.
- `tests/integration/`: Contains tests targeting specific modules:
  - `test_auth.py`: Tests login, logout, token validation, and permission mismatch errors.
  - `test_employees.py`: Tests the CRUD lifecycle for employees and non-admin creation blocks.
  - `test_revenues.py`: Tests daily/monthly revenue logging and access control.
  - `test_blacklist.py`: Tests customer blacklist additions, phone lookups, and risk scoring updates.
  - `test_dashboard.py`: Tests metrics summaries and KPI aggregation checks.
