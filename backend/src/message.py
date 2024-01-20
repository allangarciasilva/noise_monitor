from collections import defaultdict
from typing import Any, Optional

from starlette.websockets import WebSocket

from src.database import SessionLocal
from src.iot import crud
from src.shared.func import create_file_logger


def render_ws(ws: WebSocket):
    return f"{ws.client.host}:{ws.client.port}"


class MessageManager:
    def __init__(self):
        self.subscribers_by_topic: dict[str, set[WebSocket]] = defaultdict(set)
        self.db = SessionLocal()
        self.logger = create_file_logger(f"log/{__name__}.txt")

    async def publish(self, topic: str, message: Any):
        for socket in self.subscribers_by_topic[topic]:
            await socket.send_json(message)

    async def publish_to_users(self, room_id: Optional[int], message: Any):
        if room_id is None:
            return
        for db_user in crud.get_subscribed_users(self.db, room_id):
            await self.publish(f"user/{db_user.id}", message)

    def subscribe(self, ws: WebSocket, *topics: str):
        self.logger.info(f"Subscribed {render_ws(ws)} to {topics}")
        for topic in topics:
            self.subscribers_by_topic[topic].add(ws)

    def unsubscribe(self, ws: WebSocket, *topics: str):
        self.logger.info(f"Unsubscribed {render_ws(ws)} from {topics}")
        for topic in topics:
            self.subscribers_by_topic[topic].remove(ws)


message_manager = MessageManager()
