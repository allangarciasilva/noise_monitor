#include <project/mqtt.h>

#include <proto/NoiseMeasurement.pb.h>

const char *MQTT_STARTUP_TOPIC = "setup";
const char *MQTT_SHUTDOWN_TOPIC = "shutdown";
const char *MQTT_MEASUREMENT_TOPIC = "noise";

bool publishMqttMessage(PubSubClient &client, const char *topic, boolean restrained, void *message,
                        size_t bufferSize, const pb_msgdesc_t *fields) {
    uint8_t buffer[bufferSize];
    pb_ostream_t stream = pb_ostream_from_buffer(buffer, bufferSize);

    if (!pb_encode(&stream, fields, message)) {
        return false;
    }

    if (stream.bytes_written == 0) {
        return false;
    }

    if (!client.beginPublish(topic, stream.bytes_written, restrained)) {
        client.endPublish();
        return false;
    }

    if (client.write(buffer, stream.bytes_written) < stream.bytes_written) {
        client.endPublish();
        return false;
    }

    return client.endPublish();
}