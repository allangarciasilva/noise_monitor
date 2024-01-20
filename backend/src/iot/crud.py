from typing import List

from fastapi import HTTPException
from sqlalchemy import text
from starlette import status

from src.auth.crud import LoggedUser
from src.database import models
from src.database.database import DatabaseSession


def get_subscribed_rooms(db: DatabaseSession, user: LoggedUser):
    query = """
select
    id,
    name,
    case
        when creator_id = :user_id then true
        else false
    end as editable,
    (
        select
            count(*)
        from
            "Device" device
        where
            device.room_id = room.id
            and device.active = true
    ) as active_devices
from
    (
        (
            select
                room.*
            from
                "Room" room
            where
                creator_id = :user_id
        )
        union
        (
            select
                room.*
            from
                "RoomSubscription" sub
                join "Room" room on room.id = sub.room_id
            where
                sub.user_id = :user_id
        )
    ) as room
order by room.name;
"""

    return db.execute(text(query), params={"user_id": user.id}).all()


def get_subscribed_users(db: DatabaseSession, room_id: int) -> List[models.User]:
    query = """
(
    select
        user_.*
    from
        "Room" room
        join "User" user_ on room.creator_id = user_.id
    where
        room.id = :room_id
)
union
(
    select
        user_.*
    from
        "RoomSubscription" sub
        join "User" user_ on sub.user_id = user_.id
    where
        sub.room_id = :room_id
);
"""

    return db.execute(text(query), params={"room_id": room_id}).all()


def subscribe_to_room(db: DatabaseSession, user: LoggedUser, room_id: int):
    db_room = db.get(models.Room, room_id)
    if not db_room:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Room not found."
        )
    if db_room.creator_id == user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot subscribe to your own room.",
        )

    db_subscription = (
        db.query(models.RoomSubscription)
        .filter_by(user_id=user.id, room_id=room_id)
        .first()
    )
    if db_subscription:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are already subscribed to that room.",
        )
    db.add(models.RoomSubscription(user_id=user.id, room_id=room_id))
