import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional
from app.core.config import settings
from app.core.enums.employee import EmployeeStatus, Role
from app.core.security import verify_password, create_access_token, decode_token
from app.repositories.employee import EmployeeRepository
from app.repositories.employee_session import EmployeeSessionRepository
from app.schemas.auth import LoginResponse, TokenPayload
from app.schemas.employee_session import EmployeeSessionCreate


class AuthService:
    """
    Business Service for orchestrating Employee authentication, stateless session state tracking,
    JWT access token issuance, and logout/revocation checks.
    """
    def __init__(
        self,
        employee_repository: EmployeeRepository,
        session_repository: EmployeeSessionRepository
    ):
        self.employee_repository = employee_repository
        self.session_repository = session_repository

    async def authenticate(
        self,
        username: str,
        password: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None
    ) -> LoginResponse:
        """
        Validates credentials, checks account status, initializes a database session,
        generates signed access tokens, and returns detailed user login data.
        """
        # 1. Locate employee by username
        employee = await self.employee_repository.find_by_username(username)
        if not employee:
            raise ValueError("Invalid username or password")

        # 2. Check hashed password match
        if not verify_password(password, employee.hashed_password):
            raise ValueError("Invalid username or password")

        # 3. Check account activation status
        if employee.status != EmployeeStatus.ACTIVE:
            raise ValueError("User account is inactive or disabled")

        # 4. Generate session coordinates
        session_id = str(uuid.uuid4())
        created_at = datetime.now(timezone.utc)
        expires_at = created_at + timedelta(hours=settings.SESSION_EXPIRE_HOURS)

        # 5. Record session document in database
        session_schema = EmployeeSessionCreate(
            employee_id=employee.id,
            session_id=session_id,
            ip_address=ip_address,
            user_agent=user_agent,
            last_activity_at=created_at,
            expires_at=expires_at
        )
        await self.session_repository.create(session_schema)

        # 6. Issue JWT access token containing session identifiers
        token_data = {
            "sub": str(employee.id),
            "role": employee.role.value,
            "session_id": session_id
        }
        access_token = create_access_token(token_data)

        # 7. Compile and return unified response
        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            employee_id=str(employee.id),
            employee_code=employee.employee_code,
            full_name=employee.full_name,
            role=employee.role,
            session_id=session_id
        )

    async def logout(self, session_id: str) -> bool:
        """Revoke session ID validity from the tracking registry."""
        return await self.session_repository.revoke_session(session_id)

    async def validate_token(self, token: str) -> TokenPayload:
        """Decode access token signatures, verify session keys in DB, and retrieve claims."""
        try:
            payload_dict = decode_token(token)

            # Retrieve JWT standard claim outputs
            sub = payload_dict.get("sub")
            role_val = payload_dict.get("role")
            session_id = payload_dict.get("session_id")
            exp = payload_dict.get("exp")

            if not all([sub, role_val, session_id, exp]):
                raise ValueError("Missing necessary token claims")

            # Verify that the session has not been revoked or cleared
            session = await self.session_repository.find_active_session(session_id)
            if not session:
                raise ValueError("Session is expired or has been revoked")

            return TokenPayload(
                sub=sub,
                role=Role(role_val),
                session_id=session_id,
                exp=exp
            )
        except Exception as e:
            raise ValueError(f"Invalid token: {str(e)}")
