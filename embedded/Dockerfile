FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget python3 python3-venv python3-pip protobuf-compiler

RUN python3 -m pip install nanopb

RUN wget -O get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
RUN python3 get-platformio.py
ENV PATH "$PATH":"/root/.platformio/penv/bin"

WORKDIR /app

COPY ./platformio.ini ./
RUN pio pkg install

COPY ./proto ./proto