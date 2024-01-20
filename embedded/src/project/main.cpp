#include "project/ble.h"
#include <Arduino.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <project/config.h>
#include <project/config_manager.h>
#include <project/connection.h>
#include <project/mqtt.h>
#include <proto/NoiseMeasurement.pb.h>

const int soundPin = 35;

int cnt = 0;
float get_noise_voltage() {
    if (SIMULATION) {
        return (cnt++) % 15;
    }

    float minim = analogRead(soundPin);
    float curr;
    for (int i = 0; i < 10; i++) {
        curr = analogRead(soundPin);
        minim = minim < curr ? minim : curr;
    }
    minim *= (5.0 / 1023.0);
    return minim;
}

WiFiClientSecure wifiClient;
PubSubClient client(wifiClient);

NoiseMeasurement message = {"", 0};

void setup() {
    Serial.begin(115200);

    if (!SIMULATION) {
        setupBLE();
    }

    pinMode(soundPin, INPUT);
    strcpy(message.device_name, Config::ESP_UNIQUE_ID);
}

void loop() {
    if (!ConfigManager::instance.setupConnections(client, wifiClient)) {
        delay(500);
        return;
    }
    client.loop();

    float calculated_value = 0;

    int n = 10;
    for (int i = 0; i < n; i++) {
        calculated_value += get_noise_voltage();
        delay(150 / n);
    }

    calculated_value /= n;
    message.noise_value = calculated_value;

    if (publishMqttMessage(client, MQTT_MEASUREMENT_TOPIC, message)) {
        Serial.println(message.noise_value);
    } else {
        Serial.println("Error while sending message.");
    }

    // delay(150);
}