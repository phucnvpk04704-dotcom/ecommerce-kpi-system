from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.reward import RewardService
from app.schemas.reward import RewardCreate, RewardResponse
from app.dependencies.services import get_reward_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.reward import Reward
from app.models.base import PyObjectId

router = APIRouter(prefix="/rewards", tags=["Rewards"])


class DeleteRewardResponse(BaseModel):
    success: bool


@router.post("", response_model=RewardResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=RewardResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_reward(
    request: RewardCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    reward_service: Annotated[RewardService, Depends(get_reward_service)]
) -> Reward:
    """
    Create a new reward record.
    Manager privilege or higher required.
    """
    return await reward_service.create_reward_record(request)


@router.get("", response_model=List[RewardResponse])
@router.get("/", response_model=List[RewardResponse], include_in_schema=False)
async def list_rewards(
    manager_user: Annotated[Employee, Depends(require_manager())],
    reward_service: Annotated[RewardService, Depends(get_reward_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Reward]:
    """
    Retrieve all reward records with pagination support.
    Manager privilege or higher required.
    """
    return await reward_service.get_many({}, skip=skip, limit=limit)


@router.get("/history/employee/{employee_id}", response_model=List[RewardResponse])
async def get_employee_reward_history(
    employee_id: str,
    start_date: datetime,
    end_date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    reward_service: Annotated[RewardService, Depends(get_reward_service)]
) -> List[Reward]:
    """
    Retrieve employee reward history logs over a date range.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    return await reward_service.get_employee_reward_history(
        employee_id=emp_oid,
        start_date=start_date,
        end_date=end_date
    )


@router.get("/{reward_id}", response_model=RewardResponse)
async def get_reward(
    reward_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    reward_service: Annotated[RewardService, Depends(get_reward_service)]
) -> Reward:
    """
    Retrieve details of a specific reward record by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(reward_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid reward ID format"
        )
    reward = await reward_service.get_by_id(reward_id)
    if not reward:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reward record not found"
        )
    return reward


@router.delete("/{reward_id}", response_model=DeleteRewardResponse)
async def delete_reward(
    reward_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    reward_service: Annotated[RewardService, Depends(get_reward_service)]
) -> dict[str, bool]:
    """
    Delete a reward record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(reward_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid reward ID format"
        )
    success = await reward_service.delete(reward_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reward record not found"
        )
    return {"success": True}
