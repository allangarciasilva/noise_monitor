import os
from uuid import uuid4
import subprocess
from json import dumps


def error(*args):
    print(*args)
    exit(1)


def host_to_ip(host: str):
    parts = [part for part in host.split(".") if part.isnumeric()]
    if len(parts) != 4:
        error("Host must be an IP address")
    return f"IPAddress({','.join(parts)})"


def get_substring(text: str, start_substr: str, end_substr: str):
    begin = text.find(start_substr)
    end = text.find(end_substr) + len(end_substr)
    return text[begin:end]


def get_ca_certificate(host: str, port: str):
    openssl_output = subprocess.run(
        ["openssl", "s_client", "-connect", f"{host}:{port}", "-showcerts"],
        input="",
        stdout=subprocess.PIPE,
        text=True,
        check=True,
    )
    return get_substring(openssl_output.stdout, "-----BEGIN CERTIFICATE-----", "-----END CERTIFICATE-----")


MOSQUITTO_USER = os.environ["MOSQUITTO_USER"]
MOSQUITTO_PASSWORD = os.environ["MOSQUITTO_PASSWORD"]
MOSQUITTO_HOST = os.environ["MOSQUITTO_HOST"]
MOSQUITTO_PORT = os.environ["MOSQUITTO_PORT"]

CA_CERTIFICATE = get_ca_certificate(MOSQUITTO_HOST, MOSQUITTO_PORT)

cpp_contents = f"""\
#include <project/config.h>

namespace Config {{

const char *CA_CERTIFICATE = {dumps(CA_CERTIFICATE)};

const char *BLE_SERVICE_UUID = {dumps(str(uuid4()))};
const char *BLE_CHARACTERISTIC_UUID = {dumps(str(uuid4()))};

const char *MOSQUITTO_USER = {dumps(MOSQUITTO_USER)};
const char *MOSQUITTO_PASSWORD = {dumps(MOSQUITTO_PASSWORD)};
IPAddress MOSQUITTO_HOST = {host_to_ip(MOSQUITTO_HOST)};
int MOSQUITTO_PORT = {MOSQUITTO_PORT};

}}
"""

os.makedirs("./src/generated/", exist_ok=True)
with open("./src/generated/config.cpp", "w") as f:
    print(cpp_contents, file=f)
