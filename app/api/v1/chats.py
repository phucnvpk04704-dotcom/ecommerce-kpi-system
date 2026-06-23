from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.chat import ChatService
from app.schemas.chat import ChatCreate, ChatUpdate, ChatResponse
from app.dependencies.services import get_chat_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.chat import Chat
from app.models.base import PyObjectId

router = APIRouter(prefix="/chats", tags=["Chats"])


class DeleteChatResponse(BaseModel):
    success: bool


@router.post("", response_model=ChatResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=ChatResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_chat(
    request: ChatCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)]
) -> Chat:
    """
    Create a new daily chat conversation metric record.
    Manager privilege or higher required.
    """
    return await chat_service.create(request)


@router.get("", response_model=List[ChatResponse])
@router.get("/", response_model=List[ChatResponse], include_in_schema=False)
async def list_chats(
    manager_user: Annotated[Employee, Depends(require_manager())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Chat]:
    """
    Retrieve all daily chat conversation metrics records with pagination support.
    Manager privilege or higher required.
    """
    return await chat_service.get_many({}, skip=skip, limit=limit)


@router.get("/employee/{employee_id}", response_model=ChatResponse)
async def get_employee_chat_stats(
    employee_id: str,
    date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)]
) -> Chat:
    """
    Retrieve daily chat metrics for a specific employee on a given date.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    emp_oid = PyObjectId(employee_id)
    chat = await chat_service.get_employee_chat_stats(employee_id=emp_oid, date=date)
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat record not found for this employee and date"
        )
    return chat


@router.get("/{chat_id}", response_model=ChatResponse)
async def get_chat(
    chat_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)]
) -> Chat:
    """
    Retrieve daily chat metrics details by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(chat_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid chat ID format"
        )
    chat = await chat_service.get_by_id(chat_id)
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat record not found"
        )
    return chat


@router.put("/{chat_id}", response_model=ChatResponse)
async def update_chat(
    chat_id: str,
    request: ChatUpdate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)]
) -> Chat:
    """
    Perform a partial update on a daily chat conversation metric record.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(chat_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid chat ID format"
        )
    chat = await chat_service.update(chat_id, request)
    if not chat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat record not found"
        )
    return chat


@router.delete("/{chat_id}", response_model=DeleteChatResponse)
async def delete_chat(
    chat_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    chat_service: Annotated[ChatService, Depends(get_chat_service)]
) -> dict[str, bool]:
    """
    Delete a daily chat conversation metric record.
    Admin privilege required.
    """
    if not ObjectId.is_valid(chat_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid chat ID format"
        )
    success = await chat_service.delete(chat_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat record not found"
        )
    return {"success": True}
