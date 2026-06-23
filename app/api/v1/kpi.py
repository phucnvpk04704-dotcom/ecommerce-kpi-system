from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.kpi import KPIService
from app.schemas.kpi import KPIDailyCreate, KPIDailyResponse
from app.dependencies.services import get_kpi_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.kpi import KPIDaily
from app.models.base import PyObjectId

router = APIRouter(prefix="/kpi", tags=["KPI"])


class DeleteKPIResponse(BaseModel):
    success: bool


@router.post("", response_model=KPIDailyResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=KPIDailyResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_kpi(
    request: KPIDailyCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    kpi_service: Annotated[KPIService, Depends(get_kpi_service)]
) -> KPIDaily:
    """
    Create a new KPI daily record.
    Manager privilege or higher required.
    """
    return await kpi_service.create_kpi_record(request)


@router.get("", response_model=List[KPIDailyResponse])
@router.get("/", response_model=List[KPIDailyResponse], include_in_schema=False)
async def list_kpis(
    manager_user: Annotated[Employee, Depends(require_manager())],
    kpi_service: Annotated[KPIService, Depends(get_kpi_service)],
    skip: int = 0,
    limit: int = 100
) -> List[KPIDaily]:
    """
    Retrieve all daily KPI records with pagination support.
    Manager privilege or higher required.
    """
    return await kpi_service.get_many({}, skip=skip, limit=limit)


@router.get("/history/employee/{employee_id}", response_model=List[KPIDailyResponse])
async def get_employee_kpi_history(
    employee_id: str,
    start_date: datetime,
    end_date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    kpi_service: Annotated[KPIService, Depends(get_kpi_service)]
) -> List[KPIDaily]:
    """
    Retrieve a specific employee's daily KPI history logs over a date range.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    return await kpi_service.get_employee_kpi_history(
        employee_id=emp_oid,
        start_date=start_date,
        end_date=end_date
    )


@router.get("/{kpi_id}", response_model=KPIDailyResponse)
async def get_kpi(
    kpi_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    kpi_service: Annotated[KPIService, Depends(get_kpi_service)]
) -> KPIDaily:
    """
    Retrieve details of a daily KPI record by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(kpi_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid KPI ID format"
        )
    kpi = await kpi_service.get_by_id(kpi_id)
    if not kpi:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="KPI record not found"
        )
    return kpi


@router.delete("/{kpi_id}", response_model=DeleteKPIResponse)
async def delete_kpi(
    kpi_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    kpi_service: Annotated[KPIService, Depends(get_kpi_service)]
) -> dict[str, bool]:
    """
    Delete a daily KPI record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(kpi_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid KPI ID format"
        )
    success = await kpi_service.delete(kpi_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="KPI record not found"
        )
    return {"success": True}
