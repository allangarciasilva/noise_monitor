from datetime import datetime

from src.shared.schemas import BaseModel


class RoomCreate(BaseModel):
    name: str


class Room(RoomCreate):
    id: int
    editable: bool
    active_devices: int = 1


class Device(BaseModel):
    id: int
    room_id: int
    name: str
    active: bool


class MeasurementFilter(BaseModel):
    dt_min: datetime
    dt_max: datetime
