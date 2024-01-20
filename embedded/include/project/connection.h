#pragma once

#include <PubSubClient.h>
#include <WiFiClientSecure.h>

bool isWifiConnected();

bool connectToWifi(WiFiClientSecure &client, const char *ssid, const char *password);

void connectToBroker(PubSubClient &client, uint32_t room_id);