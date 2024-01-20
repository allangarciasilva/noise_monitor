#!/bin/bash

PASSWORD_FILE=./mosquitto/config/password_file
if [ -d "$PASSWORD_FILE" ] ; then
    rm -rf $PASSWORD_FILE
fi
if [ ! -f "$PASSWORD_FILE" ]; then
    mkdir -p $(dirname $PASSWORD_FILE)
    touch $PASSWORD_FILE
fi

CERT_PATH=./mosquitto/certs
if [ ! -d "$CERT_PATH" ] ; then
    rm -rf $CERT_PATH
fi
mkdir -p $CERT_PATH

OPENSSL_CONFIG_FILE=./openssl.cnf

openssl genrsa -des3 -out $CERT_PATH/ca.key 2048
openssl req -new -x509 -days 1826 -key $CERT_PATH/ca.key -out $CERT_PATH/ca.crt -config $OPENSSL_CONFIG_FILE
openssl genrsa -out $CERT_PATH/server.key 2048
openssl req -new -out $CERT_PATH/server.csr -key $CERT_PATH/server.key -config $OPENSSL_CONFIG_FILE
openssl x509 -req -in $CERT_PATH/server.csr -CA $CERT_PATH/ca.crt -CAkey $CERT_PATH/ca.key -CAcreateserial -out $CERT_PATH/server.crt -days 360
