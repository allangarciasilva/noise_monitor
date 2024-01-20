from datetime import timedelta, datetime
from typing import Annotated

from fastapi import HTTPException, Security, Depends, Query
from fastapi.security import APIKeyHeader
from jose import jwt
from passlib.context import CryptContext
from pydantic import Field
from starlette import status

from src.auth import schemas
from src.database import models
from src.database.database import DatabaseSession
from src.shared.schemas import BaseModel
from src.settings import SETTINGS


class TokenData(BaseModel):
    user_id: int
    exp: datetime = Field(default_factory=lambda: datetime.utcnow() + timedelta(days=1))


ALGORITHM = "HS256"
api_token_header = APIKeyHeader(name="X-Api-Token", auto_error=False)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str):
    return pwd_context.hash(password)


def create_access_token(data: TokenData):
    encoded_jwt = jwt.encode(
        data.model_dump(), SETTINGS.api_secret_key, algorithm=ALGORITHM
    )
    return encoded_jwt


def signup(db: DatabaseSession, user: schemas.UserAuth):
    if db.query(models.User).filter_by(email=user.email).first():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, detail="Email already registed."
        )
    db_user = models.User(
        email=user.email, hashed_password=get_password_hash(user.password)
    )
    db.add(db_user)


def login(db: DatabaseSession, user: schemas.UserAuth):
    db_user = db.query(models.User).filter_by(email=user.email).first()
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Email not found."
        )
    if not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Email and password mismatch."
        )
    return db_user, create_access_token(TokenData(user_id=db_user.id))


def get_logged_user(db: DatabaseSession, token: str):
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Please log in."
        )

    try:
        payload = jwt.decode(token, SETTINGS.api_secret_key, algorithms=[ALGORITHM])
        data = TokenData.model_validate(payload)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid access token."
        )

    db_user = db.get(models.User, data.user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found."
        )

    return db_user


def get_logged_user_http(db: DatabaseSession, token: str = Security(api_token_header)):
    return get_logged_user(db, token)


def get_logged_user_ws(db: DatabaseSession, token: str = Query()):
    return get_logged_user(db, token)


LoggedUser = Annotated[models.User, Depends(get_logged_user_http)]
LoggedUserWs = Annotated[models.User, Depends(get_logged_user_ws)]
