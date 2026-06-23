from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel

from app.services.auth import AuthService
from app.schemas.auth import LoginRequest, LoginResponse
from app.dependencies.services import get_auth_service
from app.dependencies.auth import get_current_user
from app.models.employee import Employee
from app.core.enums.employee import Role

router = APIRouter(prefix="/auth", tags=["Authentication"])


class ValidateResponse(BaseModel):
    employee_id: str
    username: str
    role: Role


@router.post("/swagger-login", response_model=LoginResponse)
async def swagger_login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> LoginResponse:
    """
    Authenticate employee credentials via URL-encoded form data for Swagger Authorize flow.
    """
    try:
        return await auth_service.authenticate(
            username=form_data.username,
            password=form_data.password
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )


@router.post("/login", response_model=LoginResponse)
async def login(
    request: LoginRequest,
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> LoginResponse:
    """
    Authenticate employee credentials and issue session JWT access tokens.
    """
    try:
        return await auth_service.authenticate(
            username=request.username,
            password=request.password
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )


@router.post("/logout")
async def logout(
    session_id: str,
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> dict[str, bool]:
    """
    Invalidate an employee session and revoke credentials state.
    """
    await auth_service.logout(session_id)
    return {"success": True}


@router.get("/validate", response_model=ValidateResponse)
async def validate_user(
    current_user: Annotated[Employee, Depends(get_current_user)]
) -> ValidateResponse:
    """
    Validate current active employee credentials and session.
    """
    return ValidateResponse(
        employee_id=str(current_user.id),
        username=current_user.username,
        role=current_user.role
    )
