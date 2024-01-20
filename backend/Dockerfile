# Base build image
FROM python:3.11 AS build

# Installing Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Installing dependencies
WORKDIR /app/
COPY poetry.lock pyproject.toml ./
RUN poetry install

# Getting certificate files
ARG MOSQUITTO_URL
RUN mkdir -p ./data
RUN openssl s_client \
    -connect $MOSQUITTO_URL \
    -showcerts </dev/null | openssl x509 -outform PEM > data/certificate.pem ; \
    exit 0

# Compiling protobuf files
COPY ./proto ./proto
RUN poetry run python -m grpc.tools.protoc -I. ./proto/*.proto --python_out=.
