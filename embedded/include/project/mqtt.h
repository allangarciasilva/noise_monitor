#pragma once

#include <Arduino.h>
#include <PubSubClient.h>
#include <pb_common.h>
#include <pb_encode.h>

#include <project/message_consts.h>

extern const char *MQTT_STARTUP_TOPIC;
extern const char *MQTT_SHUTDOWN_TOPIC;
extern const char *MQTT_MEASUREMENT_TOPIC;

bool publishMqttMessage(PubSubClient &client, const char *topic, boolean restrained, void *message,
                        size_t bufferSize, const pb_msgdesc_t *fields);

template <typename T>
inline bool publishMqttMessage(PubSubClient &client, const char *topic, const T &message,
                               boolean restrained = false) {
    return publishMqttMessage(client, topic, restrained, (void *)&message, MessageConsts<T>::SIZE,
                              MessageConsts<T>::FIELDS);
}