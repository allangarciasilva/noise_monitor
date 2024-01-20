#include <project/connection.h>

#include <Arduino.h>

#include <project/config.h>
#include <project/mqtt.h>
#include <proto/ESPSetup.pb.h>

bool isWifiConnected() { return WiFi.status() == WL_CONNECTED; }

boolean tryToConnectToWifi(const char *ssid, const char *password) {
    for (int i = 0; i < 10; i++) {
        if (isWifiConnected()) {
            return true;
        }
        Serial.print(".");
        delay(1000);
    }
    return false;
}

bool connectToWifi(WiFiClientSecure &client, const char *ssid, const char *password) {
    while (true) {
        Serial.printf("[WiFi] Trying to connect to %s.", ssid);

        WiFi.mode(WIFI_STA); // Optional
        WiFi.begin(ssid, password);

        if (tryToConnectToWifi(ssid, password)) {
            break;
        }

        Serial.printf("\n[WiFi] Error while connecting to %s. Trying again in 5 seconds.\n", ssid);
        delay(5000);
    }

    client.setCACert(Config::CA_CERTIFICATE);
    Serial.printf("\n[WiFi] Connected to %s.\n", ssid);
    return true;
}

void connectToBroker(PubSubClient &client, uint32_t room_id) {
    client.setServer(Config::MOSQUITTO_HOST, Config::MOSQUITTO_PORT);

    auto id = Config::ESP_UNIQUE_ID;

    while (true) {
        Serial.printf("[MQTT] Trying to connect as %s.\n", id);

        if (client.connect(id, Config::MOSQUITTO_USER, Config::MOSQUITTO_PASSWORD, MQTT_SHUTDOWN_TOPIC, 2,
                           false, Config::ESP_UNIQUE_ID)) {
            break;
        }

        Serial.printf("[MQTT] Error while connecting as %s.", id);
        Serial.printf("Error code: %d. Trying again in 5 seconds.\n", client.state());
        delay(5000);
    }

    ESPSetup setupMessage;
    setupMessage.room_id = room_id;
    strcpy(setupMessage.device_name, Config::ESP_UNIQUE_ID);

    publishMqttMessage(client, MQTT_STARTUP_TOPIC, setupMessage);
    Serial.printf("[MQTT] Connected as %s.\n", id);
}