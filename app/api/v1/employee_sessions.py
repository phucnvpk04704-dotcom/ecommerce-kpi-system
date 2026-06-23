from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.employee_session import EmployeeSessionService
from app.schemas.employee_session import EmployeeSessionCreate, EmployeeSessionResponse
from app.dependencies.services import get_employee_session_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.employee_session import EmployeeSession
from app.models.base import PyObjectId

router = APIRouter(prefix="/employee_sessions", tags=["EmployeeSessions"])


class DeleteSessionResponse(BaseModel):
    success: bool


class RevokeSessionResponse(BaseModel):
    success: bool


class RevokeAllSessionsResponse(BaseModel):
    revoked_count: int


@router.post("", response_model=EmployeeSessionResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=EmployeeSessionResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_session(
    request: EmployeeSessionCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> EmployeeSession:
    """
    Create a new employee session record.
    Manager privilege or higher required.
    """
    return await session_service.create(request)


@router.get("", response_model=List[EmployeeSessionResponse])
@router.get("/", response_model=List[EmployeeSessionResponse], include_in_schema=False)
async def list_sessions(
    admin_user: Annotated[Employee, Depends(require_admin())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)],
    skip: int = 0,
    limit: int = 100
) -> List[EmployeeSession]:
    """
    Retrieve all employee session records with pagination support.
    Admin privilege required.
    """
    return await session_service.get_many({}, skip=skip, limit=limit)


@router.get("/active/{session_id}", response_model=EmployeeSessionResponse)
async def get_active_session(
    session_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> EmployeeSession:
    """
    Retrieve details of an active employee session by its session ID.
    Manager privilege or higher required.
    """
    session = await session_service.get_active_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Active session not found or expired"
        )
    return session


@router.post("/revoke/{session_id}", response_model=RevokeSessionResponse)
async def revoke_session(
    session_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> dict:
    """
    Revoke a specific employee login session by its session ID.
    Manager privilege or higher required.
    """
    # Enforce role-based safety: non-managers can only revoke their own sessions.
    # We already have require_manager() for this endpoint, so it is safe.
    success = await session_service.revoke_session(session_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found to revoke"
        )
    return {"success": True}


@router.post("/revoke_all/employee/{employee_id}", response_model=RevokeAllSessionsResponse)
async def revoke_all_employee_sessions(
    employee_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> dict:
    """
    Revoke all active sessions for a specific employee.
    Admin privilege required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    count = await session_service.revoke_all_employee_sessions(emp_oid)
    return {"revoked_count": count}


@router.get("/{session_record_id}", response_model=EmployeeSessionResponse)
async def get_session(
    session_record_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> EmployeeSession:
    """
    Retrieve details of a specific employee session record by ID.
    Admin privilege required.
    """
    if not ObjectId.is_valid(session_record_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid session record ID format"
        )
    session = await session_service.get_by_id(session_record_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session record not found"
        )
    return session


@router.delete("/{session_record_id}", response_model=DeleteSessionResponse)
async def delete_session(
    session_record_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    session_service: Annotated[EmployeeSessionService, Depends(get_employee_session_service)]
) -> dict[str, bool]:
    """
    Delete a specific employee session record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(session_record_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid session record ID format"
        )
    success = await session_service.delete(session_record_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session record not found"
        )
    return {"success": True}
