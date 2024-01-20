from pydantic import EmailStr

from src.shared.schemas import BaseModel


class UserAuth(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    email: str
    token: str
