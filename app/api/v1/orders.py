from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.order import OrderService
from app.schemas.order import OrderCreate, OrderUpdate, OrderResponse
from app.dependencies.services import get_order_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.order import Order
from app.models.base import PyObjectId

router = APIRouter(prefix="/orders", tags=["Orders"])


class OrderStatsResponse(BaseModel):
    completed: int
    cancelled: int
    returned: int
    late: int
    total: int


class DeleteOrderResponse(BaseModel):
    success: bool


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_order(
    request: OrderCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    order_service: Annotated[OrderService, Depends(get_order_service)]
) -> Order:
    """
    Create a new order entry.
    Manager privilege or higher required.
    """
    return await order_service.create(request)


@router.get("", response_model=List[OrderResponse])
@router.get("/", response_model=List[OrderResponse], include_in_schema=False)
async def list_orders(
    manager_user: Annotated[Employee, Depends(require_manager())],
    order_service: Annotated[OrderService, Depends(get_order_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Order]:
    """
    Retrieve all orders with pagination support.
    Manager privilege or higher required.
    """
    return await order_service.get_many({}, skip=skip, limit=limit)


@router.get("/stats/employee/{employee_id}", response_model=OrderStatsResponse)
async def get_employee_stats(
    employee_id: str,
    start_date: datetime,
    end_date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    order_service: Annotated[OrderService, Depends(get_order_service)]
) -> dict:
    """
    Aggregate order statistics for a specific employee within a date range.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    return await order_service.get_employee_order_stats(
        employee_id=emp_oid,
        start_date=start_date,
        end_date=end_date
    )


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    order_service: Annotated[OrderService, Depends(get_order_service)]
) -> Order:
    """
    Retrieve order details by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(order_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid order ID format"
        )
    order = await order_service.get_by_id(order_id)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    return order


@router.put("/{order_id}", response_model=OrderResponse)
async def update_order(
    order_id: str,
    request: OrderUpdate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    order_service: Annotated[OrderService, Depends(get_order_service)]
) -> Order:
    """
    Perform a partial update on an order.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(order_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid order ID format"
        )
    order = await order_service.update(order_id, request)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    return order


@router.delete("/{order_id}", response_model=DeleteOrderResponse)
async def delete_order(
    order_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    order_service: Annotated[OrderService, Depends(get_order_service)]
) -> dict[str, bool]:
    """
    Delete an order.
    Admin privilege required.
    """
    if not ObjectId.is_valid(order_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid order ID format"
        )
    success = await order_service.delete(order_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    return {"success": True}
