from typing import Optional, List
from pydantic import EmailStr
from app.services.base import BaseService
from app.models.employee import Employee
from app.repositories.employee import EmployeeRepository
from app.schemas.employee import EmployeeCreate, EmployeeUpdate
from app.core.security import get_password_hash
from app.core.enums.employee import Role, EmployeeStatus
from app.core.enums.platform import Platform


class EmployeeService(BaseService[Employee, EmployeeRepository]):
    """
    Business Service for managing staff profile registrations, credentials security,
    target configurations updates, and account status states.
    """
    def __init__(self, employee_repository: EmployeeRepository):
        super().__init__(employee_repository)

    async def create_employee(self, schema: EmployeeCreate) -> Employee:
        """
        Validates username availability, issues sequential employee codes, hashes passwords,
        instantiates the Employee model, and saves the document to the database.
        """
        # 1. Verify username uniqueness
        existing_username = await self.repository.find_by_username(schema.username)
        if existing_username:
            raise ValueError(f"Username '{schema.username}' already exists")

        # 2. Sequential employee code generation (e.g. NV001, NV002)
        count = await self.repository.count({})
        code_num = count + 1
        while True:
            employee_code = f"NV{code_num:03d}"
            existing_code = await self.repository.find_by_employee_code(employee_code)
            if not existing_code:
                break
            code_num += 1

        # 3. Hash plain credentials password
        hashed_password = get_password_hash(schema.password)

        # 4. Map parameters to database-ready dictionary
        employee_data = {
            "employee_code": employee_code,
            "username": schema.username,
            "hashed_password": hashed_password,
            "full_name": schema.full_name,
            "email": schema.email,
            "role": schema.role,
            "status": EmployeeStatus.ACTIVE,
            "platforms": schema.platforms
        }

        # 5. Instantiate the model using Pydantic V2 dictionary validation
        model_instance = Employee.model_validate(employee_data)

        # 6. Insert and return model
        return await self.repository.create(model_instance)

    async def update_employee(self, employee_id: str, schema: EmployeeUpdate) -> Optional[Employee]:
        """Perform a partial update on the employee profile matching the object ID."""
        return await self.repository.update(employee_id, schema)

    async def deactivate_employee(self, employee_id: str) -> Optional[Employee]:
        """Soft-deactivate an employee profile by setting status to 'Inactive'."""
        return await self.repository.update(
            employee_id,
            {"status": EmployeeStatus.INACTIVE}
        )
