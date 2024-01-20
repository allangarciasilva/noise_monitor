from datetime import datetime
from typing import List, Optional

from sqlalchemy import ForeignKey, Index, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.database.database import Base, engine


class User(Base):
    __tablename__ = "User"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(index=True)
    hashed_password: Mapped[str]

    created_rooms: Mapped[List["Room"]] = relationship(back_populates="creator")


class Room(Base):
    __tablename__ = "Room"

    id: Mapped[int] = mapped_column(primary_key=True)
    creator_id: Mapped[int] = mapped_column(ForeignKey("User.id"), index=True)
    name: Mapped[str]

    creator: Mapped["User"] = relationship(back_populates="created_rooms")
    devices: Mapped[List["Device"]] = relationship(back_populates="room")
    measurements: Mapped[List["NoiseMeasurement"]] = relationship(back_populates="room")


class RoomSubscription(Base):
    __tablename__ = "RoomSubscription"

    id: Mapped[int] = mapped_column(primary_key=True)
    room_id: Mapped[int] = mapped_column(ForeignKey("Room.id"), index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("User.id"), index=True)


class Device(Base):
    __tablename__ = "Device"

    id: Mapped[int] = mapped_column(primary_key=True)
    room_id: Mapped[Optional[int]] = mapped_column(ForeignKey("Room.id"), index=True)
    name: Mapped[str] = mapped_column(index=True, unique=True)
    active: Mapped[bool]

    room: Mapped["Room"] = relationship(back_populates="devices")
    measurements: Mapped[List["NoiseMeasurement"]] = relationship(
        back_populates="device"
    )


class NoiseMeasurement(Base):
    __tablename__ = "NoiseMeasurement"

    id: Mapped[int] = mapped_column(primary_key=True)
    noise_value: Mapped[float]
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    room_id: Mapped[int] = mapped_column(ForeignKey("Room.id"), index=True)
    device_id: Mapped[int] = mapped_column(ForeignKey("Device.id"), index=True)

    room: Mapped["Room"] = relationship(back_populates="measurements")
    device: Mapped["Device"] = relationship(back_populates="measurements")


def create_index(*expressions):
    expr_names = [f"{expr.class_.__name__}_{expr.key}" for expr in expressions]
    Index("idx_" + "_".join(expr_names), *expressions)


create_index(NoiseMeasurement.room_id, NoiseMeasurement.created_at)
create_index(Device.room_id, Device.active)


def create_all_tables(drop=False):
    if drop:
        Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
