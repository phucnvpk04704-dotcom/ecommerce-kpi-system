from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.setting import SettingService
from app.schemas.setting import SettingCreate, SettingUpdate, SettingResponse
from app.dependencies.services import get_setting_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.setting import Setting

router = APIRouter(prefix="/settings", tags=["Settings"])


class DeleteSettingResponse(BaseModel):
    success: bool


@router.post("", response_model=SettingResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=SettingResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_setting(
    request: SettingCreate,
    admin_user: Annotated[Employee, Depends(require_admin())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)]
) -> Setting:
    """
    Create a new configuration setting.
    Admin privilege required.
    """
    return await setting_service.create(request)


@router.get("", response_model=List[SettingResponse])
@router.get("/", response_model=List[SettingResponse], include_in_schema=False)
async def list_settings(
    manager_user: Annotated[Employee, Depends(require_manager())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Setting]:
    """
    Retrieve all configuration settings with pagination support.
    Manager privilege or higher required.
    """
    return await setting_service.get_many({}, skip=skip, limit=limit)


@router.get("/key/{key}", response_model=SettingResponse)
async def get_setting_by_key(
    key: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)]
) -> Setting:
    """
    Retrieve details of a configuration setting by its unique key.
    Manager privilege or higher required.
    """
    setting = await setting_service.find_by_key(key)
    if not setting:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Setting not found for this key"
        )
    return setting


@router.get("/{setting_id}", response_model=SettingResponse)
async def get_setting(
    setting_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)]
) -> Setting:
    """
    Retrieve details of a configuration setting by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(setting_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid setting ID format"
        )
    setting = await setting_service.get_by_id(setting_id)
    if not setting:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Setting not found"
        )
    return setting


@router.put("/{setting_id}", response_model=SettingResponse)
async def update_setting(
    setting_id: str,
    request: SettingUpdate,
    admin_user: Annotated[Employee, Depends(require_admin())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)]
) -> Setting:
    """
    Perform a partial update on a configuration setting.
    Admin privilege required.
    """
    if not ObjectId.is_valid(setting_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid setting ID format"
        )
    setting = await setting_service.update(setting_id, request)
    if not setting:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Setting not found"
        )
    return setting


@router.delete("/{setting_id}", response_model=DeleteSettingResponse)
async def delete_setting(
    setting_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    setting_service: Annotated[SettingService, Depends(get_setting_service)]
) -> dict[str, bool]:
    """
    Delete a configuration setting.
    Admin privilege required.
    """
    if not ObjectId.is_valid(setting_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid setting ID format"
        )
    success = await setting_service.delete(setting_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Setting not found"
        )
    return {"success": True}
