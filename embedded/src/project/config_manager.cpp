#include <project/config_manager.h>

#include <Arduino.h>
#include <pb_common.h>
#include <pb_decode.h>

#include <project/connection.h>

ConfigManager ConfigManager::instance;

ConfigManager::ConfigManager() {
    if (SIMULATION) {
        first_set = true;
        up_to_date = false;

        data.roomId = 1;
        strcpy(data.wifiSsid, "Wokwi-GUEST");
        strcpy(data.wifiPassword, "");
    }
}

void ConfigManager::setData(uint8_t *buffer, size_t bufferSize) {
    pb_istream_t stream = pb_istream_from_buffer(buffer, bufferSize);
    if (!pb_decode(&stream, ESPConfig_fields, &data)) {
        Serial.println("Error while decoding config from BLE.");
    }

    first_set = true;
    up_to_date = false;

    Serial.println("Configuration set!");
    Serial.printf("SSID: %s\nPassword: %s\nRoom Id: %u\n", data.wifiSsid, data.wifiPassword, data.roomId);
}

bool ConfigManager::setupConnections(PubSubClient &client, WiFiClientSecure &wifiClient) {
    if (!first_set) {
        Serial.println("Missing configuration.");
        return false;
    }

    if (up_to_date) {
        return true;
    }

    if (client.connected()) {
        client.disconnect();
    }

    connectToWifi(wifiClient, data.wifiSsid, data.wifiPassword);
    connectToBroker(client, data.roomId);

    up_to_date = true;
    return true;
}