import asyncio
from typing import Callable

from paho.mqtt import client as mqtt

from proto.ESPSetup_pb2 import ESPSetup
from proto.NoiseMeasurement_pb2 import NoiseMeasurement
from src.database import SessionLocal, models
from src.message import message_manager
from src.settings import SETTINGS
from src.shared.func import create_file_logger


class DeviceCache(dict):
    def __init__(self, factory: Callable[[str], models.Device]):
        super().__init__()
        self.default_factory = factory

    def __missing__(self, key):
        if self.default_factory:
            dict.__setitem__(self, key, self.default_factory(key))
            return self[key]


class MQTTHandler:
    STARTUP_TOPIC = "setup"
    SHUTDOWN_TOPIC = "shutdown"
    MEASUREMENT_TOPIC = "noise"

    def __init__(self, user: str, password: str, host: str, port: int):
        self.client = mqtt.Client()
        self.logger = create_file_logger(f"log/{__name__}.txt")
        self.db = SessionLocal()
        self.device_cache: dict[str, models.Device] = DeviceCache(
            self.get_or_create_device
        )

        self.setup(user, password, host, port)

    def setup(self, user: str, password: str, host: str, port: int):
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.tls_set("./data/certificate.pem")
        self.client.tls_insecure_set(True)
        self.client.username_pw_set(user, password)
        self.client.connect(host, port, 60)

    def start_loop(self):
        self.client.loop_start()

    def stop_loop(self):
        self.client.loop_stop()

    def get_or_create_device(self, device_name: str):
        db_device = self.db.query(models.Device).filter_by(name=device_name).first()
        if not db_device:
            db_device = models.Device(active=True, name=device_name)
            self.db.add(db_device)
        return db_device

    def on_connect(self, client, userdata, flags, rc):
        self.logger.info(f"Connected to Mosquitto with result code {rc}.")
        self.client.subscribe(self.MEASUREMENT_TOPIC)
        self.client.subscribe(self.STARTUP_TOPIC)
        self.client.subscribe(self.SHUTDOWN_TOPIC)

    def on_message(self, client, userdata, msg: mqtt.MQTTMessage):
        if msg.topic == self.STARTUP_TOPIC:
            asyncio.run(self.on_device_startup(msg.payload))
        if msg.topic == self.SHUTDOWN_TOPIC:
            asyncio.run(self.on_device_shutdown(msg.payload))
        if msg.topic == self.MEASUREMENT_TOPIC:
            asyncio.run(self.on_noise_received(msg.payload))

    async def on_noise_received(self, payload: bytes):
        message = NoiseMeasurement()
        message.ParseFromString(payload)

        db_device = self.device_cache[message.device_name]
        db_noise = models.NoiseMeasurement(
            noise_value=message.noise_value,
            room_id=db_device.room_id,
            device_id=db_device.id,
        )
        self.db.add(db_noise)
        self.db.commit()

        self.logger.debug(f"{message.device_name} -> {message.noise_value}.")
        await message_manager.publish(
            f"noise/{message.device_name}", message.noise_value
        )

    async def on_device_startup(self, payload: bytes):
        message = ESPSetup()
        message.ParseFromString(payload)

        db_room = self.db.get(models.Room, message.room_id)
        if not db_room:
            return

        db_device = self.get_or_create_device(message.device_name)
        db_device.room_id = message.room_id
        db_device.active = True
        self.db.commit()

        log = f"The device {message.device_name} is now active at room {db_room.name}."
        self.logger.info(log)
        await message_manager.publish_to_users(db_device.room_id, log)

    async def on_device_shutdown(self, payload: bytes):
        device_name = payload.decode()

        db_device = self.get_or_create_device(device_name)
        db_device.active = False
        self.db.commit()

        log = f"The device {device_name} is now inactive."
        self.logger.info(log)
        await message_manager.publish_to_users(db_device.room_id, log)


mqtt_handler = MQTTHandler(
    SETTINGS.mosquitto_user,
    SETTINGS.mosquitto_password,
    SETTINGS.mosquitto_host,
    SETTINGS.mosquitto_port,
)
