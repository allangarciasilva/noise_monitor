#!/bin/bash

sh ./scripts/prebuild.sh
pio run -e real_hardware --target upload && pio device monitor