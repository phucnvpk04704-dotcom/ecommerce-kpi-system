from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.notification import NotificationService
from app.schemas.notification import NotificationCreate, NotificationResponse
from app.dependencies.services import get_notification_service
from app.dependencies.auth import get_current_user, require_manager, require_admin
from app.models.employee import Employee
from app.models.notification import Notification
from app.models.base import PyObjectId
from app.core.enums.employee import Role

router = APIRouter(prefix="/notifications", tags=["Notifications"])


class DeleteNotificationResponse(BaseModel):
    success: bool


@router.post("", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_notification(
    request: NotificationCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)]
) -> Notification:
    """
    Create a new notification.
    Manager privilege or higher required.
    """
    return await notification_service.create(request)


@router.get("", response_model=List[NotificationResponse])
@router.get("/", response_model=List[NotificationResponse], include_in_schema=False)
async def list_notifications(
    manager_user: Annotated[Employee, Depends(require_manager())],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Notification]:
    """
    Retrieve all notifications.
    Manager privilege or higher required.
    """
    return await notification_service.get_many({}, skip=skip, limit=limit)


@router.get("/unread/user/{user_id}", response_model=List[NotificationResponse])
async def get_unread_by_user(
    user_id: str,
    current_user: Annotated[Employee, Depends(get_current_user)],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)]
) -> List[Notification]:
    """
    Retrieve unread notifications for a specific employee.
    Employees can only view their own notifications.
    """
    if not ObjectId.is_valid(user_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid user ID format"
        )
    if current_user.role not in [Role.ADMIN, Role.MANAGER] and str(current_user.id) != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden: Cannot view notifications for another user"
        )
    recipient_oid = PyObjectId(user_id)
    return await notification_service.get_unread_by_user(recipient_oid)


@router.get("/unread/role/{role}", response_model=List[NotificationResponse])
async def get_unread_by_role(
    role: Role,
    current_user: Annotated[Employee, Depends(get_current_user)],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)]
) -> List[Notification]:
    """
    Retrieve unread notifications targeted at a specific role group.
    Employees can only view notifications for their own role.
    """
    if current_user.role not in [Role.ADMIN, Role.MANAGER] and current_user.role != role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden: Cannot view notifications for another role"
        )
    return await notification_service.get_unread_by_role(role)


@router.post("/{notification_id}/read", response_model=NotificationResponse)
async def mark_notification_as_read(
    notification_id: str,
    current_user: Annotated[Employee, Depends(get_current_user)],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)]
) -> Notification:
    """
    Mark a specific notification as read.
    Employees can only mark their own targeted notifications.
    """
    if not ObjectId.is_valid(notification_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid notification ID format"
        )
    notification = await notification_service.get_by_id(notification_id)
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    is_recipient = notification.recipient_id is not None and str(notification.recipient_id) == str(current_user.id)
    is_role_recipient = notification.recipient_role == current_user.role
    if current_user.role not in [Role.ADMIN, Role.MANAGER] and not (is_recipient or is_role_recipient):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden: Cannot access this notification"
        )
    updated_notification = await notification_service.mark_as_read(notification_id)
    if not updated_notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return updated_notification


@router.delete("/{notification_id}", response_model=DeleteNotificationResponse)
async def delete_notification(
    notification_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    notification_service: Annotated[NotificationService, Depends(get_notification_service)]
) -> dict[str, bool]:
    """
    Delete a notification.
    Admin privilege required.
    """
    if not ObjectId.is_valid(notification_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid notification ID format"
        )
    success = await notification_service.delete(notification_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return {"success": True}
