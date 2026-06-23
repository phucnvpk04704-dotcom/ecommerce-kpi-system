from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.product_activity import ProductActivityService
from app.schemas.product_activity import ProductActivityCreate, ProductActivityUpdate, ProductActivityResponse
from app.dependencies.services import get_product_activity_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.product_activity import ProductActivity
from app.models.base import PyObjectId

router = APIRouter(prefix="/product_activities", tags=["ProductActivities"])


class DeleteProductActivityResponse(BaseModel):
    success: bool


class ProductActivityStatsResponse(BaseModel):
    count: int


@router.post("", response_model=ProductActivityResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=ProductActivityResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_activity(
    request: ProductActivityCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)]
) -> ProductActivity:
    """
    Create a new product activity record.
    Manager privilege or higher required.
    """
    return await activity_service.create(request)


@router.get("", response_model=List[ProductActivityResponse])
@router.get("/", response_model=List[ProductActivityResponse], include_in_schema=False)
async def list_activities(
    manager_user: Annotated[Employee, Depends(require_manager())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)],
    skip: int = 0,
    limit: int = 100
) -> List[ProductActivity]:
    """
    Retrieve all product activity records with pagination support.
    Manager privilege or higher required.
    """
    return await activity_service.get_many({}, skip=skip, limit=limit)


@router.get("/stats/employee/{employee_id}", response_model=ProductActivityStatsResponse)
async def get_employee_activity_stats(
    employee_id: str,
    start_date: datetime,
    end_date: datetime,
    activity_type: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)]
) -> dict:
    """
    Count logged product activities of a specific type for an employee in a date range.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    count = await activity_service.get_employee_activity_count(
        employee_id=emp_oid,
        start_date=start_date,
        end_date=end_date,
        activity_type=activity_type
    )
    return {"count": count}


@router.get("/{activity_id}", response_model=ProductActivityResponse)
async def get_activity(
    activity_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)]
) -> ProductActivity:
    """
    Retrieve details of a product activity record by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(activity_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid activity ID format"
        )
    activity = await activity_service.get_by_id(activity_id)
    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product activity record not found"
        )
    return activity


@router.put("/{activity_id}", response_model=ProductActivityResponse)
async def update_activity(
    activity_id: str,
    request: ProductActivityUpdate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)]
) -> ProductActivity:
    """
    Perform a partial update on a specific product activity record.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(activity_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid activity ID format"
        )
    activity = await activity_service.update(activity_id, request)
    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product activity record not found"
        )
    return activity


@router.delete("/{activity_id}", response_model=DeleteProductActivityResponse)
async def delete_activity(
    activity_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    activity_service: Annotated[ProductActivityService, Depends(get_product_activity_service)]
) -> dict[str, bool]:
    """
    Delete a specific product activity record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(activity_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid activity ID format"
        )
    success = await activity_service.delete(activity_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product activity record not found"
        )
    return {"success": True}
