from typing import Annotated
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from app.services.auth import AuthService
from app.services.employee import EmployeeService
from app.core.enums.employee import Role
from app.models.employee import Employee
from app.dependencies.services import get_auth_service, get_employee_service

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/swagger-login"
)


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)]
) -> Employee:
    """
    Validate the authentication token and return the current authenticated employee.
    """
    try:
        payload = await auth_service.validate_token(token)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )

    employee = await employee_service.get_by_id(payload.sub)
    if not employee:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Employee not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return employee


def require_admin():
    """
    Dependency guard that yields the current employee only if they have the ADMIN role.
    """
    async def dependency(
        current_user: Annotated[Employee, Depends(get_current_user)]
    ) -> Employee:
        if current_user.role != Role.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Administrative privilege required"
            )
        return current_user
    return dependency


def require_manager():
    """
    Dependency guard that yields the current employee if they are an ADMIN or a MANAGER.
    """
    async def dependency(
        current_user: Annotated[Employee, Depends(get_current_user)]
    ) -> Employee:
        if current_user.role not in [Role.ADMIN, Role.MANAGER]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Managerial privilege required"
            )
        return current_user
    return dependency
