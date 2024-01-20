from fastapi import APIRouter
from sqlalchemy import select, delete

from src.auth.crud import LoggedUser
from src.database import models
from src.database.database import DatabaseSession
from src.iot import schemas, crud

iot_router = APIRouter(tags=["IoT"])


@iot_router.post("/rooms/")
def create_room(db: DatabaseSession, user: LoggedUser, room: schemas.RoomCreate):
    db_room = models.Room(name=room.name, creator_id=user.id)
    db.add(db_room)


@iot_router.get(
    "/rooms/",
    summary="Get all the rooms that the current user is subscribed to",
    response_model=list[schemas.Room],
)
def get_subscribed_rooms(db: DatabaseSession, user: LoggedUser):
    return crud.get_subscribed_rooms(db, user)


@iot_router.get(
    "/rooms/{room_id}/",
    summary="Get all the devices that are asigned to the room",
    response_model=list[schemas.Device],
)
def get_room_devices(db: DatabaseSession, user: LoggedUser, room_id: int):
    return db.scalars(select(models.Device).filter_by(room_id=room_id)).all()


@iot_router.post("/rooms/{room_id}/subscription/")
def subscribe_to_room(db: DatabaseSession, user: LoggedUser, room_id: int):
    crud.subscribe_to_room(db, user, room_id)


@iot_router.delete("/rooms/{room_id}/subscription/")
def unsubscribe_from_room(db: DatabaseSession, user: LoggedUser, room_id: int):
    db.execute(
        delete(models.RoomSubscription).filter_by(user_id=user.id, room_id=room_id)
    )


@iot_router.get("/rooms/{room_id}/measurements/{device_id}/")
def get_historical_data(
    db: DatabaseSession,
    user: LoggedUser,
    room_id: int,
    device_id: int,
    search_filter: schemas.MeasurementFilter,
):
    return db.scalars(
        select(models.NoiseMeasurement)
        .where(models.NoiseMeasurement.device_id == device_id)
        .where(models.NoiseMeasurement.room_id == room_id)
        .where(models.NoiseMeasurement.created_at >= search_filter.dt_min)
        .where(models.NoiseMeasurement.created_at <= search_filter.dt_max)
    ).all()
