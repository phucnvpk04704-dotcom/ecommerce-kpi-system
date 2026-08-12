from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId

from app.services.employee import EmployeeService
from app.schemas.employee import EmployeeCreate, EmployeeUpdate, EmployeeResponse
from app.dependencies.services import get_employee_service
from app.dependencies.auth import require_admin, require_manager
from app.models.employee import Employee

router = APIRouter(prefix="/employees", tags=["Employees"])


@router.post("", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_employee(
    request: EmployeeCreate,
    admin_user: Annotated[Employee, Depends(require_admin())],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)]
) -> Employee:
    """
    Create a new employee profile and sequential employee code.
    Admin privilege required.
    """
    try:
        return await employee_service.create_employee(request)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.get("", response_model=List[EmployeeResponse])
@router.get("/", response_model=List[EmployeeResponse], include_in_schema=False)
async def list_employees(
    manager_user: Annotated[Employee, Depends(require_manager())],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Employee]:
    """
    Retrieve employee profiles list with pagination support.
    Admin privilege required.
    """
    return await employee_service.get_many({}, skip=skip, limit=limit)


@router.get("/{employee_id}", response_model=EmployeeResponse)
async def get_employee(
    employee_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)]
) -> Employee:
    """
    Retrieve employee profile details by ID.
    Admin privilege required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    employee = await employee_service.get_by_id(employee_id)
    if not employee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found"
        )
    return employee


@router.put("/{employee_id}", response_model=EmployeeResponse)
async def update_employee(
    employee_id: str,
    request: EmployeeUpdate,
    admin_user: Annotated[Employee, Depends(require_admin())],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)]
) -> Employee:
    """
    Perform a partial update on the employee profile.
    Admin privilege required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    employee = await employee_service.update_employee(employee_id, request)
    if not employee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found"
        )
    return employee


@router.delete("/{employee_id}", response_model=EmployeeResponse)
async def delete_employee(
    employee_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    employee_service: Annotated[EmployeeService, Depends(get_employee_service)]
) -> Employee:
    """
    Soft-deactivate an employee profile (setting status to Inactive).
    Admin privilege required.
    """
    if not ObjectId.is_valid(employee_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid employee ID format"
        )
    employee = await employee_service.deactivate_employee(employee_id)
    if not employee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found"
        )
    return employee
