from datetime import datetime
from typing import Annotated, List
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from bson import ObjectId

from app.services.report import ReportService
from app.schemas.report import ReportCreate, ReportResponse
from app.dependencies.services import get_report_service
from app.dependencies.auth import require_manager, require_admin
from app.models.employee import Employee
from app.models.report import Report

router = APIRouter(prefix="/reports", tags=["Reports"])


class DeleteReportResponse(BaseModel):
    success: bool


@router.post("", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=ReportResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_report(
    request: ReportCreate,
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> Report:
    """
    Create a new report.
    Manager privilege or higher required.
    """
    return await report_service.create(request)


@router.get("", response_model=List[ReportResponse])
@router.get("/", response_model=List[ReportResponse], include_in_schema=False)
async def list_reports(
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)],
    skip: int = 0,
    limit: int = 100
) -> List[Report]:
    """
    Retrieve all reports with pagination support.
    Manager privilege or higher required.
    """
    return await report_service.get_many({}, skip=skip, limit=limit)


@router.get("/unsent", response_model=List[ReportResponse])
async def get_unsent_reports(
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> List[Report]:
    """
    Retrieve all unsent reports.
    Manager privilege or higher required.
    """
    return await report_service.get_unsent_reports()


@router.get("/date", response_model=ReportResponse)
async def get_report_by_date(
    date: datetime,
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> Report:
    """
    Retrieve details of a report by its reference date.
    Manager privilege or higher required.
    """
    report = await report_service.get_report_by_date(date)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found for this date"
        )
    return report


@router.get("/{report_id}", response_model=ReportResponse)
async def get_report(
    report_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> Report:
    """
    Retrieve details of a specific report by ID.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(report_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid report ID format"
        )
    report = await report_service.get_by_id(report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found"
        )
    return report


@router.post("/{report_id}/sent", response_model=ReportResponse)
async def mark_as_sent(
    report_id: str,
    manager_user: Annotated[Employee, Depends(require_manager())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> Report:
    """
    Mark a specific report as sent.
    Manager privilege or higher required.
    """
    if not ObjectId.is_valid(report_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid report ID format"
        )
    report = await report_service.mark_as_sent(report_id)
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found"
        )
    return report


@router.delete("/{report_id}", response_model=DeleteReportResponse)
async def delete_report(
    report_id: str,
    admin_user: Annotated[Employee, Depends(require_admin())],
    report_service: Annotated[ReportService, Depends(get_report_service)]
) -> dict[str, bool]:
    """
    Delete a specific report.
    Admin privilege required.
    """
    if not ObjectId.is_valid(report_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid report ID format"
        )
    success = await report_service.delete(report_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found"
        )
    return {"success": True}
