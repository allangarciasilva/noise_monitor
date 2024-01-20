#include <project/config.h>

#include <ArduinoUniqueID.h>

const char *buildUniqueId() {
    static char formattedString[] = "ESP32:0000.0000.0000.0000";

    sprintf(formattedString, "ESP32:%02X%02X.%02X%02X.%02X%02X.%02X%02X",
            UniqueID8[0], UniqueID8[1], UniqueID8[2], UniqueID8[3],
            UniqueID8[4], UniqueID8[5], UniqueID8[6], UniqueID8[7]);

    return formattedString;
}

namespace Config {
const char *ESP_UNIQUE_ID = buildUniqueId();
}