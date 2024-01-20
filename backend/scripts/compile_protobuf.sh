#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath "$0"))
BACKEND_PATH=$(realpath $SCRIPT_PATH/..)
ROOT_PATH=$(realpath $BACKEND_PATH/..)

PROTO_FILES=$ROOT_PATH/proto/*.proto

MODULE_OUT=$BACKEND_PATH/proto
rm -rf $MODULE_OUT
mkdir -p $MODULE_OUT

echo "Building Protobuf"
cd $ROOT_PATH
python3 -m pip install grpcio-tools nanopb > /dev/null
python3 -m grpc.tools.protoc $PROTO_FILES -I $ROOT_PATH --python_out=$MODULE_OUT/.. --pyi_out=$MODULE_OUT/.. 2> /dev/null