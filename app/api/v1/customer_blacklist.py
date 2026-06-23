from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.customer_blacklist import CustomerBlacklistService
from app.schemas.customer_blacklist import CustomerBlacklistCreate, CustomerBlacklistUpdate, CustomerBlacklistResponse
from app.dependencies.services import get_customer_blacklist_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.customer_blacklist import CustomerBlacklist

router = APIRouter(prefix="/customer_blacklist", tags=["CustomerBlacklist"])


class DeleteBlacklistResponse(BaseModel):
    success: bool


class EvaluateRiskRequest(BaseModel):
    customer_id: str
    customer_phone: str
    platform: str


@router.post("", response_model=CustomerBlacklistResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=CustomerBlacklistResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_blacklist_entry(
    request: CustomerBlacklistCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> CustomerBlacklist:
    """
    Create a new customer blacklist record.
    Manager privilege or higher required.
    """
    return await blacklist_service.create(request)


@router.get("", response_model=List[CustomerBlacklistResponse])
@router.get("/", response_model=List[CustomerBlacklistResponse], include_in_schema=False)
async def list_blacklist_entries(
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)],
    skip: int = 0,
    limit: int = 100
) -> List[CustomerBlacklist]:
    """
    Retrieve all customer blacklist records with pagination support.
    Manager privilege or higher required.
    """
    return await blacklist_service.get_many({}, skip=skip, limit=limit)


@router.get("/phone/{customer_phone}", response_model=CustomerBlacklistResponse)
async def find_by_phone(
    customer_phone: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> CustomerBlacklist:
    """
    Find a customer blacklist record by phone number.
    Manager privilege or higher required.
    """
    entry = await blacklist_service.find_by_phone(customer_phone)
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Blacklist record not found for this phone number"
        )
    return entry


@router.post("/evaluate", response_model=CustomerBlacklistResponse)
async def evaluate_customer_risk(
    request: EvaluateRiskRequest,
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> CustomerBlacklist:
    """
    Calculate and update/save a customer's risk level based on order statistics.
    Manager privilege or higher required.
    """
    entry = await blacklist_service.evaluate_customer_risk(
        customer_id=request.customer_id,
        customer_phone=request.customer_phone,
        platform=request.platform
    )
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer blacklist record not found to evaluate risk"
        )
    return entry


@router.get("/{blacklist_id}", response_model=CustomerBlacklistResponse)
async def get_blacklist_entry(
    blacklist_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> CustomerBlacklist:
    """
    Retrieve details of a specific customer blacklist record by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(blacklist_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid blacklist ID format"
        )
    entry = await blacklist_service.get_by_id(blacklist_id)
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Blacklist record not found"
        )
    return entry


@router.put("/{blacklist_id}", response_model=CustomerBlacklistResponse)
async def update_blacklist_entry(
    blacklist_id: str,
    request: CustomerBlacklistUpdate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> CustomerBlacklist:
    """
    Perform a partial update on a customer blacklist record.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(blacklist_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid blacklist ID format"
        )
    entry = await blacklist_service.update(blacklist_id, request)
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Blacklist record not found"
        )
    return entry


@router.delete("/{blacklist_id}", response_model=DeleteBlacklistResponse)
async def delete_blacklist_entry(
    blacklist_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    blacklist_service: Annotated[CustomerBlacklistService, Depends(get_customer_blacklist_service)]
) -> dict[str, bool]:
    """
    Delete a specific customer blacklist record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(blacklist_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid blacklist ID format"
        )
    success = await blacklist_service.delete(blacklist_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Blacklist record not found"
        )
    return {"success": True}
