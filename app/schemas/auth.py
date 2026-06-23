from pydantic import BaseModel, Field
from app.core.enums.employee import Role


class LoginRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=6, max_length=100)


class TokenPayload(BaseModel):
    sub: str = Field(...)
    role: Role = Field(...)
    session_id: str = Field(...)
    exp: int = Field(...)


class LoginResponse(BaseModel):
    access_token: str = Field(...)
    token_type: str = Field(default="bearer")
    employee_id: str = Field(...)
    employee_code: str = Field(...)
    full_name: str = Field(...)
    role: Role = Field(...)
    session_id: str = Field(...)
