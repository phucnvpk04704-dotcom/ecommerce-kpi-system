from datetime import datetime
from decimal import Decimal
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.revenue import RevenueService
from app.schemas.revenue import RevenueCreate, RevenueUpdate, RevenueResponse
from app.dependencies.services import get_revenue_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.revenue import Revenue
from app.models.base import PyObjectId

router = APIRouter(prefix="/revenues", tags=["Revenues"])


class RevenueStatsResponse(BaseModel):
    total_revenue: Decimal
    target_revenue: Decimal
    total_orders: int
    successful_orders: int
    returned_orders: int
    cancelled_orders: int


class DeleteRevenueResponse(BaseModel):
    success: bool


@router.post("", response_model=RevenueResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=RevenueResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_revenue(
    request: RevenueCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)]
) -> Revenue:
    """
    Create a new daily/monthly revenue record.
    Manager privilege or higher required.
    """
    return await revenue_service.create(request)


@router.get("", response_model=List[RevenueResponse])
@router.get("/", response_model=List[RevenueResponse], include_in_schema=False)
async def list_revenues(
    manager_user: Annotated[Employee, Depends(require_manager())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Revenue]:
    """
    Retrieve all revenue records with pagination support.
    Manager privilege or higher required.
    """
    return await revenue_service.get_many({}, skip=skip, limit=limit)


@router.get("/stats/employee/{employee_id}", response_model=RevenueStatsResponse)
async def get_employee_stats(
    employee_id: str,
    platform: str,
    start_date: datetime,
    end_date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)]
) -> dict:
    """
    Aggregate revenue statistics for a specific employee within a date range.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    return await revenue_service.get_employee_revenue_stats(
        employee_id=emp_oid,
        platform=platform,
        start_date=start_date,
        end_date=end_date
    )


@router.get("/{revenue_id}", response_model=RevenueResponse)
async def get_revenue(
    revenue_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)]
) -> Revenue:
    """
    Retrieve details of a specific revenue record by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(revenue_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid revenue ID format"
        )
    revenue = await revenue_service.get_by_id(revenue_id)
    if not revenue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Revenue record not found"
        )
    return revenue


@router.put("/{revenue_id}", response_model=RevenueResponse)
async def update_revenue(
    revenue_id: str,
    request: RevenueUpdate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)]
) -> Revenue:
    """
    Perform a partial update on a specific revenue record.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(revenue_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid revenue ID format"
        )
    revenue = await revenue_service.update(revenue_id, request)
    if not revenue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Revenue record not found"
        )
    return revenue


@router.delete("/{revenue_id}", response_model=DeleteRevenueResponse)
async def delete_revenue(
    revenue_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    revenue_service: Annotated[RevenueService, Depends(get_revenue_service)]
) -> dict[str, bool]:
    """
    Delete a specific revenue record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(revenue_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid revenue ID format"
        )
    success = await revenue_service.delete(revenue_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Revenue record not found"
        )
    return {"success": True}
