#include <project/ble.h>

#include <Arduino.h>

#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

#include <project/config.h>
#include <project/config_manager.h>
#include <proto/ESPConfig.pb.h>

#define BUFFER_MAX_SIZE (ESPConfig_size + 20)

BLEServer *pServer = NULL;
BLEService *pService = NULL;
BLECharacteristic *pCharacteristic = NULL;

uint8_t buffer[BUFFER_MAX_SIZE];
size_t bufferSize = 0;

bool isLedOn = false;

class ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer *pServer) { Serial.println("Bluetooth Connected."); }

    void onDisconnect(BLEServer *pServer) {
        Serial.println("Bluetooth Disconnected.");
        pServer->startAdvertising();
        bufferSize = 0;
    }
};

class CharacteristicCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        size_t receivedDataLength = value.size() - 1;

        if (bufferSize + receivedDataLength > BUFFER_MAX_SIZE) {
            Serial.println("Message too long");
            return;
        }

        memcpy(buffer + bufferSize, value.c_str() + 1, receivedDataLength);
        bufferSize += receivedDataLength;

        if (value[0]) {
            return;
        }

        for (int i = 0; i < bufferSize; i++) {
            Serial.printf("%02x ", buffer[i]);
        }
        Serial.println("");

        ConfigManager::instance.setData(buffer, bufferSize);
        bufferSize = 0;
    }
};

void setupBLE() {
    BLEDevice::init(Config::ESP_UNIQUE_ID);

    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());
    pService = pServer->createService(Config::BLE_SERVICE_UUID);

    pCharacteristic =
        pService->createCharacteristic(Config::BLE_CHARACTERISTIC_UUID,
                                       BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

    pCharacteristic->addDescriptor(new BLE2902());
    pCharacteristic->setCallbacks(new CharacteristicCallbacks());
    pService->start();

    pServer->getAdvertising()->start();
    Serial.println("Waiting for a BLE client connection...");
}