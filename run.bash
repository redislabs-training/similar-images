#!/bin/bash
## Redis
echo "Starting Redis ..."
redis-server --loadmodule $BUILD_HOME/modules/redisai.so TF $BUILD_HOME/modules/redisai_tensorflow.so --loadmodule $BUILD_HOME/modules/redisearch.so &
sleep 5

## Flask
echo "Starting Server ..."
source ./env/bin/activate
export FLASK_APP=server.py
flask run --host=0.0.0.0