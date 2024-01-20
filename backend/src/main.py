import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, WebSocket
from starlette.websockets import WebSocketDisconnect

from src.auth.crud import LoggedUserWs
from src.auth.routes import auth_router
from src.message import message_manager
from src.database import create_all_tables
from src.iot.mqtt import mqtt_handler
from src.iot.routes import iot_router


@asynccontextmanager
async def lifespan(_: FastAPI):
    # Start up
    create_all_tables(drop=False)
    mqtt_handler.start_loop()

    yield

    # Shutdown
    mqtt_handler.stop_loop()


app = FastAPI(lifespan=lifespan)
app.include_router(auth_router)
app.include_router(iot_router)


@app.websocket("/ws/user/")
async def websocket_subscribe_to_device(user: LoggedUserWs, ws: WebSocket):
    await ws.accept()
    message_manager.subscribe(ws, f"user/{user.id}")
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        message_manager.unsubscribe(ws, f"user/{user.id}")


@app.websocket("/ws/noise/{device_name}")
async def websocket_subscribe_to_device(
    device_name: str,
    ws: WebSocket,
    user: LoggedUserWs,
):
    await ws.accept()
    message_manager.subscribe(ws, f"noise/{device_name}")
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        message_manager.unsubscribe(ws, f"noise/{device_name}")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)
